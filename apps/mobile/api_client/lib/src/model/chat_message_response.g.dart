// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_message_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ChatMessageResponse extends ChatMessageResponse {
  @override
  final String body;
  @override
  final String chatId;
  @override
  final DateTime createdAt;
  @override
  final String id;
  @override
  final String senderId;

  factory _$ChatMessageResponse(
          [void Function(ChatMessageResponseBuilder)? updates]) =>
      (ChatMessageResponseBuilder()..update(updates))._build();

  _$ChatMessageResponse._(
      {required this.body,
      required this.chatId,
      required this.createdAt,
      required this.id,
      required this.senderId})
      : super._();
  @override
  ChatMessageResponse rebuild(
          void Function(ChatMessageResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ChatMessageResponseBuilder toBuilder() =>
      ChatMessageResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ChatMessageResponse &&
        body == other.body &&
        chatId == other.chatId &&
        createdAt == other.createdAt &&
        id == other.id &&
        senderId == other.senderId;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, body.hashCode);
    _$hash = $jc(_$hash, chatId.hashCode);
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, senderId.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ChatMessageResponse')
          ..add('body', body)
          ..add('chatId', chatId)
          ..add('createdAt', createdAt)
          ..add('id', id)
          ..add('senderId', senderId))
        .toString();
  }
}

class ChatMessageResponseBuilder
    implements Builder<ChatMessageResponse, ChatMessageResponseBuilder> {
  _$ChatMessageResponse? _$v;

  String? _body;
  String? get body => _$this._body;
  set body(String? body) => _$this._body = body;

  String? _chatId;
  String? get chatId => _$this._chatId;
  set chatId(String? chatId) => _$this._chatId = chatId;

  DateTime? _createdAt;
  DateTime? get createdAt => _$this._createdAt;
  set createdAt(DateTime? createdAt) => _$this._createdAt = createdAt;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _senderId;
  String? get senderId => _$this._senderId;
  set senderId(String? senderId) => _$this._senderId = senderId;

  ChatMessageResponseBuilder() {
    ChatMessageResponse._defaults(this);
  }

  ChatMessageResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _body = $v.body;
      _chatId = $v.chatId;
      _createdAt = $v.createdAt;
      _id = $v.id;
      _senderId = $v.senderId;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ChatMessageResponse other) {
    _$v = other as _$ChatMessageResponse;
  }

  @override
  void update(void Function(ChatMessageResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ChatMessageResponse build() => _build();

  _$ChatMessageResponse _build() {
    final _$result = _$v ??
        _$ChatMessageResponse._(
          body: BuiltValueNullFieldError.checkNotNull(
              body, r'ChatMessageResponse', 'body'),
          chatId: BuiltValueNullFieldError.checkNotNull(
              chatId, r'ChatMessageResponse', 'chatId'),
          createdAt: BuiltValueNullFieldError.checkNotNull(
              createdAt, r'ChatMessageResponse', 'createdAt'),
          id: BuiltValueNullFieldError.checkNotNull(
              id, r'ChatMessageResponse', 'id'),
          senderId: BuiltValueNullFieldError.checkNotNull(
              senderId, r'ChatMessageResponse', 'senderId'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
