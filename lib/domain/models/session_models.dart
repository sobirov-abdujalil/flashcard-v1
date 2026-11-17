import '../../data/models/word.dart';

/// A word inside a learning session together with the reason it was selected.
class SessionWord {
  const SessionWord({
    required this.word,
    required this.isNew,
    required this.isDue,
  });

  final Word word;

  /// True when the user has never answered this word before.
  final bool isNew;

  /// True when the word was selected because its review date has passed.
  final bool isDue;
}

/// One Uzbek answer option in a recall question.
class AnswerChoice {
  const AnswerChoice({required this.translation});

  final String translation;
}

/// A single recall question: the English word, four Uzbek choices and which
/// choice is correct.
class SessionQuestion {
  const SessionQuestion({
    required this.word,
    required this.choices,
    required this.correctIndex,
    required this.isNew,
    this.isRetry = false,
  });

  final Word word;
  final List<AnswerChoice> choices;
  final int correctIndex;
  final bool isNew;
  final bool isRetry;

  String get correctTranslation => choices[correctIndex].translation;

  SessionQuestion asRetry() => SessionQuestion(
    word: word,
    choices: choices,
    correctIndex: correctIndex,
    isNew: isNew,
    isRetry: true,
  );
}

/// The complete plan for one learning session.
class LearningSession {
  const LearningSession({
    required this.words,
    required this.questions,
    required this.dailyGoal,
  });

  final List<SessionWord> words;
  final List<SessionQuestion> questions;
  final int dailyGoal;

  int get size => questions.length;

  int get newWordCount => words.where((SessionWord w) => w.isNew).length;

  int get dueWordCount => words.where((SessionWord w) => w.isDue).length;

  bool get isEmpty => questions.isEmpty;
}

/// Result of answering one recall question.
class AnswerOutcome {
  const AnswerOutcome({
    required this.isCorrect,
    required this.correctIndex,
    required this.correctTranslation,
    required this.wasRetry,
    required this.retryScheduled,
  });

  final bool isCorrect;
  final int correctIndex;
  final String correctTranslation;
  final bool wasRetry;

  /// True when this incorrect first attempt also added the word to the retry
  /// queue at the end of the session.
  final bool retryScheduled;
}

/// Summary shown on the Session Complete screen.
class SessionSummary {
  const SessionSummary({
    required this.totalExercises,
    required this.correctAnswers,
    required this.newWordsStudied,
    required this.currentStreak,
    required this.nextReviewAt,
    required this.dailyGoal,
    required this.completedToday,
    required this.goalCompleted,
    required this.retryCount,
    required this.completedAt,
  });

  final int totalExercises;
  final int correctAnswers;
  final int newWordsStudied;
  final int currentStreak;
  final DateTime? nextReviewAt;
  final int dailyGoal;
  final int completedToday;
  final bool goalCompleted;
  final int retryCount;
  final DateTime completedAt;

  int get incorrectAnswers => totalExercises - correctAnswers;

  double get accuracy {
    if (totalExercises == 0) return 0;
    return correctAnswers / totalExercises;
  }
}
