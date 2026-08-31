// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'conversation_context.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const ConversationContext _$listing = const ConversationContext._('listing');
const ConversationContext _$tutoring = const ConversationContext._('tutoring');
const ConversationContext _$direct = const ConversationContext._('direct');
const ConversationContext _$run = const ConversationContext._('run');

ConversationContext _$valueOf(String name) {
  switch (name) {
    case 'listing':
      return _$listing;
    case 'tutoring':
      return _$tutoring;
    case 'direct':
      return _$direct;
    case 'run':
      return _$run;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<ConversationContext> _$values =
    BuiltSet<ConversationContext>(const <ConversationContext>[
  _$listing,
  _$tutoring,
  _$direct,
  _$run,
]);

class _$ConversationContextMeta {
  const _$ConversationContextMeta();
  ConversationContext get listing => _$listing;
  ConversationContext get tutoring => _$tutoring;
  ConversationContext get direct => _$direct;
  ConversationContext get run => _$run;
  ConversationContext valueOf(String name) => _$valueOf(name);
  BuiltSet<ConversationContext> get values => _$values;
}

abstract class _$ConversationContextMixin {
  // ignore: non_constant_identifier_names
  _$ConversationContextMeta get ConversationContext =>
      const _$ConversationContextMeta();
}

Serializer<ConversationContext> _$conversationContextSerializer =
    _$ConversationContextSerializer();

class _$ConversationContextSerializer
    implements PrimitiveSerializer<ConversationContext> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'listing': 'listing',
    'tutoring': 'tutoring',
    'direct': 'direct',
    'run': 'run',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'listing': 'listing',
    'tutoring': 'tutoring',
    'direct': 'direct',
    'run': 'run',
  };

  @override
  final Iterable<Type> types = const <Type>[ConversationContext];
  @override
  final String wireName = 'ConversationContext';

  @override
  Object serialize(Serializers serializers, ConversationContext object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  ConversationContext deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      ConversationContext.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
