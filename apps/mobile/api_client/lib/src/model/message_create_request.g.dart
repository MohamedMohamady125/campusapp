// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message_create_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$MessageCreateRequest extends MessageCreateRequest {
  @override
  final String body;

  factory _$MessageCreateRequest(
          [void Function(MessageCreateRequestBuilder)? updates]) =>
      (MessageCreateRequestBuilder()..update(updates))._build();

  _$MessageCreateRequest._({required this.body}) : super._();
  @override
  MessageCreateRequest rebuild(
          void Function(MessageCreateRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  MessageCreateRequestBuilder toBuilder() =>
      MessageCreateRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is MessageCreateRequest && body == other.body;
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
    return (newBuiltValueToStringHelper(r'MessageCreateRequest')
          ..add('body', body))
        .toString();
  }
}

class MessageCreateRequestBuilder
    implements Builder<MessageCreateRequest, MessageCreateRequestBuilder> {
  _$MessageCreateRequest? _$v;

  String? _body;
  String? get body => _$this._body;
  set body(String? body) => _$this._body = body;

  MessageCreateRequestBuilder() {
    MessageCreateRequest._defaults(this);
  }

  MessageCreateRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _body = $v.body;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(MessageCreateRequest other) {
    _$v = other as _$MessageCreateRequest;
  }

  @override
  void update(void Function(MessageCreateRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  MessageCreateRequest build() => _build();

  _$MessageCreateRequest _build() {
    final _$result = _$v ??
        _$MessageCreateRequest._(
          body: BuiltValueNullFieldError.checkNotNull(
              body, r'MessageCreateRequest', 'body'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
