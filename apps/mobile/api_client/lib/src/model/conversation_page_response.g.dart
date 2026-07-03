// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'conversation_page_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ConversationPageResponse extends ConversationPageResponse {
  @override
  final BuiltList<ConversationResponse> items;
  @override
  final String? nextCursor;

  factory _$ConversationPageResponse(
          [void Function(ConversationPageResponseBuilder)? updates]) =>
      (ConversationPageResponseBuilder()..update(updates))._build();

  _$ConversationPageResponse._({required this.items, this.nextCursor})
      : super._();
  @override
  ConversationPageResponse rebuild(
          void Function(ConversationPageResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ConversationPageResponseBuilder toBuilder() =>
      ConversationPageResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ConversationPageResponse &&
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
    return (newBuiltValueToStringHelper(r'ConversationPageResponse')
          ..add('items', items)
          ..add('nextCursor', nextCursor))
        .toString();
  }
}

class ConversationPageResponseBuilder
    implements
        Builder<ConversationPageResponse, ConversationPageResponseBuilder> {
  _$ConversationPageResponse? _$v;

  ListBuilder<ConversationResponse>? _items;
  ListBuilder<ConversationResponse> get items =>
      _$this._items ??= ListBuilder<ConversationResponse>();
  set items(ListBuilder<ConversationResponse>? items) => _$this._items = items;

  String? _nextCursor;
  String? get nextCursor => _$this._nextCursor;
  set nextCursor(String? nextCursor) => _$this._nextCursor = nextCursor;

  ConversationPageResponseBuilder() {
    ConversationPageResponse._defaults(this);
  }

  ConversationPageResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _items = $v.items.toBuilder();
      _nextCursor = $v.nextCursor;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ConversationPageResponse other) {
    _$v = other as _$ConversationPageResponse;
  }

  @override
  void update(void Function(ConversationPageResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ConversationPageResponse build() => _build();

  _$ConversationPageResponse _build() {
    _$ConversationPageResponse _$result;
    try {
      _$result = _$v ??
          _$ConversationPageResponse._(
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
            r'ConversationPageResponse', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
