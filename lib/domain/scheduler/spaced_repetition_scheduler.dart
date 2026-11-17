import '../../core/constants/app_constants.dart';
import '../../core/utils/local_date.dart';

/// The next review state calculated by [SpacedRepetitionScheduler].
class ReviewSchedule {
  const ReviewSchedule({
    required this.successfulRepetitions,
    required this.lapseCount,
    required this.lastReviewAt,
    required this.nextReviewAt,
  });

  final int successfulRepetitions;
  final int lapseCount;
  final DateTime lastReviewAt;
  final DateTime nextReviewAt;

  /// Review interval that was applied, in days.
  int get intervalDays =>
      LocalDate.dayDifference(LocalDate.startOfDay(lastReviewAt), nextReviewAt);
}

/// A deliberately simple, testable spaced repetition scheduler.
///
/// Intervals after consecutive successful recalls:
/// 1 day → 3 days → 7 days → 14 days → 30 days (and 30 days from then on).
///
/// An incorrect recall resets the success stage to zero, increases the lapse
/// count and schedules an earlier review for the next local day.
class SpacedRepetitionScheduler {
  const SpacedRepetitionScheduler({
    this.intervalsDays = AppConstants.reviewIntervalsDays,
  });

  final List<int> intervalsDays;

  int get maxStage => intervalsDays.length;

  ReviewSchedule schedule({
    required int previousSuccessfulRepetitions,
    required int previousLapseCount,
    required bool correct,
    required DateTime now,
  }) {
    final DateTime today = LocalDate.startOfDay(now);
    if (correct) {
      final int previousStage = previousSuccessfulRepetitions.clamp(
        0,
        maxStage,
      );
      final int nextStage = (previousStage + 1).clamp(1, maxStage);
      final int interval = intervalsDays[nextStage - 1];
      return ReviewSchedule(
        successfulRepetitions: nextStage,
        lapseCount: previousLapseCount,
        lastReviewAt: now,
        nextReviewAt: LocalDate.addDays(today, interval),
      );
    }

    // Incorrect: reset the consecutive success stage and bring the next
    // review forward to tomorrow so the word is seen again soon.
    return ReviewSchedule(
      successfulRepetitions: 0,
      lapseCount: previousLapseCount + 1,
      lastReviewAt: now,
      nextReviewAt: LocalDate.addDays(today, 1),
    );
  }
}
