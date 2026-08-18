//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'chat_message_delete_request.g.dart';

/// ChatMessageDeleteRequest
///
/// Properties:
/// * [reason] 
@BuiltValue()
abstract class ChatMessageDeleteRequest implements Built<ChatMessageDeleteRequest, ChatMessageDeleteRequestBuilder> {
  @BuiltValueField(wireName: r'reason')
  String get reason;

  ChatMessageDeleteRequest._();

  factory ChatMessageDeleteRequest([void updates(ChatMessageDeleteRequestBuilder b)]) = _$ChatMessageDeleteRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ChatMessageDeleteRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ChatMessageDeleteRequest> get serializer => _$ChatMessageDeleteRequestSerializer();
}

class _$ChatMessageDeleteRequestSerializer implements PrimitiveSerializer<ChatMessageDeleteRequest> {
  @override
  final Iterable<Type> types = const [ChatMessageDeleteRequest, _$ChatMessageDeleteRequest];

  @override
  final String wireName = r'ChatMessageDeleteRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ChatMessageDeleteRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'reason';
    yield serializers.serialize(
      object.reason,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    ChatMessageDeleteRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ChatMessageDeleteRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'reason':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.reason = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ChatMessageDeleteRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ChatMessageDeleteRequestBuilder();
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

