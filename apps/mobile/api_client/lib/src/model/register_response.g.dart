// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'register_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$RegisterResponse extends RegisterResponse {
  @override
  final String message;
  @override
  final String userId;

  factory _$RegisterResponse(
          [void Function(RegisterResponseBuilder)? updates]) =>
      (RegisterResponseBuilder()..update(updates))._build();

  _$RegisterResponse._({required this.message, required this.userId})
      : super._();
  @override
  RegisterResponse rebuild(void Function(RegisterResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  RegisterResponseBuilder toBuilder() =>
      RegisterResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is RegisterResponse &&
        message == other.message &&
        userId == other.userId;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, message.hashCode);
    _$hash = $jc(_$hash, userId.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'RegisterResponse')
          ..add('message', message)
          ..add('userId', userId))
        .toString();
  }
}

class RegisterResponseBuilder
    implements Builder<RegisterResponse, RegisterResponseBuilder> {
  _$RegisterResponse? _$v;

  String? _message;
  String? get message => _$this._message;
  set message(String? message) => _$this._message = message;

  String? _userId;
  String? get userId => _$this._userId;
  set userId(String? userId) => _$this._userId = userId;

  RegisterResponseBuilder() {
    RegisterResponse._defaults(this);
  }

  RegisterResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _message = $v.message;
      _userId = $v.userId;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(RegisterResponse other) {
    _$v = other as _$RegisterResponse;
  }

  @override
  void update(void Function(RegisterResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  RegisterResponse build() => _build();

  _$RegisterResponse _build() {
    final _$result = _$v ??
        _$RegisterResponse._(
          message: BuiltValueNullFieldError.checkNotNull(
              message, r'RegisterResponse', 'message'),
          userId: BuiltValueNullFieldError.checkNotNull(
              userId, r'RegisterResponse', 'userId'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
