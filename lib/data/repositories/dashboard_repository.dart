import '../../core/utils/local_date.dart';
import '../database/app_database.dart';
import '../models/home_snapshot.dart';
import '../models/study_day.dart';
import '../repositories/progress_repository.dart';

/// Aggregates the numbers shown on the Home screen from real database data.
///
/// All statistics are real user data — the application never shows sample
/// statistics.
class DashboardRepository {
  DashboardRepository(this._database, this._progressRepository);

  final AppDatabase _database;
  final ProgressRepository _progressRepository;

  Future<HomeSnapshot> load({required int dailyGoal, DateTime? now}) async {
    final DateTime clock = now ?? DateTime.now();
    final DateTime today = LocalDate.today(clock);
    final String todayKey = LocalDate.key(today);

    final StudyDay? todayActivity = await _progressRepository.studyDay(
      todayKey,
    );
    final int completedToday = todayActivity?.completedExercises ?? 0;

    final List<DateTime> week = LocalDate.lastSevenDays(today);
    final Map<String, StudyDay> weekDays = await _progressRepository
        .studyDaysBetween(
          startKey: LocalDate.key(week.first),
          endKey: LocalDate.key(week.last),
        );

    final List<DailyActivity> weekActivity = <DailyActivity>[
      for (final DateTime day in week)
        DailyActivity(
          date: day,
          exercises: weekDays[LocalDate.key(day)]?.completedExercises ?? 0,
          sessionCompleted:
              weekDays[LocalDate.key(day)]?.sessionCompleted ?? false,
        ),
    ];

    final Map<String, int> aggregates = await _aggregates();
    final List<String> completedKeys = await _progressRepository
        .completedSessionDateKeys();

    final int dueReviews = await _progressRepository.dueReviewCount(clock);
    final DateTime? nextReview = dueReviews == 0
        ? await _progressRepository.nextReviewDate(clock)
        : null;

    return HomeSnapshot(
      dailyGoal: dailyGoal,
      completedToday: completedToday,
      dueReviews: dueReviews,
      nextReviewAt: nextReview,
      totalWordsStudied: aggregates['studied'] ?? 0,
      totalVocabulary: await _database.vocabularyCount(),
      rememberedWords: aggregates['remembered'] ?? 0,
      totalCorrect: aggregates['correct'] ?? 0,
      totalAttempts: aggregates['attempts'] ?? 0,
      currentStreak: StreakCalculator.currentStreak(
        completedDateKeys: completedKeys,
        today: today,
      ),
      weekActivity: weekActivity,
      today: today,
    );
  }

  Future<Map<String, int>> _aggregates() async {
    final db = await _database.database;
    final rows = await db.rawQuery('''
      SELECT
        COUNT(*) AS studied,
        SUM(CASE WHEN successful_repetitions >= 1 THEN 1 ELSE 0 END) AS remembered,
        SUM(total_correct) AS correct,
        SUM(total_attempts) AS attempts
      FROM word_progress
    ''');
    if (rows.isEmpty) {
      return <String, int>{};
    }
    final row = rows.first;
    int asInt(Object? value) => value is int ? value : 0;
    return <String, int>{
      'studied': asInt(row['studied']),
      'remembered': asInt(row['remembered']),
      'correct': asInt(row['correct']),
      'attempts': asInt(row['attempts']),
    };
  }

  Future<int> vocabularyCount() => _database.vocabularyCount();
}
