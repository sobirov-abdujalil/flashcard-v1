/// Spaced repetition state for a single vocabulary item.
class WordProgress {
  const WordProgress({
    required this.wordId,
    required this.lastReviewAt,
    required this.nextReviewAt,
    required this.successfulRepetitions,
    required this.lapseCount,
    required this.totalCorrect,
    required this.totalAttempts,
  });

  final int wordId;
  final DateTime lastReviewAt;
  final DateTime nextReviewAt;
  final int successfulRepetitions;
  final int lapseCount;
  final int totalCorrect;
  final int totalAttempts;

  bool isDue(DateTime now) => !nextReviewAt.isAfter(now);

  WordProgress copyWith({
    DateTime? lastReviewAt,
    DateTime? nextReviewAt,
    int? successfulRepetitions,
    int? lapseCount,
    int? totalCorrect,
    int? totalAttempts,
  }) {
    return WordProgress(
      wordId: wordId,
      lastReviewAt: lastReviewAt ?? this.lastReviewAt,
      nextReviewAt: nextReviewAt ?? this.nextReviewAt,
      successfulRepetitions:
          successfulRepetitions ?? this.successfulRepetitions,
      lapseCount: lapseCount ?? this.lapseCount,
      totalCorrect: totalCorrect ?? this.totalCorrect,
      totalAttempts: totalAttempts ?? this.totalAttempts,
    );
  }

  factory WordProgress.fromMap(Map<String, Object?> map) {
    return WordProgress(
      wordId: map['word_id'] as int,
      lastReviewAt: DateTime.fromMillisecondsSinceEpoch(
        map['last_review_at'] as int,
      ),
      nextReviewAt: DateTime.fromMillisecondsSinceEpoch(
        map['next_review_at'] as int,
      ),
      successfulRepetitions: map['successful_repetitions'] as int,
      lapseCount: map['lapse_count'] as int,
      totalCorrect: map['total_correct'] as int,
      totalAttempts: map['total_attempts'] as int,
    );
  }

  Map<String, Object?> toMap() => <String, Object?>{
    'word_id': wordId,
    'last_review_at': lastReviewAt.millisecondsSinceEpoch,
    'next_review_at': nextReviewAt.millisecondsSinceEpoch,
    'successful_repetitions': successfulRepetitions,
    'lapse_count': lapseCount,
    'total_correct': totalCorrect,
    'total_attempts': totalAttempts,
  };
}
