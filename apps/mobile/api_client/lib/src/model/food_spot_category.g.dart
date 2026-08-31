// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'food_spot_category.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const FoodSpotCategory _$campus = const FoodSpotCategory._('campus');
const FoodSpotCategory _$offCampus = const FoodSpotCategory._('offCampus');

FoodSpotCategory _$valueOf(String name) {
  switch (name) {
    case 'campus':
      return _$campus;
    case 'offCampus':
      return _$offCampus;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<FoodSpotCategory> _$values =
    BuiltSet<FoodSpotCategory>(const <FoodSpotCategory>[
  _$campus,
  _$offCampus,
]);

class _$FoodSpotCategoryMeta {
  const _$FoodSpotCategoryMeta();
  FoodSpotCategory get campus => _$campus;
  FoodSpotCategory get offCampus => _$offCampus;
  FoodSpotCategory valueOf(String name) => _$valueOf(name);
  BuiltSet<FoodSpotCategory> get values => _$values;
}

abstract class _$FoodSpotCategoryMixin {
  // ignore: non_constant_identifier_names
  _$FoodSpotCategoryMeta get FoodSpotCategory => const _$FoodSpotCategoryMeta();
}

Serializer<FoodSpotCategory> _$foodSpotCategorySerializer =
    _$FoodSpotCategorySerializer();

class _$FoodSpotCategorySerializer
    implements PrimitiveSerializer<FoodSpotCategory> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'campus': 'campus',
    'offCampus': 'off_campus',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'campus': 'campus',
    'off_campus': 'offCampus',
  };

  @override
  final Iterable<Type> types = const <Type>[FoodSpotCategory];
  @override
  final String wireName = 'FoodSpotCategory';

  @override
  Object serialize(Serializers serializers, FoodSpotCategory object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  FoodSpotCategory deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      FoodSpotCategory.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
