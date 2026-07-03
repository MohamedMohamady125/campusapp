//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'chat_visibility.g.dart';

class ChatVisibility extends EnumClass {

  @BuiltValueEnumConst(wireName: r'open')
  static const ChatVisibility open = _$open;
  @BuiltValueEnumConst(wireName: r'request')
  static const ChatVisibility request = _$request;
  @BuiltValueEnumConst(wireName: r'private')
  static const ChatVisibility private = _$private;

  static Serializer<ChatVisibility> get serializer => _$chatVisibilitySerializer;

  const ChatVisibility._(String name): super(name);

  static BuiltSet<ChatVisibility> get values => _$values;
  static ChatVisibility valueOf(String name) => _$valueOf(name);
}

/// Optionally, enum_class can generate a mixin to go with your enum for use
/// with Angular. It exposes your enum constants as getters. So, if you mix it
/// in to your Dart component class, the values become available to the
/// corresponding Angular template.
///
/// Trigger mixin generation by writing a line like this one next to your enum.
abstract class ChatVisibilityMixin = Object with _$ChatVisibilityMixin;

