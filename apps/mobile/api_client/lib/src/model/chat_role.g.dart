// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_role.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const ChatRole _$member = const ChatRole._('member');
const ChatRole _$mod = const ChatRole._('mod');
const ChatRole _$owner = const ChatRole._('owner');

ChatRole _$valueOf(String name) {
  switch (name) {
    case 'member':
      return _$member;
    case 'mod':
      return _$mod;
    case 'owner':
      return _$owner;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<ChatRole> _$values = BuiltSet<ChatRole>(const <ChatRole>[
  _$member,
  _$mod,
  _$owner,
]);

class _$ChatRoleMeta {
  const _$ChatRoleMeta();
  ChatRole get member => _$member;
  ChatRole get mod => _$mod;
  ChatRole get owner => _$owner;
  ChatRole valueOf(String name) => _$valueOf(name);
  BuiltSet<ChatRole> get values => _$values;
}

abstract class _$ChatRoleMixin {
  // ignore: non_constant_identifier_names
  _$ChatRoleMeta get ChatRole => const _$ChatRoleMeta();
}

Serializer<ChatRole> _$chatRoleSerializer = _$ChatRoleSerializer();

class _$ChatRoleSerializer implements PrimitiveSerializer<ChatRole> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'member': 'member',
    'mod': 'mod',
    'owner': 'owner',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'member': 'member',
    'mod': 'mod',
    'owner': 'owner',
  };

  @override
  final Iterable<Type> types = const <Type>[ChatRole];
  @override
  final String wireName = 'ChatRole';

  @override
  Object serialize(Serializers serializers, ChatRole object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  ChatRole deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      ChatRole.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
