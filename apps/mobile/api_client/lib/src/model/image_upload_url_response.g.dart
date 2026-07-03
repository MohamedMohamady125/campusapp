// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'image_upload_url_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ImageUploadUrlResponse extends ImageUploadUrlResponse {
  @override
  final BuiltMap<String, String> fields;
  @override
  final String imageId;
  @override
  final String key;
  @override
  final String uploadUrl;

  factory _$ImageUploadUrlResponse(
          [void Function(ImageUploadUrlResponseBuilder)? updates]) =>
      (ImageUploadUrlResponseBuilder()..update(updates))._build();

  _$ImageUploadUrlResponse._(
      {required this.fields,
      required this.imageId,
      required this.key,
      required this.uploadUrl})
      : super._();
  @override
  ImageUploadUrlResponse rebuild(
          void Function(ImageUploadUrlResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ImageUploadUrlResponseBuilder toBuilder() =>
      ImageUploadUrlResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ImageUploadUrlResponse &&
        fields == other.fields &&
        imageId == other.imageId &&
        key == other.key &&
        uploadUrl == other.uploadUrl;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, fields.hashCode);
    _$hash = $jc(_$hash, imageId.hashCode);
    _$hash = $jc(_$hash, key.hashCode);
    _$hash = $jc(_$hash, uploadUrl.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ImageUploadUrlResponse')
          ..add('fields', fields)
          ..add('imageId', imageId)
          ..add('key', key)
          ..add('uploadUrl', uploadUrl))
        .toString();
  }
}

class ImageUploadUrlResponseBuilder
    implements Builder<ImageUploadUrlResponse, ImageUploadUrlResponseBuilder> {
  _$ImageUploadUrlResponse? _$v;

  MapBuilder<String, String>? _fields;
  MapBuilder<String, String> get fields =>
      _$this._fields ??= MapBuilder<String, String>();
  set fields(MapBuilder<String, String>? fields) => _$this._fields = fields;

  String? _imageId;
  String? get imageId => _$this._imageId;
  set imageId(String? imageId) => _$this._imageId = imageId;

  String? _key;
  String? get key => _$this._key;
  set key(String? key) => _$this._key = key;

  String? _uploadUrl;
  String? get uploadUrl => _$this._uploadUrl;
  set uploadUrl(String? uploadUrl) => _$this._uploadUrl = uploadUrl;

  ImageUploadUrlResponseBuilder() {
    ImageUploadUrlResponse._defaults(this);
  }

  ImageUploadUrlResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _fields = $v.fields.toBuilder();
      _imageId = $v.imageId;
      _key = $v.key;
      _uploadUrl = $v.uploadUrl;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ImageUploadUrlResponse other) {
    _$v = other as _$ImageUploadUrlResponse;
  }

  @override
  void update(void Function(ImageUploadUrlResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ImageUploadUrlResponse build() => _build();

  _$ImageUploadUrlResponse _build() {
    _$ImageUploadUrlResponse _$result;
    try {
      _$result = _$v ??
          _$ImageUploadUrlResponse._(
            fields: fields.build(),
            imageId: BuiltValueNullFieldError.checkNotNull(
                imageId, r'ImageUploadUrlResponse', 'imageId'),
            key: BuiltValueNullFieldError.checkNotNull(
                key, r'ImageUploadUrlResponse', 'key'),
            uploadUrl: BuiltValueNullFieldError.checkNotNull(
                uploadUrl, r'ImageUploadUrlResponse', 'uploadUrl'),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'fields';
        fields.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'ImageUploadUrlResponse', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
