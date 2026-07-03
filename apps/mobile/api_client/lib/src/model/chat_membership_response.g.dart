// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_membership_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ChatMembershipResponse extends ChatMembershipResponse {
  @override
  final DateTime? bannedAt;
  @override
  final String chatId;
  @override
  final DateTime? mutedUntil;
  @override
  final ChatRole role;
  @override
  final String userId;

  factory _$ChatMembershipResponse(
          [void Function(ChatMembershipResponseBuilder)? updates]) =>
      (ChatMembershipResponseBuilder()..update(updates))._build();

  _$ChatMembershipResponse._(
      {this.bannedAt,
      required this.chatId,
      this.mutedUntil,
      required this.role,
      required this.userId})
      : super._();
  @override
  ChatMembershipResponse rebuild(
          void Function(ChatMembershipResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ChatMembershipResponseBuilder toBuilder() =>
      ChatMembershipResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ChatMembershipResponse &&
        bannedAt == other.bannedAt &&
        chatId == other.chatId &&
        mutedUntil == other.mutedUntil &&
        role == other.role &&
        userId == other.userId;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, bannedAt.hashCode);
    _$hash = $jc(_$hash, chatId.hashCode);
    _$hash = $jc(_$hash, mutedUntil.hashCode);
    _$hash = $jc(_$hash, role.hashCode);
    _$hash = $jc(_$hash, userId.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ChatMembershipResponse')
          ..add('bannedAt', bannedAt)
          ..add('chatId', chatId)
          ..add('mutedUntil', mutedUntil)
          ..add('role', role)
          ..add('userId', userId))
        .toString();
  }
}

class ChatMembershipResponseBuilder
    implements Builder<ChatMembershipResponse, ChatMembershipResponseBuilder> {
  _$ChatMembershipResponse? _$v;

  DateTime? _bannedAt;
  DateTime? get bannedAt => _$this._bannedAt;
  set bannedAt(DateTime? bannedAt) => _$this._bannedAt = bannedAt;

  String? _chatId;
  String? get chatId => _$this._chatId;
  set chatId(String? chatId) => _$this._chatId = chatId;

  DateTime? _mutedUntil;
  DateTime? get mutedUntil => _$this._mutedUntil;
  set mutedUntil(DateTime? mutedUntil) => _$this._mutedUntil = mutedUntil;

  ChatRole? _role;
  ChatRole? get role => _$this._role;
  set role(ChatRole? role) => _$this._role = role;

  String? _userId;
  String? get userId => _$this._userId;
  set userId(String? userId) => _$this._userId = userId;

  ChatMembershipResponseBuilder() {
    ChatMembershipResponse._defaults(this);
  }

  ChatMembershipResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _bannedAt = $v.bannedAt;
      _chatId = $v.chatId;
      _mutedUntil = $v.mutedUntil;
      _role = $v.role;
      _userId = $v.userId;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ChatMembershipResponse other) {
    _$v = other as _$ChatMembershipResponse;
  }

  @override
  void update(void Function(ChatMembershipResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ChatMembershipResponse build() => _build();

  _$ChatMembershipResponse _build() {
    final _$result = _$v ??
        _$ChatMembershipResponse._(
          bannedAt: bannedAt,
          chatId: BuiltValueNullFieldError.checkNotNull(
              chatId, r'ChatMembershipResponse', 'chatId'),
          mutedUntil: mutedUntil,
          role: BuiltValueNullFieldError.checkNotNull(
              role, r'ChatMembershipResponse', 'role'),
          userId: BuiltValueNullFieldError.checkNotNull(
              userId, r'ChatMembershipResponse', 'userId'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
