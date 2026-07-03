import 'package:campusconnect/core/router/app_router.dart';
import 'package:campusconnect/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  runApp(const ProviderScope(child: CampusConnectApp()));
}

class CampusConnectApp extends ConsumerWidget {
  const CampusConnectApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    return MaterialApp.router(
      title: 'CampusConnect',
      theme: lightTheme,
      darkTheme: darkTheme,
      // themeMode defaults to system — respects the OS setting (spec §6.1).
      routerConfig: router,
    );
  }
}
