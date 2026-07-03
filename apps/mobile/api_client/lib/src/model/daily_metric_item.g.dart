// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'daily_metric_item.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$DailyMetricItem extends DailyMetricItem {
  @override
  final Date day;
  @override
  final String name;
  @override
  final num value;

  factory _$DailyMetricItem([void Function(DailyMetricItemBuilder)? updates]) =>
      (DailyMetricItemBuilder()..update(updates))._build();

  _$DailyMetricItem._(
      {required this.day, required this.name, required this.value})
      : super._();
  @override
  DailyMetricItem rebuild(void Function(DailyMetricItemBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  DailyMetricItemBuilder toBuilder() => DailyMetricItemBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is DailyMetricItem &&
        day == other.day &&
        name == other.name &&
        value == other.value;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, day.hashCode);
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, value.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'DailyMetricItem')
          ..add('day', day)
          ..add('name', name)
          ..add('value', value))
        .toString();
  }
}

class DailyMetricItemBuilder
    implements Builder<DailyMetricItem, DailyMetricItemBuilder> {
  _$DailyMetricItem? _$v;

  Date? _day;
  Date? get day => _$this._day;
  set day(Date? day) => _$this._day = day;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  num? _value;
  num? get value => _$this._value;
  set value(num? value) => _$this._value = value;

  DailyMetricItemBuilder() {
    DailyMetricItem._defaults(this);
  }

  DailyMetricItemBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _day = $v.day;
      _name = $v.name;
      _value = $v.value;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(DailyMetricItem other) {
    _$v = other as _$DailyMetricItem;
  }

  @override
  void update(void Function(DailyMetricItemBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  DailyMetricItem build() => _build();

  _$DailyMetricItem _build() {
    final _$result = _$v ??
        _$DailyMetricItem._(
          day: BuiltValueNullFieldError.checkNotNull(
              day, r'DailyMetricItem', 'day'),
          name: BuiltValueNullFieldError.checkNotNull(
              name, r'DailyMetricItem', 'name'),
          value: BuiltValueNullFieldError.checkNotNull(
              value, r'DailyMetricItem', 'value'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
