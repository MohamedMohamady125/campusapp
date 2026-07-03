//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'register_response.g.dart';

/// RegisterResponse
///
/// Properties:
/// * [message] 
/// * [userId] 
@BuiltValue()
abstract class RegisterResponse implements Built<RegisterResponse, RegisterResponseBuilder> {
  @BuiltValueField(wireName: r'message')
  String get message;

  @BuiltValueField(wireName: r'user_id')
  String get userId;

  RegisterResponse._();

  factory RegisterResponse([void updates(RegisterResponseBuilder b)]) = _$RegisterResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(RegisterResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<RegisterResponse> get serializer => _$RegisterResponseSerializer();
}

class _$RegisterResponseSerializer implements PrimitiveSerializer<RegisterResponse> {
  @override
  final Iterable<Type> types = const [RegisterResponse, _$RegisterResponse];

  @override
  final String wireName = r'RegisterResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    RegisterResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'message';
    yield serializers.serialize(
      object.message,
      specifiedType: const FullType(String),
    );
    yield r'user_id';
    yield serializers.serialize(
      object.userId,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    RegisterResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required RegisterResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'message':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.message = valueDes;
          break;
        case r'user_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.userId = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  RegisterResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = RegisterResponseBuilder();
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

