import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Default live-data cadence for list/detail screens (spec §7.4 smart
/// polling): fresh enough to feel realtime, cheap enough to leave on.
const kAutoRefreshInterval = Duration(seconds: 10);

extension AutoRefresh on Ref<Object?> {
  /// Silently re-fetches this provider every [interval] so the screen stays
  /// live with zero pull-to-refresh. Riverpod keeps the previous value while
  /// the re-fetch is in flight (`when`'s default `skipLoadingOnRefresh`), so
  /// polls never flash skeletons. Auto-dispose cancels the timer the moment
  /// the screen goes away.
  void autoRefresh([Duration interval = kAutoRefreshInterval]) {
    final timer = Timer(interval, invalidateSelf);
    onDispose(timer.cancel);
  }
}
