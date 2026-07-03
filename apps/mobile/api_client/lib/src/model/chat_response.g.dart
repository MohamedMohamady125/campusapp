// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_response.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ChatResponse extends ChatResponse {
  @override
  final DateTime createdAt;
  @override
  final String createdById;
  @override
  final String? description;
  @override
  final String id;
  @override
  final int memberCap;
  @override
  final int memberCount;
  @override
  final String name;
  @override
  final String slug;
  @override
  final ChatVisibility visibility;

  factory _$ChatResponse([void Function(ChatResponseBuilder)? updates]) =>
      (ChatResponseBuilder()..update(updates))._build();

  _$ChatResponse._(
      {required this.createdAt,
      required this.createdById,
      this.description,
      required this.id,
      required this.memberCap,
      required this.memberCount,
      required this.name,
      required this.slug,
      required this.visibility})
      : super._();
  @override
  ChatResponse rebuild(void Function(ChatResponseBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ChatResponseBuilder toBuilder() => ChatResponseBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ChatResponse &&
        createdAt == other.createdAt &&
        createdById == other.createdById &&
        description == other.description &&
        id == other.id &&
        memberCap == other.memberCap &&
        memberCount == other.memberCount &&
        name == other.name &&
        slug == other.slug &&
        visibility == other.visibility;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jc(_$hash, createdById.hashCode);
    _$hash = $jc(_$hash, description.hashCode);
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, memberCap.hashCode);
    _$hash = $jc(_$hash, memberCount.hashCode);
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, slug.hashCode);
    _$hash = $jc(_$hash, visibility.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ChatResponse')
          ..add('createdAt', createdAt)
          ..add('createdById', createdById)
          ..add('description', description)
          ..add('id', id)
          ..add('memberCap', memberCap)
          ..add('memberCount', memberCount)
          ..add('name', name)
          ..add('slug', slug)
          ..add('visibility', visibility))
        .toString();
  }
}

class ChatResponseBuilder
    implements Builder<ChatResponse, ChatResponseBuilder> {
  _$ChatResponse? _$v;

  DateTime? _createdAt;
  DateTime? get createdAt => _$this._createdAt;
  set createdAt(DateTime? createdAt) => _$this._createdAt = createdAt;

  String? _createdById;
  String? get createdById => _$this._createdById;
  set createdById(String? createdById) => _$this._createdById = createdById;

  String? _description;
  String? get description => _$this._description;
  set description(String? description) => _$this._description = description;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  int? _memberCap;
  int? get memberCap => _$this._memberCap;
  set memberCap(int? memberCap) => _$this._memberCap = memberCap;

  int? _memberCount;
  int? get memberCount => _$this._memberCount;
  set memberCount(int? memberCount) => _$this._memberCount = memberCount;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  String? _slug;
  String? get slug => _$this._slug;
  set slug(String? slug) => _$this._slug = slug;

  ChatVisibility? _visibility;
  ChatVisibility? get visibility => _$this._visibility;
  set visibility(ChatVisibility? visibility) => _$this._visibility = visibility;

  ChatResponseBuilder() {
    ChatResponse._defaults(this);
  }

  ChatResponseBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _createdAt = $v.createdAt;
      _createdById = $v.createdById;
      _description = $v.description;
      _id = $v.id;
      _memberCap = $v.memberCap;
      _memberCount = $v.memberCount;
      _name = $v.name;
      _slug = $v.slug;
      _visibility = $v.visibility;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ChatResponse other) {
    _$v = other as _$ChatResponse;
  }

  @override
  void update(void Function(ChatResponseBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ChatResponse build() => _build();

  _$ChatResponse _build() {
    final _$result = _$v ??
        _$ChatResponse._(
          createdAt: BuiltValueNullFieldError.checkNotNull(
              createdAt, r'ChatResponse', 'createdAt'),
          createdById: BuiltValueNullFieldError.checkNotNull(
              createdById, r'ChatResponse', 'createdById'),
          description: description,
          id: BuiltValueNullFieldError.checkNotNull(id, r'ChatResponse', 'id'),
          memberCap: BuiltValueNullFieldError.checkNotNull(
              memberCap, r'ChatResponse', 'memberCap'),
          memberCount: BuiltValueNullFieldError.checkNotNull(
              memberCount, r'ChatResponse', 'memberCount'),
          name: BuiltValueNullFieldError.checkNotNull(
              name, r'ChatResponse', 'name'),
          slug: BuiltValueNullFieldError.checkNotNull(
              slug, r'ChatResponse', 'slug'),
          visibility: BuiltValueNullFieldError.checkNotNull(
              visibility, r'ChatResponse', 'visibility'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
