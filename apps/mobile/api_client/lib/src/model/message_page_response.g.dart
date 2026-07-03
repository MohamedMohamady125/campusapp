// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message_page_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$MessagePageResponse extends MessagePageResponse {
  @override
  final BuiltList<AppSchemasConversationMessageResponse> items;
  @override
  final String? nextCursor;

  factory _$MessagePageResponse(
          [void Function(MessagePageResponseBuilder)? updates]) =>
      (MessagePageResponseBuilder()..update(updates))._build();

  _$MessagePageResponse._({required this.items, this.nextCursor}) : super._();
  @override
  MessagePageResponse rebuild(
          void Function(MessagePageResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  MessagePageResponseBuilder toBuilder() =>
      MessagePageResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is MessagePageResponse &&
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
    return (newBuiltValueToStringHelper(r'MessagePageResponse')
          ..add('items', items)
          ..add('nextCursor', nextCursor))
        .toString();
  }
}

class MessagePageResponseBuilder
    implements Builder<MessagePageResponse, MessagePageResponseBuilder> {
  _$MessagePageResponse? _$v;

  ListBuilder<AppSchemasConversationMessageResponse>? _items;
  ListBuilder<AppSchemasConversationMessageResponse> get items =>
      _$this._items ??= ListBuilder<AppSchemasConversationMessageResponse>();
  set items(ListBuilder<AppSchemasConversationMessageResponse>? items) =>
      _$this._items = items;

  String? _nextCursor;
  String? get nextCursor => _$this._nextCursor;
  set nextCursor(String? nextCursor) => _$this._nextCursor = nextCursor;

  MessagePageResponseBuilder() {
    MessagePageResponse._defaults(this);
  }

  MessagePageResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _items = $v.items.toBuilder();
      _nextCursor = $v.nextCursor;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(MessagePageResponse other) {
    _$v = other as _$MessagePageResponse;
  }

  @override
  void update(void Function(MessagePageResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  MessagePageResponse build() => _build();

  _$MessagePageResponse _build() {
    _$MessagePageResponse _$result;
    try {
      _$result = _$v ??
          _$MessagePageResponse._(
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
            r'MessagePageResponse', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
