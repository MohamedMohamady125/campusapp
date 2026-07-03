//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'message_create_request.g.dart';

/// MessageCreateRequest
///
/// Properties:
/// * [body] 
@BuiltValue()
abstract class MessageCreateRequest implements Built<MessageCreateRequest, MessageCreateRequestBuilder> {
  @BuiltValueField(wireName: r'body')
  String get body;

  MessageCreateRequest._();

  factory MessageCreateRequest([void updates(MessageCreateRequestBuilder b)]) = _$MessageCreateRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(MessageCreateRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<MessageCreateRequest> get serializer => _$MessageCreateRequestSerializer();
}

class _$MessageCreateRequestSerializer implements PrimitiveSerializer<MessageCreateRequest> {
  @override
  final Iterable<Type> types = const [MessageCreateRequest, _$MessageCreateRequest];

  @override
  final String wireName = r'MessageCreateRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    MessageCreateRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'body';
    yield serializers.serialize(
      object.body,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    MessageCreateRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required MessageCreateRequestBuilder result,
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
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  MessageCreateRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = MessageCreateRequestBuilder();
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

