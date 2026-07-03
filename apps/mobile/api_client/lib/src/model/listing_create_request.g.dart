// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'listing_create_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ListingCreateRequest extends ListingCreateRequest {
  @override
  final ListingCategory category;
  @override
  final ListingCondition condition;
  @override
  final String description;
  @override
  final int priceCents;
  @override
  final String title;

  factory _$ListingCreateRequest(
          [void Function(ListingCreateRequestBuilder)? updates]) =>
      (ListingCreateRequestBuilder()..update(updates))._build();

  _$ListingCreateRequest._(
      {required this.category,
      required this.condition,
      required this.description,
      required this.priceCents,
      required this.title})
      : super._();
  @override
  ListingCreateRequest rebuild(
          void Function(ListingCreateRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ListingCreateRequestBuilder toBuilder() =>
      ListingCreateRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ListingCreateRequest &&
        category == other.category &&
        condition == other.condition &&
        description == other.description &&
        priceCents == other.priceCents &&
        title == other.title;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, category.hashCode);
    _$hash = $jc(_$hash, condition.hashCode);
    _$hash = $jc(_$hash, description.hashCode);
    _$hash = $jc(_$hash, priceCents.hashCode);
    _$hash = $jc(_$hash, title.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ListingCreateRequest')
          ..add('category', category)
          ..add('condition', condition)
          ..add('description', description)
          ..add('priceCents', priceCents)
          ..add('title', title))
        .toString();
  }
}

class ListingCreateRequestBuilder
    implements Builder<ListingCreateRequest, ListingCreateRequestBuilder> {
  _$ListingCreateRequest? _$v;

  ListingCategory? _category;
  ListingCategory? get category => _$this._category;
  set category(ListingCategory? category) => _$this._category = category;

  ListingCondition? _condition;
  ListingCondition? get condition => _$this._condition;
  set condition(ListingCondition? condition) => _$this._condition = condition;

  String? _description;
  String? get description => _$this._description;
  set description(String? description) => _$this._description = description;

  int? _priceCents;
  int? get priceCents => _$this._priceCents;
  set priceCents(int? priceCents) => _$this._priceCents = priceCents;

  String? _title;
  String? get title => _$this._title;
  set title(String? title) => _$this._title = title;

  ListingCreateRequestBuilder() {
    ListingCreateRequest._defaults(this);
  }

  ListingCreateRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _category = $v.category;
      _condition = $v.condition;
      _description = $v.description;
      _priceCents = $v.priceCents;
      _title = $v.title;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ListingCreateRequest other) {
    _$v = other as _$ListingCreateRequest;
  }

  @override
  void update(void Function(ListingCreateRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ListingCreateRequest build() => _build();

  _$ListingCreateRequest _build() {
    final _$result = _$v ??
        _$ListingCreateRequest._(
          category: BuiltValueNullFieldError.checkNotNull(
              category, r'ListingCreateRequest', 'category'),
          condition: BuiltValueNullFieldError.checkNotNull(
              condition, r'ListingCreateRequest', 'condition'),
          description: BuiltValueNullFieldError.checkNotNull(
              description, r'ListingCreateRequest', 'description'),
          priceCents: BuiltValueNullFieldError.checkNotNull(
              priceCents, r'ListingCreateRequest', 'priceCents'),
          title: BuiltValueNullFieldError.checkNotNull(
              title, r'ListingCreateRequest', 'title'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
