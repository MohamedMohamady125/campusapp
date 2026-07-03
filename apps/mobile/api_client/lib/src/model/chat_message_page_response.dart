//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:campus_api/src/model/chat_message_response.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'chat_message_page_response.g.dart';

/// ChatMessagePageResponse
///
/// Properties:
/// * [items] 
/// * [nextCursor] 
@BuiltValue()
abstract class ChatMessagePageResponse implements Built<ChatMessagePageResponse, ChatMessagePageResponseBuilder> {
  @BuiltValueField(wireName: r'items')
  BuiltList<ChatMessageResponse> get items;

  @BuiltValueField(wireName: r'next_cursor')
  String? get nextCursor;

  ChatMessagePageResponse._();

  factory ChatMessagePageResponse([void updates(ChatMessagePageResponseBuilder b)]) = _$ChatMessagePageResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ChatMessagePageResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ChatMessagePageResponse> get serializer => _$ChatMessagePageResponseSerializer();
}

class _$ChatMessagePageResponseSerializer implements PrimitiveSerializer<ChatMessagePageResponse> {
  @override
  final Iterable<Type> types = const [ChatMessagePageResponse, _$ChatMessagePageResponse];

  @override
  final String wireName = r'ChatMessagePageResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ChatMessagePageResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'items';
    yield serializers.serialize(
      object.items,
      specifiedType: const FullType(BuiltList, [FullType(ChatMessageResponse)]),
    );
    yield r'next_cursor';
    yield object.nextCursor == null ? null : serializers.serialize(
      object.nextCursor,
      specifiedType: const FullType.nullable(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    ChatMessagePageResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ChatMessagePageResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'items':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(ChatMessageResponse)]),
          ) as BuiltList<ChatMessageResponse>;
          result.items.replace(valueDes);
          break;
        case r'next_cursor':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.nextCursor = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ChatMessagePageResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ChatMessagePageResponseBuilder();
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

