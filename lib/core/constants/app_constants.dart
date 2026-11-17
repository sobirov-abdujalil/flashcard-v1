/// Application-wide constants that are safe to keep outside of the theme.
abstract final class AppConstants {
  static const String appName = 'So‘z Atlas';
  static const String appVersion = '1.0.0';
  static const String appBuildNumber = '1';

  /// Number of exercises inside one learning session by default.
  static const int defaultSessionSize = 5;

  /// Daily goal options offered in settings.
  static const List<int> dailyGoalOptions = [5, 10, 15];

  static const int defaultDailyGoal = 5;

  /// Minimum target size for anything tappable.
  static const double minTouchTarget = 48;

  /// Screen layout rhythm.
  static const double screenPadding = 20;
  static const double space4 = 4;
  static const double space8 = 8;
  static const double space12 = 12;
  static const double space16 = 16;
  static const double space20 = 20;
  static const double space24 = 24;
  static const double space32 = 32;

  /// Corner radii.
  static const double cardRadius = 26;
  static const double buttonRadius = 18;
  static const double chipRadius = 12;
  static const double sheetRadius = 30;

  /// Heights.
  static const double primaryButtonHeight = 56;
  static const double secondaryButtonHeight = 52;

  /// Motion durations.
  static const Duration micro = Duration(milliseconds: 140);
  static const Duration short = Duration(milliseconds: 180);
  static const Duration screen = Duration(milliseconds: 240);
  static const Duration reveal = Duration(milliseconds: 320);
  static const Duration celebration = Duration(milliseconds: 560);

  /// Spaced repetition intervals in days, indexed by successful repetition
  /// count (first success = 1 day, and so on).
  static const List<int> reviewIntervalsDays = [1, 3, 7, 14, 30];

  /// Number of vocabulary constellation nodes rendered at most.
  static const int atlasNodeCount = 26;
}
