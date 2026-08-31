//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:campus_api/src/model/conversation_context.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'conversation_create_request.g.dart';

/// ConversationCreateRequest
///
/// Properties:
/// * [contextId] 
/// * [contextType] 
/// * [recipientId] 
@BuiltValue()
abstract class ConversationCreateRequest implements Built<ConversationCreateRequest, ConversationCreateRequestBuilder> {
  @BuiltValueField(wireName: r'context_id')
  String? get contextId;

  @BuiltValueField(wireName: r'context_type')
  ConversationContext? get contextType;
  // enum contextTypeEnum {  listing,  tutoring,  direct,  run,  };

  @BuiltValueField(wireName: r'recipient_id')
  String get recipientId;

  ConversationCreateRequest._();

  factory ConversationCreateRequest([void updates(ConversationCreateRequestBuilder b)]) = _$ConversationCreateRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ConversationCreateRequestBuilder b) => b
      ..contextType = ConversationContext.direct;

  @BuiltValueSerializer(custom: true)
  static Serializer<ConversationCreateRequest> get serializer => _$ConversationCreateRequestSerializer();
}

class _$ConversationCreateRequestSerializer implements PrimitiveSerializer<ConversationCreateRequest> {
  @override
  final Iterable<Type> types = const [ConversationCreateRequest, _$ConversationCreateRequest];

  @override
  final String wireName = r'ConversationCreateRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ConversationCreateRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.contextId != null) {
      yield r'context_id';
      yield serializers.serialize(
        object.contextId,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.contextType != null) {
      yield r'context_type';
      yield serializers.serialize(
        object.contextType,
        specifiedType: const FullType(ConversationContext),
      );
    }
    yield r'recipient_id';
    yield serializers.serialize(
      object.recipientId,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    ConversationCreateRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ConversationCreateRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'context_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.contextId = valueDes;
          break;
        case r'context_type':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(ConversationContext),
          ) as ConversationContext;
          result.contextType = valueDes;
          break;
        case r'recipient_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.recipientId = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ConversationCreateRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ConversationCreateRequestBuilder();
    final serializedList = (serialized as Iterable<Object?>).toList();
    final unhandled = <Object?>[];
    _deserializeProperties(
      serializers,
      serialized,
      specifiedType: specifiedType,
      serializedList: serializedList,
      unhandled: unhandled,
      result: result,
    );
    return result.build();
  }
}

