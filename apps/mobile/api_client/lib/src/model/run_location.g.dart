// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'run_location.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$RunLocation extends RunLocation {
  @override
  final num lat;
  @override
  final num lng;
  @override
  final DateTime updatedAt;

  factory _$RunLocation([void Function(RunLocationBuilder)? updates]) =>
      (RunLocationBuilder()..update(updates))._build();

  _$RunLocation._(
      {required this.lat, required this.lng, required this.updatedAt})
      : super._();
  @override
  RunLocation rebuild(void Function(RunLocationBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  RunLocationBuilder toBuilder() => RunLocationBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is RunLocation &&
        lat == other.lat &&
        lng == other.lng &&
        updatedAt == other.updatedAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, lat.hashCode);
    _$hash = $jc(_$hash, lng.hashCode);
    _$hash = $jc(_$hash, updatedAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'RunLocation')
          ..add('lat', lat)
          ..add('lng', lng)
          ..add('updatedAt', updatedAt))
        .toString();
  }
}

class RunLocationBuilder implements Builder<RunLocation, RunLocationBuilder> {
  _$RunLocation? _$v;

  num? _lat;
  num? get lat => _$this._lat;
  set lat(num? lat) => _$this._lat = lat;

  num? _lng;
  num? get lng => _$this._lng;
  set lng(num? lng) => _$this._lng = lng;

  DateTime? _updatedAt;
  DateTime? get updatedAt => _$this._updatedAt;
  set updatedAt(DateTime? updatedAt) => _$this._updatedAt = updatedAt;

  RunLocationBuilder() {
    RunLocation._defaults(this);
  }

  RunLocationBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _lat = $v.lat;
      _lng = $v.lng;
      _updatedAt = $v.updatedAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(RunLocation other) {
    _$v = other as _$RunLocation;
  }

  @override
  void update(void Function(RunLocationBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  RunLocation build() => _build();

  _$RunLocation _build() {
    final _$result = _$v ??
        _$RunLocation._(
          lat:
              BuiltValueNullFieldError.checkNotNull(lat, r'RunLocation', 'lat'),
          lng:
              BuiltValueNullFieldError.checkNotNull(lng, r'RunLocation', 'lng'),
          updatedAt: BuiltValueNullFieldError.checkNotNull(
              updatedAt, r'RunLocation', 'updatedAt'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
