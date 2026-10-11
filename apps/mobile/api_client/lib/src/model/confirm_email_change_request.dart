//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'confirm_email_change_request.g.dart';

/// ConfirmEmailChangeRequest
///
/// Properties:
/// * [code] 
@BuiltValue()
abstract class ConfirmEmailChangeRequest implements Built<ConfirmEmailChangeRequest, ConfirmEmailChangeRequestBuilder> {
  @BuiltValueField(wireName: r'code')
  String get code;

  ConfirmEmailChangeRequest._();

  factory ConfirmEmailChangeRequest([void updates(ConfirmEmailChangeRequestBuilder b)]) = _$ConfirmEmailChangeRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ConfirmEmailChangeRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ConfirmEmailChangeRequest> get serializer => _$ConfirmEmailChangeRequestSerializer();
}

class _$ConfirmEmailChangeRequestSerializer implements PrimitiveSerializer<ConfirmEmailChangeRequest> {
  @override
  final Iterable<Type> types = const [ConfirmEmailChangeRequest, _$ConfirmEmailChangeRequest];

  @override
  final String wireName = r'ConfirmEmailChangeRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ConfirmEmailChangeRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'code';
    yield serializers.serialize(
      object.code,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    ConfirmEmailChangeRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ConfirmEmailChangeRequestBuilder result,
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
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ConfirmEmailChangeRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ConfirmEmailChangeRequestBuilder();
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

