// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'resend_code_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ResendCodeRequest extends ResendCodeRequest {
  @override
  final String email;

  factory _$ResendCodeRequest(
          [void Function(ResendCodeRequestBuilder)? updates]) =>
      (ResendCodeRequestBuilder()..update(updates))._build();

  _$ResendCodeRequest._({required this.email}) : super._();
  @override
  ResendCodeRequest rebuild(void Function(ResendCodeRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ResendCodeRequestBuilder toBuilder() =>
      ResendCodeRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ResendCodeRequest && email == other.email;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, email.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ResendCodeRequest')
          ..add('email', email))
        .toString();
  }
}

class ResendCodeRequestBuilder
    implements Builder<ResendCodeRequest, ResendCodeRequestBuilder> {
  _$ResendCodeRequest? _$v;

  String? _email;
  String? get email => _$this._email;
  set email(String? email) => _$this._email = email;

  ResendCodeRequestBuilder() {
    ResendCodeRequest._defaults(this);
  }

  ResendCodeRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _email = $v.email;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ResendCodeRequest other) {
    _$v = other as _$ResendCodeRequest;
  }

  @override
  void update(void Function(ResendCodeRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ResendCodeRequest build() => _build();

  _$ResendCodeRequest _build() {
    final _$result = _$v ??
        _$ResendCodeRequest._(
          email: BuiltValueNullFieldError.checkNotNull(
              email, r'ResendCodeRequest', 'email'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
