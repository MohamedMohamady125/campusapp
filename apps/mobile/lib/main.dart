import 'package:campusconnect/core/router/app_router.dart';
import 'package:campusconnect/design_system/material.dart';
import 'package:campusconnect/design_system/theme/app_theme.dart';
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
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      // themeMode defaults to system — respects the OS setting (spec §9.3).
      // 2.0 keeps WCAG 1.4.4 (200% resize) satisfied (spec §15.3).
      builder: (context, child) => MediaQuery.withClampedTextScaling(
        maxScaleFactor: 2,
        child: child!,
      ),
      routerConfig: router,
    );
  }
}
