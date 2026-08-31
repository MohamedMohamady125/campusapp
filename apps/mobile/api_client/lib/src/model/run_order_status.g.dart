// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'run_order_status.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const RunOrderStatus _$requested = const RunOrderStatus._('requested');
const RunOrderStatus _$accepted = const RunOrderStatus._('accepted');
const RunOrderStatus _$declined = const RunOrderStatus._('declined');
const RunOrderStatus _$cancelled = const RunOrderStatus._('cancelled');
const RunOrderStatus _$delivered = const RunOrderStatus._('delivered');
const RunOrderStatus _$received = const RunOrderStatus._('received');
const RunOrderStatus _$noShow = const RunOrderStatus._('noShow');

RunOrderStatus _$valueOf(String name) {
  switch (name) {
    case 'requested':
      return _$requested;
    case 'accepted':
      return _$accepted;
    case 'declined':
      return _$declined;
    case 'cancelled':
      return _$cancelled;
    case 'delivered':
      return _$delivered;
    case 'received':
      return _$received;
    case 'noShow':
      return _$noShow;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<RunOrderStatus> _$values =
    BuiltSet<RunOrderStatus>(const <RunOrderStatus>[
  _$requested,
  _$accepted,
  _$declined,
  _$cancelled,
  _$delivered,
  _$received,
  _$noShow,
]);

class _$RunOrderStatusMeta {
  const _$RunOrderStatusMeta();
  RunOrderStatus get requested => _$requested;
  RunOrderStatus get accepted => _$accepted;
  RunOrderStatus get declined => _$declined;
  RunOrderStatus get cancelled => _$cancelled;
  RunOrderStatus get delivered => _$delivered;
  RunOrderStatus get received => _$received;
  RunOrderStatus get noShow => _$noShow;
  RunOrderStatus valueOf(String name) => _$valueOf(name);
  BuiltSet<RunOrderStatus> get values => _$values;
}

abstract class _$RunOrderStatusMixin {
  // ignore: non_constant_identifier_names
  _$RunOrderStatusMeta get RunOrderStatus => const _$RunOrderStatusMeta();
}

Serializer<RunOrderStatus> _$runOrderStatusSerializer =
    _$RunOrderStatusSerializer();

class _$RunOrderStatusSerializer
    implements PrimitiveSerializer<RunOrderStatus> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'requested': 'requested',
    'accepted': 'accepted',
    'declined': 'declined',
    'cancelled': 'cancelled',
    'delivered': 'delivered',
    'received': 'received',
    'noShow': 'no_show',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'requested': 'requested',
    'accepted': 'accepted',
    'declined': 'declined',
    'cancelled': 'cancelled',
    'delivered': 'delivered',
    'received': 'received',
    'no_show': 'noShow',
  };

  @override
  final Iterable<Type> types = const <Type>[RunOrderStatus];
  @override
  final String wireName = 'RunOrderStatus';

  @override
  Object serialize(Serializers serializers, RunOrderStatus object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  RunOrderStatus deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      RunOrderStatus.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
