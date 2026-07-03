// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'flag_item.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$FlagItem extends FlagItem {
  @override
  final bool enabled;
  @override
  final String key;
  @override
  final int rolloutPercent;

  factory _$FlagItem([void Function(FlagItemBuilder)? updates]) =>
      (FlagItemBuilder()..update(updates))._build();

  _$FlagItem._(
      {required this.enabled, required this.key, required this.rolloutPercent})
      : super._();
  @override
  FlagItem rebuild(void Function(FlagItemBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  FlagItemBuilder toBuilder() => FlagItemBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is FlagItem &&
        enabled == other.enabled &&
        key == other.key &&
        rolloutPercent == other.rolloutPercent;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, enabled.hashCode);
    _$hash = $jc(_$hash, key.hashCode);
    _$hash = $jc(_$hash, rolloutPercent.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'FlagItem')
          ..add('enabled', enabled)
          ..add('key', key)
          ..add('rolloutPercent', rolloutPercent))
        .toString();
  }
}

class FlagItemBuilder implements Builder<FlagItem, FlagItemBuilder> {
  _$FlagItem? _$v;

  bool? _enabled;
  bool? get enabled => _$this._enabled;
  set enabled(bool? enabled) => _$this._enabled = enabled;

  String? _key;
  String? get key => _$this._key;
  set key(String? key) => _$this._key = key;

  int? _rolloutPercent;
  int? get rolloutPercent => _$this._rolloutPercent;
  set rolloutPercent(int? rolloutPercent) =>
      _$this._rolloutPercent = rolloutPercent;

  FlagItemBuilder() {
    FlagItem._defaults(this);
  }

  FlagItemBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _enabled = $v.enabled;
      _key = $v.key;
      _rolloutPercent = $v.rolloutPercent;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(FlagItem other) {
    _$v = other as _$FlagItem;
  }

  @override
  void update(void Function(FlagItemBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  FlagItem build() => _build();

  _$FlagItem _build() {
    final _$result = _$v ??
        _$FlagItem._(
          enabled: BuiltValueNullFieldError.checkNotNull(
              enabled, r'FlagItem', 'enabled'),
          key: BuiltValueNullFieldError.checkNotNull(key, r'FlagItem', 'key'),
          rolloutPercent: BuiltValueNullFieldError.checkNotNull(
              rolloutPercent, r'FlagItem', 'rolloutPercent'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
