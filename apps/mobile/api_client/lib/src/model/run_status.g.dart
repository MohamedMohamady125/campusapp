// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'run_status.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const RunStatus _$open = const RunStatus._('open');
const RunStatus _$locked = const RunStatus._('locked');
const RunStatus _$atStore = const RunStatus._('atStore');
const RunStatus _$delivering = const RunStatus._('delivering');
const RunStatus _$done = const RunStatus._('done');
const RunStatus _$expired = const RunStatus._('expired');
const RunStatus _$cancelled = const RunStatus._('cancelled');

RunStatus _$valueOf(String name) {
  switch (name) {
    case 'open':
      return _$open;
    case 'locked':
      return _$locked;
    case 'atStore':
      return _$atStore;
    case 'delivering':
      return _$delivering;
    case 'done':
      return _$done;
    case 'expired':
      return _$expired;
    case 'cancelled':
      return _$cancelled;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<RunStatus> _$values = BuiltSet<RunStatus>(const <RunStatus>[
  _$open,
  _$locked,
  _$atStore,
  _$delivering,
  _$done,
  _$expired,
  _$cancelled,
]);

class _$RunStatusMeta {
  const _$RunStatusMeta();
  RunStatus get open => _$open;
  RunStatus get locked => _$locked;
  RunStatus get atStore => _$atStore;
  RunStatus get delivering => _$delivering;
  RunStatus get done => _$done;
  RunStatus get expired => _$expired;
  RunStatus get cancelled => _$cancelled;
  RunStatus valueOf(String name) => _$valueOf(name);
  BuiltSet<RunStatus> get values => _$values;
}

abstract class _$RunStatusMixin {
  // ignore: non_constant_identifier_names
  _$RunStatusMeta get RunStatus => const _$RunStatusMeta();
}

Serializer<RunStatus> _$runStatusSerializer = _$RunStatusSerializer();

class _$RunStatusSerializer implements PrimitiveSerializer<RunStatus> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'open': 'open',
    'locked': 'locked',
    'atStore': 'at_store',
    'delivering': 'delivering',
    'done': 'done',
    'expired': 'expired',
    'cancelled': 'cancelled',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'open': 'open',
    'locked': 'locked',
    'at_store': 'atStore',
    'delivering': 'delivering',
    'done': 'done',
    'expired': 'expired',
    'cancelled': 'cancelled',
  };

  @override
  final Iterable<Type> types = const <Type>[RunStatus];
  @override
  final String wireName = 'RunStatus';

  @override
  Object serialize(Serializers serializers, RunStatus object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  RunStatus deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      RunStatus.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
