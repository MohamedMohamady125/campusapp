// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_message_create_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ChatMessageCreateRequest extends ChatMessageCreateRequest {
  @override
  final String body;

  factory _$ChatMessageCreateRequest(
          [void Function(ChatMessageCreateRequestBuilder)? updates]) =>
      (ChatMessageCreateRequestBuilder()..update(updates))._build();

  _$ChatMessageCreateRequest._({required this.body}) : super._();
  @override
  ChatMessageCreateRequest rebuild(
          void Function(ChatMessageCreateRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ChatMessageCreateRequestBuilder toBuilder() =>
      ChatMessageCreateRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ChatMessageCreateRequest && body == other.body;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, body.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ChatMessageCreateRequest')
          ..add('body', body))
        .toString();
  }
}

class ChatMessageCreateRequestBuilder
    implements
        Builder<ChatMessageCreateRequest, ChatMessageCreateRequestBuilder> {
  _$ChatMessageCreateRequest? _$v;

  String? _body;
  String? get body => _$this._body;
  set body(String? body) => _$this._body = body;

  ChatMessageCreateRequestBuilder() {
    ChatMessageCreateRequest._defaults(this);
  }

  ChatMessageCreateRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _body = $v.body;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ChatMessageCreateRequest other) {
    _$v = other as _$ChatMessageCreateRequest;
  }

  @override
  void update(void Function(ChatMessageCreateRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ChatMessageCreateRequest build() => _build();

  _$ChatMessageCreateRequest _build() {
    final _$result = _$v ??
        _$ChatMessageCreateRequest._(
          body: BuiltValueNullFieldError.checkNotNull(
              body, r'ChatMessageCreateRequest', 'body'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
