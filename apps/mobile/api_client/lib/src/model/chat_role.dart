//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'chat_role.g.dart';

class ChatRole extends EnumClass {

  @BuiltValueEnumConst(wireName: r'member')
  static const ChatRole member = _$member;
  @BuiltValueEnumConst(wireName: r'mod')
  static const ChatRole mod = _$mod;
  @BuiltValueEnumConst(wireName: r'owner')
  static const ChatRole owner = _$owner;

  static Serializer<ChatRole> get serializer => _$chatRoleSerializer;

  const ChatRole._(String name): super(name);

  static BuiltSet<ChatRole> get values => _$values;
  static ChatRole valueOf(String name) => _$valueOf(name);
}

/// Optionally, enum_class can generate a mixin to go with your enum for use
/// with Angular. It exposes your enum constants as getters. So, if you mix it
/// in to your Dart component class, the values become available to the
/// corresponding Angular template.
///
/// Trigger mixin generation by writing a line like this one next to your enum.
abstract class ChatRoleMixin = Object with _$ChatRoleMixin;

