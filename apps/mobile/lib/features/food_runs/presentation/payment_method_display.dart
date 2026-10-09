import 'package:campus_api/campus_api.dart';
import 'package:campusconnect/design_system/material.dart';

/// Presentation metadata for a payment rail (food-runs spec): CampusConnect
/// never moves money, these just label the off-app handle a requester uses.
extension PaymentMethodTypeDisplay on PaymentMethodType {
  String get label => switch (this) {
    PaymentMethodType.venmo => 'Venmo',
    PaymentMethodType.zelle => 'Zelle',
    PaymentMethodType.cashapp => 'Cash App',
    PaymentMethodType.paypal => 'PayPal',
    PaymentMethodType.appleCash => 'Apple Cash',
    _ => 'Payment',
  };

  IconData get icon => switch (this) {
    PaymentMethodType.venmo => Icons.account_balance_wallet_outlined,
    PaymentMethodType.zelle => Icons.bolt_outlined,
    PaymentMethodType.cashapp => Icons.attach_money,
    PaymentMethodType.paypal => Icons.account_balance_outlined,
    PaymentMethodType.appleCash => Icons.phone_iphone,
    _ => Icons.payments_outlined,
  };

  /// API wire value (the enum's Dart name differs for apple_cash). Used for
  /// Run.paymentPref, which carries a raw string ("cash" or a rail type).
  String get wireValue => switch (this) {
    PaymentMethodType.appleCash => 'apple_cash',
    _ => name,
  };

  /// Hint text for the handle field — the shape each app expects.
  String get handleHint => switch (this) {
    PaymentMethodType.venmo => '@your-venmo',
    PaymentMethodType.zelle => 'Phone or email',
    PaymentMethodType.cashapp => r'$yourcashtag',
    PaymentMethodType.paypal => 'PayPal.me link or email',
    PaymentMethodType.appleCash => 'Phone number',
    _ => 'Handle',
  };
}

/// Human label for Run.paymentPrefs ("cash" + rail wire values), e.g.
/// "Cash or Venmo". Null when empty/unknown — callers hide the line then.
String? paymentPrefsLabel(Iterable<String> prefs) {
  final labels = <String>[];
  for (final pref in prefs) {
    if (pref == 'cash') {
      labels.add('Cash');
      continue;
    }
    for (final t in kSelectablePaymentTypes) {
      if (t.wireValue == pref) {
        labels.add(t.label);
        break;
      }
    }
  }
  if (labels.isEmpty) return null;
  if (labels.length == 1) return labels.first;
  return '${labels.sublist(0, labels.length - 1).join(', ')} '
      'or ${labels.last}';
}

/// The types offered in pickers, in the order students expect them.
const List<PaymentMethodType> kSelectablePaymentTypes = [
  PaymentMethodType.venmo,
  PaymentMethodType.zelle,
  PaymentMethodType.cashapp,
  PaymentMethodType.paypal,
  PaymentMethodType.appleCash,
];
