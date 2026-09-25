//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'payment_qr_upload_url_request.g.dart';

/// Runner asks for a signed URL to upload a payment-app QR code image.
///
/// Properties:
/// * [contentType] 
@BuiltValue()
abstract class PaymentQrUploadUrlRequest implements Built<PaymentQrUploadUrlRequest, PaymentQrUploadUrlRequestBuilder> {
  @BuiltValueField(wireName: r'content_type')
  String get contentType;

  PaymentQrUploadUrlRequest._();

  factory PaymentQrUploadUrlRequest([void updates(PaymentQrUploadUrlRequestBuilder b)]) = _$PaymentQrUploadUrlRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PaymentQrUploadUrlRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PaymentQrUploadUrlRequest> get serializer => _$PaymentQrUploadUrlRequestSerializer();
}

class _$PaymentQrUploadUrlRequestSerializer implements PrimitiveSerializer<PaymentQrUploadUrlRequest> {
  @override
  final Iterable<Type> types = const [PaymentQrUploadUrlRequest, _$PaymentQrUploadUrlRequest];

  @override
  final String wireName = r'PaymentQrUploadUrlRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PaymentQrUploadUrlRequest object, {
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
    PaymentQrUploadUrlRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required PaymentQrUploadUrlRequestBuilder result,
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
  PaymentQrUploadUrlRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PaymentQrUploadUrlRequestBuilder();
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

