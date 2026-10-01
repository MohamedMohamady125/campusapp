// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'image_upload_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ImageUploadRequest extends ImageUploadRequest {
  @override
  final String contentType;
  @override
  final String dataBase64;

  factory _$ImageUploadRequest(
          [void Function(ImageUploadRequestBuilder)? updates]) =>
      (ImageUploadRequestBuilder()..update(updates))._build();

  _$ImageUploadRequest._({required this.contentType, required this.dataBase64})
      : super._();
  @override
  ImageUploadRequest rebuild(
          void Function(ImageUploadRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ImageUploadRequestBuilder toBuilder() =>
      ImageUploadRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ImageUploadRequest &&
        contentType == other.contentType &&
        dataBase64 == other.dataBase64;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, contentType.hashCode);
    _$hash = $jc(_$hash, dataBase64.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ImageUploadRequest')
          ..add('contentType', contentType)
          ..add('dataBase64', dataBase64))
        .toString();
  }
}

class ImageUploadRequestBuilder
    implements Builder<ImageUploadRequest, ImageUploadRequestBuilder> {
  _$ImageUploadRequest? _$v;

  String? _contentType;
  String? get contentType => _$this._contentType;
  set contentType(String? contentType) => _$this._contentType = contentType;

  String? _dataBase64;
  String? get dataBase64 => _$this._dataBase64;
  set dataBase64(String? dataBase64) => _$this._dataBase64 = dataBase64;

  ImageUploadRequestBuilder() {
    ImageUploadRequest._defaults(this);
  }

  ImageUploadRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _contentType = $v.contentType;
      _dataBase64 = $v.dataBase64;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ImageUploadRequest other) {
    _$v = other as _$ImageUploadRequest;
  }

  @override
  void update(void Function(ImageUploadRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ImageUploadRequest build() => _build();

  _$ImageUploadRequest _build() {
    final _$result = _$v ??
        _$ImageUploadRequest._(
          contentType: BuiltValueNullFieldError.checkNotNull(
              contentType, r'ImageUploadRequest', 'contentType'),
          dataBase64: BuiltValueNullFieldError.checkNotNull(
              dataBase64, r'ImageUploadRequest', 'dataBase64'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
