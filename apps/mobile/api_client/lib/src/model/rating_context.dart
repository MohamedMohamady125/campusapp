//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'rating_context.g.dart';

class RatingContext extends EnumClass {

  @BuiltValueEnumConst(wireName: r'listing')
  static const RatingContext listing = _$listing;
  @BuiltValueEnumConst(wireName: r'tutoring')
  static const RatingContext tutoring = _$tutoring;

  static Serializer<RatingContext> get serializer => _$ratingContextSerializer;

  const RatingContext._(String name): super(name);

  static BuiltSet<RatingContext> get values => _$values;
  static RatingContext valueOf(String name) => _$valueOf(name);
}

/// Optionally, enum_class can generate a mixin to go with your enum for use
/// with Angular. It exposes your enum constants as getters. So, if you mix it
/// in to your Dart component class, the values become available to the
/// corresponding Angular template.
///
/// Trigger mixin generation by writing a line like this one next to your enum.
abstract class RatingContextMixin = Object with _$RatingContextMixin;

