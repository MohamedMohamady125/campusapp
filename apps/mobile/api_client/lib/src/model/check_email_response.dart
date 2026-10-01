//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'check_email_response.g.dart';

/// Whether an account exists for this email (login/registration UX hint).  Campus-scoped app: accounts are .edu-verified peers, so email-existence disclosure is an accepted trade-off for a far clearer sign-in flow.
///
/// Properties:
/// * [exists] 
@BuiltValue()
abstract class CheckEmailResponse implements Built<CheckEmailResponse, CheckEmailResponseBuilder> {
  @BuiltValueField(wireName: r'exists')
  bool get exists;

  CheckEmailResponse._();

  factory CheckEmailResponse([void updates(CheckEmailResponseBuilder b)]) = _$CheckEmailResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(CheckEmailResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<CheckEmailResponse> get serializer => _$CheckEmailResponseSerializer();
}

class _$CheckEmailResponseSerializer implements PrimitiveSerializer<CheckEmailResponse> {
  @override
  final Iterable<Type> types = const [CheckEmailResponse, _$CheckEmailResponse];

  @override
  final String wireName = r'CheckEmailResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    CheckEmailResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'exists';
    yield serializers.serialize(
      object.exists,
      specifiedType: const FullType(bool),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    CheckEmailResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required CheckEmailResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'exists':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.exists = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  CheckEmailResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = CheckEmailResponseBuilder();
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

