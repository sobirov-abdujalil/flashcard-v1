/// Activity for a single day, used by the weekly chart on Home.
class DailyActivity {
  const DailyActivity({
    required this.date,
    required this.exercises,
    required this.sessionCompleted,
  });

  final DateTime date;
  final int exercises;
  final bool sessionCompleted;
}

/// Everything the Home screen needs, fetched in one pass so the screen does not
/// scatter database queries across widget builds.
class HomeSnapshot {
  const HomeSnapshot({
    required this.dailyGoal,
    required this.completedToday,
    required this.dueReviews,
    required this.totalWordsStudied,
    required this.totalVocabulary,
    required this.rememberedWords,
    required this.totalCorrect,
    required this.totalAttempts,
    required this.currentStreak,
    required this.weekActivity,
    required this.today,
  });

  final int dailyGoal;
  final int completedToday;
  final int dueReviews;
  final int totalWordsStudied;
  final int totalVocabulary;

  /// Words that were answered correctly at least once and are being retained.
  final int rememberedWords;
  final int totalCorrect;
  final int totalAttempts;
  final int currentStreak;
  final List<DailyActivity> weekActivity;
  final DateTime today;

  bool get goalMet => completedToday >= dailyGoal;

  double get goalProgress {
    if (dailyGoal <= 0) return 0;
    return (completedToday / dailyGoal).clamp(0.0, 1.0);
  }

  int get remainingToday {
    final int remaining = dailyGoal - completedToday;
    return remaining < 0 ? 0 : remaining;
  }

  int get maxWeekExercises => weekActivity.fold<int>(
    1,
    (int max, DailyActivity a) => a.exercises > max ? a.exercises : max,
  );
}
