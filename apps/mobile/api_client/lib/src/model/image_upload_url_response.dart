//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'image_upload_url_response.g.dart';

/// ImageUploadUrlResponse
///
/// Properties:
/// * [fields] 
/// * [imageId] 
/// * [key] 
/// * [uploadUrl] 
@BuiltValue()
abstract class ImageUploadUrlResponse implements Built<ImageUploadUrlResponse, ImageUploadUrlResponseBuilder> {
  @BuiltValueField(wireName: r'fields')
  BuiltMap<String, String> get fields;

  @BuiltValueField(wireName: r'image_id')
  String get imageId;

  @BuiltValueField(wireName: r'key')
  String get key;

  @BuiltValueField(wireName: r'upload_url')
  String get uploadUrl;

  ImageUploadUrlResponse._();

  factory ImageUploadUrlResponse([void updates(ImageUploadUrlResponseBuilder b)]) = _$ImageUploadUrlResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ImageUploadUrlResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ImageUploadUrlResponse> get serializer => _$ImageUploadUrlResponseSerializer();
}

class _$ImageUploadUrlResponseSerializer implements PrimitiveSerializer<ImageUploadUrlResponse> {
  @override
  final Iterable<Type> types = const [ImageUploadUrlResponse, _$ImageUploadUrlResponse];

  @override
  final String wireName = r'ImageUploadUrlResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ImageUploadUrlResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'fields';
    yield serializers.serialize(
      object.fields,
      specifiedType: const FullType(BuiltMap, [FullType(String), FullType(String)]),
    );
    yield r'image_id';
    yield serializers.serialize(
      object.imageId,
      specifiedType: const FullType(String),
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
    ImageUploadUrlResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ImageUploadUrlResponseBuilder result,
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
        case r'image_id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.imageId = valueDes;
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
  ImageUploadUrlResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ImageUploadUrlResponseBuilder();
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

