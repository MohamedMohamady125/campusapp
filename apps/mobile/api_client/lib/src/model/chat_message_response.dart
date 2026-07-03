//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'chat_message_response.g.dart';

/// ChatMessageResponse
///
/// Properties:
/// * [body] 
/// * [chatId] 
/// * [createdAt] 
/// * [id] 
/// * [senderId] 
@BuiltValue()
abstract class ChatMessageResponse implements Built<ChatMessageResponse, ChatMessageResponseBuilder> {
  @BuiltValueField(wireName: r'body')
  String get body;

  @BuiltValueField(wireName: r'chat_id')
  String get chatId;

  @BuiltValueField(wireName: r'created_at')
  DateTime get createdAt;

  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'sender_id')
  String get senderId;

  ChatMessageResponse._();

  factory ChatMessageResponse([void updates(ChatMessageResponseBuilder b)]) = _$ChatMessageResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ChatMessageResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ChatMessageResponse> get serializer => _$ChatMessageResponseSerializer();
}

class _$ChatMessageResponseSerializer implements PrimitiveSerializer<ChatMessageResponse> {
  @override
  final Iterable<Type> types = const [ChatMessageResponse, _$ChatMessageResponse];

  @override
  final String wireName = r'ChatMessageResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ChatMessageResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'body';
    yield serializers.serialize(
      object.body,
      specifiedType: const FullType(String),
    );
    yield r'chat_id';
    yield serializers.serialize(
      object.chatId,
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
    yield r'sender_id';
    yield serializers.serialize(
      object.senderId,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    ChatMessageResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ChatMessageResponseBuilder result,
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
        case r'chat_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.chatId = valueDes;
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
  ChatMessageResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ChatMessageResponseBuilder();
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

