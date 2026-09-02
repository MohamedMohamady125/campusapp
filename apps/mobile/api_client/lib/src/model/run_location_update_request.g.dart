// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'run_location_update_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$RunLocationUpdateRequest extends RunLocationUpdateRequest {
  @override
  final num lat;
  @override
  final num lng;

  factory _$RunLocationUpdateRequest(
          [void Function(RunLocationUpdateRequestBuilder)? updates]) =>
      (RunLocationUpdateRequestBuilder()..update(updates))._build();

  _$RunLocationUpdateRequest._({required this.lat, required this.lng})
      : super._();
  @override
  RunLocationUpdateRequest rebuild(
          void Function(RunLocationUpdateRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  RunLocationUpdateRequestBuilder toBuilder() =>
      RunLocationUpdateRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is RunLocationUpdateRequest &&
        lat == other.lat &&
        lng == other.lng;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, lat.hashCode);
    _$hash = $jc(_$hash, lng.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'RunLocationUpdateRequest')
          ..add('lat', lat)
          ..add('lng', lng))
        .toString();
  }
}

class RunLocationUpdateRequestBuilder
    implements
        Builder<RunLocationUpdateRequest, RunLocationUpdateRequestBuilder> {
  _$RunLocationUpdateRequest? _$v;

  num? _lat;
  num? get lat => _$this._lat;
  set lat(num? lat) => _$this._lat = lat;

  num? _lng;
  num? get lng => _$this._lng;
  set lng(num? lng) => _$this._lng = lng;

  RunLocationUpdateRequestBuilder() {
    RunLocationUpdateRequest._defaults(this);
  }

  RunLocationUpdateRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _lat = $v.lat;
      _lng = $v.lng;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(RunLocationUpdateRequest other) {
    _$v = other as _$RunLocationUpdateRequest;
  }

  @override
  void update(void Function(RunLocationUpdateRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  RunLocationUpdateRequest build() => _build();

  _$RunLocationUpdateRequest _build() {
    final _$result = _$v ??
        _$RunLocationUpdateRequest._(
          lat: BuiltValueNullFieldError.checkNotNull(
              lat, r'RunLocationUpdateRequest', 'lat'),
          lng: BuiltValueNullFieldError.checkNotNull(
              lng, r'RunLocationUpdateRequest', 'lng'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
