import 'dart:async' show unawaited;

import 'package:flutter/material.dart' show ThemeMode;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kThemeModeKey = 'theme_mode';

/// App-wide theme mode (QA S-05): user-pickable Light / Dark / System,
/// persisted locally. Defaults to light — the pre-picker behavior
/// (light forced per user preference, 2026-08-05) — until a choice loads.
class ThemeModeController extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    unawaited(_load());
    return ThemeMode.light;
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_kThemeModeKey);
    for (final mode in ThemeMode.values) {
      if (mode.name == stored && mode != state) {
        state = mode;
        return;
      }
    }
  }

  Future<void> set(ThemeMode mode) async {
    state = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kThemeModeKey, mode.name);
  }
}

final themeModeProvider = NotifierProvider<ThemeModeController, ThemeMode>(
  ThemeModeController.new,
);
