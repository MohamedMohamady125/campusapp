import 'dart:async';
import 'dart:io' show Platform;

import 'package:campus_api/campus_api.dart';
import 'package:campusconnect/core/network/api_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Push registration + tap routing (FCM → APNs/Android).
///
/// Degrades to a silent no-op when Firebase isn't configured (no
/// GoogleService-Info.plist / google-services.json yet), so every build —
/// including web and CI — stays green without keys. The server is the
/// anti-spam brain; this class only moves tokens and routes taps.
class PushService {
  PushService(this._api);

  final CampusApi _api;
  bool _firebaseReady = false;
  String? _token;
  StreamSubscription<String>? _refreshSub;

  void dispose() {
    unawaited(_refreshSub?.cancel());
    _refreshSub = null;
  }

  /// Where a tapped push should navigate; wired by the router owner.
  void Function(String location)? onOpenRoute;

  Future<bool> _ensureFirebase() async {
    if (_firebaseReady) return true;
    if (kIsWeb) return false; // web ships without push in v1
    try {
      await Firebase.initializeApp();
      _firebaseReady = true;
      return true;
    } on Object {
      // No platform config bundled — push stays off, app works normally.
      return false;
    }
  }

  /// Call once the user is authenticated: ask permission, register the
  /// device token with the API, and keep it fresh across rotations.
  Future<void> syncToken() async {
    if (!await _ensureFirebase()) return;
    try {
      final messaging = FirebaseMessaging.instance;
      final settings = await messaging.requestPermission();
      if (settings.authorizationStatus == AuthorizationStatus.denied) return;
      final token = await messaging.getToken();
      if (token != null) await _register(token);
      _refreshSub ??= messaging.onTokenRefresh.listen(_register);
      _wireTapHandlers(messaging);
    } on Object {
      // Push is best-effort; never surface registration noise to the user.
    }
  }

  /// Call on logout BEFORE the session dies: stop pushes for this account
  /// on a possibly shared device.
  Future<void> clearToken() async {
    final token = _token;
    if (token == null) return;
    _token = null;
    try {
      await _api
          .getNotificationsApi()
          .unregisterDeviceApiV1NotificationsDevicesRemovePost(
            deviceUnregisterRequest: DeviceUnregisterRequest(
              (b) => b..token = token,
            ),
          );
      await FirebaseMessaging.instance.deleteToken();
    } on Object {
      // Offline logout: the server prunes the token once FCM reports it dead.
    }
  }

  Future<void> _register(String token) async {
    _token = token;
    final platform = Platform.isIOS
        ? DeviceRegisterRequestPlatformEnum.ios
        : DeviceRegisterRequestPlatformEnum.android;
    await _api
        .getNotificationsApi()
        .registerDeviceApiV1NotificationsDevicesPost(
          deviceRegisterRequest: DeviceRegisterRequest(
            (b) => b
              ..platform = platform
              ..token = token,
          ),
        );
  }

  void _wireTapHandlers(FirebaseMessaging messaging) {
    unawaited(
      messaging.getInitialMessage().then((message) {
        if (message != null) _openFromData(message.data);
      }),
    );
    FirebaseMessaging.onMessageOpenedApp.listen((m) => _openFromData(m.data));
    // Foreground pushes are intentionally dropped: the in-app bell badge
    // (15s poll) already covers it — no double banners while using the app.
  }

  void _openFromData(Map<String, dynamic> data) {
    final location = pushRoute(data);
    if (location != null) onOpenRoute?.call(location);
  }
}

/// Deep-link location for a push `data` payload — mirrors
/// notification_presenter.notificationRoute on the server copy's keys.
String? pushRoute(Map<String, dynamic> data) {
  final type = data['type'] as String?;
  switch (type) {
    case 'chat_message' || 'chat_mention':
      final chatId = data['chat_id'];
      return chatId is String ? '/chats/room/$chatId' : null;
    case 'dm_message':
      final conversationId = data['conversation_id'];
      return conversationId is String ? '/messages/$conversationId' : null;
    case 'run_request' ||
        'run_request_accepted' ||
        'run_request_declined' ||
        'run_status' ||
        'run_completed' ||
        'run_runner_arrived' ||
        'run_no_show' ||
        'run_payment_submitted' ||
        'run_payment_confirmed' ||
        'run_price_final':
      final runId = data['run_id'];
      return runId is String ? '/runs/run/$runId' : null;
  }
  return null;
}

final pushServiceProvider = Provider<PushService>((ref) {
  final service = PushService(ref.watch(campusApiProvider));
  ref.onDispose(service.dispose);
  return service;
});
