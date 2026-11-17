import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/app_settings.dart';
import 'app_providers.dart';

/// Loads and persists user settings (theme choice and daily goal).
class SettingsNotifier extends AsyncNotifier<AppSettings> {
  @override
  Future<AppSettings> build() {
    return ref.watch(settingsRepositoryProvider).load();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    final AppSettings current = state.value ?? AppSettings.defaults;
    if (current.themeMode == mode) return;
    state = AsyncData(current.copyWith(themeMode: mode));
    try {
      await ref.read(settingsRepositoryProvider).saveThemeMode(mode);
    } catch (_) {
      state = AsyncData(current);
    }
  }

  Future<void> setDailyGoal(int goal) async {
    final AppSettings current = state.value ?? AppSettings.defaults;
    if (current.dailyGoal == goal) return;
    state = AsyncData(current.copyWith(dailyGoal: goal));
    try {
      await ref.read(settingsRepositoryProvider).saveDailyGoal(goal);
    } catch (_) {
      state = AsyncData(current);
    }
  }
}

final AsyncNotifierProvider<SettingsNotifier, AppSettings> settingsProvider =
    AsyncNotifierProvider<SettingsNotifier, AppSettings>(SettingsNotifier.new);

/// Incremented whenever persisted learning data changes so dependent screens
/// refresh with real numbers.
class ProgressRevision extends Notifier<int> {
  @override
  int build() => 0;

  void bump() => state = state + 1;
}

final NotifierProvider<ProgressRevision, int> progressRevisionProvider =
    NotifierProvider<ProgressRevision, int>(ProgressRevision.new);
