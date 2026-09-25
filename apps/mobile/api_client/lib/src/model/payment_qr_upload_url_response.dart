//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'payment_qr_upload_url_response.g.dart';

/// PaymentQrUploadUrlResponse
///
/// Properties:
/// * [fields] 
/// * [key] 
/// * [uploadUrl] 
@BuiltValue()
abstract class PaymentQrUploadUrlResponse implements Built<PaymentQrUploadUrlResponse, PaymentQrUploadUrlResponseBuilder> {
  @BuiltValueField(wireName: r'fields')
  BuiltMap<String, String> get fields;

  @BuiltValueField(wireName: r'key')
  String get key;

  @BuiltValueField(wireName: r'upload_url')
  String get uploadUrl;

  PaymentQrUploadUrlResponse._();

  factory PaymentQrUploadUrlResponse([void updates(PaymentQrUploadUrlResponseBuilder b)]) = _$PaymentQrUploadUrlResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PaymentQrUploadUrlResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PaymentQrUploadUrlResponse> get serializer => _$PaymentQrUploadUrlResponseSerializer();
}

class _$PaymentQrUploadUrlResponseSerializer implements PrimitiveSerializer<PaymentQrUploadUrlResponse> {
  @override
  final Iterable<Type> types = const [PaymentQrUploadUrlResponse, _$PaymentQrUploadUrlResponse];

  @override
  final String wireName = r'PaymentQrUploadUrlResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PaymentQrUploadUrlResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'fields';
    yield serializers.serialize(
      object.fields,
      specifiedType: const FullType(BuiltMap, [FullType(String), FullType(String)]),
    );
    yield r'key';
    yield serializers.serialize(
      object.key,
      specifiedType: const FullType(String),
    );
    yield r'upload_url';
    yield serializers.serialize(
      object.uploadUrl,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    PaymentQrUploadUrlResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required PaymentQrUploadUrlResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'fields':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltMap, [FullType(String), FullType(String)]),
          ) as BuiltMap<String, String>;
          result.fields.replace(valueDes);
          break;
        case r'key':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.key = valueDes;
          break;
        case r'upload_url':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.uploadUrl = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  PaymentQrUploadUrlResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PaymentQrUploadUrlResponseBuilder();
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

