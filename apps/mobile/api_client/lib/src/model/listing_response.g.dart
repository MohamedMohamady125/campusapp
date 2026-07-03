// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'listing_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ListingResponse extends ListingResponse {
  @override
  final ListingCategory category;
  @override
  final ListingCondition condition;
  @override
  final DateTime createdAt;
  @override
  final String description;
  @override
  final DateTime expiresAt;
  @override
  final String id;
  @override
  final BuiltList<ListingImageResponse> images;
  @override
  final int priceCents;
  @override
  final UserPublicResponse seller;
  @override
  final ListingStatus status;
  @override
  final String title;

  factory _$ListingResponse([void Function(ListingResponseBuilder)? updates]) =>
      (ListingResponseBuilder()..update(updates))._build();

  _$ListingResponse._(
      {required this.category,
      required this.condition,
      required this.createdAt,
      required this.description,
      required this.expiresAt,
      required this.id,
      required this.images,
      required this.priceCents,
      required this.seller,
      required this.status,
      required this.title})
      : super._();
  @override
  ListingResponse rebuild(void Function(ListingResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ListingResponseBuilder toBuilder() => ListingResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ListingResponse &&
        category == other.category &&
        condition == other.condition &&
        createdAt == other.createdAt &&
        description == other.description &&
        expiresAt == other.expiresAt &&
        id == other.id &&
        images == other.images &&
        priceCents == other.priceCents &&
        seller == other.seller &&
        status == other.status &&
        title == other.title;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, category.hashCode);
    _$hash = $jc(_$hash, condition.hashCode);
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jc(_$hash, description.hashCode);
    _$hash = $jc(_$hash, expiresAt.hashCode);
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, images.hashCode);
    _$hash = $jc(_$hash, priceCents.hashCode);
    _$hash = $jc(_$hash, seller.hashCode);
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jc(_$hash, title.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ListingResponse')
          ..add('category', category)
          ..add('condition', condition)
          ..add('createdAt', createdAt)
          ..add('description', description)
          ..add('expiresAt', expiresAt)
          ..add('id', id)
          ..add('images', images)
          ..add('priceCents', priceCents)
          ..add('seller', seller)
          ..add('status', status)
          ..add('title', title))
        .toString();
  }
}

class ListingResponseBuilder
    implements Builder<ListingResponse, ListingResponseBuilder> {
  _$ListingResponse? _$v;

  ListingCategory? _category;
  ListingCategory? get category => _$this._category;
  set category(ListingCategory? category) => _$this._category = category;

  ListingCondition? _condition;
  ListingCondition? get condition => _$this._condition;
  set condition(ListingCondition? condition) => _$this._condition = condition;

  DateTime? _createdAt;
  DateTime? get createdAt => _$this._createdAt;
  set createdAt(DateTime? createdAt) => _$this._createdAt = createdAt;

  String? _description;
  String? get description => _$this._description;
  set description(String? description) => _$this._description = description;

  DateTime? _expiresAt;
  DateTime? get expiresAt => _$this._expiresAt;
  set expiresAt(DateTime? expiresAt) => _$this._expiresAt = expiresAt;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  ListBuilder<ListingImageResponse>? _images;
  ListBuilder<ListingImageResponse> get images =>
      _$this._images ??= ListBuilder<ListingImageResponse>();
  set images(ListBuilder<ListingImageResponse>? images) =>
      _$this._images = images;

  int? _priceCents;
  int? get priceCents => _$this._priceCents;
  set priceCents(int? priceCents) => _$this._priceCents = priceCents;

  UserPublicResponseBuilder? _seller;
  UserPublicResponseBuilder get seller =>
      _$this._seller ??= UserPublicResponseBuilder();
  set seller(UserPublicResponseBuilder? seller) => _$this._seller = seller;

  ListingStatus? _status;
  ListingStatus? get status => _$this._status;
  set status(ListingStatus? status) => _$this._status = status;

  String? _title;
  String? get title => _$this._title;
  set title(String? title) => _$this._title = title;

  ListingResponseBuilder() {
    ListingResponse._defaults(this);
  }

  ListingResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _category = $v.category;
      _condition = $v.condition;
      _createdAt = $v.createdAt;
      _description = $v.description;
      _expiresAt = $v.expiresAt;
      _id = $v.id;
      _images = $v.images.toBuilder();
      _priceCents = $v.priceCents;
      _seller = $v.seller.toBuilder();
      _status = $v.status;
      _title = $v.title;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ListingResponse other) {
    _$v = other as _$ListingResponse;
  }

  @override
  void update(void Function(ListingResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ListingResponse build() => _build();

  _$ListingResponse _build() {
    _$ListingResponse _$result;
    try {
      _$result = _$v ??
          _$ListingResponse._(
            category: BuiltValueNullFieldError.checkNotNull(
                category, r'ListingResponse', 'category'),
            condition: BuiltValueNullFieldError.checkNotNull(
                condition, r'ListingResponse', 'condition'),
            createdAt: BuiltValueNullFieldError.checkNotNull(
                createdAt, r'ListingResponse', 'createdAt'),
            description: BuiltValueNullFieldError.checkNotNull(
                description, r'ListingResponse', 'description'),
            expiresAt: BuiltValueNullFieldError.checkNotNull(
                expiresAt, r'ListingResponse', 'expiresAt'),
            id: BuiltValueNullFieldError.checkNotNull(
                id, r'ListingResponse', 'id'),
            images: images.build(),
            priceCents: BuiltValueNullFieldError.checkNotNull(
                priceCents, r'ListingResponse', 'priceCents'),
            seller: seller.build(),
            status: BuiltValueNullFieldError.checkNotNull(
                status, r'ListingResponse', 'status'),
            title: BuiltValueNullFieldError.checkNotNull(
                title, r'ListingResponse', 'title'),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'images';
        images.build();

        _$failedField = 'seller';
        seller.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'ListingResponse', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
