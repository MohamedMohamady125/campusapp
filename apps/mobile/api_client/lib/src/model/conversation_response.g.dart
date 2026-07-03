// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'conversation_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ConversationResponse extends ConversationResponse {
  @override
  final String? contextId;
  @override
  final ConversationContext contextType;
  @override
  final DateTime createdAt;
  @override
  final String id;
  @override
  final BuiltList<UserPublicResponse> participants;

  factory _$ConversationResponse(
          [void Function(ConversationResponseBuilder)? updates]) =>
      (ConversationResponseBuilder()..update(updates))._build();

  _$ConversationResponse._(
      {this.contextId,
      required this.contextType,
      required this.createdAt,
      required this.id,
      required this.participants})
      : super._();
  @override
  ConversationResponse rebuild(
          void Function(ConversationResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ConversationResponseBuilder toBuilder() =>
      ConversationResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ConversationResponse &&
        contextId == other.contextId &&
        contextType == other.contextType &&
        createdAt == other.createdAt &&
        id == other.id &&
        participants == other.participants;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, contextId.hashCode);
    _$hash = $jc(_$hash, contextType.hashCode);
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, participants.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ConversationResponse')
          ..add('contextId', contextId)
          ..add('contextType', contextType)
          ..add('createdAt', createdAt)
          ..add('id', id)
          ..add('participants', participants))
        .toString();
  }
}

class ConversationResponseBuilder
    implements Builder<ConversationResponse, ConversationResponseBuilder> {
  _$ConversationResponse? _$v;

  String? _contextId;
  String? get contextId => _$this._contextId;
  set contextId(String? contextId) => _$this._contextId = contextId;

  ConversationContext? _contextType;
  ConversationContext? get contextType => _$this._contextType;
  set contextType(ConversationContext? contextType) =>
      _$this._contextType = contextType;

  DateTime? _createdAt;
  DateTime? get createdAt => _$this._createdAt;
  set createdAt(DateTime? createdAt) => _$this._createdAt = createdAt;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  ListBuilder<UserPublicResponse>? _participants;
  ListBuilder<UserPublicResponse> get participants =>
      _$this._participants ??= ListBuilder<UserPublicResponse>();
  set participants(ListBuilder<UserPublicResponse>? participants) =>
      _$this._participants = participants;

  ConversationResponseBuilder() {
    ConversationResponse._defaults(this);
  }

  ConversationResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _contextId = $v.contextId;
      _contextType = $v.contextType;
      _createdAt = $v.createdAt;
      _id = $v.id;
      _participants = $v.participants.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ConversationResponse other) {
    _$v = other as _$ConversationResponse;
  }

  @override
  void update(void Function(ConversationResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ConversationResponse build() => _build();

  _$ConversationResponse _build() {
    _$ConversationResponse _$result;
    try {
      _$result = _$v ??
          _$ConversationResponse._(
            contextId: contextId,
            contextType: BuiltValueNullFieldError.checkNotNull(
                contextType, r'ConversationResponse', 'contextType'),
            createdAt: BuiltValueNullFieldError.checkNotNull(
                createdAt, r'ConversationResponse', 'createdAt'),
            id: BuiltValueNullFieldError.checkNotNull(
                id, r'ConversationResponse', 'id'),
            participants: participants.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'participants';
        participants.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'ConversationResponse', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
