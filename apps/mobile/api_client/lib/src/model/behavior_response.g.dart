// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'behavior_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$BehaviorResponse extends BehaviorResponse {
  @override
  final BuiltList<BehaviorDay> daily;
  @override
  final int days;
  @override
  final BuiltList<ScreenStat> screens;
  @override
  final BuiltList<EventStat> topEvents;

  factory _$BehaviorResponse(
          [void Function(BehaviorResponseBuilder)? updates]) =>
      (BehaviorResponseBuilder()..update(updates))._build();

  _$BehaviorResponse._(
      {required this.daily,
      required this.days,
      required this.screens,
      required this.topEvents})
      : super._();
  @override
  BehaviorResponse rebuild(void Function(BehaviorResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  BehaviorResponseBuilder toBuilder() =>
      BehaviorResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is BehaviorResponse &&
        daily == other.daily &&
        days == other.days &&
        screens == other.screens &&
        topEvents == other.topEvents;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, daily.hashCode);
    _$hash = $jc(_$hash, days.hashCode);
    _$hash = $jc(_$hash, screens.hashCode);
    _$hash = $jc(_$hash, topEvents.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'BehaviorResponse')
          ..add('daily', daily)
          ..add('days', days)
          ..add('screens', screens)
          ..add('topEvents', topEvents))
        .toString();
  }
}

class BehaviorResponseBuilder
    implements Builder<BehaviorResponse, BehaviorResponseBuilder> {
  _$BehaviorResponse? _$v;

  ListBuilder<BehaviorDay>? _daily;
  ListBuilder<BehaviorDay> get daily =>
      _$this._daily ??= ListBuilder<BehaviorDay>();
  set daily(ListBuilder<BehaviorDay>? daily) => _$this._daily = daily;

  int? _days;
  int? get days => _$this._days;
  set days(int? days) => _$this._days = days;

  ListBuilder<ScreenStat>? _screens;
  ListBuilder<ScreenStat> get screens =>
      _$this._screens ??= ListBuilder<ScreenStat>();
  set screens(ListBuilder<ScreenStat>? screens) => _$this._screens = screens;

  ListBuilder<EventStat>? _topEvents;
  ListBuilder<EventStat> get topEvents =>
      _$this._topEvents ??= ListBuilder<EventStat>();
  set topEvents(ListBuilder<EventStat>? topEvents) =>
      _$this._topEvents = topEvents;

  BehaviorResponseBuilder() {
    BehaviorResponse._defaults(this);
  }

  BehaviorResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _daily = $v.daily.toBuilder();
      _days = $v.days;
      _screens = $v.screens.toBuilder();
      _topEvents = $v.topEvents.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(BehaviorResponse other) {
    _$v = other as _$BehaviorResponse;
  }

  @override
  void update(void Function(BehaviorResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  BehaviorResponse build() => _build();

  _$BehaviorResponse _build() {
    _$BehaviorResponse _$result;
    try {
      _$result = _$v ??
          _$BehaviorResponse._(
            daily: daily.build(),
            days: BuiltValueNullFieldError.checkNotNull(
                days, r'BehaviorResponse', 'days'),
            screens: screens.build(),
            topEvents: topEvents.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'daily';
        daily.build();

        _$failedField = 'screens';
        screens.build();
        _$failedField = 'topEvents';
        topEvents.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'BehaviorResponse', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
