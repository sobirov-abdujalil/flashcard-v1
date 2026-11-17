import 'package:flutter_test/flutter_test.dart';
import 'package:soz_atlas/core/constants/part_of_speech.dart';
import 'package:soz_atlas/core/utils/local_date.dart';
import 'package:soz_atlas/data/models/word.dart';
import 'package:soz_atlas/domain/models/session_models.dart';
import 'package:soz_atlas/domain/session/session_composer.dart';

Word word(int id) => Word(
  id: id,
  word: 'word$id',
  phonetic: '/wɜːd/',
  partOfSpeech: PartOfSpeech.noun,
  cefrLevel: 'A1',
  translation: 'tarjima$id',
  definition: 'definition $id',
  example: 'Example sentence $id.',
  exampleTranslation: 'Misol gap $id.',
);

void main() {
  group('SessionComposer', () {
    test('prioritises due words in the provided (oldest first) order', () {
      final List<SessionWord> result = SessionComposer.compose(
        dueWords: <Word>[word(1), word(2)],
        newWords: <Word>[word(3), word(4), word(5)],
        fallbackWords: <Word>[],
        size: 5,
      );
      expect(result.map((SessionWord e) => e.word.id), <int>[1, 2, 3, 4, 5]);
      expect(result[0].isDue, isTrue);
      expect(result[0].isNew, isFalse);
      expect(result[2].isNew, isTrue);
      expect(result[2].isDue, isFalse);
    });

    test('caps the session at the requested size', () {
      final List<SessionWord> result = SessionComposer.compose(
        dueWords: <Word>[for (int id = 1; id <= 8; id++) word(id)],
        newWords: <Word>[for (int id = 20; id <= 30; id++) word(id)],
        fallbackWords: <Word>[],
        size: 5,
      );
      expect(result, hasLength(5));
      expect(result.map((SessionWord e) => e.word.id), <int>[1, 2, 3, 4, 5]);
    });

    test('never duplicates a word that appears in several candidate lists', () {
      final List<SessionWord> result = SessionComposer.compose(
        dueWords: <Word>[word(1)],
        newWords: <Word>[word(1), word(2)],
        fallbackWords: <Word>[word(2), word(3)],
        size: 5,
      );
      expect(result.map((SessionWord e) => e.word.id), <int>[1, 2, 3]);
    });

    test('fills remaining places with fallback words', () {
      final List<SessionWord> result = SessionComposer.compose(
        dueWords: <Word>[],
        newWords: <Word>[word(1)],
        fallbackWords: <Word>[word(2), word(3)],
        size: 3,
      );
      expect(result.map((SessionWord e) => e.word.id), <int>[1, 2, 3]);
      expect(result[0].isNew, isTrue);
      expect(result[1].isNew, isFalse);
      expect(result[1].isDue, isFalse);
    });

    test('returns an empty session for a non-positive size', () {
      expect(
        SessionComposer.compose(
          dueWords: <Word>[word(1)],
          newWords: <Word>[word(2)],
          fallbackWords: <Word>[],
          size: 0,
        ),
        isEmpty,
      );
    });
  });

  group('DailyGoalPlanner', () {
    test('a fresh day uses the full daily goal', () {
      expect(DailyGoalPlanner.sessionSize(dailyGoal: 5, completedToday: 0), 5);
    });

    test('a partially completed goal is filled up exactly', () {
      expect(DailyGoalPlanner.sessionSize(dailyGoal: 5, completedToday: 2), 3);
      expect(DailyGoalPlanner.sessionSize(dailyGoal: 10, completedToday: 4), 6);
    });

    test('a completed goal keeps offering a full extra practice session', () {
      expect(DailyGoalPlanner.sessionSize(dailyGoal: 5, completedToday: 5), 5);
      expect(DailyGoalPlanner.sessionSize(dailyGoal: 5, completedToday: 9), 5);
    });

    test('an invalid goal falls back to the default session size', () {
      expect(DailyGoalPlanner.sessionSize(dailyGoal: 0, completedToday: 0), 5);
    });
  });

  group('StreakCalculator', () {
    final DateTime today = DateTime(2026, 11, 14);

    String key(int year, int month, int day) =>
        LocalDate.key(DateTime(year, month, day));

    test('no completed sessions means no streak', () {
      expect(
        StreakCalculator.currentStreak(
          completedDateKeys: const <String>[],
          today: today,
        ),
        0,
      );
    });

    test('a completed session today starts a streak', () {
      expect(
        StreakCalculator.currentStreak(
          completedDateKeys: <String>[key(2026, 11, 14)],
          today: today,
        ),
        1,
      );
    });

    test('the streak survives until today is finished', () {
      expect(
        StreakCalculator.currentStreak(
          completedDateKeys: <String>[key(2026, 11, 13)],
          today: today,
        ),
        1,
      );
    });

    test('consecutive days are counted backwards from today', () {
      expect(
        StreakCalculator.currentStreak(
          completedDateKeys: <String>[
            key(2026, 11, 14),
            key(2026, 11, 13),
            key(2026, 11, 12),
          ],
          today: today,
        ),
        3,
      );
    });

    test('a gap ends the streak', () {
      expect(
        StreakCalculator.currentStreak(
          completedDateKeys: <String>[
            key(2026, 11, 14),
            key(2026, 11, 13),
            // 12 missing
            key(2026, 11, 11),
          ],
          today: today,
        ),
        2,
      );
    });

    test('a streak that ended before yesterday is zero', () {
      expect(
        StreakCalculator.currentStreak(
          completedDateKeys: <String>[key(2026, 11, 10)],
          today: today,
        ),
        0,
      );
    });

    test('month and year boundaries work', () {
      expect(
        StreakCalculator.currentStreak(
          completedDateKeys: <String>[
            key(2027, 1, 1),
            key(2026, 12, 31),
            key(2026, 12, 30),
          ],
          today: DateTime(2027, 1, 1),
        ),
        3,
      );
    });
  });
}
