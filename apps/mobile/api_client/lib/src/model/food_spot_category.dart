//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'food_spot_category.g.dart';

class FoodSpotCategory extends EnumClass {

  @BuiltValueEnumConst(wireName: r'campus')
  static const FoodSpotCategory campus = _$campus;
  @BuiltValueEnumConst(wireName: r'off_campus')
  static const FoodSpotCategory offCampus = _$offCampus;

  static Serializer<FoodSpotCategory> get serializer => _$foodSpotCategorySerializer;

  const FoodSpotCategory._(String name): super(name);

  static BuiltSet<FoodSpotCategory> get values => _$values;
  static FoodSpotCategory valueOf(String name) => _$valueOf(name);
}

/// Optionally, enum_class can generate a mixin to go with your enum for use
/// with Angular. It exposes your enum constants as getters. So, if you mix it
/// in to your Dart component class, the values become available to the
/// corresponding Angular template.
///
/// Trigger mixin generation by writing a line like this one next to your enum.
abstract class FoodSpotCategoryMixin = Object with _$FoodSpotCategoryMixin;

