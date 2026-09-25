// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_proof_upload_url_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PaymentProofUploadUrlResponse extends PaymentProofUploadUrlResponse {
  @override
  final BuiltMap<String, String> fields;
  @override
  final String key;
  @override
  final String uploadUrl;

  factory _$PaymentProofUploadUrlResponse(
          [void Function(PaymentProofUploadUrlResponseBuilder)? updates]) =>
      (PaymentProofUploadUrlResponseBuilder()..update(updates))._build();

  _$PaymentProofUploadUrlResponse._(
      {required this.fields, required this.key, required this.uploadUrl})
      : super._();
  @override
  PaymentProofUploadUrlResponse rebuild(
          void Function(PaymentProofUploadUrlResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PaymentProofUploadUrlResponseBuilder toBuilder() =>
      PaymentProofUploadUrlResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PaymentProofUploadUrlResponse &&
        fields == other.fields &&
        key == other.key &&
        uploadUrl == other.uploadUrl;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, fields.hashCode);
    _$hash = $jc(_$hash, key.hashCode);
    _$hash = $jc(_$hash, uploadUrl.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'PaymentProofUploadUrlResponse')
          ..add('fields', fields)
          ..add('key', key)
          ..add('uploadUrl', uploadUrl))
        .toString();
  }
}

class PaymentProofUploadUrlResponseBuilder
    implements
        Builder<PaymentProofUploadUrlResponse,
            PaymentProofUploadUrlResponseBuilder> {
  _$PaymentProofUploadUrlResponse? _$v;

  MapBuilder<String, String>? _fields;
  MapBuilder<String, String> get fields =>
      _$this._fields ??= MapBuilder<String, String>();
  set fields(MapBuilder<String, String>? fields) => _$this._fields = fields;

  String? _key;
  String? get key => _$this._key;
  set key(String? key) => _$this._key = key;

  String? _uploadUrl;
  String? get uploadUrl => _$this._uploadUrl;
  set uploadUrl(String? uploadUrl) => _$this._uploadUrl = uploadUrl;

  PaymentProofUploadUrlResponseBuilder() {
    PaymentProofUploadUrlResponse._defaults(this);
  }

  PaymentProofUploadUrlResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _fields = $v.fields.toBuilder();
      _key = $v.key;
      _uploadUrl = $v.uploadUrl;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PaymentProofUploadUrlResponse other) {
    _$v = other as _$PaymentProofUploadUrlResponse;
  }

  @override
  void update(void Function(PaymentProofUploadUrlResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PaymentProofUploadUrlResponse build() => _build();

  _$PaymentProofUploadUrlResponse _build() {
    _$PaymentProofUploadUrlResponse _$result;
    try {
      _$result = _$v ??
          _$PaymentProofUploadUrlResponse._(
            fields: fields.build(),
            key: BuiltValueNullFieldError.checkNotNull(
                key, r'PaymentProofUploadUrlResponse', 'key'),
            uploadUrl: BuiltValueNullFieldError.checkNotNull(
                uploadUrl, r'PaymentProofUploadUrlResponse', 'uploadUrl'),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'fields';
        fields.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'PaymentProofUploadUrlResponse', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
