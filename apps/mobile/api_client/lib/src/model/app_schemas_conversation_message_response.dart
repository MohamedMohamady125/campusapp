//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'app_schemas_conversation_message_response.g.dart';

/// AppSchemasConversationMessageResponse
///
/// Properties:
/// * [body] 
/// * [conversationId] 
/// * [createdAt] 
/// * [id] 
/// * [readAt] 
/// * [senderId] 
@BuiltValue()
abstract class AppSchemasConversationMessageResponse implements Built<AppSchemasConversationMessageResponse, AppSchemasConversationMessageResponseBuilder> {
  @BuiltValueField(wireName: r'body')
  String get body;

  @BuiltValueField(wireName: r'conversation_id')
  String get conversationId;

  @BuiltValueField(wireName: r'created_at')
  DateTime get createdAt;

  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'read_at')
  DateTime? get readAt;

  @BuiltValueField(wireName: r'sender_id')
  String get senderId;

  AppSchemasConversationMessageResponse._();

  factory AppSchemasConversationMessageResponse([void updates(AppSchemasConversationMessageResponseBuilder b)]) = _$AppSchemasConversationMessageResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AppSchemasConversationMessageResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AppSchemasConversationMessageResponse> get serializer => _$AppSchemasConversationMessageResponseSerializer();
}

class _$AppSchemasConversationMessageResponseSerializer implements PrimitiveSerializer<AppSchemasConversationMessageResponse> {
  @override
  final Iterable<Type> types = const [AppSchemasConversationMessageResponse, _$AppSchemasConversationMessageResponse];

  @override
  final String wireName = r'AppSchemasConversationMessageResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AppSchemasConversationMessageResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'body';
    yield serializers.serialize(
      object.body,
      specifiedType: const FullType(String),
    );
    yield r'conversation_id';
    yield serializers.serialize(
      object.conversationId,
      specifiedType: const FullType(String),
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
    yield r'read_at';
    yield object.readAt == null ? null : serializers.serialize(
      object.readAt,
      specifiedType: const FullType.nullable(DateTime),
    );
    yield r'sender_id';
    yield serializers.serialize(
      object.senderId,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    AppSchemasConversationMessageResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required AppSchemasConversationMessageResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'body':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.body = valueDes;
          break;
        case r'conversation_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.conversationId = valueDes;
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
        case r'read_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.readAt = valueDes;
          break;
        case r'sender_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.senderId = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  AppSchemasConversationMessageResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AppSchemasConversationMessageResponseBuilder();
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

