//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:campus_api/src/model/app_schemas_conversation_message_response.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'message_page_response.g.dart';

/// MessagePageResponse
///
/// Properties:
/// * [items] 
/// * [nextCursor] 
@BuiltValue()
abstract class MessagePageResponse implements Built<MessagePageResponse, MessagePageResponseBuilder> {
  @BuiltValueField(wireName: r'items')
  BuiltList<AppSchemasConversationMessageResponse> get items;

  @BuiltValueField(wireName: r'next_cursor')
  String? get nextCursor;

  MessagePageResponse._();

  factory MessagePageResponse([void updates(MessagePageResponseBuilder b)]) = _$MessagePageResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(MessagePageResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<MessagePageResponse> get serializer => _$MessagePageResponseSerializer();
}

class _$MessagePageResponseSerializer implements PrimitiveSerializer<MessagePageResponse> {
  @override
  final Iterable<Type> types = const [MessagePageResponse, _$MessagePageResponse];

  @override
  final String wireName = r'MessagePageResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    MessagePageResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'items';
    yield serializers.serialize(
      object.items,
      specifiedType: const FullType(BuiltList, [FullType(AppSchemasConversationMessageResponse)]),
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
    MessagePageResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required MessagePageResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'items':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(AppSchemasConversationMessageResponse)]),
          ) as BuiltList<AppSchemasConversationMessageResponse>;
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
  MessagePageResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = MessagePageResponseBuilder();
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

