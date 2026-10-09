//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'avatar_upload_url_request.g.dart';

/// Signed-URL request for a profile photo (required to post a run).
///
/// Properties:
/// * [contentType] 
@BuiltValue()
abstract class AvatarUploadUrlRequest implements Built<AvatarUploadUrlRequest, AvatarUploadUrlRequestBuilder> {
  @BuiltValueField(wireName: r'content_type')
  String get contentType;

  AvatarUploadUrlRequest._();

  factory AvatarUploadUrlRequest([void updates(AvatarUploadUrlRequestBuilder b)]) = _$AvatarUploadUrlRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AvatarUploadUrlRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AvatarUploadUrlRequest> get serializer => _$AvatarUploadUrlRequestSerializer();
}

class _$AvatarUploadUrlRequestSerializer implements PrimitiveSerializer<AvatarUploadUrlRequest> {
  @override
  final Iterable<Type> types = const [AvatarUploadUrlRequest, _$AvatarUploadUrlRequest];

  @override
  final String wireName = r'AvatarUploadUrlRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AvatarUploadUrlRequest object, {
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
    AvatarUploadUrlRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required AvatarUploadUrlRequestBuilder result,
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
  AvatarUploadUrlRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AvatarUploadUrlRequestBuilder();
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

