//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'image_upload_url_request.g.dart';

/// ImageUploadUrlRequest
///
/// Properties:
/// * [contentType] 
@BuiltValue()
abstract class ImageUploadUrlRequest implements Built<ImageUploadUrlRequest, ImageUploadUrlRequestBuilder> {
  @BuiltValueField(wireName: r'content_type')
  String get contentType;

  ImageUploadUrlRequest._();

  factory ImageUploadUrlRequest([void updates(ImageUploadUrlRequestBuilder b)]) = _$ImageUploadUrlRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ImageUploadUrlRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ImageUploadUrlRequest> get serializer => _$ImageUploadUrlRequestSerializer();
}

class _$ImageUploadUrlRequestSerializer implements PrimitiveSerializer<ImageUploadUrlRequest> {
  @override
  final Iterable<Type> types = const [ImageUploadUrlRequest, _$ImageUploadUrlRequest];

  @override
  final String wireName = r'ImageUploadUrlRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ImageUploadUrlRequest object, {
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
    ImageUploadUrlRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ImageUploadUrlRequestBuilder result,
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
  ImageUploadUrlRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ImageUploadUrlRequestBuilder();
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

