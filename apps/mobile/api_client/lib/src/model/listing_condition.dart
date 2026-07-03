//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'listing_condition.g.dart';

class ListingCondition extends EnumClass {

  @BuiltValueEnumConst(wireName: r'new')
  static const ListingCondition new_ = _$new_;
  @BuiltValueEnumConst(wireName: r'like_new')
  static const ListingCondition likeNew = _$likeNew;
  @BuiltValueEnumConst(wireName: r'good')
  static const ListingCondition good = _$good;
  @BuiltValueEnumConst(wireName: r'fair')
  static const ListingCondition fair = _$fair;
  @BuiltValueEnumConst(wireName: r'poor')
  static const ListingCondition poor = _$poor;

  static Serializer<ListingCondition> get serializer => _$listingConditionSerializer;

  const ListingCondition._(String name): super(name);

  static BuiltSet<ListingCondition> get values => _$values;
  static ListingCondition valueOf(String name) => _$valueOf(name);
}

/// Optionally, enum_class can generate a mixin to go with your enum for use
/// with Angular. It exposes your enum constants as getters. So, if you mix it
/// in to your Dart component class, the values become available to the
/// corresponding Angular template.
///
/// Trigger mixin generation by writing a line like this one next to your enum.
abstract class ListingConditionMixin = Object with _$ListingConditionMixin;

