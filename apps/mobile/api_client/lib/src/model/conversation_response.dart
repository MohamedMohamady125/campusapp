//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:campus_api/src/model/user_public_response.dart';
import 'package:campus_api/src/model/conversation_context.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'conversation_response.g.dart';

/// ConversationResponse
///
/// Properties:
/// * [contextId] 
/// * [contextType] 
/// * [createdAt] 
/// * [id] 
/// * [participants] 
@BuiltValue()
abstract class ConversationResponse implements Built<ConversationResponse, ConversationResponseBuilder> {
  @BuiltValueField(wireName: r'context_id')
  String? get contextId;

  @BuiltValueField(wireName: r'context_type')
  ConversationContext get contextType;
  // enum contextTypeEnum {  listing,  tutoring,  direct,  };

  @BuiltValueField(wireName: r'created_at')
  DateTime get createdAt;

  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'participants')
  BuiltList<UserPublicResponse> get participants;

  ConversationResponse._();

  factory ConversationResponse([void updates(ConversationResponseBuilder b)]) = _$ConversationResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ConversationResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ConversationResponse> get serializer => _$ConversationResponseSerializer();
}

class _$ConversationResponseSerializer implements PrimitiveSerializer<ConversationResponse> {
  @override
  final Iterable<Type> types = const [ConversationResponse, _$ConversationResponse];

  @override
  final String wireName = r'ConversationResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ConversationResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'context_id';
    yield object.contextId == null ? null : serializers.serialize(
      object.contextId,
      specifiedType: const FullType.nullable(String),
    );
    yield r'context_type';
    yield serializers.serialize(
      object.contextType,
      specifiedType: const FullType(ConversationContext),
    );
    yield r'created_at';
    yield serializers.serialize(
      object.createdAt,
      specifiedType: const FullType(DateTime),
    );
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'participants';
    yield serializers.serialize(
      object.participants,
      specifiedType: const FullType(BuiltList, [FullType(UserPublicResponse)]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    ConversationResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ConversationResponseBuilder result,
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
        case r'created_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.createdAt = valueDes;
          break;
        case r'id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.id = valueDes;
          break;
        case r'participants':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(UserPublicResponse)]),
          ) as BuiltList<UserPublicResponse>;
          result.participants.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ConversationResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ConversationResponseBuilder();
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

