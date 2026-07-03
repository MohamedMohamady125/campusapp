// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'listing_update_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ListingUpdateRequest extends ListingUpdateRequest {
  @override
  final ListingCategory? category;
  @override
  final ListingCondition? condition;
  @override
  final String? description;
  @override
  final int? priceCents;
  @override
  final String? title;

  factory _$ListingUpdateRequest(
          [void Function(ListingUpdateRequestBuilder)? updates]) =>
      (ListingUpdateRequestBuilder()..update(updates))._build();

  _$ListingUpdateRequest._(
      {this.category,
      this.condition,
      this.description,
      this.priceCents,
      this.title})
      : super._();
  @override
  ListingUpdateRequest rebuild(
          void Function(ListingUpdateRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ListingUpdateRequestBuilder toBuilder() =>
      ListingUpdateRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ListingUpdateRequest &&
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
    return (newBuiltValueToStringHelper(r'ListingUpdateRequest')
          ..add('category', category)
          ..add('condition', condition)
          ..add('description', description)
          ..add('priceCents', priceCents)
          ..add('title', title))
        .toString();
  }
}

class ListingUpdateRequestBuilder
    implements Builder<ListingUpdateRequest, ListingUpdateRequestBuilder> {
  _$ListingUpdateRequest? _$v;

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

  ListingUpdateRequestBuilder() {
    ListingUpdateRequest._defaults(this);
  }

  ListingUpdateRequestBuilder get _$this {
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
  void replace(ListingUpdateRequest other) {
    _$v = other as _$ListingUpdateRequest;
  }

  @override
  void update(void Function(ListingUpdateRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ListingUpdateRequest build() => _build();

  _$ListingUpdateRequest _build() {
    final _$result = _$v ??
        _$ListingUpdateRequest._(
          category: category,
          condition: condition,
          description: description,
          priceCents: priceCents,
          title: title,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
