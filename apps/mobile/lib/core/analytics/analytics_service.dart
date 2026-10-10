import 'dart:async';
import 'dart:io' show Platform;
import 'dart:math';

import 'package:built_collection/built_collection.dart';
import 'package:campus_api/campus_api.dart';
import 'package:campusconnect/core/network/api_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:one_of/any_of.dart';

/// How often the buffered events ship to the API.
const kAnalyticsFlushInterval = Duration(seconds: 30);

/// Server batch cap (mirrors MAX_EVENTS_PER_BATCH).
const kAnalyticsBatchSize = 50;

/// Memory cap — oldest events drop first if the API is unreachable.
const kAnalyticsBufferCap = 300;

/// Behavioural analytics: which screens students live on, for how long,
/// and what they actually do — so the product can be shaped around real
/// usage ("create stuff and remove stuff based on what they need").
///
/// Design mirrors PushService: starts after auth, silent best-effort
/// (analytics must NEVER break or slow the app), stops on logout.
/// Events buffer locally and flush every 30s, on screen change pile-up,
/// and when the app is backgrounded.
class AnalyticsService with WidgetsBindingObserver {
  AnalyticsService(this._api);

  final CampusApi _api;

  final List<ClientEventIn> _buffer = [];
  final String _sessionId = _newSessionId();
  Timer? _timer;
  bool _started = false;
  bool _flushing = false;

  // Dwell tracking: the screen currently on display and when it appeared.
  String? _currentScreen;
  DateTime? _screenSince;

  static String _newSessionId() {
    final rand = Random();
    final suffix = List.generate(
      12,
      (_) => 'abcdefghijklmnopqrstuvwxyz0123456789'[rand.nextInt(36)],
    ).join();
    return 's${DateTime.now().millisecondsSinceEpoch.toRadixString(36)}$suffix';
  }

  /// Call once the user is authenticated (events are rejected otherwise).
  void start() {
    if (_started) return;
    _started = true;
    WidgetsBinding.instance.addObserver(this);
    _timer = Timer.periodic(kAnalyticsFlushInterval, (_) => _flush());
    track('session_start');
  }

  /// Call on logout: flush what we have while the token is still valid.
  Future<void> stop() async {
    if (!_started) return;
    _closeCurrentScreen();
    track('session_end');
    await _flush();
    _started = false;
    _timer?.cancel();
    _timer = null;
    WidgetsBinding.instance.removeObserver(this);
    _currentScreen = null;
    _screenSince = null;
  }

  /// Router hook: the visible location changed. Emits a screen_view for
  /// the screen just left, carrying how long it was on display.
  void onLocationChanged(String location) {
    final screen = normalizeScreen(location);
    if (screen == _currentScreen) return;
    _closeCurrentScreen();
    _currentScreen = screen;
    _screenSince = DateTime.now();
  }

  /// Discrete action (e.g. "run_order_placed"); names are lowercase
  /// snake-case per the API contract.
  void track(String name, {Map<String, Object?> properties = const {}}) {
    if (!_started) return;
    _enqueue(
      ClientEventIn(
        (b) => b
          ..name = name
          ..occurredAt = DateTime.now().toUtc()
          ..screen = _currentScreen
          ..properties = _props(properties),
      ),
    );
  }

  /// Records the dwell on the screen being left as one screen_view event.
  void _closeCurrentScreen() {
    final screen = _currentScreen;
    final since = _screenSince;
    if (!_started || screen == null || since == null) return;
    final dwell = DateTime.now().difference(since).inMilliseconds;
    _enqueue(
      ClientEventIn(
        (b) => b
          ..name = 'screen_view'
          ..occurredAt = DateTime.now().toUtc()
          ..screen = screen
          ..durationMs = dwell.clamp(0, 86400000),
      ),
    );
  }

  void _enqueue(ClientEventIn event) {
    _buffer.add(event);
    if (_buffer.length > kAnalyticsBufferCap) _buffer.removeAt(0);
    if (_buffer.length >= kAnalyticsBatchSize) unawaited(_flush());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      // Count time-on-screen up to the moment the app leaves the
      // foreground, then ship it — backgrounded time is not engagement.
      _closeCurrentScreen();
      unawaited(_flush());
    } else if (state == AppLifecycleState.resumed) {
      // Restart the dwell clock for the screen the user comes back to.
      if (_currentScreen != null) _screenSince = DateTime.now();
    }
  }

  Future<void> _flush() async {
    if (_flushing || _buffer.isEmpty) return;
    _flushing = true;
    try {
      while (_buffer.isNotEmpty) {
        final take = _buffer.length < kAnalyticsBatchSize
            ? _buffer.length
            : kAnalyticsBatchSize;
        final chunk = _buffer.sublist(0, take);
        await _api.getAnalyticsApi().ingestEventsApiV1AnalyticsEventsPost(
          clientEventBatchRequest: ClientEventBatchRequest(
            (b) => b
              ..sessionId = _sessionId
              ..platform = _platform
              ..events = ListBuilder(chunk),
          ),
        );
        _buffer.removeRange(0, take);
      }
    } on Object {
      // Keep the buffer; retry on the next tick. Analytics never surfaces
      // errors to the user and never blocks a flow.
    } finally {
      _flushing = false;
    }
  }

  ClientEventBatchRequestPlatformEnum get _platform {
    if (kIsWeb) return ClientEventBatchRequestPlatformEnum.web;
    return Platform.isIOS
        ? ClientEventBatchRequestPlatformEnum.ios
        : ClientEventBatchRequestPlatformEnum.android;
  }

  MapBuilder<String, PropertiesValue?> _props(Map<String, Object?> raw) {
    final builder = MapBuilder<String, PropertiesValue?>();
    for (final entry in raw.entries.take(10)) {
      final value = entry.value;
      builder[entry.key] = switch (value) {
        null => null,
        final bool v => PropertiesValue(
          (b) => b.anyOf = AnyOf1<bool>(value: v),
        ),
        final int v => PropertiesValue((b) => b.anyOf = AnyOf1<int>(value: v)),
        final num v => PropertiesValue((b) => b.anyOf = AnyOf1<num>(value: v)),
        _ => PropertiesValue(
          (b) => b.anyOf = AnyOf1<String>(value: value.toString()),
        ),
      };
    }
    return builder;
  }
}

final _uuidSegment = RegExp(
  r'^[0-9a-fA-F]{8}-([0-9a-fA-F]{4}-){3}[0-9a-fA-F]{12}$',
);
final _numericSegment = RegExp(r'^\d+$');

/// Collapses volatile path segments so "/runs/run/{uuid}" aggregates as
/// one screen ("/runs/run/:id") instead of thousands of unique rows.
String normalizeScreen(String location) {
  final path = Uri.parse(location).path;
  final segments = path
      .split('/')
      .map(
        (s) =>
            _uuidSegment.hasMatch(s) || _numericSegment.hasMatch(s) ? ':id' : s,
      )
      .join('/');
  final normalized = segments.isEmpty ? '/' : segments;
  return normalized.length > 80 ? normalized.substring(0, 80) : normalized;
}

final analyticsServiceProvider = Provider<AnalyticsService>((ref) {
  final service = AnalyticsService(ref.watch(campusApiProvider));
  ref.onDispose(() => unawaited(service.stop()));
  return service;
});
