import 'dart:math';

import 'package:sqflite/sqflite.dart';

import '../../core/utils/local_date.dart';
import '../../domain/scheduler/spaced_repetition_scheduler.dart';
import '../../domain/session/answer_options_generator.dart';
import '../../domain/session/session_composer.dart';
import '../../domain/models/session_models.dart';
import '../database/app_database.dart';
import '../database/study_day_dao.dart';
import '../models/study_day.dart';
import '../models/word.dart';
import '../models/word_progress.dart';
import 'progress_repository.dart';
import 'vocabulary_repository.dart';

/// Thrown when a learning session cannot be created (for example when the
/// vocabulary table is empty and no candidate words exist).
class SessionUnavailableException implements Exception {
  const SessionUnavailableException(this.message);

  final String message;

  @override
  String toString() => 'SessionUnavailableException: $message';
}

/// Orchestrates session creation and persists every answer.
///
/// A session is never stored as one mutable blob: each answer is committed
/// immediately in a transaction so progress survives app termination.
class SessionRepository {
  SessionRepository(
    this._database,
    this._vocabularyRepository,
    this._progressRepository, {
    SpacedRepetitionScheduler? scheduler,
    AnswerOptionsGenerator? optionsGenerator,
    Random? random,
  }) : _scheduler = scheduler ?? const SpacedRepetitionScheduler(),
       _optionsGenerator = optionsGenerator ?? const AnswerOptionsGenerator(),
       _random = random ?? Random();

  final AppDatabase _database;
  final VocabularyRepository _vocabularyRepository;
  final ProgressRepository _progressRepository;
  final SpacedRepetitionScheduler _scheduler;
  final AnswerOptionsGenerator _optionsGenerator;
  final Random _random;

  /// Builds a session: due reviews first, then new words, then a fallback.
  Future<LearningSession> createSession({
    required int dailyGoal,
    DateTime? now,
  }) async {
    final DateTime clock = now ?? DateTime.now();
    final String todayKey = LocalDate.key(clock);
    final StudyDay? todayActivity = await _progressRepository.studyDay(
      todayKey,
    );
    final int completedToday = todayActivity?.completedExercises ?? 0;
    final int size = DailyGoalPlanner.sessionSize(
      dailyGoal: dailyGoal,
      completedToday: completedToday,
    );

    final List<Word> dueWords = await _vocabularyRepository.dueWords(
      now: clock,
      limit: size,
    );
    final int remainingAfterDue = size - dueWords.length;
    final List<Word> newWords = remainingAfterDue > 0
        ? await _vocabularyRepository.newWords(limit: remainingAfterDue)
        : const <Word>[];
    final int remainingAfterNew = size - dueWords.length - newWords.length;
    final List<Word> fallbackWords = remainingAfterNew > 0
        ? await _vocabularyRepository.leastRecentlyReviewed(limit: size)
        : const <Word>[];

    final List<SessionWord> sessionWords = SessionComposer.compose(
      dueWords: dueWords,
      newWords: newWords,
      fallbackWords: fallbackWords,
      size: size,
    );
    if (sessionWords.isEmpty) {
      throw const SessionUnavailableException(
        'Mashq uchun so‘z topilmadi. Iltimos, keyinroq qayta urinib ko‘ring.',
      );
    }

    final List<Word> pool = await _vocabularyRepository.allWords();
    final List<SessionQuestion> questions = _optionsGenerator.createQuestions(
      words: sessionWords,
      pool: pool,
      random: _random,
    );

    return LearningSession(
      words: sessionWords,
      questions: questions,
      dailyGoal: dailyGoal < 1 ? size : dailyGoal,
    );
  }

  /// Records one answer for a word.
  ///
  /// First attempts flow through the spaced repetition scheduler; retry
  /// attempts inside the same session only increase the attempt counters so a
  /// single session cannot shorten or lengthen the schedule twice.
  Future<void> recordAnswer({
    required Word word,
    required bool isCorrect,
    required bool isNewWord,
    required bool isRetry,
    DateTime? now,
  }) async {
    final DateTime clock = now ?? DateTime.now();
    final String todayKey = LocalDate.key(clock);
    final Database db = await _database.database;

    await db.transaction((Transaction txn) async {
      final List<Map<String, Object?>> rows = await txn.query(
        'word_progress',
        where: 'word_id = ?',
        whereArgs: <Object?>[word.id],
        limit: 1,
      );
      final WordProgress? existing = rows.isEmpty
          ? null
          : WordProgress.fromMap(rows.first);

      final WordProgress updated;
      final bool scheduledFirstAttempt = !isRetry || existing == null;
      if (scheduledFirstAttempt) {
        final ReviewSchedule schedule = _scheduler.schedule(
          previousSuccessfulRepetitions: existing?.successfulRepetitions ?? 0,
          previousLapseCount: existing?.lapseCount ?? 0,
          correct: isCorrect,
          now: clock,
        );
        updated = WordProgress(
          wordId: word.id,
          lastReviewAt: schedule.lastReviewAt,
          nextReviewAt: schedule.nextReviewAt,
          successfulRepetitions: schedule.successfulRepetitions,
          lapseCount: schedule.lapseCount,
          totalCorrect: (existing?.totalCorrect ?? 0) + (isCorrect ? 1 : 0),
          totalAttempts: (existing?.totalAttempts ?? 0) + 1,
        );
      } else {
        updated = existing.copyWith(
          totalCorrect: existing.totalCorrect + (isCorrect ? 1 : 0),
          totalAttempts: existing.totalAttempts + 1,
        );
      }

      if (existing == null) {
        await txn.insert('word_progress', updated.toMap());
      } else {
        await txn.update(
          'word_progress',
          updated.toMap(),
          where: 'word_id = ?',
          whereArgs: <Object?>[word.id],
        );
      }

      await StudyDayDao.increment(
        txn,
        dateKey: todayKey,
        exercises: isRetry ? 0 : 1,
        correctAnswers: isRetry ? 0 : (isCorrect ? 1 : 0),
        newWords: (!isRetry && isNewWord) ? 1 : 0,
      );
    });
  }

  /// Marks the session complete and computes the real summary shown on the
  /// completion screen.
  Future<SessionSummary> completeSession({
    required LearningSession session,
    required int correctAnswers,
    required int newWordsStudied,
    required int retryCount,
    DateTime? now,
  }) async {
    final DateTime clock = now ?? DateTime.now();
    final String todayKey = LocalDate.key(clock);
    final Database db = await _database.database;

    await db.transaction((Transaction txn) async {
      await StudyDayDao.markSessionCompleted(txn, todayKey);
    });

    final List<String> completedKeys = await _progressRepository
        .completedSessionDateKeys();
    final int streak = StreakCalculator.currentStreak(
      completedDateKeys: completedKeys,
      today: LocalDate.today(clock),
    );

    DateTime? nextReviewAt;
    final List<int> wordIds = session.words
        .map((SessionWord entry) => entry.word.id)
        .toList(growable: false);
    if (wordIds.isNotEmpty) {
      final String placeholders = List<String>.filled(
        wordIds.length,
        '?',
      ).join(',');
      final List<Map<String, Object?>> rows = await db.rawQuery(
        'SELECT MIN(next_review_at) AS next_review_at '
        'FROM word_progress WHERE word_id IN ($placeholders)',
        wordIds,
      );
      final Object? value = rows.isEmpty ? null : rows.first['next_review_at'];
      if (value is int) {
        nextReviewAt = DateTime.fromMillisecondsSinceEpoch(value);
      }
    }

    final StudyDay? todayActivity = await _progressRepository.studyDay(
      todayKey,
    );
    final int completedToday = todayActivity?.completedExercises ?? 0;

    return SessionSummary(
      totalExercises: session.questions.length,
      correctAnswers: correctAnswers,
      newWordsStudied: newWordsStudied,
      currentStreak: streak,
      nextReviewAt: nextReviewAt,
      dailyGoal: session.dailyGoal,
      completedToday: completedToday,
      goalCompleted: completedToday >= session.dailyGoal,
      retryCount: retryCount,
      completedAt: clock,
    );
  }
}
