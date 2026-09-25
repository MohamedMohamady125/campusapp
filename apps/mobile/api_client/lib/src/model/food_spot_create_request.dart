//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:campus_api/src/model/food_spot_category.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'food_spot_create_request.g.dart';

/// Admin-only: add a campus/off-campus destination to the catalog.
///
/// Properties:
/// * [category] 
/// * [description] 
/// * [lat] 
/// * [lng] 
/// * [name] 
@BuiltValue()
abstract class FoodSpotCreateRequest implements Built<FoodSpotCreateRequest, FoodSpotCreateRequestBuilder> {
  @BuiltValueField(wireName: r'category')
  FoodSpotCategory? get category;
  // enum categoryEnum {  campus,  off_campus,  };

  @BuiltValueField(wireName: r'description')
  String? get description;

  @BuiltValueField(wireName: r'lat')
  num? get lat;

  @BuiltValueField(wireName: r'lng')
  num? get lng;

  @BuiltValueField(wireName: r'name')
  String get name;

  FoodSpotCreateRequest._();

  factory FoodSpotCreateRequest([void updates(FoodSpotCreateRequestBuilder b)]) = _$FoodSpotCreateRequest;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(FoodSpotCreateRequestBuilder b) => b
      ..category = FoodSpotCategory.campus;

  @BuiltValueSerializer(custom: true)
  static Serializer<FoodSpotCreateRequest> get serializer => _$FoodSpotCreateRequestSerializer();
}

class _$FoodSpotCreateRequestSerializer implements PrimitiveSerializer<FoodSpotCreateRequest> {
  @override
  final Iterable<Type> types = const [FoodSpotCreateRequest, _$FoodSpotCreateRequest];

  @override
  final String wireName = r'FoodSpotCreateRequest';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    FoodSpotCreateRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.category != null) {
      yield r'category';
      yield serializers.serialize(
        object.category,
        specifiedType: const FullType(FoodSpotCategory),
      );
    }
    if (object.description != null) {
      yield r'description';
      yield serializers.serialize(
        object.description,
        specifiedType: const FullType.nullable(String),
      );
    }
    if (object.lat != null) {
      yield r'lat';
      yield serializers.serialize(
        object.lat,
        specifiedType: const FullType.nullable(num),
      );
    }
    if (object.lng != null) {
      yield r'lng';
      yield serializers.serialize(
        object.lng,
        specifiedType: const FullType.nullable(num),
      );
    }
    yield r'name';
    yield serializers.serialize(
      object.name,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    FoodSpotCreateRequest object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required FoodSpotCreateRequestBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'category':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(FoodSpotCategory),
          ) as FoodSpotCategory;
          result.category = valueDes;
          break;
        case r'description':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.description = valueDes;
          break;
        case r'lat':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(num),
          ) as num?;
          if (valueDes == null) continue;
          result.lat = valueDes;
          break;
        case r'lng':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(num),
          ) as num?;
          if (valueDes == null) continue;
          result.lng = valueDes;
          break;
        case r'name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.name = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  FoodSpotCreateRequest deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = FoodSpotCreateRequestBuilder();
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

