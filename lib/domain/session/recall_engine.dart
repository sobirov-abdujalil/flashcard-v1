import 'dart:math';

import '../models/session_models.dart';

/// In-memory state machine for the recall (quiz) phase.
///
/// It is intentionally free of Flutter and database dependencies so every
/// rule — one answer per question, immediate feedback, retry queue, counters —
/// can be unit tested directly.
class RecallEngine {
  RecallEngine({
    required List<SessionQuestion> questions,
    this.maxRetriesPerWord = 1,
  }) : _queue = <SessionQuestion>[...questions] {
    _baseQuestionCount = questions.length;
  }

  final int maxRetriesPerWord;

  late final int _baseQuestionCount;
  final List<SessionQuestion> _queue;
  final Set<int> _retriedWordIds = <int>{};

  int _index = 0;
  int _answeredFirstAttempts = 0;
  int _correctFirstAttempts = 0;
  int _retryAttempts = 0;
  int _retryCorrect = 0;
  int _answeredTotal = 0;
  AnswerOutcome? _lastOutcome;

  int get totalQuestions => _baseQuestionCount;

  int get answeredFirstAttempts => _answeredFirstAttempts;

  int get correctFirstAttempts => _correctFirstAttempts;

  int get retryAttempts => _retryAttempts;

  int get retryCorrect => _retryCorrect;

  int get answeredTotal => _answeredTotal;

  int get retryQuestionsScheduled => _retryAttempts;

  int get currentNumber => min(_index + 1, _queue.length);

  SessionQuestion? get current =>
      _index < _queue.length ? _queue[_index] : null;

  bool get isCurrentRetry => current?.isRetry ?? false;

  bool get isAnswered => _lastOutcome != null;

  AnswerOutcome? get lastOutcome => _lastOutcome;

  int? get selectedIndex => _lastOutcome == null ? null : _selectedIndex;
  int? _selectedIndex;

  bool get isComplete => _index >= _queue.length;

  bool get isLastQuestion => _index >= _queue.length - 1;

  /// Zero-based index in the live question queue (retries included).
  int get questionIndex => _index;

  /// How many first-attempt questions have been answered, for the `3 / 5`
  /// progress label. Retries never increase this number.
  int get firstAttemptProgress => _answeredFirstAttempts;

  /// Records an answer for the current question.
  ///
  /// Throws [StateError] when the current question has already been answered,
  /// which is the safety net behind the UI's disabled state.
  AnswerOutcome answer(int choiceIndex) {
    final SessionQuestion? question = current;
    if (question == null) {
      throw StateError('There is no active question.');
    }
    if (_lastOutcome != null) {
      throw StateError('This question has already been answered.');
    }
    if (choiceIndex < 0 || choiceIndex >= question.choices.length) {
      throw RangeError.index(choiceIndex, question.choices, 'choiceIndex');
    }

    final bool correct = choiceIndex == question.correctIndex;
    bool retryScheduled = false;

    if (question.isRetry) {
      _retryAttempts++;
      if (correct) _retryCorrect++;
    } else {
      _answeredFirstAttempts++;
      if (correct) {
        _correctFirstAttempts++;
      } else if (maxRetriesPerWord > 0 &&
          _retriedWordIds.add(question.word.id)) {
        // Give the learner one more chance at the end of the same session.
        _queue.add(question.asRetry());
        retryScheduled = true;
      }
    }
    _answeredTotal++;

    _selectedIndex = choiceIndex;
    _lastOutcome = AnswerOutcome(
      isCorrect: correct,
      correctIndex: question.correctIndex,
      correctTranslation: question.correctTranslation,
      wasRetry: question.isRetry,
      retryScheduled: retryScheduled,
    );
    return _lastOutcome!;
  }

  /// Moves to the next question (or completes the engine).
  void next() {
    if (_lastOutcome == null) {
      throw StateError('Answer the current question before moving on.');
    }
    _index++;
    _lastOutcome = null;
    _selectedIndex = null;
  }

  /// Checks a choice index without mutating anything (used by tests).
  bool isCorrectChoice(int choiceIndex) =>
      current != null && choiceIndex == current!.correctIndex;
}
