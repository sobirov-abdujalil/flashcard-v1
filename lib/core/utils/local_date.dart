import '../constants/app_constants.dart';

/// Calendar-safe helpers for local dates.
///
/// The application intentionally works with *local calendar dates*: streaks,
/// daily goals and review due dates must follow the user's wall clock, not UTC.
/// [DateTime] values with a time component are never compared directly.
abstract final class LocalDate {
  static DateTime startOfDay(DateTime value) =>
      DateTime(value.year, value.month, value.day);

  static DateTime today([DateTime? clock]) =>
      startOfDay(clock ?? DateTime.now());

  /// Adds whole calendar days. Using the DateTime constructor (instead of
  /// `Duration(days: n)`) keeps the result at local midnight even across
  /// daylight-saving transitions.
  static DateTime addDays(DateTime value, int days) =>
      DateTime(value.year, value.month, value.day + days);

  static DateTime tomorrow([DateTime? clock]) => addDays(today(clock), 1);

  /// ISO-like `yyyy-MM-dd` key that sorts lexicographically.
  static String key(DateTime value) {
    final String month = value.month.toString().padLeft(2, '0');
    final String day = value.day.toString().padLeft(2, '0');
    return '${value.year.toString().padLeft(4, '0')}-$month-$day';
  }

  static DateTime? parseKey(String value) {
    final List<String> parts = value.split('-');
    if (parts.length != 3) return null;
    final int? year = int.tryParse(parts[0]);
    final int? month = int.tryParse(parts[1]);
    final int? day = int.tryParse(parts[2]);
    if (year == null || month == null || day == null) return null;
    if (month < 1 || month > 12 || day < 1 || day > 31) return null;
    return DateTime(year, month, day);
  }

  static bool isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  /// Whole calendar days from [from] to [to] (positive when [to] is later).
  static int dayDifference(DateTime from, DateTime to) {
    final DateTime a = DateTime.utc(from.year, from.month, from.day);
    final DateTime b = DateTime.utc(to.year, to.month, to.day);
    return b.difference(a).inDays;
  }

  static bool isPast(DateTime value, DateTime now) => value.isBefore(now);

  static const List<String> monthNamesUz = <String>[
    'yanvar',
    'fevral',
    'mart',
    'aprel',
    'may',
    'iyun',
    'iyul',
    'avgust',
    'sentabr',
    'oktabr',
    'noyabr',
    'dekabr',
  ];

  static const List<String> weekdayNamesUz = <String>[
    'dushanba',
    'seshanba',
    'chorshanba',
    'payshanba',
    'juma',
    'shanba',
    'yakshanba',
  ];

  static const List<String> weekdayShortUz = <String>[
    'Du',
    'Se',
    'Ch',
    'Pa',
    'Ju',
    'Sh',
    'Ya',
  ];

  /// Example: `14-noyabr, juma`.
  static String formatLongUz(DateTime value) {
    final String month = monthNamesUz[value.month - 1];
    final String weekday = weekdayNamesUz[value.weekday - 1];
    return '${value.day}-$month, $weekday';
  }

  /// Example: `14-noyabr`.
  static String formatShortUz(DateTime value) =>
      '${value.day}-${monthNamesUz[value.month - 1]}';

  /// Human friendly Uzbek phrase for a future review date.
  static String describeFutureUz(DateTime target, {DateTime? clock}) {
    final DateTime now = today(clock);
    final int days = dayDifference(now, target);
    if (days <= 0) return 'Bugun';
    if (days == 1) return 'Ertaga';
    if (days <= 6) return '$days kundan so‘ng';
    if (days <= 13) return 'Keyingi hafta';
    return formatShortUz(target);
  }

  /// Greeting that follows the local time of day.
  static String greetingUz(DateTime now) {
    final int hour = now.hour;
    if (hour < 5) return 'Xayrli tun';
    if (hour < 12) return 'Xayrli tong';
    if (hour < 18) return 'Xayrli kun';
    return 'Xayrli kech';
  }

  static List<DateTime> lastSevenDays(DateTime today) {
    final DateTime start = startOfDay(today);
    return List<DateTime>.generate(7, (int index) => addDays(start, index - 6));
  }
}

/// Calculates the current daily learning streak from completed session days.
abstract final class StreakCalculator {
  /// [completedDateKeys] contains one `yyyy-MM-dd` key per day that had at
  /// least one fully completed learning session.
  ///
  /// The streak counts back from today. If today has no completed session yet,
  /// the streak is still alive when yesterday was completed (so the user does
  /// not lose their streak before finishing today's goal).
  static int currentStreak({
    required Iterable<String> completedDateKeys,
    required DateTime today,
  }) {
    final Set<String> days = completedDateKeys.toSet();
    if (days.isEmpty) return 0;

    DateTime cursor = LocalDate.startOfDay(today);
    if (!days.contains(LocalDate.key(cursor))) {
      cursor = LocalDate.addDays(cursor, -1);
      if (!days.contains(LocalDate.key(cursor))) return 0;
    }

    int streak = 0;
    while (days.contains(LocalDate.key(cursor))) {
      streak++;
      cursor = LocalDate.addDays(cursor, -1);
    }
    return streak;
  }
}

/// How many exercises a session should contain so that it can complete the
/// daily goal without exceeding it.
abstract final class DailyGoalPlanner {
  static int sessionSize({
    required int dailyGoal,
    required int completedToday,
    int defaultSize = AppConstants.defaultSessionSize,
  }) {
    final int goal = dailyGoal < 1 ? defaultSize : dailyGoal;
    if (completedToday < 0) return goal;
    final int remaining = goal - completedToday;
    if (remaining <= 0) return goal; // extra practice session
    return remaining;
  }
}
