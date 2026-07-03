//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'listing_category.g.dart';

class ListingCategory extends EnumClass {

  @BuiltValueEnumConst(wireName: r'textbooks')
  static const ListingCategory textbooks = _$textbooks;
  @BuiltValueEnumConst(wireName: r'furniture')
  static const ListingCategory furniture = _$furniture;
  @BuiltValueEnumConst(wireName: r'electronics')
  static const ListingCategory electronics = _$electronics;
  @BuiltValueEnumConst(wireName: r'tickets')
  static const ListingCategory tickets = _$tickets;
  @BuiltValueEnumConst(wireName: r'clothing')
  static const ListingCategory clothing = _$clothing;
  @BuiltValueEnumConst(wireName: r'other')
  static const ListingCategory other = _$other;

  static Serializer<ListingCategory> get serializer => _$listingCategorySerializer;

  const ListingCategory._(String name): super(name);

  static BuiltSet<ListingCategory> get values => _$values;
  static ListingCategory valueOf(String name) => _$valueOf(name);
}

/// Optionally, enum_class can generate a mixin to go with your enum for use
/// with Angular. It exposes your enum constants as getters. So, if you mix it
/// in to your Dart component class, the values become available to the
/// corresponding Angular template.
///
/// Trigger mixin generation by writing a line like this one next to your enum.
abstract class ListingCategoryMixin = Object with _$ListingCategoryMixin;

