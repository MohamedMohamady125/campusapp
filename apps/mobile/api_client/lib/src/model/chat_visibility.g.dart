// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_visibility.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const ChatVisibility _$open = const ChatVisibility._('open');
const ChatVisibility _$request = const ChatVisibility._('request');
const ChatVisibility _$private = const ChatVisibility._('private');

ChatVisibility _$valueOf(String name) {
  switch (name) {
    case 'open':
      return _$open;
    case 'request':
      return _$request;
    case 'private':
      return _$private;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<ChatVisibility> _$values =
    BuiltSet<ChatVisibility>(const <ChatVisibility>[
  _$open,
  _$request,
  _$private,
]);

class _$ChatVisibilityMeta {
  const _$ChatVisibilityMeta();
  ChatVisibility get open => _$open;
  ChatVisibility get request => _$request;
  ChatVisibility get private => _$private;
  ChatVisibility valueOf(String name) => _$valueOf(name);
  BuiltSet<ChatVisibility> get values => _$values;
}

abstract class _$ChatVisibilityMixin {
  // ignore: non_constant_identifier_names
  _$ChatVisibilityMeta get ChatVisibility => const _$ChatVisibilityMeta();
}

Serializer<ChatVisibility> _$chatVisibilitySerializer =
    _$ChatVisibilitySerializer();

class _$ChatVisibilitySerializer
    implements PrimitiveSerializer<ChatVisibility> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'open': 'open',
    'request': 'request',
    'private': 'private',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'open': 'open',
    'request': 'request',
    'private': 'private',
  };

  @override
  final Iterable<Type> types = const <Type>[ChatVisibility];
  @override
  final String wireName = 'ChatVisibility';

  @override
  Object serialize(Serializers serializers, ChatVisibility object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  ChatVisibility deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      ChatVisibility.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
