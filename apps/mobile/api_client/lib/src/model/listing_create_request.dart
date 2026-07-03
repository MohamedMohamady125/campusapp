//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:campus_api/src/model/listing_condition.dart';
import 'package:campus_api/src/model/listing_category.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'listing_create_request.g.dart';

/// ListingCreateRequest
///
/// Properties:
/// * [category] 
/// * [condition] 
/// * [description] 
/// * [priceCents] 
/// * [title] 
@BuiltValue()
abstract class ListingCreateRequest implements Built<ListingCreateRequest, ListingCreateRequestBuilder> {
  @BuiltValueField(wireName: r'category')
  ListingCategory get category;
  // enum categoryEnum {  textbooks,  furniture,  electronics,  tickets,  clothing,  other,  };

  @BuiltValueField(wireName: r'condition')
  ListingCondition get condition;
  // enum conditionEnum {  new,  like_new,  good,  fair,  poor,  };

  @BuiltValueField(wireName: r'description')
  String get description;

  @BuiltValueField(wireName: r'price_cents')
  int get priceCents;

  @BuiltValueField(wireName: r'title')
  String get title;

  ListingCreateRequest._();

  factory ListingCreateRequest([void updates(ListingCreateRequestBuilder b)]) = _$ListingCreateRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ListingCreateRequestBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ListingCreateRequest> get serializer => _$ListingCreateRequestSerializer();
}

class _$ListingCreateRequestSerializer implements PrimitiveSerializer<ListingCreateRequest> {
  @override
  final Iterable<Type> types = const [ListingCreateRequest, _$ListingCreateRequest];

  @override
  final String wireName = r'ListingCreateRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ListingCreateRequest object, {
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
    yield r'description';
    yield serializers.serialize(
      object.description,
      specifiedType: const FullType(String),
    );
    yield r'price_cents';
    yield serializers.serialize(
      object.priceCents,
      specifiedType: const FullType(int),
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
    ListingCreateRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ListingCreateRequestBuilder result,
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
        case r'description':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.description = valueDes;
          break;
        case r'price_cents':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.priceCents = valueDes;
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
  ListingCreateRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ListingCreateRequestBuilder();
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

