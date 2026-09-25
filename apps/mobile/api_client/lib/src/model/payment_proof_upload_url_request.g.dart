// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_proof_upload_url_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PaymentProofUploadUrlRequest extends PaymentProofUploadUrlRequest {
  @override
  final String contentType;

  factory _$PaymentProofUploadUrlRequest(
          [void Function(PaymentProofUploadUrlRequestBuilder)? updates]) =>
      (PaymentProofUploadUrlRequestBuilder()..update(updates))._build();

  _$PaymentProofUploadUrlRequest._({required this.contentType}) : super._();
  @override
  PaymentProofUploadUrlRequest rebuild(
          void Function(PaymentProofUploadUrlRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PaymentProofUploadUrlRequestBuilder toBuilder() =>
      PaymentProofUploadUrlRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PaymentProofUploadUrlRequest &&
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
    return (newBuiltValueToStringHelper(r'PaymentProofUploadUrlRequest')
          ..add('contentType', contentType))
        .toString();
  }
}

class PaymentProofUploadUrlRequestBuilder
    implements
        Builder<PaymentProofUploadUrlRequest,
            PaymentProofUploadUrlRequestBuilder> {
  _$PaymentProofUploadUrlRequest? _$v;

  String? _contentType;
  String? get contentType => _$this._contentType;
  set contentType(String? contentType) => _$this._contentType = contentType;

  PaymentProofUploadUrlRequestBuilder() {
    PaymentProofUploadUrlRequest._defaults(this);
  }

  PaymentProofUploadUrlRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _contentType = $v.contentType;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PaymentProofUploadUrlRequest other) {
    _$v = other as _$PaymentProofUploadUrlRequest;
  }

  @override
  void update(void Function(PaymentProofUploadUrlRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PaymentProofUploadUrlRequest build() => _build();

  _$PaymentProofUploadUrlRequest _build() {
    final _$result = _$v ??
        _$PaymentProofUploadUrlRequest._(
          contentType: BuiltValueNullFieldError.checkNotNull(
              contentType, r'PaymentProofUploadUrlRequest', 'contentType'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
