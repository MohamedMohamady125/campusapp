// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'listing_image_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ListingImageResponse extends ListingImageResponse {
  @override
  final String id;
  @override
  final ModerationStatus moderationStatus;
  @override
  final int order;
  @override
  final String s3Key;

  factory _$ListingImageResponse(
          [void Function(ListingImageResponseBuilder)? updates]) =>
      (ListingImageResponseBuilder()..update(updates))._build();

  _$ListingImageResponse._(
      {required this.id,
      required this.moderationStatus,
      required this.order,
      required this.s3Key})
      : super._();
  @override
  ListingImageResponse rebuild(
          void Function(ListingImageResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ListingImageResponseBuilder toBuilder() =>
      ListingImageResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ListingImageResponse &&
        id == other.id &&
        moderationStatus == other.moderationStatus &&
        order == other.order &&
        s3Key == other.s3Key;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, moderationStatus.hashCode);
    _$hash = $jc(_$hash, order.hashCode);
    _$hash = $jc(_$hash, s3Key.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ListingImageResponse')
          ..add('id', id)
          ..add('moderationStatus', moderationStatus)
          ..add('order', order)
          ..add('s3Key', s3Key))
        .toString();
  }
}

class ListingImageResponseBuilder
    implements Builder<ListingImageResponse, ListingImageResponseBuilder> {
  _$ListingImageResponse? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  ModerationStatus? _moderationStatus;
  ModerationStatus? get moderationStatus => _$this._moderationStatus;
  set moderationStatus(ModerationStatus? moderationStatus) =>
      _$this._moderationStatus = moderationStatus;

  int? _order;
  int? get order => _$this._order;
  set order(int? order) => _$this._order = order;

  String? _s3Key;
  String? get s3Key => _$this._s3Key;
  set s3Key(String? s3Key) => _$this._s3Key = s3Key;

  ListingImageResponseBuilder() {
    ListingImageResponse._defaults(this);
  }

  ListingImageResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _moderationStatus = $v.moderationStatus;
      _order = $v.order;
      _s3Key = $v.s3Key;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ListingImageResponse other) {
    _$v = other as _$ListingImageResponse;
  }

  @override
  void update(void Function(ListingImageResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ListingImageResponse build() => _build();

  _$ListingImageResponse _build() {
    final _$result = _$v ??
        _$ListingImageResponse._(
          id: BuiltValueNullFieldError.checkNotNull(
              id, r'ListingImageResponse', 'id'),
          moderationStatus: BuiltValueNullFieldError.checkNotNull(
              moderationStatus, r'ListingImageResponse', 'moderationStatus'),
          order: BuiltValueNullFieldError.checkNotNull(
              order, r'ListingImageResponse', 'order'),
          s3Key: BuiltValueNullFieldError.checkNotNull(
              s3Key, r'ListingImageResponse', 's3Key'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
