// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'device_unregister_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$DeviceUnregisterRequest extends DeviceUnregisterRequest {
  @override
  final String token;

  factory _$DeviceUnregisterRequest(
          [void Function(DeviceUnregisterRequestBuilder)? updates]) =>
      (DeviceUnregisterRequestBuilder()..update(updates))._build();

  _$DeviceUnregisterRequest._({required this.token}) : super._();
  @override
  DeviceUnregisterRequest rebuild(
          void Function(DeviceUnregisterRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  DeviceUnregisterRequestBuilder toBuilder() =>
      DeviceUnregisterRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is DeviceUnregisterRequest && token == other.token;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, token.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'DeviceUnregisterRequest')
          ..add('token', token))
        .toString();
  }
}

class DeviceUnregisterRequestBuilder
    implements
        Builder<DeviceUnregisterRequest, DeviceUnregisterRequestBuilder> {
  _$DeviceUnregisterRequest? _$v;

  String? _token;
  String? get token => _$this._token;
  set token(String? token) => _$this._token = token;

  DeviceUnregisterRequestBuilder() {
    DeviceUnregisterRequest._defaults(this);
  }

  DeviceUnregisterRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _token = $v.token;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(DeviceUnregisterRequest other) {
    _$v = other as _$DeviceUnregisterRequest;
  }

  @override
  void update(void Function(DeviceUnregisterRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  DeviceUnregisterRequest build() => _build();

  _$DeviceUnregisterRequest _build() {
    final _$result = _$v ??
        _$DeviceUnregisterRequest._(
          token: BuiltValueNullFieldError.checkNotNull(
              token, r'DeviceUnregisterRequest', 'token'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
