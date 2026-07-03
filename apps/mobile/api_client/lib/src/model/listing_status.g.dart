// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'listing_status.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const ListingStatus _$active = const ListingStatus._('active');
const ListingStatus _$sold = const ListingStatus._('sold');
const ListingStatus _$removed = const ListingStatus._('removed');

ListingStatus _$valueOf(String name) {
  switch (name) {
    case 'active':
      return _$active;
    case 'sold':
      return _$sold;
    case 'removed':
      return _$removed;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<ListingStatus> _$values =
    BuiltSet<ListingStatus>(const <ListingStatus>[
  _$active,
  _$sold,
  _$removed,
]);

class _$ListingStatusMeta {
  const _$ListingStatusMeta();
  ListingStatus get active => _$active;
  ListingStatus get sold => _$sold;
  ListingStatus get removed => _$removed;
  ListingStatus valueOf(String name) => _$valueOf(name);
  BuiltSet<ListingStatus> get values => _$values;
}

abstract class _$ListingStatusMixin {
  // ignore: non_constant_identifier_names
  _$ListingStatusMeta get ListingStatus => const _$ListingStatusMeta();
}

Serializer<ListingStatus> _$listingStatusSerializer =
    _$ListingStatusSerializer();

class _$ListingStatusSerializer implements PrimitiveSerializer<ListingStatus> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'active': 'active',
    'sold': 'sold',
    'removed': 'removed',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'active': 'active',
    'sold': 'sold',
    'removed': 'removed',
  };

  @override
  final Iterable<Type> types = const <Type>[ListingStatus];
  @override
  final String wireName = 'ListingStatus';

  @override
  Object serialize(Serializers serializers, ListingStatus object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  ListingStatus deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      ListingStatus.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
