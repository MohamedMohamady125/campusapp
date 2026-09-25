// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_qr_upload_url_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PaymentQrUploadUrlResponse extends PaymentQrUploadUrlResponse {
  @override
  final BuiltMap<String, String> fields;
  @override
  final String key;
  @override
  final String uploadUrl;

  factory _$PaymentQrUploadUrlResponse(
          [void Function(PaymentQrUploadUrlResponseBuilder)? updates]) =>
      (PaymentQrUploadUrlResponseBuilder()..update(updates))._build();

  _$PaymentQrUploadUrlResponse._(
      {required this.fields, required this.key, required this.uploadUrl})
      : super._();
  @override
  PaymentQrUploadUrlResponse rebuild(
          void Function(PaymentQrUploadUrlResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PaymentQrUploadUrlResponseBuilder toBuilder() =>
      PaymentQrUploadUrlResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PaymentQrUploadUrlResponse &&
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
    return (newBuiltValueToStringHelper(r'PaymentQrUploadUrlResponse')
          ..add('fields', fields)
          ..add('key', key)
          ..add('uploadUrl', uploadUrl))
        .toString();
  }
}

class PaymentQrUploadUrlResponseBuilder
    implements
        Builder<PaymentQrUploadUrlResponse, PaymentQrUploadUrlResponseBuilder> {
  _$PaymentQrUploadUrlResponse? _$v;

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

  PaymentQrUploadUrlResponseBuilder() {
    PaymentQrUploadUrlResponse._defaults(this);
  }

  PaymentQrUploadUrlResponseBuilder get _$this {
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
  void replace(PaymentQrUploadUrlResponse other) {
    _$v = other as _$PaymentQrUploadUrlResponse;
  }

  @override
  void update(void Function(PaymentQrUploadUrlResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PaymentQrUploadUrlResponse build() => _build();

  _$PaymentQrUploadUrlResponse _build() {
    _$PaymentQrUploadUrlResponse _$result;
    try {
      _$result = _$v ??
          _$PaymentQrUploadUrlResponse._(
            fields: fields.build(),
            key: BuiltValueNullFieldError.checkNotNull(
                key, r'PaymentQrUploadUrlResponse', 'key'),
            uploadUrl: BuiltValueNullFieldError.checkNotNull(
                uploadUrl, r'PaymentQrUploadUrlResponse', 'uploadUrl'),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'fields';
        fields.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'PaymentQrUploadUrlResponse', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
