import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:soz_atlas/core/utils/local_date.dart';
import 'package:soz_atlas/data/database/app_database.dart';
import 'package:soz_atlas/data/models/home_snapshot.dart';
import 'package:soz_atlas/data/models/study_day.dart';
import 'package:soz_atlas/data/models/word.dart';
import 'package:soz_atlas/data/models/word_progress.dart';
import 'package:soz_atlas/data/repositories/dashboard_repository.dart';
import 'package:soz_atlas/data/repositories/progress_repository.dart';
import 'package:soz_atlas/data/repositories/session_repository.dart';
import 'package:soz_atlas/data/repositories/vocabulary_repository.dart';
import 'package:soz_atlas/domain/models/session_models.dart';

import '../helpers/test_database.dart';

void main() {
  late TestDatabaseHandle handle;
  late AppDatabase database;
  late VocabularyRepository vocabulary;
  late ProgressRepository progress;
  late SessionRepository sessions;
  late DashboardRepository dashboard;

  final DateTime day1 = DateTime(2026, 11, 14, 10, 30);
  final DateTime day2 = DateTime(2026, 11, 15, 9);
  final DateTime day4 = DateTime(2026, 11, 17, 18);

  setUp(() async {
    handle = await TestDatabaseHandle.create();
    database = handle.database;
    vocabulary = VocabularyRepository(database);
    progress = ProgressRepository(database);
    sessions = SessionRepository(
      database,
      vocabulary,
      progress,
      random: Random(7),
    );
    dashboard = DashboardRepository(database, progress);
  });

  tearDown(() async {
    await handle.dispose();
  });

  Future<void> answerWholeSession(
    LearningSession session, {
    required bool correct,
    required DateTime now,
  }) async {
    for (final SessionQuestion question in session.questions) {
      await sessions.recordAnswer(
        word: question.word,
        isCorrect: correct,
        isNewWord: question.isNew,
        isRetry: question.isRetry,
        now: now,
      );
    }
  }

  Future<SessionSummary> complete(LearningSession session, DateTime now) {
    final int correct = session.questions.length;
    return sessions.completeSession(
      session: session,
      correctAnswers: correct,
      newWordsStudied: session.newWordCount,
      retryCount: 0,
      now: now,
    );
  }

  group('database creation and seeding', () {
    test('seeds 100 words with 50 A1 and 50 A2 exactly once', () async {
      expect(await vocabulary.count(), 100);
      final List<Word> words = await vocabulary.allWords();
      expect(words, hasLength(100));
      expect(words.where((Word word) => word.cefrLevel == 'A1').length, 50);
      expect(words.where((Word word) => word.cefrLevel == 'A2').length, 50);
      // Opening again must not duplicate the seed data.
      await vocabulary.allWords();
      expect(await vocabulary.count(), 100);
    });

    test('schema includes the progress and study-day tables', () async {
      final db = await database.database;
      final List<Map<String, Object?>> tables = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table'",
      );
      final Set<String> names = tables
          .map((Map<String, Object?> row) => row['name'] as String)
          .toSet();
      expect(
        names,
        containsAll(<String>['words', 'word_progress', 'study_days']),
      );
    });

    test('foreign keys are enforced', () async {
      final db = await database.database;
      await expectLater(
        db.insert('word_progress', <String, Object?>{
          'word_id': 99999,
          'last_review_at': 1,
          'next_review_at': 2,
          'successful_repetitions': 0,
          'lapse_count': 0,
          'total_correct': 0,
          'total_attempts': 0,
        }),
        throwsA(anything),
      );
    });

    test('progress survives a database close and reopen', () async {
      final LearningSession session = await sessions.createSession(
        dailyGoal: 5,
        now: day1,
      );
      await sessions.recordAnswer(
        word: session.words.first.word,
        isCorrect: true,
        isNewWord: true,
        isRetry: false,
        now: day1,
      );
      await database.close();

      final AppDatabase reopened = await TestDatabaseHandle.reopen(handle.path);
      final VocabularyRepository reopenedVocabulary = VocabularyRepository(
        reopened,
      );
      final ProgressRepository reopenedProgress = ProgressRepository(reopened);

      expect(await reopenedVocabulary.count(), 100);
      expect(await reopenedProgress.totalWordsStudied(), 1);
      final WordProgress? saved = await reopenedProgress.progressFor(
        session.words.first.word.id,
      );
      expect(saved, isNotNull);
      expect(saved!.totalAttempts, 1);
      expect(saved.totalCorrect, 1);
      expect(saved.successfulRepetitions, 1);
      expect(saved.nextReviewAt, DateTime(2026, 11, 15));

      await reopened.close();
    });
  });

  group('session creation', () {
    test('a fresh install gets a full session of new A1 words', () async {
      final LearningSession session = await sessions.createSession(
        dailyGoal: 5,
        now: day1,
      );
      expect(session.questions, hasLength(5));
      expect(session.words, hasLength(5));
      expect(session.newWordCount, 5);
      expect(session.dueWordCount, 0);
      expect(
        session.words.map((SessionWord entry) => entry.word.cefrLevel).toSet(),
        <String>{'A1'},
      );
      for (final SessionQuestion question in session.questions) {
        expect(question.choices, hasLength(4));
        expect(
          question.choices[question.correctIndex].translation,
          question.word.translation,
        );
        expect(
          question.choices.map((AnswerChoice c) => c.translation).toSet(),
          hasLength(4),
        );
      }
    });

    test('respects a larger daily goal', () async {
      final LearningSession session = await sessions.createSession(
        dailyGoal: 15,
        now: day1,
      );
      expect(session.questions, hasLength(15));
      expect(session.newWordCount, 15);
    });

    test(
      'fills only the remaining part of a partially completed goal',
      () async {
        final LearningSession first = await sessions.createSession(
          dailyGoal: 5,
          now: day1,
        );
        for (final SessionQuestion question in first.questions.take(2)) {
          await sessions.recordAnswer(
            word: question.word,
            isCorrect: true,
            isNewWord: question.isNew,
            isRetry: false,
            now: day1,
          );
        }
        final LearningSession second = await sessions.createSession(
          dailyGoal: 5,
          now: day1,
        );
        expect(second.questions, hasLength(3));
      },
    );

    test(
      'prioritises due reviews before new words, oldest due first',
      () async {
        // Schedule three words in the past so that all are overdue now.
        await sessions.recordAnswer(
          word: (await vocabulary.allWords())[0],
          isCorrect: true,
          isNewWord: true,
          isRetry: false,
          now: DateTime(2026, 11, 4, 10), // due 2026-11-05
        );
        await sessions.recordAnswer(
          word: (await vocabulary.allWords())[1],
          isCorrect: true,
          isNewWord: true,
          isRetry: false,
          now: DateTime(2026, 11, 10, 10), // due 2026-11-11
        );
        await sessions.recordAnswer(
          word: (await vocabulary.allWords())[2],
          isCorrect: true,
          isNewWord: true,
          isRetry: false,
          now: DateTime(2026, 10, 20, 10), // due 2026-10-21
        );

        final LearningSession session = await sessions.createSession(
          dailyGoal: 5,
          now: day1,
        );
        final List<int> ids = session.words
            .map((SessionWord entry) => entry.word.id)
            .toList();
        // Oldest due date first: word 3 (Oct 21), word 1 (Nov 5), word 2 (Nov 11).
        expect(ids.take(3).toList(), <int>[3, 1, 2]);
        expect(session.dueWordCount, 3);
        expect(session.newWordCount, 2);
        expect(session.words[0].isDue, isTrue);
        expect(session.words[3].isNew, isTrue);
      },
    );

    test(
      'uses the full goal for extra practice after it was completed',
      () async {
        final LearningSession first = await sessions.createSession(
          dailyGoal: 5,
          now: day1,
        );
        await answerWholeSession(first, correct: true, now: day1);
        await complete(first, day1);

        final LearningSession extra = await sessions.createSession(
          dailyGoal: 5,
          now: day1,
        );
        expect(extra.questions, hasLength(5));
      },
    );
  });

  group('answer persistence', () {
    test(
      'a correct first attempt schedules the next review in 1 day',
      () async {
        final LearningSession session = await sessions.createSession(
          dailyGoal: 5,
          now: day1,
        );
        final Word word = session.words.first.word;
        await sessions.recordAnswer(
          word: word,
          isCorrect: true,
          isNewWord: true,
          isRetry: false,
          now: day1,
        );

        final WordProgress? saved = await progress.progressFor(word.id);
        expect(saved, isNotNull);
        expect(saved!.lastReviewAt, day1);
        expect(saved.nextReviewAt, DateTime(2026, 11, 15));
        expect(saved.successfulRepetitions, 1);
        expect(saved.lapseCount, 0);
        expect(saved.totalCorrect, 1);
        expect(saved.totalAttempts, 1);

        final StudyDay? today = await progress.studyDay(LocalDate.key(day1));
        expect(today, isNotNull);
        expect(today!.completedExercises, 1);
        expect(today.correctAnswers, 1);
        expect(today.newWordsStudied, 1);
        expect(today.sessionCompleted, isFalse);
      },
    );

    test('an incorrect answer resets the stage and reviews tomorrow', () async {
      final LearningSession session = await sessions.createSession(
        dailyGoal: 5,
        now: day1,
      );
      final Word word = session.words.first.word;
      await sessions.recordAnswer(
        word: word,
        isCorrect: false,
        isNewWord: true,
        isRetry: false,
        now: day1,
      );

      final WordProgress? saved = await progress.progressFor(word.id);
      expect(saved, isNotNull);
      expect(saved!.successfulRepetitions, 0);
      expect(saved.lapseCount, 1);
      expect(saved.nextReviewAt, DateTime(2026, 11, 15));
      expect(saved.totalCorrect, 0);
      expect(saved.totalAttempts, 1);

      final StudyDay? today = await progress.studyDay(LocalDate.key(day1));
      expect(today!.correctAnswers, 0);
      expect(today.completedExercises, 1);
    });

    test('a retry updates the counters but not the schedule', () async {
      final LearningSession session = await sessions.createSession(
        dailyGoal: 5,
        now: day1,
      );
      final Word word = session.words.first.word;
      await sessions.recordAnswer(
        word: word,
        isCorrect: true,
        isNewWord: true,
        isRetry: false,
        now: day1,
      );
      final WordProgress afterFirst = (await progress.progressFor(word.id))!;
      await sessions.recordAnswer(
        word: word,
        isCorrect: false,
        isNewWord: true,
        isRetry: true,
        now: day1,
      );
      final WordProgress afterRetry = (await progress.progressFor(word.id))!;
      expect(afterRetry.nextReviewAt, afterFirst.nextReviewAt);
      expect(
        afterRetry.successfulRepetitions,
        afterFirst.successfulRepetitions,
      );
      expect(afterRetry.lapseCount, afterFirst.lapseCount);
      expect(afterRetry.totalAttempts, 2);
      expect(afterRetry.totalCorrect, 1);

      final StudyDay? today = await progress.studyDay(LocalDate.key(day1));
      expect(
        today!.completedExercises,
        1,
        reason: 'retries must not inflate the daily goal',
      );
    });

    test('consecutive correct reviews advance the interval chain', () async {
      final Word word = (await vocabulary.allWords()).first;
      DateTime cursor = day1;
      const List<int> expectedIntervals = <int>[1, 3, 7, 14, 30];

      for (int index = 0; index < expectedIntervals.length; index++) {
        await sessions.recordAnswer(
          word: word,
          isCorrect: true,
          isNewWord: index == 0,
          isRetry: false,
          now: cursor,
        );
        final WordProgress saved = (await progress.progressFor(word.id))!;
        expect(saved.successfulRepetitions, index + 1);
        expect(
          saved.nextReviewAt,
          LocalDate.addDays(LocalDate.today(cursor), expectedIntervals[index]),
        );
        cursor = saved.nextReviewAt.add(const Duration(hours: 9));
      }
    });

    test(
      'a wrong review after a long stage schedules a short interval',
      () async {
        final Word word = (await vocabulary.allWords()).first;
        for (int index = 0; index < 3; index++) {
          await sessions.recordAnswer(
            word: word,
            isCorrect: true,
            isNewWord: index == 0,
            isRetry: false,
            now: LocalDate.addDays(day1, index * 5),
          );
        }
        final DateTime reviewDay = LocalDate.addDays(day1, 20);
        await sessions.recordAnswer(
          word: word,
          isCorrect: false,
          isNewWord: false,
          isRetry: false,
          now: reviewDay,
        );
        final WordProgress saved = (await progress.progressFor(word.id))!;
        expect(saved.successfulRepetitions, 0);
        expect(saved.lapseCount, 1);
        expect(saved.nextReviewAt, LocalDate.addDays(reviewDay, 1));
      },
    );
  });

  group('daily goal and dashboard', () {
    test('dashboard reports real progress after a completed session', () async {
      final LearningSession session = await sessions.createSession(
        dailyGoal: 5,
        now: day1,
      );
      await answerWholeSession(session, correct: true, now: day1);
      final SessionSummary summary = await complete(session, day1);

      expect(summary.totalExercises, 5);
      expect(summary.correctAnswers, 5);
      expect(summary.newWordsStudied, 5);
      expect(summary.currentStreak, 1);
      expect(summary.nextReviewAt, DateTime(2026, 11, 15));
      expect(summary.goalCompleted, isTrue);
      expect(summary.completedToday, 5);

      final HomeSnapshot snapshot = await dashboard.load(
        dailyGoal: 5,
        now: day1,
      );
      expect(snapshot.completedToday, 5);
      expect(snapshot.goalMet, isTrue);
      expect(snapshot.totalWordsStudied, 5);
      expect(snapshot.totalVocabulary, 100);
      expect(snapshot.rememberedWords, 5);
      expect(snapshot.currentStreak, 1);
      expect(snapshot.dueReviews, 0);
      expect(snapshot.weekActivity, hasLength(7));
      expect(
        snapshot.weekActivity.last.exercises,
        5,
        reason: 'today is the last bar',
      );
      expect(snapshot.weekActivity.last.sessionCompleted, isTrue);
      expect(snapshot.totalCorrect, 5);
      expect(snapshot.totalAttempts, 5);
    });

    test(
      'streak counts consecutive completed days and resets after a gap',
      () async {
        final LearningSession session1 = await sessions.createSession(
          dailyGoal: 5,
          now: day1,
        );
        await answerWholeSession(session1, correct: true, now: day1);
        await complete(session1, day1);

        final LearningSession session2 = await sessions.createSession(
          dailyGoal: 5,
          now: day2,
        );
        // Due words from day1 are prioritised.
        expect(session2.dueWordCount, 5);
        await answerWholeSession(session2, correct: true, now: day2);
        final SessionSummary summary2 = await complete(session2, day2);
        expect(summary2.currentStreak, 2);

        final LearningSession session4 = await sessions.createSession(
          dailyGoal: 5,
          now: day4,
        );
        await answerWholeSession(session4, correct: true, now: day4);
        final SessionSummary summary4 = await complete(session4, day4);
        expect(
          summary4.currentStreak,
          1,
          reason: 'day 3 was skipped, so only day 4 is consecutive',
        );
      },
    );

    test('dashboard shows due reviews on the following day', () async {
      final LearningSession session = await sessions.createSession(
        dailyGoal: 5,
        now: day1,
      );
      await answerWholeSession(session, correct: true, now: day1);
      await complete(session, day1);

      final HomeSnapshot nextDay = await dashboard.load(
        dailyGoal: 5,
        now: day2,
      );
      expect(nextDay.completedToday, 0);
      expect(nextDay.dueReviews, 5);
      expect(nextDay.currentStreak, 1, reason: 'yesterday keeps it alive');
      expect(nextDay.rememberedWords, 5);
    });

    test('opening the app does not create a streak', () async {
      final HomeSnapshot snapshot = await dashboard.load(
        dailyGoal: 5,
        now: day1,
      );
      expect(snapshot.currentStreak, 0);
      expect(snapshot.completedToday, 0);
      expect(snapshot.totalWordsStudied, 0);
    });
  });

  group('reset learning progress', () {
    test('removes progress and study days but keeps vocabulary', () async {
      final LearningSession session = await sessions.createSession(
        dailyGoal: 5,
        now: day1,
      );
      await answerWholeSession(session, correct: true, now: day1);
      await complete(session, day1);

      await database.resetLearningProgress();

      expect(await vocabulary.count(), 100);
      expect(await progress.totalWordsStudied(), 0);
      expect(await progress.completedSessionDateKeys(), isEmpty);
      expect(await progress.progressFor(session.words.first.word.id), isNull);

      final HomeSnapshot snapshot = await dashboard.load(
        dailyGoal: 5,
        now: day1,
      );
      expect(snapshot.currentStreak, 0);
      expect(snapshot.completedToday, 0);
      expect(snapshot.dueReviews, 0);
    });
  });
}
