// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'check_email_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$CheckEmailResponse extends CheckEmailResponse {
  @override
  final bool exists;

  factory _$CheckEmailResponse(
          [void Function(CheckEmailResponseBuilder)? updates]) =>
      (CheckEmailResponseBuilder()..update(updates))._build();

  _$CheckEmailResponse._({required this.exists}) : super._();
  @override
  CheckEmailResponse rebuild(
          void Function(CheckEmailResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  CheckEmailResponseBuilder toBuilder() =>
      CheckEmailResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is CheckEmailResponse && exists == other.exists;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, exists.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'CheckEmailResponse')
          ..add('exists', exists))
        .toString();
  }
}

class CheckEmailResponseBuilder
    implements Builder<CheckEmailResponse, CheckEmailResponseBuilder> {
  _$CheckEmailResponse? _$v;

  bool? _exists;
  bool? get exists => _$this._exists;
  set exists(bool? exists) => _$this._exists = exists;

  CheckEmailResponseBuilder() {
    CheckEmailResponse._defaults(this);
  }

  CheckEmailResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _exists = $v.exists;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(CheckEmailResponse other) {
    _$v = other as _$CheckEmailResponse;
  }

  @override
  void update(void Function(CheckEmailResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  CheckEmailResponse build() => _build();

  _$CheckEmailResponse _build() {
    final _$result = _$v ??
        _$CheckEmailResponse._(
          exists: BuiltValueNullFieldError.checkNotNull(
              exists, r'CheckEmailResponse', 'exists'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
