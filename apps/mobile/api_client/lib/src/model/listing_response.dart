//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:campus_api/src/model/listing_condition.dart';
import 'package:campus_api/src/model/listing_image_response.dart';
import 'package:built_collection/built_collection.dart';
import 'package:campus_api/src/model/user_public_response.dart';
import 'package:campus_api/src/model/listing_status.dart';
import 'package:campus_api/src/model/listing_category.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'listing_response.g.dart';

/// ListingResponse
///
/// Properties:
/// * [category] 
/// * [condition] 
/// * [createdAt] 
/// * [description] 
/// * [expiresAt] 
/// * [id] 
/// * [images] 
/// * [priceCents] 
/// * [seller] 
/// * [status] 
/// * [title] 
@BuiltValue()
abstract class ListingResponse implements Built<ListingResponse, ListingResponseBuilder> {
  @BuiltValueField(wireName: r'category')
  ListingCategory get category;
  // enum categoryEnum {  textbooks,  furniture,  electronics,  tickets,  clothing,  other,  };

  @BuiltValueField(wireName: r'condition')
  ListingCondition get condition;
  // enum conditionEnum {  new,  like_new,  good,  fair,  poor,  };

  @BuiltValueField(wireName: r'created_at')
  DateTime get createdAt;

  @BuiltValueField(wireName: r'description')
  String get description;

  @BuiltValueField(wireName: r'expires_at')
  DateTime get expiresAt;

  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'images')
  BuiltList<ListingImageResponse> get images;

  @BuiltValueField(wireName: r'price_cents')
  int get priceCents;

  @BuiltValueField(wireName: r'seller')
  UserPublicResponse get seller;

  @BuiltValueField(wireName: r'status')
  ListingStatus get status;
  // enum statusEnum {  active,  sold,  removed,  };

  @BuiltValueField(wireName: r'title')
  String get title;

  ListingResponse._();

  factory ListingResponse([void updates(ListingResponseBuilder b)]) = _$ListingResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ListingResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ListingResponse> get serializer => _$ListingResponseSerializer();
}

class _$ListingResponseSerializer implements PrimitiveSerializer<ListingResponse> {
  @override
  final Iterable<Type> types = const [ListingResponse, _$ListingResponse];

  @override
  final String wireName = r'ListingResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ListingResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'category';
    yield serializers.serialize(
      object.category,
      specifiedType: const FullType(ListingCategory),
    );
    yield r'condition';
    yield serializers.serialize(
      object.condition,
      specifiedType: const FullType(ListingCondition),
    );
    yield r'created_at';
    yield serializers.serialize(
      object.createdAt,
      specifiedType: const FullType(DateTime),
    );
    yield r'description';
    yield serializers.serialize(
      object.description,
      specifiedType: const FullType(String),
    );
    yield r'expires_at';
    yield serializers.serialize(
      object.expiresAt,
      specifiedType: const FullType(DateTime),
    );
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'images';
    yield serializers.serialize(
      object.images,
      specifiedType: const FullType(BuiltList, [FullType(ListingImageResponse)]),
    );
    yield r'price_cents';
    yield serializers.serialize(
      object.priceCents,
      specifiedType: const FullType(int),
    );
    yield r'seller';
    yield serializers.serialize(
      object.seller,
      specifiedType: const FullType(UserPublicResponse),
    );
    yield r'status';
    yield serializers.serialize(
      object.status,
      specifiedType: const FullType(ListingStatus),
    );
    yield r'title';
    yield serializers.serialize(
      object.title,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    ListingResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ListingResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'category':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(ListingCategory),
          ) as ListingCategory;
          result.category = valueDes;
          break;
        case r'condition':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(ListingCondition),
          ) as ListingCondition;
          result.condition = valueDes;
          break;
        case r'created_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.createdAt = valueDes;
          break;
        case r'description':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.description = valueDes;
          break;
        case r'expires_at':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.expiresAt = valueDes;
          break;
        case r'id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.id = valueDes;
          break;
        case r'images':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(ListingImageResponse)]),
          ) as BuiltList<ListingImageResponse>;
          result.images.replace(valueDes);
          break;
        case r'price_cents':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.priceCents = valueDes;
          break;
        case r'seller':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(UserPublicResponse),
          ) as UserPublicResponse;
          result.seller.replace(valueDes);
          break;
        case r'status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(ListingStatus),
          ) as ListingStatus;
          result.status = valueDes;
          break;
        case r'title':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.title = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ListingResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ListingResponseBuilder();
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

