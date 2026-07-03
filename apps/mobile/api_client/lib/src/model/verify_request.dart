//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'verify_request.g.dart';

/// VerifyRequest
///
/// Properties:
/// * [code] 
/// * [email] 
@BuiltValue()
abstract class VerifyRequest implements Built<VerifyRequest, VerifyRequestBuilder> {
  @BuiltValueField(wireName: r'code')
  String get code;

  @BuiltValueField(wireName: r'email')
  String get email;

  VerifyRequest._();

  factory VerifyRequest([void updates(VerifyRequestBuilder b)]) = _$VerifyRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(VerifyRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<VerifyRequest> get serializer => _$VerifyRequestSerializer();
}

class _$VerifyRequestSerializer implements PrimitiveSerializer<VerifyRequest> {
  @override
  final Iterable<Type> types = const [VerifyRequest, _$VerifyRequest];

  @override
  final String wireName = r'VerifyRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    VerifyRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'code';
    yield serializers.serialize(
      object.code,
      specifiedType: const FullType(String),
    );
    yield r'email';
    yield serializers.serialize(
      object.email,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    VerifyRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required VerifyRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'code':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.code = valueDes;
          break;
        case r'email':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.email = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  VerifyRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = VerifyRequestBuilder();
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

