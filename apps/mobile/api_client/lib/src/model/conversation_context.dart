//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'conversation_context.g.dart';

class ConversationContext extends EnumClass {

  @BuiltValueEnumConst(wireName: r'listing')
  static const ConversationContext listing = _$listing;
  @BuiltValueEnumConst(wireName: r'tutoring')
  static const ConversationContext tutoring = _$tutoring;
  @BuiltValueEnumConst(wireName: r'direct')
  static const ConversationContext direct = _$direct;
  @BuiltValueEnumConst(wireName: r'run')
  static const ConversationContext run = _$run;

  static Serializer<ConversationContext> get serializer => _$conversationContextSerializer;

  const ConversationContext._(String name): super(name);

  static BuiltSet<ConversationContext> get values => _$values;
  static ConversationContext valueOf(String name) => _$valueOf(name);
}

/// Optionally, enum_class can generate a mixin to go with your enum for use
/// with Angular. It exposes your enum constants as getters. So, if you mix it
/// in to your Dart component class, the values become available to the
/// corresponding Angular template.
///
/// Trigger mixin generation by writing a line like this one next to your enum.
abstract class ConversationContextMixin = Object with _$ConversationContextMixin;

