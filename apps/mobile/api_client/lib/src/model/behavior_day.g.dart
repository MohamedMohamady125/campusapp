// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'behavior_day.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$BehaviorDay extends BehaviorDay {
  @override
  final int activeUsers;
  @override
  final Date day;
  @override
  final int events;
  @override
  final int sessions;

  factory _$BehaviorDay([void Function(BehaviorDayBuilder)? updates]) =>
      (BehaviorDayBuilder()..update(updates))._build();

  _$BehaviorDay._(
      {required this.activeUsers,
      required this.day,
      required this.events,
      required this.sessions})
      : super._();
  @override
  BehaviorDay rebuild(void Function(BehaviorDayBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  BehaviorDayBuilder toBuilder() => BehaviorDayBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is BehaviorDay &&
        activeUsers == other.activeUsers &&
        day == other.day &&
        events == other.events &&
        sessions == other.sessions;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, activeUsers.hashCode);
    _$hash = $jc(_$hash, day.hashCode);
    _$hash = $jc(_$hash, events.hashCode);
    _$hash = $jc(_$hash, sessions.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'BehaviorDay')
          ..add('activeUsers', activeUsers)
          ..add('day', day)
          ..add('events', events)
          ..add('sessions', sessions))
        .toString();
  }
}

class BehaviorDayBuilder implements Builder<BehaviorDay, BehaviorDayBuilder> {
  _$BehaviorDay? _$v;

  int? _activeUsers;
  int? get activeUsers => _$this._activeUsers;
  set activeUsers(int? activeUsers) => _$this._activeUsers = activeUsers;

  Date? _day;
  Date? get day => _$this._day;
  set day(Date? day) => _$this._day = day;

  int? _events;
  int? get events => _$this._events;
  set events(int? events) => _$this._events = events;

  int? _sessions;
  int? get sessions => _$this._sessions;
  set sessions(int? sessions) => _$this._sessions = sessions;

  BehaviorDayBuilder() {
    BehaviorDay._defaults(this);
  }

  BehaviorDayBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _activeUsers = $v.activeUsers;
      _day = $v.day;
      _events = $v.events;
      _sessions = $v.sessions;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(BehaviorDay other) {
    _$v = other as _$BehaviorDay;
  }

  @override
  void update(void Function(BehaviorDayBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  BehaviorDay build() => _build();

  _$BehaviorDay _build() {
    final _$result = _$v ??
        _$BehaviorDay._(
          activeUsers: BuiltValueNullFieldError.checkNotNull(
              activeUsers, r'BehaviorDay', 'activeUsers'),
          day:
              BuiltValueNullFieldError.checkNotNull(day, r'BehaviorDay', 'day'),
          events: BuiltValueNullFieldError.checkNotNull(
              events, r'BehaviorDay', 'events'),
          sessions: BuiltValueNullFieldError.checkNotNull(
              sessions, r'BehaviorDay', 'sessions'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
