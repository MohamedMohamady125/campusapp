// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'report_target_type.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const ReportTargetType _$listing = const ReportTargetType._('listing');
const ReportTargetType _$message = const ReportTargetType._('message');
const ReportTargetType _$chatMessage = const ReportTargetType._('chatMessage');
const ReportTargetType _$user = const ReportTargetType._('user');

ReportTargetType _$valueOf(String name) {
  switch (name) {
    case 'listing':
      return _$listing;
    case 'message':
      return _$message;
    case 'chatMessage':
      return _$chatMessage;
    case 'user':
      return _$user;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<ReportTargetType> _$values =
    BuiltSet<ReportTargetType>(const <ReportTargetType>[
  _$listing,
  _$message,
  _$chatMessage,
  _$user,
]);

class _$ReportTargetTypeMeta {
  const _$ReportTargetTypeMeta();
  ReportTargetType get listing => _$listing;
  ReportTargetType get message => _$message;
  ReportTargetType get chatMessage => _$chatMessage;
  ReportTargetType get user => _$user;
  ReportTargetType valueOf(String name) => _$valueOf(name);
  BuiltSet<ReportTargetType> get values => _$values;
}

abstract class _$ReportTargetTypeMixin {
  // ignore: non_constant_identifier_names
  _$ReportTargetTypeMeta get ReportTargetType => const _$ReportTargetTypeMeta();
}

Serializer<ReportTargetType> _$reportTargetTypeSerializer =
    _$ReportTargetTypeSerializer();

class _$ReportTargetTypeSerializer
    implements PrimitiveSerializer<ReportTargetType> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'listing': 'listing',
    'message': 'message',
    'chatMessage': 'chat_message',
    'user': 'user',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'listing': 'listing',
    'message': 'message',
    'chat_message': 'chatMessage',
    'user': 'user',
  };

  @override
  final Iterable<Type> types = const <Type>[ReportTargetType];
  @override
  final String wireName = 'ReportTargetType';

  @override
  Object serialize(Serializers serializers, ReportTargetType object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  ReportTargetType deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      ReportTargetType.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
