import 'package:flutter_test/flutter_test.dart';
import 'package:soz_atlas/domain/models/session_models.dart';
import 'package:soz_atlas/domain/summary/share_text_builder.dart';

SessionSummary summary({
  int totalExercises = 5,
  int correctAnswers = 4,
  int newWordsStudied = 2,
  int currentStreak = 3,
  bool goalCompleted = true,
  int retryCount = 0,
}) => SessionSummary(
  totalExercises: totalExercises,
  correctAnswers: correctAnswers,
  newWordsStudied: newWordsStudied,
  currentStreak: currentStreak,
  nextReviewAt: DateTime(2026, 11, 15),
  dailyGoal: 5,
  completedToday: 5,
  goalCompleted: goalCompleted,
  retryCount: retryCount,
  completedAt: DateTime(2026, 11, 14, 18),
);

void main() {
  group('buildSessionShareText', () {
    test('uses only the real numbers from the session', () {
      final String text = buildSessionShareText(summary());
      expect(text, contains('5 ta mashq'));
      expect(text, contains('4 ta to‘g‘ri javob'));
      expect(text, contains('2 ta yangi so‘z'));
      expect(text, contains('Joriy seriya: 3 kun'));
      expect(text, contains('Bugungi maqsad bajarildi.'));
      expect(text, contains('So‘z Atlas'));
      expect(text, isNot(contains('null')));
    });

    test('never invents achievements that did not happen', () {
      final String text = buildSessionShareText(
        summary(
          totalExercises: 5,
          correctAnswers: 0,
          newWordsStudied: 0,
          currentStreak: 0,
          goalCompleted: false,
        ),
      );
      expect(text, contains('0 ta to‘g‘ri javob'));
      expect(text, isNot(contains('seriya')));
      expect(text, isNot(contains('bajarildi')));
    });

    test('omits the streak line when there is no streak yet', () {
      final String text = buildSessionShareText(summary(currentStreak: 0));
      expect(text, isNot(contains('Joriy seriya')));
    });

    test('mentions the goal only when it was actually completed', () {
      expect(
        buildSessionShareText(summary(goalCompleted: true)),
        contains('Bugungi maqsad bajarildi.'),
      );
      expect(
        buildSessionShareText(summary(goalCompleted: false)),
        isNot(contains('Bugungi maqsad bajarildi.')),
      );
    });
  });
}
