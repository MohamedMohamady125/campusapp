// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'image_upload_url_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ImageUploadUrlRequest extends ImageUploadUrlRequest {
  @override
  final String contentType;

  factory _$ImageUploadUrlRequest(
          [void Function(ImageUploadUrlRequestBuilder)? updates]) =>
      (ImageUploadUrlRequestBuilder()..update(updates))._build();

  _$ImageUploadUrlRequest._({required this.contentType}) : super._();
  @override
  ImageUploadUrlRequest rebuild(
          void Function(ImageUploadUrlRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ImageUploadUrlRequestBuilder toBuilder() =>
      ImageUploadUrlRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ImageUploadUrlRequest && contentType == other.contentType;
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
    return (newBuiltValueToStringHelper(r'ImageUploadUrlRequest')
          ..add('contentType', contentType))
        .toString();
  }
}

class ImageUploadUrlRequestBuilder
    implements Builder<ImageUploadUrlRequest, ImageUploadUrlRequestBuilder> {
  _$ImageUploadUrlRequest? _$v;

  String? _contentType;
  String? get contentType => _$this._contentType;
  set contentType(String? contentType) => _$this._contentType = contentType;

  ImageUploadUrlRequestBuilder() {
    ImageUploadUrlRequest._defaults(this);
  }

  ImageUploadUrlRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _contentType = $v.contentType;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ImageUploadUrlRequest other) {
    _$v = other as _$ImageUploadUrlRequest;
  }

  @override
  void update(void Function(ImageUploadUrlRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ImageUploadUrlRequest build() => _build();

  _$ImageUploadUrlRequest _build() {
    final _$result = _$v ??
        _$ImageUploadUrlRequest._(
          contentType: BuiltValueNullFieldError.checkNotNull(
              contentType, r'ImageUploadUrlRequest', 'contentType'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
