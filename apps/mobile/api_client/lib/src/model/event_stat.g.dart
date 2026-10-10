// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event_stat.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$EventStat extends EventStat {
  @override
  final int count;
  @override
  final String name;
  @override
  final int uniqueUsers;

  factory _$EventStat([void Function(EventStatBuilder)? updates]) =>
      (EventStatBuilder()..update(updates))._build();

  _$EventStat._(
      {required this.count, required this.name, required this.uniqueUsers})
      : super._();
  @override
  EventStat rebuild(void Function(EventStatBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  EventStatBuilder toBuilder() => EventStatBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is EventStat &&
        count == other.count &&
        name == other.name &&
        uniqueUsers == other.uniqueUsers;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, count.hashCode);
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, uniqueUsers.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'EventStat')
          ..add('count', count)
          ..add('name', name)
          ..add('uniqueUsers', uniqueUsers))
        .toString();
  }
}

class EventStatBuilder implements Builder<EventStat, EventStatBuilder> {
  _$EventStat? _$v;

  int? _count;
  int? get count => _$this._count;
  set count(int? count) => _$this._count = count;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  int? _uniqueUsers;
  int? get uniqueUsers => _$this._uniqueUsers;
  set uniqueUsers(int? uniqueUsers) => _$this._uniqueUsers = uniqueUsers;

  EventStatBuilder() {
    EventStat._defaults(this);
  }

  EventStatBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _count = $v.count;
      _name = $v.name;
      _uniqueUsers = $v.uniqueUsers;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(EventStat other) {
    _$v = other as _$EventStat;
  }

  @override
  void update(void Function(EventStatBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  EventStat build() => _build();

  _$EventStat _build() {
    final _$result = _$v ??
        _$EventStat._(
          count: BuiltValueNullFieldError.checkNotNull(
              count, r'EventStat', 'count'),
          name:
              BuiltValueNullFieldError.checkNotNull(name, r'EventStat', 'name'),
          uniqueUsers: BuiltValueNullFieldError.checkNotNull(
              uniqueUsers, r'EventStat', 'uniqueUsers'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
