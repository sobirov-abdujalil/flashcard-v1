import '../data/models/word.dart';
import '../domain/models/session_models.dart';
import '../domain/session/recall_engine.dart';

/// Which part of the session the UI is currently showing.
enum SessionPhase { idle, loading, learning, recall, complete, error }

/// Immutable UI state for the whole learning journey.
///
/// The mutable quiz bookkeeping lives in [RecallEngine]; this state simply
/// carries the engine plus everything needed to render a frame.
class SessionState {
  const SessionState({
    this.phase = SessionPhase.idle,
    this.session,
    this.recall,
    this.learnIndex = 0,
    this.meaningRevealed = false,
    this.isReviewSession = false,
    this.summary,
    this.errorMessage,
    this.warningMessage,
    this.isSavingAnswer = false,
  });

  final SessionPhase phase;
  final LearningSession? session;
  final RecallEngine? recall;
  final int learnIndex;
  final bool meaningRevealed;
  final bool isReviewSession;
  final SessionSummary? summary;
  final String? errorMessage;

  /// True while the current answer is being committed to SQLite. The "next"
  /// action stays disabled so an answer is never lost.
  final bool isSavingAnswer;

  /// Non-fatal problem, e.g. a progress write failed but the session continued.
  final String? warningMessage;

  bool get isLoading => phase == SessionPhase.loading;

  bool get isActive =>
      phase == SessionPhase.learning || phase == SessionPhase.recall;

  SessionWord? get currentLearnWord {
    final LearningSession? learningSession = session;
    if (learningSession == null) return null;
    if (learnIndex < 0 || learnIndex >= learningSession.words.length) {
      return null;
    }
    return learningSession.words[learnIndex];
  }

  int get learnCount => session?.words.length ?? 0;

  int get learnProgressNumber => (learnIndex + 1).clamp(1, learnCount);

  double get learnProgress {
    if (learnCount == 0) return 0;
    return ((learnIndex + (meaningRevealed ? 1 : 0)) / learnCount).clamp(
      0.0,
      1.0,
    );
  }

  bool get isLastLearnWord => learnCount > 0 && learnIndex >= learnCount - 1;

  SessionQuestion? get currentQuestion => recall?.current;

  bool get recallAnswered => recall?.isAnswered ?? false;

  int get questionNumber => recall?.currentNumber ?? 0;

  int get questionTotal => recall?.totalQuestions ?? 0;

  double get recallProgress {
    final RecallEngine? engine = recall;
    if (engine == null || engine.totalQuestions == 0) return 0;
    return (engine.firstAttemptProgress / engine.totalQuestions).clamp(
      0.0,
      1.0,
    );
  }

  Word? get currentWord => currentQuestion?.word;

  /// Convenience copy used by the controller.
  SessionState copyWith({
    SessionPhase? phase,
    LearningSession? session,
    RecallEngine? recall,
    int? learnIndex,
    bool? meaningRevealed,
    bool? isReviewSession,
    SessionSummary? summary,
    String? errorMessage,
    String? warningMessage,
    bool clearError = false,
    bool clearWarning = false,
    bool clearSummary = false,
    bool? isSavingAnswer,
  }) {
    return SessionState(
      phase: phase ?? this.phase,
      session: session ?? this.session,
      recall: recall ?? this.recall,
      learnIndex: learnIndex ?? this.learnIndex,
      meaningRevealed: meaningRevealed ?? this.meaningRevealed,
      isReviewSession: isReviewSession ?? this.isReviewSession,
      summary: clearSummary ? null : (summary ?? this.summary),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      warningMessage: clearWarning
          ? null
          : (warningMessage ?? this.warningMessage),
      isSavingAnswer: isSavingAnswer ?? this.isSavingAnswer,
    );
  }
}
