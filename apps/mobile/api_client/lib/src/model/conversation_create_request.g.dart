// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'conversation_create_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ConversationCreateRequest extends ConversationCreateRequest {
  @override
  final String? contextId;
  @override
  final ConversationContext? contextType;
  @override
  final String recipientId;

  factory _$ConversationCreateRequest(
          [void Function(ConversationCreateRequestBuilder)? updates]) =>
      (ConversationCreateRequestBuilder()..update(updates))._build();

  _$ConversationCreateRequest._(
      {this.contextId, this.contextType, required this.recipientId})
      : super._();
  @override
  ConversationCreateRequest rebuild(
          void Function(ConversationCreateRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ConversationCreateRequestBuilder toBuilder() =>
      ConversationCreateRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ConversationCreateRequest &&
        contextId == other.contextId &&
        contextType == other.contextType &&
        recipientId == other.recipientId;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, contextId.hashCode);
    _$hash = $jc(_$hash, contextType.hashCode);
    _$hash = $jc(_$hash, recipientId.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ConversationCreateRequest')
          ..add('contextId', contextId)
          ..add('contextType', contextType)
          ..add('recipientId', recipientId))
        .toString();
  }
}

class ConversationCreateRequestBuilder
    implements
        Builder<ConversationCreateRequest, ConversationCreateRequestBuilder> {
  _$ConversationCreateRequest? _$v;

  String? _contextId;
  String? get contextId => _$this._contextId;
  set contextId(String? contextId) => _$this._contextId = contextId;

  ConversationContext? _contextType;
  ConversationContext? get contextType => _$this._contextType;
  set contextType(ConversationContext? contextType) =>
      _$this._contextType = contextType;

  String? _recipientId;
  String? get recipientId => _$this._recipientId;
  set recipientId(String? recipientId) => _$this._recipientId = recipientId;

  ConversationCreateRequestBuilder() {
    ConversationCreateRequest._defaults(this);
  }

  ConversationCreateRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _contextId = $v.contextId;
      _contextType = $v.contextType;
      _recipientId = $v.recipientId;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ConversationCreateRequest other) {
    _$v = other as _$ConversationCreateRequest;
  }

  @override
  void update(void Function(ConversationCreateRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ConversationCreateRequest build() => _build();

  _$ConversationCreateRequest _build() {
    final _$result = _$v ??
        _$ConversationCreateRequest._(
          contextId: contextId,
          contextType: contextType,
          recipientId: BuiltValueNullFieldError.checkNotNull(
              recipientId, r'ConversationCreateRequest', 'recipientId'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
