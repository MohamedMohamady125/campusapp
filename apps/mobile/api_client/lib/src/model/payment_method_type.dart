//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'payment_method_type.g.dart';

class PaymentMethodType extends EnumClass {

  /// Off-app peer payment rails a runner can advertise (food-runs spec).  CampusConnect never moves money — these are just handles a requester uses to pay the runner in the corresponding third-party app.
  @BuiltValueEnumConst(wireName: r'venmo')
  static const PaymentMethodType venmo = _$venmo;
  /// Off-app peer payment rails a runner can advertise (food-runs spec).  CampusConnect never moves money — these are just handles a requester uses to pay the runner in the corresponding third-party app.
  @BuiltValueEnumConst(wireName: r'zelle')
  static const PaymentMethodType zelle = _$zelle;
  /// Off-app peer payment rails a runner can advertise (food-runs spec).  CampusConnect never moves money — these are just handles a requester uses to pay the runner in the corresponding third-party app.
  @BuiltValueEnumConst(wireName: r'cashapp')
  static const PaymentMethodType cashapp = _$cashapp;
  /// Off-app peer payment rails a runner can advertise (food-runs spec).  CampusConnect never moves money — these are just handles a requester uses to pay the runner in the corresponding third-party app.
  @BuiltValueEnumConst(wireName: r'paypal')
  static const PaymentMethodType paypal = _$paypal;
  /// Off-app peer payment rails a runner can advertise (food-runs spec).  CampusConnect never moves money — these are just handles a requester uses to pay the runner in the corresponding third-party app.
  @BuiltValueEnumConst(wireName: r'apple_cash')
  static const PaymentMethodType appleCash = _$appleCash;

  static Serializer<PaymentMethodType> get serializer => _$paymentMethodTypeSerializer;

  const PaymentMethodType._(String name): super(name);

  static BuiltSet<PaymentMethodType> get values => _$values;
  static PaymentMethodType valueOf(String name) => _$valueOf(name);
}

/// Optionally, enum_class can generate a mixin to go with your enum for use
/// with Angular. It exposes your enum constants as getters. So, if you mix it
/// in to your Dart component class, the values become available to the
/// corresponding Angular template.
///
/// Trigger mixin generation by writing a line like this one next to your enum.
abstract class PaymentMethodTypeMixin = Object with _$PaymentMethodTypeMixin;

