// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'listing_category.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const ListingCategory _$textbooks = const ListingCategory._('textbooks');
const ListingCategory _$furniture = const ListingCategory._('furniture');
const ListingCategory _$electronics = const ListingCategory._('electronics');
const ListingCategory _$tickets = const ListingCategory._('tickets');
const ListingCategory _$clothing = const ListingCategory._('clothing');
const ListingCategory _$other = const ListingCategory._('other');

ListingCategory _$valueOf(String name) {
  switch (name) {
    case 'textbooks':
      return _$textbooks;
    case 'furniture':
      return _$furniture;
    case 'electronics':
      return _$electronics;
    case 'tickets':
      return _$tickets;
    case 'clothing':
      return _$clothing;
    case 'other':
      return _$other;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<ListingCategory> _$values =
    BuiltSet<ListingCategory>(const <ListingCategory>[
  _$textbooks,
  _$furniture,
  _$electronics,
  _$tickets,
  _$clothing,
  _$other,
]);

class _$ListingCategoryMeta {
  const _$ListingCategoryMeta();
  ListingCategory get textbooks => _$textbooks;
  ListingCategory get furniture => _$furniture;
  ListingCategory get electronics => _$electronics;
  ListingCategory get tickets => _$tickets;
  ListingCategory get clothing => _$clothing;
  ListingCategory get other => _$other;
  ListingCategory valueOf(String name) => _$valueOf(name);
  BuiltSet<ListingCategory> get values => _$values;
}

abstract class _$ListingCategoryMixin {
  // ignore: non_constant_identifier_names
  _$ListingCategoryMeta get ListingCategory => const _$ListingCategoryMeta();
}

Serializer<ListingCategory> _$listingCategorySerializer =
    _$ListingCategorySerializer();

class _$ListingCategorySerializer
    implements PrimitiveSerializer<ListingCategory> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'textbooks': 'textbooks',
    'furniture': 'furniture',
    'electronics': 'electronics',
    'tickets': 'tickets',
    'clothing': 'clothing',
    'other': 'other',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'textbooks': 'textbooks',
    'furniture': 'furniture',
    'electronics': 'electronics',
    'tickets': 'tickets',
    'clothing': 'clothing',
    'other': 'other',
  };

  @override
  final Iterable<Type> types = const <Type>[ListingCategory];
  @override
  final String wireName = 'ListingCategory';

  @override
  Object serialize(Serializers serializers, ListingCategory object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  ListingCategory deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      ListingCategory.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
