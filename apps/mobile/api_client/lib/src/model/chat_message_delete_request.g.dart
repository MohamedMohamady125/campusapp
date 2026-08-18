// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_message_delete_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ChatMessageDeleteRequest extends ChatMessageDeleteRequest {
  @override
  final String reason;

  factory _$ChatMessageDeleteRequest(
          [void Function(ChatMessageDeleteRequestBuilder)? updates]) =>
      (ChatMessageDeleteRequestBuilder()..update(updates))._build();

  _$ChatMessageDeleteRequest._({required this.reason}) : super._();
  @override
  ChatMessageDeleteRequest rebuild(
          void Function(ChatMessageDeleteRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ChatMessageDeleteRequestBuilder toBuilder() =>
      ChatMessageDeleteRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ChatMessageDeleteRequest && reason == other.reason;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, reason.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ChatMessageDeleteRequest')
          ..add('reason', reason))
        .toString();
  }
}

class ChatMessageDeleteRequestBuilder
    implements
        Builder<ChatMessageDeleteRequest, ChatMessageDeleteRequestBuilder> {
  _$ChatMessageDeleteRequest? _$v;

  String? _reason;
  String? get reason => _$this._reason;
  set reason(String? reason) => _$this._reason = reason;

  ChatMessageDeleteRequestBuilder() {
    ChatMessageDeleteRequest._defaults(this);
  }

  ChatMessageDeleteRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _reason = $v.reason;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ChatMessageDeleteRequest other) {
    _$v = other as _$ChatMessageDeleteRequest;
  }

  @override
  void update(void Function(ChatMessageDeleteRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ChatMessageDeleteRequest build() => _build();

  _$ChatMessageDeleteRequest _build() {
    final _$result = _$v ??
        _$ChatMessageDeleteRequest._(
          reason: BuiltValueNullFieldError.checkNotNull(
              reason, r'ChatMessageDeleteRequest', 'reason'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
