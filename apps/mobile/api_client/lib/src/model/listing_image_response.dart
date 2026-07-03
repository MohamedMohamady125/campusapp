//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:campus_api/src/model/moderation_status.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'listing_image_response.g.dart';

/// ListingImageResponse
///
/// Properties:
/// * [id] 
/// * [moderationStatus] 
/// * [order] 
/// * [s3Key] 
@BuiltValue()
abstract class ListingImageResponse implements Built<ListingImageResponse, ListingImageResponseBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'moderation_status')
  ModerationStatus get moderationStatus;
  // enum moderationStatusEnum {  pending,  approved,  rejected,  };

  @BuiltValueField(wireName: r'order')
  int get order;

  @BuiltValueField(wireName: r's3_key')
  String get s3Key;

  ListingImageResponse._();

  factory ListingImageResponse([void updates(ListingImageResponseBuilder b)]) = _$ListingImageResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ListingImageResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ListingImageResponse> get serializer => _$ListingImageResponseSerializer();
}

class _$ListingImageResponseSerializer implements PrimitiveSerializer<ListingImageResponse> {
  @override
  final Iterable<Type> types = const [ListingImageResponse, _$ListingImageResponse];

  @override
  final String wireName = r'ListingImageResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ListingImageResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'moderation_status';
    yield serializers.serialize(
      object.moderationStatus,
      specifiedType: const FullType(ModerationStatus),
    );
    yield r'order';
    yield serializers.serialize(
      object.order,
      specifiedType: const FullType(int),
    );
    yield r's3_key';
    yield serializers.serialize(
      object.s3Key,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    ListingImageResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ListingImageResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.id = valueDes;
          break;
        case r'moderation_status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(ModerationStatus),
          ) as ModerationStatus;
          result.moderationStatus = valueDes;
          break;
        case r'order':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.order = valueDes;
          break;
        case r's3_key':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.s3Key = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ListingImageResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ListingImageResponseBuilder();
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

