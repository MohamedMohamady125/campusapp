// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'avatar_upload_url_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$AvatarUploadUrlRequest extends AvatarUploadUrlRequest {
  @override
  final String contentType;

  factory _$AvatarUploadUrlRequest(
          [void Function(AvatarUploadUrlRequestBuilder)? updates]) =>
      (AvatarUploadUrlRequestBuilder()..update(updates))._build();

  _$AvatarUploadUrlRequest._({required this.contentType}) : super._();
  @override
  AvatarUploadUrlRequest rebuild(
          void Function(AvatarUploadUrlRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  AvatarUploadUrlRequestBuilder toBuilder() =>
      AvatarUploadUrlRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AvatarUploadUrlRequest && contentType == other.contentType;
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
    return (newBuiltValueToStringHelper(r'AvatarUploadUrlRequest')
          ..add('contentType', contentType))
        .toString();
  }
}

class AvatarUploadUrlRequestBuilder
    implements Builder<AvatarUploadUrlRequest, AvatarUploadUrlRequestBuilder> {
  _$AvatarUploadUrlRequest? _$v;

  String? _contentType;
  String? get contentType => _$this._contentType;
  set contentType(String? contentType) => _$this._contentType = contentType;

  AvatarUploadUrlRequestBuilder() {
    AvatarUploadUrlRequest._defaults(this);
  }

  AvatarUploadUrlRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _contentType = $v.contentType;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(AvatarUploadUrlRequest other) {
    _$v = other as _$AvatarUploadUrlRequest;
  }

  @override
  void update(void Function(AvatarUploadUrlRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AvatarUploadUrlRequest build() => _build();

  _$AvatarUploadUrlRequest _build() {
    final _$result = _$v ??
        _$AvatarUploadUrlRequest._(
          contentType: BuiltValueNullFieldError.checkNotNull(
              contentType, r'AvatarUploadUrlRequest', 'contentType'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
