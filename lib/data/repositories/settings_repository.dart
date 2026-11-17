import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/app_settings.dart';

/// Persists the small set of user preferences that live outside SQLite.
class SettingsRepository {
  SettingsRepository({Future<SharedPreferences> Function()? preferencesLoader})
    : _loadPreferences = preferencesLoader ?? SharedPreferences.getInstance;

  static const String themeModeKey = 'theme_mode';
  static const String dailyGoalKey = 'daily_goal';

  final Future<SharedPreferences> Function() _loadPreferences;

  Future<AppSettings> load() async {
    final SharedPreferences prefs = await _loadPreferences();
    return AppSettings(
      themeMode: decodeThemeMode(prefs.getString(themeModeKey)),
      dailyGoal: sanitizeGoal(prefs.getInt(dailyGoalKey)),
    );
  }

  Future<void> saveThemeMode(ThemeMode mode) async {
    final SharedPreferences prefs = await _loadPreferences();
    await prefs.setString(themeModeKey, encodeThemeMode(mode));
  }

  Future<void> saveDailyGoal(int goal) async {
    final SharedPreferences prefs = await _loadPreferences();
    await prefs.setInt(dailyGoalKey, sanitizeGoal(goal));
  }

  static int sanitizeGoal(int? value) {
    if (value == null) return AppSettings.defaults.dailyGoal;
    if (value < 1) return AppSettings.defaults.dailyGoal;
    if (value > 50) return 50;
    return value;
  }

  static String encodeThemeMode(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
        return 'system';
    }
  }

  static ThemeMode decodeThemeMode(String? value) {
    switch (value) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }
}
