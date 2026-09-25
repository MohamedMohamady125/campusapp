//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'payment_proof_submit_request.g.dart';

/// Requester confirms they paid: the uploaded screenshot key + optional note.
///
/// Properties:
/// * [note] 
/// * [proofKey] 
@BuiltValue()
abstract class PaymentProofSubmitRequest implements Built<PaymentProofSubmitRequest, PaymentProofSubmitRequestBuilder> {
  @BuiltValueField(wireName: r'note')
  String? get note;

  @BuiltValueField(wireName: r'proof_key')
  String get proofKey;

  PaymentProofSubmitRequest._();

  factory PaymentProofSubmitRequest([void updates(PaymentProofSubmitRequestBuilder b)]) = _$PaymentProofSubmitRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PaymentProofSubmitRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PaymentProofSubmitRequest> get serializer => _$PaymentProofSubmitRequestSerializer();
}

class _$PaymentProofSubmitRequestSerializer implements PrimitiveSerializer<PaymentProofSubmitRequest> {
  @override
  final Iterable<Type> types = const [PaymentProofSubmitRequest, _$PaymentProofSubmitRequest];

  @override
  final String wireName = r'PaymentProofSubmitRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PaymentProofSubmitRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.note != null) {
      yield r'note';
      yield serializers.serialize(
        object.note,
        specifiedType: const FullType.nullable(String),
      );
    }
    yield r'proof_key';
    yield serializers.serialize(
      object.proofKey,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    PaymentProofSubmitRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required PaymentProofSubmitRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'note':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.note = valueDes;
          break;
        case r'proof_key':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.proofKey = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  PaymentProofSubmitRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PaymentProofSubmitRequestBuilder();
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

