//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'payment_proof_upload_url_request.g.dart';

/// Requester asks for a signed URL to upload the transaction screenshot.
///
/// Properties:
/// * [contentType] 
@BuiltValue()
abstract class PaymentProofUploadUrlRequest implements Built<PaymentProofUploadUrlRequest, PaymentProofUploadUrlRequestBuilder> {
  @BuiltValueField(wireName: r'content_type')
  String get contentType;

  PaymentProofUploadUrlRequest._();

  factory PaymentProofUploadUrlRequest([void updates(PaymentProofUploadUrlRequestBuilder b)]) = _$PaymentProofUploadUrlRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PaymentProofUploadUrlRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PaymentProofUploadUrlRequest> get serializer => _$PaymentProofUploadUrlRequestSerializer();
}

class _$PaymentProofUploadUrlRequestSerializer implements PrimitiveSerializer<PaymentProofUploadUrlRequest> {
  @override
  final Iterable<Type> types = const [PaymentProofUploadUrlRequest, _$PaymentProofUploadUrlRequest];

  @override
  final String wireName = r'PaymentProofUploadUrlRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PaymentProofUploadUrlRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'content_type';
    yield serializers.serialize(
      object.contentType,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    PaymentProofUploadUrlRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required PaymentProofUploadUrlRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'content_type':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.contentType = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  PaymentProofUploadUrlRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PaymentProofUploadUrlRequestBuilder();
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

