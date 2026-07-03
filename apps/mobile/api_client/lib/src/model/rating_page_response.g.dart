// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rating_page_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$RatingPageResponse extends RatingPageResponse {
  @override
  final BuiltList<RatingResponse> items;
  @override
  final String? nextCursor;

  factory _$RatingPageResponse(
          [void Function(RatingPageResponseBuilder)? updates]) =>
      (RatingPageResponseBuilder()..update(updates))._build();

  _$RatingPageResponse._({required this.items, this.nextCursor}) : super._();
  @override
  RatingPageResponse rebuild(
          void Function(RatingPageResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  RatingPageResponseBuilder toBuilder() =>
      RatingPageResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is RatingPageResponse &&
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
    return (newBuiltValueToStringHelper(r'RatingPageResponse')
          ..add('items', items)
          ..add('nextCursor', nextCursor))
        .toString();
  }
}

class RatingPageResponseBuilder
    implements Builder<RatingPageResponse, RatingPageResponseBuilder> {
  _$RatingPageResponse? _$v;

  ListBuilder<RatingResponse>? _items;
  ListBuilder<RatingResponse> get items =>
      _$this._items ??= ListBuilder<RatingResponse>();
  set items(ListBuilder<RatingResponse>? items) => _$this._items = items;

  String? _nextCursor;
  String? get nextCursor => _$this._nextCursor;
  set nextCursor(String? nextCursor) => _$this._nextCursor = nextCursor;

  RatingPageResponseBuilder() {
    RatingPageResponse._defaults(this);
  }

  RatingPageResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _items = $v.items.toBuilder();
      _nextCursor = $v.nextCursor;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(RatingPageResponse other) {
    _$v = other as _$RatingPageResponse;
  }

  @override
  void update(void Function(RatingPageResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  RatingPageResponse build() => _build();

  _$RatingPageResponse _build() {
    _$RatingPageResponse _$result;
    try {
      _$result = _$v ??
          _$RatingPageResponse._(
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
            r'RatingPageResponse', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
