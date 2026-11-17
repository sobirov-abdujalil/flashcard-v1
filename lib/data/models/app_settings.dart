import 'package:flutter/material.dart';

/// User controlled application preferences.
@immutable
class AppSettings {
  const AppSettings({required this.themeMode, required this.dailyGoal});

  static const AppSettings defaults = AppSettings(
    themeMode: ThemeMode.system,
    dailyGoal: 5,
  );

  final ThemeMode themeMode;
  final int dailyGoal;

  AppSettings copyWith({ThemeMode? themeMode, int? dailyGoal}) => AppSettings(
    themeMode: themeMode ?? this.themeMode,
    dailyGoal: dailyGoal ?? this.dailyGoal,
  );

  @override
  bool operator ==(Object other) =>
      other is AppSettings &&
      other.themeMode == themeMode &&
      other.dailyGoal == dailyGoal;

  @override
  int get hashCode => Object.hash(themeMode, dailyGoal);
}
