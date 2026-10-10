//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'dart:core';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:one_of/any_of.dart';

part 'properties_value.g.dart';

/// PropertiesValue
@BuiltValue()
abstract class PropertiesValue implements Built<PropertiesValue, PropertiesValueBuilder> {
  /// Any Of [String], [bool], [int], [num]
  AnyOf get anyOf;

  PropertiesValue._();

  factory PropertiesValue([void updates(PropertiesValueBuilder b)]) = _$PropertiesValue;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(PropertiesValueBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<PropertiesValue> get serializer => _$PropertiesValueSerializer();
}

class _$PropertiesValueSerializer implements PrimitiveSerializer<PropertiesValue> {
  @override
  final Iterable<Type> types = const [PropertiesValue, _$PropertiesValue];

  @override
  final String wireName = r'PropertiesValue';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    PropertiesValue object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
  }

  @override
  Object serialize(
    Serializers serializers,
    PropertiesValue object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final anyOf = object.anyOf;
    return serializers.serialize(anyOf, specifiedType: FullType(AnyOf, anyOf.valueTypes.map((type) => FullType(type)).toList()))!;
  }

  @override
  PropertiesValue deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = PropertiesValueBuilder();
    Object? anyOfDataSrc;
    final targetType = const FullType(AnyOf, [FullType(String), FullType(int), FullType(num), FullType(bool), ]);
    anyOfDataSrc = serialized;
    result.anyOf = serializers.deserialize(anyOfDataSrc, specifiedType: targetType) as AnyOf;
    return result.build();
  }
}

