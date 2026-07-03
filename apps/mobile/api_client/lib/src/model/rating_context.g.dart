// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rating_context.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const RatingContext _$listing = const RatingContext._('listing');
const RatingContext _$tutoring = const RatingContext._('tutoring');

RatingContext _$valueOf(String name) {
  switch (name) {
    case 'listing':
      return _$listing;
    case 'tutoring':
      return _$tutoring;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<RatingContext> _$values =
    BuiltSet<RatingContext>(const <RatingContext>[
  _$listing,
  _$tutoring,
]);

class _$RatingContextMeta {
  const _$RatingContextMeta();
  RatingContext get listing => _$listing;
  RatingContext get tutoring => _$tutoring;
  RatingContext valueOf(String name) => _$valueOf(name);
  BuiltSet<RatingContext> get values => _$values;
}

abstract class _$RatingContextMixin {
  // ignore: non_constant_identifier_names
  _$RatingContextMeta get RatingContext => const _$RatingContextMeta();
}

Serializer<RatingContext> _$ratingContextSerializer =
    _$RatingContextSerializer();

class _$RatingContextSerializer implements PrimitiveSerializer<RatingContext> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'listing': 'listing',
    'tutoring': 'tutoring',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'listing': 'listing',
    'tutoring': 'tutoring',
  };

  @override
  final Iterable<Type> types = const <Type>[RatingContext];
  @override
  final String wireName = 'RatingContext';

  @override
  Object serialize(Serializers serializers, RatingContext object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  RatingContext deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      RatingContext.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
