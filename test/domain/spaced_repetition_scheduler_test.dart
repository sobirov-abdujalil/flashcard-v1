import 'package:flutter_test/flutter_test.dart';
import 'package:soz_atlas/core/utils/local_date.dart';
import 'package:soz_atlas/domain/scheduler/spaced_repetition_scheduler.dart';

void main() {
  const SpacedRepetitionScheduler scheduler = SpacedRepetitionScheduler();
  final DateTime now = DateTime(2026, 11, 14, 20, 30);

  group('SpacedRepetitionScheduler intervals', () {
    test('first successful recall schedules the next review in 1 day', () {
      final ReviewSchedule schedule = scheduler.schedule(
        previousSuccessfulRepetitions: 0,
        previousLapseCount: 0,
        correct: true,
        now: now,
      );
      expect(schedule.successfulRepetitions, 1);
      expect(schedule.nextReviewAt, DateTime(2026, 11, 15));
      expect(schedule.intervalDays, 1);
      expect(schedule.lapseCount, 0);
      expect(schedule.lastReviewAt, now);
    });

    test('second consecutive success schedules 3 days', () {
      final ReviewSchedule schedule = scheduler.schedule(
        previousSuccessfulRepetitions: 1,
        previousLapseCount: 0,
        correct: true,
        now: now,
      );
      expect(schedule.successfulRepetitions, 2);
      expect(schedule.nextReviewAt, DateTime(2026, 11, 17));
      expect(schedule.intervalDays, 3);
    });

    test('third consecutive success schedules 7 days', () {
      final ReviewSchedule schedule = scheduler.schedule(
        previousSuccessfulRepetitions: 2,
        previousLapseCount: 1,
        correct: true,
        now: now,
      );
      expect(schedule.successfulRepetitions, 3);
      expect(schedule.nextReviewAt, DateTime(2026, 11, 21));
      expect(schedule.intervalDays, 7);
      expect(schedule.lapseCount, 1, reason: 'lapses are historical');
    });

    test('fourth consecutive success schedules 14 days', () {
      final ReviewSchedule schedule = scheduler.schedule(
        previousSuccessfulRepetitions: 3,
        previousLapseCount: 0,
        correct: true,
        now: now,
      );
      expect(schedule.successfulRepetitions, 4);
      expect(schedule.nextReviewAt, DateTime(2026, 11, 28));
      expect(schedule.intervalDays, 14);
    });

    test('fifth consecutive success schedules 30 days', () {
      final ReviewSchedule schedule = scheduler.schedule(
        previousSuccessfulRepetitions: 4,
        previousLapseCount: 0,
        correct: true,
        now: now,
      );
      expect(schedule.successfulRepetitions, 5);
      expect(schedule.nextReviewAt, DateTime(2026, 12, 14));
      expect(schedule.intervalDays, 30);
    });

    test('later successes stay at the 30 day interval', () {
      final ReviewSchedule schedule = scheduler.schedule(
        previousSuccessfulRepetitions: 9,
        previousLapseCount: 0,
        correct: true,
        now: now,
      );
      expect(schedule.successfulRepetitions, 5);
      expect(schedule.nextReviewAt, DateTime(2026, 12, 14));
    });
  });

  group('SpacedRepetitionScheduler incorrect answers', () {
    test(
      'resets the success stage, increments lapses and reviews tomorrow',
      () {
        final ReviewSchedule schedule = scheduler.schedule(
          previousSuccessfulRepetitions: 4,
          previousLapseCount: 2,
          correct: false,
          now: now,
        );
        expect(schedule.successfulRepetitions, 0);
        expect(schedule.lapseCount, 3);
        expect(schedule.nextReviewAt, DateTime(2026, 11, 15));
        expect(schedule.intervalDays, 1);
      },
    );

    test('a recovery after a lapse starts the interval chain again', () {
      final ReviewSchedule afterLapse = scheduler.schedule(
        previousSuccessfulRepetitions: 0,
        previousLapseCount: 1,
        correct: true,
        now: now,
      );
      expect(afterLapse.successfulRepetitions, 1);
      expect(afterLapse.nextReviewAt, DateTime(2026, 11, 15));
    });
  });

  group('local calendar date handling', () {
    test('uses local midnight even when reviewed late at night', () {
      final ReviewSchedule schedule = scheduler.schedule(
        previousSuccessfulRepetitions: 0,
        previousLapseCount: 0,
        correct: true,
        now: DateTime(2026, 11, 14, 23, 58, 30),
      );
      expect(schedule.nextReviewAt, DateTime(2026, 11, 15));
      expect(schedule.nextReviewAt.hour, 0);
      expect(schedule.nextReviewAt.minute, 0);
    });

    test('handles month and year boundaries', () {
      final ReviewSchedule schedule = scheduler.schedule(
        previousSuccessfulRepetitions: 0,
        previousLapseCount: 0,
        correct: true,
        now: DateTime(2026, 12, 31, 22),
      );
      expect(schedule.nextReviewAt, DateTime(2027, 1, 1));
    });

    test('handles leap-year February', () {
      final ReviewSchedule schedule = scheduler.schedule(
        previousSuccessfulRepetitions: 0,
        previousLapseCount: 0,
        correct: true,
        now: DateTime(2028, 2, 28, 23, 59),
      );
      expect(schedule.nextReviewAt, DateTime(2028, 2, 29));
    });

    test('a scheduled review is due at the start of the next local day', () {
      final ReviewSchedule schedule = scheduler.schedule(
        previousSuccessfulRepetitions: 0,
        previousLapseCount: 0,
        correct: true,
        now: now,
      );
      expect(
        LocalDate.key(schedule.nextReviewAt),
        LocalDate.key(DateTime(2026, 11, 15)),
      );
    });
  });
}
