//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'check_email_request.g.dart';

/// CheckEmailRequest
///
/// Properties:
/// * [email] 
@BuiltValue()
abstract class CheckEmailRequest implements Built<CheckEmailRequest, CheckEmailRequestBuilder> {
  @BuiltValueField(wireName: r'email')
  String get email;

  CheckEmailRequest._();

  factory CheckEmailRequest([void updates(CheckEmailRequestBuilder b)]) = _$CheckEmailRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(CheckEmailRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<CheckEmailRequest> get serializer => _$CheckEmailRequestSerializer();
}

class _$CheckEmailRequestSerializer implements PrimitiveSerializer<CheckEmailRequest> {
  @override
  final Iterable<Type> types = const [CheckEmailRequest, _$CheckEmailRequest];

  @override
  final String wireName = r'CheckEmailRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    CheckEmailRequest object, {
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
    CheckEmailRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required CheckEmailRequestBuilder result,
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
  CheckEmailRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = CheckEmailRequestBuilder();
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

