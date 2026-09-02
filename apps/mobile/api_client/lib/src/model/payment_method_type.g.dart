// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_method_type.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const PaymentMethodType _$venmo = const PaymentMethodType._('venmo');
const PaymentMethodType _$zelle = const PaymentMethodType._('zelle');
const PaymentMethodType _$cashapp = const PaymentMethodType._('cashapp');
const PaymentMethodType _$paypal = const PaymentMethodType._('paypal');
const PaymentMethodType _$appleCash = const PaymentMethodType._('appleCash');

PaymentMethodType _$valueOf(String name) {
  switch (name) {
    case 'venmo':
      return _$venmo;
    case 'zelle':
      return _$zelle;
    case 'cashapp':
      return _$cashapp;
    case 'paypal':
      return _$paypal;
    case 'appleCash':
      return _$appleCash;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<PaymentMethodType> _$values =
    BuiltSet<PaymentMethodType>(const <PaymentMethodType>[
  _$venmo,
  _$zelle,
  _$cashapp,
  _$paypal,
  _$appleCash,
]);

class _$PaymentMethodTypeMeta {
  const _$PaymentMethodTypeMeta();
  PaymentMethodType get venmo => _$venmo;
  PaymentMethodType get zelle => _$zelle;
  PaymentMethodType get cashapp => _$cashapp;
  PaymentMethodType get paypal => _$paypal;
  PaymentMethodType get appleCash => _$appleCash;
  PaymentMethodType valueOf(String name) => _$valueOf(name);
  BuiltSet<PaymentMethodType> get values => _$values;
}

abstract class _$PaymentMethodTypeMixin {
  // ignore: non_constant_identifier_names
  _$PaymentMethodTypeMeta get PaymentMethodType =>
      const _$PaymentMethodTypeMeta();
}

Serializer<PaymentMethodType> _$paymentMethodTypeSerializer =
    _$PaymentMethodTypeSerializer();

class _$PaymentMethodTypeSerializer
    implements PrimitiveSerializer<PaymentMethodType> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'venmo': 'venmo',
    'zelle': 'zelle',
    'cashapp': 'cashapp',
    'paypal': 'paypal',
    'appleCash': 'apple_cash',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'venmo': 'venmo',
    'zelle': 'zelle',
    'cashapp': 'cashapp',
    'paypal': 'paypal',
    'apple_cash': 'appleCash',
  };

  @override
  final Iterable<Type> types = const <Type>[PaymentMethodType];
  @override
  final String wireName = 'PaymentMethodType';

  @override
  Object serialize(Serializers serializers, PaymentMethodType object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  PaymentMethodType deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      PaymentMethodType.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
