// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'report_status.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const ReportStatus _$open = const ReportStatus._('open');
const ReportStatus _$reviewing = const ReportStatus._('reviewing');
const ReportStatus _$actioned = const ReportStatus._('actioned');
const ReportStatus _$dismissed = const ReportStatus._('dismissed');

ReportStatus _$valueOf(String name) {
  switch (name) {
    case 'open':
      return _$open;
    case 'reviewing':
      return _$reviewing;
    case 'actioned':
      return _$actioned;
    case 'dismissed':
      return _$dismissed;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<ReportStatus> _$values =
    BuiltSet<ReportStatus>(const <ReportStatus>[
  _$open,
  _$reviewing,
  _$actioned,
  _$dismissed,
]);

class _$ReportStatusMeta {
  const _$ReportStatusMeta();
  ReportStatus get open => _$open;
  ReportStatus get reviewing => _$reviewing;
  ReportStatus get actioned => _$actioned;
  ReportStatus get dismissed => _$dismissed;
  ReportStatus valueOf(String name) => _$valueOf(name);
  BuiltSet<ReportStatus> get values => _$values;
}

abstract class _$ReportStatusMixin {
  // ignore: non_constant_identifier_names
  _$ReportStatusMeta get ReportStatus => const _$ReportStatusMeta();
}

Serializer<ReportStatus> _$reportStatusSerializer = _$ReportStatusSerializer();

class _$ReportStatusSerializer implements PrimitiveSerializer<ReportStatus> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'open': 'open',
    'reviewing': 'reviewing',
    'actioned': 'actioned',
    'dismissed': 'dismissed',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'open': 'open',
    'reviewing': 'reviewing',
    'actioned': 'actioned',
    'dismissed': 'dismissed',
  };

  @override
  final Iterable<Type> types = const <Type>[ReportStatus];
  @override
  final String wireName = 'ReportStatus';

  @override
  Object serialize(Serializers serializers, ReportStatus object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  ReportStatus deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      ReportStatus.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
