// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'image_upload_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ImageUploadResponse extends ImageUploadResponse {
  @override
  final String key;
  @override
  final String url;

  factory _$ImageUploadResponse(
          [void Function(ImageUploadResponseBuilder)? updates]) =>
      (ImageUploadResponseBuilder()..update(updates))._build();

  _$ImageUploadResponse._({required this.key, required this.url}) : super._();
  @override
  ImageUploadResponse rebuild(
          void Function(ImageUploadResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ImageUploadResponseBuilder toBuilder() =>
      ImageUploadResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ImageUploadResponse && key == other.key && url == other.url;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, key.hashCode);
    _$hash = $jc(_$hash, url.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ImageUploadResponse')
          ..add('key', key)
          ..add('url', url))
        .toString();
  }
}

class ImageUploadResponseBuilder
    implements Builder<ImageUploadResponse, ImageUploadResponseBuilder> {
  _$ImageUploadResponse? _$v;

  String? _key;
  String? get key => _$this._key;
  set key(String? key) => _$this._key = key;

  String? _url;
  String? get url => _$this._url;
  set url(String? url) => _$this._url = url;

  ImageUploadResponseBuilder() {
    ImageUploadResponse._defaults(this);
  }

  ImageUploadResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _key = $v.key;
      _url = $v.url;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ImageUploadResponse other) {
    _$v = other as _$ImageUploadResponse;
  }

  @override
  void update(void Function(ImageUploadResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ImageUploadResponse build() => _build();

  _$ImageUploadResponse _build() {
    final _$result = _$v ??
        _$ImageUploadResponse._(
          key: BuiltValueNullFieldError.checkNotNull(
              key, r'ImageUploadResponse', 'key'),
          url: BuiltValueNullFieldError.checkNotNull(
              url, r'ImageUploadResponse', 'url'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
