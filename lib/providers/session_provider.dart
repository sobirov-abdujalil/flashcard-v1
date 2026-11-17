import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/utils/app_haptics.dart';
import '../data/models/app_settings.dart';
import '../data/repositories/session_repository.dart';
import '../domain/models/session_models.dart';
import '../domain/session/recall_engine.dart';
import '../services/tts_service.dart';
import 'app_providers.dart';
import 'session_state.dart';
import 'settings_provider.dart';

/// Drives the Home → Learn → Recall → Session Complete journey.
///
/// The controller owns no database access directly: it delegates to
/// [SessionRepository], which commits every answer in its own transaction.
class SessionController extends Notifier<SessionState> {
  @override
  SessionState build() => const SessionState();

  /// Creates a fresh session and moves to the Learn phase.
  Future<LearningSession?> startSession() async {
    state = const SessionState(phase: SessionPhase.loading);
    try {
      await ref.read(appBootstrapProvider.future);
      final AppSettings settings = await ref.read(settingsProvider.future);
      final SessionRepository repository = ref.read(sessionRepositoryProvider);
      final LearningSession session = await repository.createSession(
        dailyGoal: settings.dailyGoal,
      );
      state = SessionState(
        phase: SessionPhase.learning,
        session: session,
        recall: RecallEngine(questions: session.questions),
      );
      return session;
    } on SessionUnavailableException catch (error) {
      state = SessionState(
        phase: SessionPhase.error,
        errorMessage: error.message,
      );
      return null;
    } catch (_) {
      state = const SessionState(
        phase: SessionPhase.error,
        errorMessage: 'Mashqni boshlashda xatolik yuz berdi. Iltimos, qayta urinib ko‘ring.',
      );
      return null;
    }
  }

  /// Reveals the meaning of the current Learn word.
  void revealMeaning() {
    if (state.phase != SessionPhase.learning || state.meaningRevealed) return;
    state = state.copyWith(meaningRevealed: true);
  }

  /// Advances inside the Learn phase; after the last word it moves to Recall.
  void nextLearnWord() {
    if (state.phase != SessionPhase.learning || !state.meaningRevealed) return;
    if (state.isLastLearnWord) {
      state = state.copyWith(
        phase: SessionPhase.recall,
        meaningRevealed: false,
      );
      return;
    }
    state = state.copyWith(
      learnIndex: state.learnIndex + 1,
      meaningRevealed: false,
    );
  }

  /// Speaks the current word. Returns false when TTS is unavailable.
  Future<bool> pronounceCurrent({bool recall = false}) async {
    final TtsService tts = ref.read(ttsServiceProvider);
    final String? text = recall
        ? state.currentQuestion?.word.word
        : state.currentLearnWord?.word.word;
    if (text == null) return false;
    return tts.speak(text);
  }

  /// Records an answer. Returns false when the answer could not be persisted.
  Future<bool> answer(int choiceIndex) async {
    final SessionState current = state;
    final RecallEngine? engine = current.recall;
    if (current.phase != SessionPhase.recall ||
        engine == null ||
        engine.isAnswered ||
        engine.current == null) {
      return true;
    }

    final SessionQuestion question = engine.current!;
    state = current.copyWith(isSavingAnswer: true);
    final AnswerOutcome outcome = engine.answer(choiceIndex);
    state = state.copyWith(recall: engine);

    if (outcome.isCorrect) {
      await AppHaptics.success();
    } else {
      await AppHaptics.error();
    }

    try {
      await ref
          .read(sessionRepositoryProvider)
          .recordAnswer(
            word: question.word,
            isCorrect: outcome.isCorrect,
            isNewWord: question.isNew,
            isRetry: question.isRetry,
          );
      ref.read(progressRevisionProvider.notifier).bump();
      state = state.copyWith(isSavingAnswer: false);
      return true;
    } catch (_) {
      state = state.copyWith(
        isSavingAnswer: false,
        warningMessage: 'Javobni saqlashda muammo bo‘ldi, lekin mashqni davom ettirishingiz mumkin.',
        clearError: true,
      );
      return false;
    }
  }

  /// Moves to the next question or completes the session.
  Future<void> nextQuestion() async {
    final SessionState current = state;
    final RecallEngine? engine = current.recall;
    if (current.phase != SessionPhase.recall ||
        engine == null ||
        !engine.isAnswered ||
        current.isSavingAnswer) {
      return;
    }
    engine.next();
    if (engine.isComplete) {
      state = current.copyWith(recall: engine);
      await _completeSession();
      return;
    }
    state = current.copyWith(recall: engine);
  }

  Future<void> _completeSession() async {
    final SessionState current = state;
    final LearningSession? session = current.session;
    final RecallEngine? engine = current.recall;
    if (session == null || engine == null) return;

    final int newWordsStudied = session.words
        .where((SessionWord entry) => entry.isNew)
        .length;

    try {
      final SessionSummary summary = await ref
          .read(sessionRepositoryProvider)
          .completeSession(
            session: session,
            correctAnswers: engine.correctFirstAttempts,
            newWordsStudied: newWordsStudied,
            retryCount: engine.retryAttempts,
          );
      state = state.copyWith(phase: SessionPhase.complete, summary: summary);
      ref.read(progressRevisionProvider.notifier).bump();
    } catch (_) {
      final SessionSummary fallback = SessionSummary(
        totalExercises: session.questions.length,
        correctAnswers: engine.correctFirstAttempts,
        newWordsStudied: newWordsStudied,
        currentStreak: 0,
        nextReviewAt: null,
        dailyGoal: session.dailyGoal,
        completedToday: session.questions.length,
        goalCompleted: session.questions.length >= session.dailyGoal,
        retryCount: engine.retryAttempts,
        completedAt: DateTime.now(),
      );
      state = state.copyWith(
        phase: SessionPhase.complete,
        summary: fallback,
        warningMessage: 'Natijani saqlashda muammo bo‘ldi. Mashqlar javoblari saqlangan bo‘lishi mumkin.',
      );
    }
  }

  /// Clears the session (used when leaving for Home).
  void reset() {
    state = const SessionState();
  }

  void clearWarning() {
    if (state.warningMessage == null) return;
    state = state.copyWith(clearWarning: true);
  }
}

final NotifierProvider<SessionController, SessionState> sessionProvider =
    NotifierProvider<SessionController, SessionState>(
      SessionController.new,
      isAutoDispose: false,
    );
