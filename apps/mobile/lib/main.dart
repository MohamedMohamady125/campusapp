import 'package:campusconnect/core/router/app_router.dart';
import 'package:campusconnect/design_system/material.dart';
import 'package:campusconnect/design_system/theme/app_theme.dart';
import 'package:flutter/foundation.dart'
    show LicenseEntryWithLineBreaks, LicenseRegistry;
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  // Inter is bundled as an asset (whole.md §3.3) — register its OFL license.
  LicenseRegistry.addLicense(() async* {
    final license = await rootBundle.loadString(
      'assets/google_fonts/OFL.txt',
    );
    yield LicenseEntryWithLineBreaks(const ['google_fonts'], license);
  });
  runApp(const ProviderScope(child: CampusConnectApp()));
}

class CampusConnectApp extends ConsumerWidget {
  const CampusConnectApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    return MaterialApp.router(
      title: 'CampusConnect',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      // Light theme forced per user preference (2026-08-05).
      themeMode: ThemeMode.light,
      // 2.0 keeps WCAG 1.4.4 (200% resize) satisfied (spec §15.3).
      builder: (context, child) => MediaQuery.withClampedTextScaling(
        minScaleFactor: 1,
        maxScaleFactor: 2,
        child: child!,
      ),
      routerConfig: router,
    );
  }
}
