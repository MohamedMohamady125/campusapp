// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'listing_condition.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const ListingCondition _$new_ = const ListingCondition._('new_');
const ListingCondition _$likeNew = const ListingCondition._('likeNew');
const ListingCondition _$good = const ListingCondition._('good');
const ListingCondition _$fair = const ListingCondition._('fair');
const ListingCondition _$poor = const ListingCondition._('poor');

ListingCondition _$valueOf(String name) {
  switch (name) {
    case 'new_':
      return _$new_;
    case 'likeNew':
      return _$likeNew;
    case 'good':
      return _$good;
    case 'fair':
      return _$fair;
    case 'poor':
      return _$poor;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<ListingCondition> _$values =
    BuiltSet<ListingCondition>(const <ListingCondition>[
  _$new_,
  _$likeNew,
  _$good,
  _$fair,
  _$poor,
]);

class _$ListingConditionMeta {
  const _$ListingConditionMeta();
  ListingCondition get new_ => _$new_;
  ListingCondition get likeNew => _$likeNew;
  ListingCondition get good => _$good;
  ListingCondition get fair => _$fair;
  ListingCondition get poor => _$poor;
  ListingCondition valueOf(String name) => _$valueOf(name);
  BuiltSet<ListingCondition> get values => _$values;
}

abstract class _$ListingConditionMixin {
  // ignore: non_constant_identifier_names
  _$ListingConditionMeta get ListingCondition => const _$ListingConditionMeta();
}

Serializer<ListingCondition> _$listingConditionSerializer =
    _$ListingConditionSerializer();

class _$ListingConditionSerializer
    implements PrimitiveSerializer<ListingCondition> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'new_': 'new',
    'likeNew': 'like_new',
    'good': 'good',
    'fair': 'fair',
    'poor': 'poor',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'new': 'new_',
    'like_new': 'likeNew',
    'good': 'good',
    'fair': 'fair',
    'poor': 'poor',
  };

  @override
  final Iterable<Type> types = const <Type>[ListingCondition];
  @override
  final String wireName = 'ListingCondition';

  @override
  Object serialize(Serializers serializers, ListingCondition object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  ListingCondition deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      ListingCondition.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
