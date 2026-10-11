// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'confirm_email_change_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ConfirmEmailChangeRequest extends ConfirmEmailChangeRequest {
  @override
  final String code;

  factory _$ConfirmEmailChangeRequest(
          [void Function(ConfirmEmailChangeRequestBuilder)? updates]) =>
      (ConfirmEmailChangeRequestBuilder()..update(updates))._build();

  _$ConfirmEmailChangeRequest._({required this.code}) : super._();
  @override
  ConfirmEmailChangeRequest rebuild(
          void Function(ConfirmEmailChangeRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ConfirmEmailChangeRequestBuilder toBuilder() =>
      ConfirmEmailChangeRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ConfirmEmailChangeRequest && code == other.code;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, code.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ConfirmEmailChangeRequest')
          ..add('code', code))
        .toString();
  }
}

class ConfirmEmailChangeRequestBuilder
    implements
        Builder<ConfirmEmailChangeRequest, ConfirmEmailChangeRequestBuilder> {
  _$ConfirmEmailChangeRequest? _$v;

  String? _code;
  String? get code => _$this._code;
  set code(String? code) => _$this._code = code;

  ConfirmEmailChangeRequestBuilder() {
    ConfirmEmailChangeRequest._defaults(this);
  }

  ConfirmEmailChangeRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _code = $v.code;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ConfirmEmailChangeRequest other) {
    _$v = other as _$ConfirmEmailChangeRequest;
  }

  @override
  void update(void Function(ConfirmEmailChangeRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ConfirmEmailChangeRequest build() => _build();

  _$ConfirmEmailChangeRequest _build() {
    final _$result = _$v ??
        _$ConfirmEmailChangeRequest._(
          code: BuiltValueNullFieldError.checkNotNull(
              code, r'ConfirmEmailChangeRequest', 'code'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
