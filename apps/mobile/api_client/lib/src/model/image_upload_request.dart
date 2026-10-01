//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'image_upload_request.g.dart';

/// Direct image upload: base64 body, stored in Postgres.  Base64 inflates ~33%, so the field cap is above the 5MB binary limit; the decoded size is enforced server-side.
///
/// Properties:
/// * [contentType] 
/// * [dataBase64] 
@BuiltValue()
abstract class ImageUploadRequest implements Built<ImageUploadRequest, ImageUploadRequestBuilder> {
  @BuiltValueField(wireName: r'content_type')
  String get contentType;

  @BuiltValueField(wireName: r'data_base64')
  String get dataBase64;

  ImageUploadRequest._();

  factory ImageUploadRequest([void updates(ImageUploadRequestBuilder b)]) = _$ImageUploadRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ImageUploadRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ImageUploadRequest> get serializer => _$ImageUploadRequestSerializer();
}

class _$ImageUploadRequestSerializer implements PrimitiveSerializer<ImageUploadRequest> {
  @override
  final Iterable<Type> types = const [ImageUploadRequest, _$ImageUploadRequest];

  @override
  final String wireName = r'ImageUploadRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ImageUploadRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'content_type';
    yield serializers.serialize(
      object.contentType,
      specifiedType: const FullType(String),
    );
    yield r'data_base64';
    yield serializers.serialize(
      object.dataBase64,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    ImageUploadRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ImageUploadRequestBuilder result,
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
        case r'data_base64':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.dataBase64 = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ImageUploadRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ImageUploadRequestBuilder();
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

