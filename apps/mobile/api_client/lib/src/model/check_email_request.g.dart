// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'check_email_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$CheckEmailRequest extends CheckEmailRequest {
  @override
  final String email;

  factory _$CheckEmailRequest(
          [void Function(CheckEmailRequestBuilder)? updates]) =>
      (CheckEmailRequestBuilder()..update(updates))._build();

  _$CheckEmailRequest._({required this.email}) : super._();
  @override
  CheckEmailRequest rebuild(void Function(CheckEmailRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  CheckEmailRequestBuilder toBuilder() =>
      CheckEmailRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is CheckEmailRequest && email == other.email;
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
    return (newBuiltValueToStringHelper(r'CheckEmailRequest')
          ..add('email', email))
        .toString();
  }
}

class CheckEmailRequestBuilder
    implements Builder<CheckEmailRequest, CheckEmailRequestBuilder> {
  _$CheckEmailRequest? _$v;

  String? _email;
  String? get email => _$this._email;
  set email(String? email) => _$this._email = email;

  CheckEmailRequestBuilder() {
    CheckEmailRequest._defaults(this);
  }

  CheckEmailRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _email = $v.email;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(CheckEmailRequest other) {
    _$v = other as _$CheckEmailRequest;
  }

  @override
  void update(void Function(CheckEmailRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  CheckEmailRequest build() => _build();

  _$CheckEmailRequest _build() {
    final _$result = _$v ??
        _$CheckEmailRequest._(
          email: BuiltValueNullFieldError.checkNotNull(
              email, r'CheckEmailRequest', 'email'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
