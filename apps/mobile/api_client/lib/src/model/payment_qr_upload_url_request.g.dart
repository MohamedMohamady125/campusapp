// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_qr_upload_url_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PaymentQrUploadUrlRequest extends PaymentQrUploadUrlRequest {
  @override
  final String contentType;

  factory _$PaymentQrUploadUrlRequest(
          [void Function(PaymentQrUploadUrlRequestBuilder)? updates]) =>
      (PaymentQrUploadUrlRequestBuilder()..update(updates))._build();

  _$PaymentQrUploadUrlRequest._({required this.contentType}) : super._();
  @override
  PaymentQrUploadUrlRequest rebuild(
          void Function(PaymentQrUploadUrlRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PaymentQrUploadUrlRequestBuilder toBuilder() =>
      PaymentQrUploadUrlRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PaymentQrUploadUrlRequest &&
        contentType == other.contentType;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, contentType.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'PaymentQrUploadUrlRequest')
          ..add('contentType', contentType))
        .toString();
  }
}

class PaymentQrUploadUrlRequestBuilder
    implements
        Builder<PaymentQrUploadUrlRequest, PaymentQrUploadUrlRequestBuilder> {
  _$PaymentQrUploadUrlRequest? _$v;

  String? _contentType;
  String? get contentType => _$this._contentType;
  set contentType(String? contentType) => _$this._contentType = contentType;

  PaymentQrUploadUrlRequestBuilder() {
    PaymentQrUploadUrlRequest._defaults(this);
  }

  PaymentQrUploadUrlRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _contentType = $v.contentType;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PaymentQrUploadUrlRequest other) {
    _$v = other as _$PaymentQrUploadUrlRequest;
  }

  @override
  void update(void Function(PaymentQrUploadUrlRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PaymentQrUploadUrlRequest build() => _build();

  _$PaymentQrUploadUrlRequest _build() {
    final _$result = _$v ??
        _$PaymentQrUploadUrlRequest._(
          contentType: BuiltValueNullFieldError.checkNotNull(
              contentType, r'PaymentQrUploadUrlRequest', 'contentType'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
