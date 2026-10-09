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

/// Deep link that opens the payment app with the runner's handle (and the
/// amount, where the app supports it) prefilled — tap-to-pay instead of a
/// QR you can't scan on your own phone. Null when the rail has no public
/// link scheme (Zelle lives inside bank apps; Apple Cash inside iMessage).
Uri? payDeepLink(PaymentMethod method, int amountCents) {
  final handle = method.handle.trim();
  final dollars = amountCents % 100 == 0
      ? '${amountCents ~/ 100}'
      : (amountCents / 100).toStringAsFixed(2);
  if (method.type == PaymentMethodType.venmo) {
    final user = handle.startsWith('@') ? handle.substring(1) : handle;
    // Universal link: opens the Venmo app when installed, web otherwise.
    return Uri.https('venmo.com', '/$user', {
      'txn': 'pay',
      if (amountCents > 0) 'amount': dollars,
    });
  }
  if (method.type == PaymentMethodType.cashapp) {
    if (!handle.startsWith(r'$')) return null; // phone/email: no link
    final tag = handle.substring(1);
    return Uri.https(
      'cash.app',
      amountCents > 0 ? '/\$$tag/$dollars' : '/\$$tag',
    );
  }
  if (method.type == PaymentMethodType.paypal) {
    final i = handle.toLowerCase().indexOf('paypal.me/');
    if (i < 0) return null; // bare email: no pay link
    final user = handle.substring(i + 'paypal.me/'.length).split('/').first;
    if (user.isEmpty) return null;
    return Uri.https(
      'paypal.me',
      amountCents > 0 ? '/$user/$dollars' : '/$user',
    );
  }
  return null;
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
