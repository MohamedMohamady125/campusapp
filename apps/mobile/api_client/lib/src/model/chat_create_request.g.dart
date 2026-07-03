// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_create_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ChatCreateRequest extends ChatCreateRequest {
  @override
  final String? description;
  @override
  final int? memberCap;
  @override
  final String name;
  @override
  final ChatVisibility? visibility;

  factory _$ChatCreateRequest(
          [void Function(ChatCreateRequestBuilder)? updates]) =>
      (ChatCreateRequestBuilder()..update(updates))._build();

  _$ChatCreateRequest._(
      {this.description, this.memberCap, required this.name, this.visibility})
      : super._();
  @override
  ChatCreateRequest rebuild(void Function(ChatCreateRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ChatCreateRequestBuilder toBuilder() =>
      ChatCreateRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ChatCreateRequest &&
        description == other.description &&
        memberCap == other.memberCap &&
        name == other.name &&
        visibility == other.visibility;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, description.hashCode);
    _$hash = $jc(_$hash, memberCap.hashCode);
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, visibility.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ChatCreateRequest')
          ..add('description', description)
          ..add('memberCap', memberCap)
          ..add('name', name)
          ..add('visibility', visibility))
        .toString();
  }
}

class ChatCreateRequestBuilder
    implements Builder<ChatCreateRequest, ChatCreateRequestBuilder> {
  _$ChatCreateRequest? _$v;

  String? _description;
  String? get description => _$this._description;
  set description(String? description) => _$this._description = description;

  int? _memberCap;
  int? get memberCap => _$this._memberCap;
  set memberCap(int? memberCap) => _$this._memberCap = memberCap;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  ChatVisibility? _visibility;
  ChatVisibility? get visibility => _$this._visibility;
  set visibility(ChatVisibility? visibility) => _$this._visibility = visibility;

  ChatCreateRequestBuilder() {
    ChatCreateRequest._defaults(this);
  }

  ChatCreateRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _description = $v.description;
      _memberCap = $v.memberCap;
      _name = $v.name;
      _visibility = $v.visibility;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ChatCreateRequest other) {
    _$v = other as _$ChatCreateRequest;
  }

  @override
  void update(void Function(ChatCreateRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ChatCreateRequest build() => _build();

  _$ChatCreateRequest _build() {
    final _$result = _$v ??
        _$ChatCreateRequest._(
          description: description,
          memberCap: memberCap,
          name: BuiltValueNullFieldError.checkNotNull(
              name, r'ChatCreateRequest', 'name'),
          visibility: visibility,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
