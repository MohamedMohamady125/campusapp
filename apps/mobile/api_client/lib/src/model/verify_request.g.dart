// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'verify_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$VerifyRequest extends VerifyRequest {
  @override
  final String code;
  @override
  final String email;

  factory _$VerifyRequest([void Function(VerifyRequestBuilder)? updates]) =>
      (VerifyRequestBuilder()..update(updates))._build();

  _$VerifyRequest._({required this.code, required this.email}) : super._();
  @override
  VerifyRequest rebuild(void Function(VerifyRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  VerifyRequestBuilder toBuilder() => VerifyRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is VerifyRequest && code == other.code && email == other.email;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, code.hashCode);
    _$hash = $jc(_$hash, email.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'VerifyRequest')
          ..add('code', code)
          ..add('email', email))
        .toString();
  }
}

class VerifyRequestBuilder
    implements Builder<VerifyRequest, VerifyRequestBuilder> {
  _$VerifyRequest? _$v;

  String? _code;
  String? get code => _$this._code;
  set code(String? code) => _$this._code = code;

  String? _email;
  String? get email => _$this._email;
  set email(String? email) => _$this._email = email;

  VerifyRequestBuilder() {
    VerifyRequest._defaults(this);
  }

  VerifyRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _code = $v.code;
      _email = $v.email;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(VerifyRequest other) {
    _$v = other as _$VerifyRequest;
  }

  @override
  void update(void Function(VerifyRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  VerifyRequest build() => _build();

  _$VerifyRequest _build() {
    final _$result = _$v ??
        _$VerifyRequest._(
          code: BuiltValueNullFieldError.checkNotNull(
              code, r'VerifyRequest', 'code'),
          email: BuiltValueNullFieldError.checkNotNull(
              email, r'VerifyRequest', 'email'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
