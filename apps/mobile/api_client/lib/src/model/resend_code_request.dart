//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'resend_code_request.g.dart';

/// ResendCodeRequest
///
/// Properties:
/// * [email] 
@BuiltValue()
abstract class ResendCodeRequest implements Built<ResendCodeRequest, ResendCodeRequestBuilder> {
  @BuiltValueField(wireName: r'email')
  String get email;

  ResendCodeRequest._();

  factory ResendCodeRequest([void updates(ResendCodeRequestBuilder b)]) = _$ResendCodeRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ResendCodeRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ResendCodeRequest> get serializer => _$ResendCodeRequestSerializer();
}

class _$ResendCodeRequestSerializer implements PrimitiveSerializer<ResendCodeRequest> {
  @override
  final Iterable<Type> types = const [ResendCodeRequest, _$ResendCodeRequest];

  @override
  final String wireName = r'ResendCodeRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ResendCodeRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'email';
    yield serializers.serialize(
      object.email,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    ResendCodeRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ResendCodeRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
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
  ResendCodeRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ResendCodeRequestBuilder();
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

