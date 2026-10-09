// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'avatar_upload_url_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$AvatarUploadUrlResponse extends AvatarUploadUrlResponse {
  @override
  final BuiltMap<String, String> fields;
  @override
  final String key;
  @override
  final String uploadUrl;

  factory _$AvatarUploadUrlResponse(
          [void Function(AvatarUploadUrlResponseBuilder)? updates]) =>
      (AvatarUploadUrlResponseBuilder()..update(updates))._build();

  _$AvatarUploadUrlResponse._(
      {required this.fields, required this.key, required this.uploadUrl})
      : super._();
  @override
  AvatarUploadUrlResponse rebuild(
          void Function(AvatarUploadUrlResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  AvatarUploadUrlResponseBuilder toBuilder() =>
      AvatarUploadUrlResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AvatarUploadUrlResponse &&
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
    return (newBuiltValueToStringHelper(r'AvatarUploadUrlResponse')
          ..add('fields', fields)
          ..add('key', key)
          ..add('uploadUrl', uploadUrl))
        .toString();
  }
}

class AvatarUploadUrlResponseBuilder
    implements
        Builder<AvatarUploadUrlResponse, AvatarUploadUrlResponseBuilder> {
  _$AvatarUploadUrlResponse? _$v;

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

  AvatarUploadUrlResponseBuilder() {
    AvatarUploadUrlResponse._defaults(this);
  }

  AvatarUploadUrlResponseBuilder get _$this {
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
  void replace(AvatarUploadUrlResponse other) {
    _$v = other as _$AvatarUploadUrlResponse;
  }

  @override
  void update(void Function(AvatarUploadUrlResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AvatarUploadUrlResponse build() => _build();

  _$AvatarUploadUrlResponse _build() {
    _$AvatarUploadUrlResponse _$result;
    try {
      _$result = _$v ??
          _$AvatarUploadUrlResponse._(
            fields: fields.build(),
            key: BuiltValueNullFieldError.checkNotNull(
                key, r'AvatarUploadUrlResponse', 'key'),
            uploadUrl: BuiltValueNullFieldError.checkNotNull(
                uploadUrl, r'AvatarUploadUrlResponse', 'uploadUrl'),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'fields';
        fields.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'AvatarUploadUrlResponse', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
