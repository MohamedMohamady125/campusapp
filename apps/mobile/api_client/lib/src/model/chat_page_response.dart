//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:campus_api/src/model/chat_response.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'chat_page_response.g.dart';

/// ChatPageResponse
///
/// Properties:
/// * [items] 
/// * [nextCursor] 
@BuiltValue()
abstract class ChatPageResponse implements Built<ChatPageResponse, ChatPageResponseBuilder> {
  @BuiltValueField(wireName: r'items')
  BuiltList<ChatResponse> get items;

  @BuiltValueField(wireName: r'next_cursor')
  String? get nextCursor;

  ChatPageResponse._();

  factory ChatPageResponse([void updates(ChatPageResponseBuilder b)]) = _$ChatPageResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ChatPageResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ChatPageResponse> get serializer => _$ChatPageResponseSerializer();
}

class _$ChatPageResponseSerializer implements PrimitiveSerializer<ChatPageResponse> {
  @override
  final Iterable<Type> types = const [ChatPageResponse, _$ChatPageResponse];

  @override
  final String wireName = r'ChatPageResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ChatPageResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'items';
    yield serializers.serialize(
      object.items,
      specifiedType: const FullType(BuiltList, [FullType(ChatResponse)]),
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
    ChatPageResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ChatPageResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'items':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(ChatResponse)]),
          ) as BuiltList<ChatResponse>;
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
  ChatPageResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ChatPageResponseBuilder();
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

