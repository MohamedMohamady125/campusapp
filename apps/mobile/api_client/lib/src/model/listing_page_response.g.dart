// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'listing_page_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ListingPageResponse extends ListingPageResponse {
  @override
  final BuiltList<ListingResponse> items;
  @override
  final String? nextCursor;

  factory _$ListingPageResponse(
          [void Function(ListingPageResponseBuilder)? updates]) =>
      (ListingPageResponseBuilder()..update(updates))._build();

  _$ListingPageResponse._({required this.items, this.nextCursor}) : super._();
  @override
  ListingPageResponse rebuild(
          void Function(ListingPageResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ListingPageResponseBuilder toBuilder() =>
      ListingPageResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ListingPageResponse &&
        items == other.items &&
        nextCursor == other.nextCursor;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, items.hashCode);
    _$hash = $jc(_$hash, nextCursor.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ListingPageResponse')
          ..add('items', items)
          ..add('nextCursor', nextCursor))
        .toString();
  }
}

class ListingPageResponseBuilder
    implements Builder<ListingPageResponse, ListingPageResponseBuilder> {
  _$ListingPageResponse? _$v;

  ListBuilder<ListingResponse>? _items;
  ListBuilder<ListingResponse> get items =>
      _$this._items ??= ListBuilder<ListingResponse>();
  set items(ListBuilder<ListingResponse>? items) => _$this._items = items;

  String? _nextCursor;
  String? get nextCursor => _$this._nextCursor;
  set nextCursor(String? nextCursor) => _$this._nextCursor = nextCursor;

  ListingPageResponseBuilder() {
    ListingPageResponse._defaults(this);
  }

  ListingPageResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _items = $v.items.toBuilder();
      _nextCursor = $v.nextCursor;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ListingPageResponse other) {
    _$v = other as _$ListingPageResponse;
  }

  @override
  void update(void Function(ListingPageResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ListingPageResponse build() => _build();

  _$ListingPageResponse _build() {
    _$ListingPageResponse _$result;
    try {
      _$result = _$v ??
          _$ListingPageResponse._(
            items: items.build(),
            nextCursor: nextCursor,
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'items';
        items.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'ListingPageResponse', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
