// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_message_page_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ChatMessagePageResponse extends ChatMessagePageResponse {
  @override
  final BuiltList<ChatMessageResponse> items;
  @override
  final String? nextCursor;

  factory _$ChatMessagePageResponse(
          [void Function(ChatMessagePageResponseBuilder)? updates]) =>
      (ChatMessagePageResponseBuilder()..update(updates))._build();

  _$ChatMessagePageResponse._({required this.items, this.nextCursor})
      : super._();
  @override
  ChatMessagePageResponse rebuild(
          void Function(ChatMessagePageResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ChatMessagePageResponseBuilder toBuilder() =>
      ChatMessagePageResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ChatMessagePageResponse &&
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
    return (newBuiltValueToStringHelper(r'ChatMessagePageResponse')
          ..add('items', items)
          ..add('nextCursor', nextCursor))
        .toString();
  }
}

class ChatMessagePageResponseBuilder
    implements
        Builder<ChatMessagePageResponse, ChatMessagePageResponseBuilder> {
  _$ChatMessagePageResponse? _$v;

  ListBuilder<ChatMessageResponse>? _items;
  ListBuilder<ChatMessageResponse> get items =>
      _$this._items ??= ListBuilder<ChatMessageResponse>();
  set items(ListBuilder<ChatMessageResponse>? items) => _$this._items = items;

  String? _nextCursor;
  String? get nextCursor => _$this._nextCursor;
  set nextCursor(String? nextCursor) => _$this._nextCursor = nextCursor;

  ChatMessagePageResponseBuilder() {
    ChatMessagePageResponse._defaults(this);
  }

  ChatMessagePageResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _items = $v.items.toBuilder();
      _nextCursor = $v.nextCursor;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ChatMessagePageResponse other) {
    _$v = other as _$ChatMessagePageResponse;
  }

  @override
  void update(void Function(ChatMessagePageResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ChatMessagePageResponse build() => _build();

  _$ChatMessagePageResponse _build() {
    _$ChatMessagePageResponse _$result;
    try {
      _$result = _$v ??
          _$ChatMessagePageResponse._(
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
            r'ChatMessagePageResponse', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
