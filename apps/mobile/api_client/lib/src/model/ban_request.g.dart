// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ban_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$BanRequest extends BanRequest {
  @override
  final String? reason;

  factory _$BanRequest([void Function(BanRequestBuilder)? updates]) =>
      (BanRequestBuilder()..update(updates))._build();

  _$BanRequest._({this.reason}) : super._();
  @override
  BanRequest rebuild(void Function(BanRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  BanRequestBuilder toBuilder() => BanRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is BanRequest && reason == other.reason;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, reason.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'BanRequest')..add('reason', reason))
        .toString();
  }
}

class BanRequestBuilder implements Builder<BanRequest, BanRequestBuilder> {
  _$BanRequest? _$v;

  String? _reason;
  String? get reason => _$this._reason;
  set reason(String? reason) => _$this._reason = reason;

  BanRequestBuilder() {
    BanRequest._defaults(this);
  }

  BanRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _reason = $v.reason;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(BanRequest other) {
    _$v = other as _$BanRequest;
  }

  @override
  void update(void Function(BanRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  BanRequest build() => _build();

  _$BanRequest _build() {
    final _$result = _$v ??
        _$BanRequest._(
          reason: reason,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
