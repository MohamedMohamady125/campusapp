// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'moderation_status.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const ModerationStatus _$pending = const ModerationStatus._('pending');
const ModerationStatus _$approved = const ModerationStatus._('approved');
const ModerationStatus _$rejected = const ModerationStatus._('rejected');

ModerationStatus _$valueOf(String name) {
  switch (name) {
    case 'pending':
      return _$pending;
    case 'approved':
      return _$approved;
    case 'rejected':
      return _$rejected;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<ModerationStatus> _$values =
    BuiltSet<ModerationStatus>(const <ModerationStatus>[
  _$pending,
  _$approved,
  _$rejected,
]);

class _$ModerationStatusMeta {
  const _$ModerationStatusMeta();
  ModerationStatus get pending => _$pending;
  ModerationStatus get approved => _$approved;
  ModerationStatus get rejected => _$rejected;
  ModerationStatus valueOf(String name) => _$valueOf(name);
  BuiltSet<ModerationStatus> get values => _$values;
}

abstract class _$ModerationStatusMixin {
  // ignore: non_constant_identifier_names
  _$ModerationStatusMeta get ModerationStatus => const _$ModerationStatusMeta();
}

Serializer<ModerationStatus> _$moderationStatusSerializer =
    _$ModerationStatusSerializer();

class _$ModerationStatusSerializer
    implements PrimitiveSerializer<ModerationStatus> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'pending': 'pending',
    'approved': 'approved',
    'rejected': 'rejected',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'pending': 'pending',
    'approved': 'approved',
    'rejected': 'rejected',
  };

  @override
  final Iterable<Type> types = const <Type>[ModerationStatus];
  @override
  final String wireName = 'ModerationStatus';

  @override
  Object serialize(Serializers serializers, ModerationStatus object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  ModerationStatus deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      ModerationStatus.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
