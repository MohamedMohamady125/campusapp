// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'properties_value.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PropertiesValue extends PropertiesValue {
  @override
  final AnyOf anyOf;

  factory _$PropertiesValue([void Function(PropertiesValueBuilder)? updates]) =>
      (PropertiesValueBuilder()..update(updates))._build();

  _$PropertiesValue._({required this.anyOf}) : super._();
  @override
  PropertiesValue rebuild(void Function(PropertiesValueBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PropertiesValueBuilder toBuilder() => PropertiesValueBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PropertiesValue && anyOf == other.anyOf;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, anyOf.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'PropertiesValue')
          ..add('anyOf', anyOf))
        .toString();
  }
}

class PropertiesValueBuilder
    implements Builder<PropertiesValue, PropertiesValueBuilder> {
  _$PropertiesValue? _$v;

  AnyOf? _anyOf;
  AnyOf? get anyOf => _$this._anyOf;
  set anyOf(AnyOf? anyOf) => _$this._anyOf = anyOf;

  PropertiesValueBuilder() {
    PropertiesValue._defaults(this);
  }

  PropertiesValueBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _anyOf = $v.anyOf;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PropertiesValue other) {
    _$v = other as _$PropertiesValue;
  }

  @override
  void update(void Function(PropertiesValueBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PropertiesValue build() => _build();

  _$PropertiesValue _build() {
    final _$result = _$v ??
        _$PropertiesValue._(
          anyOf: BuiltValueNullFieldError.checkNotNull(
              anyOf, r'PropertiesValue', 'anyOf'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
