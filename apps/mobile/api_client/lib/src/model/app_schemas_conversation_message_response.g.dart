// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_schemas_conversation_message_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$AppSchemasConversationMessageResponse
    extends AppSchemasConversationMessageResponse {
  @override
  final String body;
  @override
  final String conversationId;
  @override
  final DateTime createdAt;
  @override
  final String id;
  @override
  final DateTime? readAt;
  @override
  final String senderId;

  factory _$AppSchemasConversationMessageResponse(
          [void Function(AppSchemasConversationMessageResponseBuilder)?
              updates]) =>
      (AppSchemasConversationMessageResponseBuilder()..update(updates))
          ._build();

  _$AppSchemasConversationMessageResponse._(
      {required this.body,
      required this.conversationId,
      required this.createdAt,
      required this.id,
      this.readAt,
      required this.senderId})
      : super._();
  @override
  AppSchemasConversationMessageResponse rebuild(
          void Function(AppSchemasConversationMessageResponseBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  AppSchemasConversationMessageResponseBuilder toBuilder() =>
      AppSchemasConversationMessageResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AppSchemasConversationMessageResponse &&
        body == other.body &&
        conversationId == other.conversationId &&
        createdAt == other.createdAt &&
        id == other.id &&
        readAt == other.readAt &&
        senderId == other.senderId;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, body.hashCode);
    _$hash = $jc(_$hash, conversationId.hashCode);
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, readAt.hashCode);
    _$hash = $jc(_$hash, senderId.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'AppSchemasConversationMessageResponse')
          ..add('body', body)
          ..add('conversationId', conversationId)
          ..add('createdAt', createdAt)
          ..add('id', id)
          ..add('readAt', readAt)
          ..add('senderId', senderId))
        .toString();
  }
}

class AppSchemasConversationMessageResponseBuilder
    implements
        Builder<AppSchemasConversationMessageResponse,
            AppSchemasConversationMessageResponseBuilder> {
  _$AppSchemasConversationMessageResponse? _$v;

  String? _body;
  String? get body => _$this._body;
  set body(String? body) => _$this._body = body;

  String? _conversationId;
  String? get conversationId => _$this._conversationId;
  set conversationId(String? conversationId) =>
      _$this._conversationId = conversationId;

  DateTime? _createdAt;
  DateTime? get createdAt => _$this._createdAt;
  set createdAt(DateTime? createdAt) => _$this._createdAt = createdAt;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  DateTime? _readAt;
  DateTime? get readAt => _$this._readAt;
  set readAt(DateTime? readAt) => _$this._readAt = readAt;

  String? _senderId;
  String? get senderId => _$this._senderId;
  set senderId(String? senderId) => _$this._senderId = senderId;

  AppSchemasConversationMessageResponseBuilder() {
    AppSchemasConversationMessageResponse._defaults(this);
  }

  AppSchemasConversationMessageResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _body = $v.body;
      _conversationId = $v.conversationId;
      _createdAt = $v.createdAt;
      _id = $v.id;
      _readAt = $v.readAt;
      _senderId = $v.senderId;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(AppSchemasConversationMessageResponse other) {
    _$v = other as _$AppSchemasConversationMessageResponse;
  }

  @override
  void update(
      void Function(AppSchemasConversationMessageResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AppSchemasConversationMessageResponse build() => _build();

  _$AppSchemasConversationMessageResponse _build() {
    final _$result = _$v ??
        _$AppSchemasConversationMessageResponse._(
          body: BuiltValueNullFieldError.checkNotNull(
              body, r'AppSchemasConversationMessageResponse', 'body'),
          conversationId: BuiltValueNullFieldError.checkNotNull(conversationId,
              r'AppSchemasConversationMessageResponse', 'conversationId'),
          createdAt: BuiltValueNullFieldError.checkNotNull(
              createdAt, r'AppSchemasConversationMessageResponse', 'createdAt'),
          id: BuiltValueNullFieldError.checkNotNull(
              id, r'AppSchemasConversationMessageResponse', 'id'),
          readAt: readAt,
          senderId: BuiltValueNullFieldError.checkNotNull(
              senderId, r'AppSchemasConversationMessageResponse', 'senderId'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
