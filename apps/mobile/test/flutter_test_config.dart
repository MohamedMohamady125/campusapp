import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Global test bootstrap.
///
/// flutter_secure_storage's platform channel never responds in widget tests,
/// which leaves every dio request awaiting a token forever (infinite
/// skeletons → pumpAndSettle timeouts). Mock the channel so reads resolve to
/// "no token" and writes succeed.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('plugins.it_nomads.com/flutter_secure_storage');
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(channel, (call) async {
        switch (call.method) {
          case 'read':
            return null;
          case 'readAll':
            return <String, String>{};
          case 'containsKey':
            return false;
          default:
            return null; // write / delete / deleteAll succeed silently.
        }
      });
  await testMain();
}
