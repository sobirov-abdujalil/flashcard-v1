import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_constants.dart';
import '../../core/constants/routes.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/word.dart';
import '../../domain/models/session_models.dart';
import '../../domain/session/recall_engine.dart';
import '../../features/session/session_launcher.dart';
import '../../providers/session_provider.dart';
import '../../providers/session_state.dart';
import '../../shared/utils/dialogs.dart';
import '../../shared/widgets/answer_option.dart';
import '../../shared/widgets/glass_card.dart';
import '../../shared/widgets/gradient_background.dart';
import '../../shared/widgets/gradient_button.dart';
import '../../shared/widgets/pressable_scale.dart';
import '../../shared/widgets/session_progress_header.dart';

/// Screen 3 — Recall / Quiz.
class RecallScreen extends ConsumerStatefulWidget {
  const RecallScreen({super.key});

  @override
  ConsumerState<RecallScreen> createState() => _RecallScreenState();
}

class _RecallScreenState extends ConsumerState<RecallScreen> {
  bool _advancing = false;
  bool _pronouncing = false;

  Future<void> _answer(int index) async {
    final bool persisted = await ref
        .read(sessionProvider.notifier)
        .answer(index);
    if (!mounted) return;
    if (!persisted) {
      showAppSnack(context, 'Javobni saqlashda muammo bo‘ldi.', isError: true);
    }
  }

  Future<void> _next() async {
    if (_advancing) return;
    setState(() => _advancing = true);
    await ref.read(sessionProvider.notifier).nextQuestion();
    if (!mounted) {
      return;
    }
    final SessionState state = ref.read(sessionProvider);
    if (state.phase == SessionPhase.complete) {
      Navigator.of(context).pushReplacementNamed(AppRoutes.summary);
      return;
    }
    setState(() => _advancing = false);
  }

  Future<void> _pronounce(Word word) async {
    if (_pronouncing) return;
    setState(() => _pronouncing = true);
    final bool ok = await ref
        .read(sessionProvider.notifier)
        .pronounceCurrent(recall: true);
    if (!mounted) return;
    setState(() => _pronouncing = false);
    if (!ok) {
      showAppSnack(
        context,
        'Bu qurilmada ingliz tili talaffuzi mavjud emas.',
        isError: true,
        icon: Icons.volume_off_rounded,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final SozAtlasColors colors = context.colors;
    final SessionState state = ref.watch(sessionProvider);
    final RecallEngine? engine = state.recall;
    final SessionQuestion? question = engine?.current;

    if (state.phase != SessionPhase.recall ||
        engine == null ||
        question == null) {
      return _RecallFallback(
        onHome: () {
          ref.read(sessionProvider.notifier).reset();
          Navigator.of(context).popUntil(ModalRoute.withName(AppRoutes.home));
        },
      );
    }

    final bool answered = engine.isAnswered;
    final int? selectedIndex = engine.selectedIndex;
    final bool isCorrect = engine.lastOutcome?.isCorrect ?? false;
    final String counterLabel = question.isRetry
        ? 'Takror'
        : '${engine.answeredFirstAttempts + (answered ? 0 : 1)} / ${engine.totalQuestions}';

    return Scaffold(
      backgroundColor: colors.background,
      body: GradientBackground(
        child: SafeArea(
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppConstants.screenPadding,
                  12,
                  AppConstants.screenPadding,
                  0,
                ),
                child: SessionProgressHeader(
                  title: 'Tekshirish',
                  counterLabel: counterLabel,
                  progress: engine.firstAttemptProgress / engine.totalQuestions,
                  onClose: () => exitSessionToHome(context, ref),
                ),
              ),
              Expanded(
                child: LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                    return SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(
                        AppConstants.screenPadding,
                        AppConstants.space20,
                        AppConstants.screenPadding,
                        AppConstants.space16,
                      ),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: (constraints.maxHeight - 36).clamp(
                            0.0,
                            double.infinity,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            _RecallWordCard(
                              word: question.word,
                              pronouncing: _pronouncing,
                              onPronounce: () => _pronounce(question.word),
                            ),
                            const SizedBox(height: AppConstants.space20),
                            Row(
                              children: <Widget>[
                                Flexible(
                                  child: Text(
                                    'Bu so‘zning ma’nosi qaysi?',
                                    style: context.textTheme.titleLarge
                                        ?.copyWith(fontSize: 19),
                                  ),
                                ),
                                if (question.isRetry) ...<Widget>[
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      color: colors.accentPink.withValues(
                                        alpha: 0.14,
                                      ),
                                      border: Border.all(
                                        color: colors.accentPink.withValues(
                                          alpha: 0.3,
                                        ),
                                      ),
                                    ),
                                    child: Text(
                                      'QAYTA',
                                      style: context.textTheme.labelSmall
                                          ?.copyWith(
                                            color: colors.accentPink,
                                            fontSize: 10,
                                            letterSpacing: 0.8,
                                          ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: AppConstants.space16),
                            for (
                              int index = 0;
                              index < question.choices.length;
                              index++
                            ) ...<Widget>[
                              AnswerOption(
                                key: ValueKey<String>(
                                  '${engine.questionIndex}-$index-${question.isRetry}',
                                ),
                                letter: String.fromCharCode(65 + index),
                                label: question.choices[index].translation,
                                state: _visualState(
                                  index: index,
                                  answered: answered,
                                  correctIndex: question.correctIndex,
                                  selectedIndex: selectedIndex,
                                ),
                                onTap: answered ? null : () => _answer(index),
                              ),
                              if (index != question.choices.length - 1)
                                const SizedBox(height: 10),
                            ],
                            const SizedBox(height: AppConstants.space12),
                            AnimatedSize(
                              duration:
                                  MediaQuery.maybeDisableAnimationsOf(
                                        context,
                                      ) ??
                                      false
                                  ? Duration.zero
                                  : const Duration(milliseconds: 200),
                              curve: Curves.easeOutCubic,
                              child: answered
                                  ? _AnswerFeedback(
                                      isCorrect: isCorrect,
                                      correctTranslation:
                                          question.correctTranslation,
                                      wasRetry: question.isRetry,
                                    )
                                  : const SizedBox(height: 76),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppConstants.screenPadding,
                  8,
                  AppConstants.screenPadding,
                  16,
                ),
                child: GradientButton(
                  label: 'Keyingi so‘z',
                  trailingIcon: Icons.arrow_forward_rounded,
                  onPressed: answered && !state.isSavingAnswer && !_advancing
                      ? _next
                      : null,
                  isLoading: _advancing,
                  semanticLabel: 'Keyingi so‘zga o‘tish',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  AnswerVisualState _visualState({
    required int index,
    required bool answered,
    required int correctIndex,
    required int? selectedIndex,
  }) {
    if (!answered) return AnswerVisualState.idle;
    if (index == correctIndex) return AnswerVisualState.correct;
    if (index == selectedIndex) return AnswerVisualState.incorrect;
    return AnswerVisualState.muted;
  }
}

class _RecallWordCard extends StatelessWidget {
  const _RecallWordCard({
    required this.word,
    required this.pronouncing,
    required this.onPronounce,
  });

  final Word word;
  final bool pronouncing;
  final VoidCallback onPronounce;

  @override
  Widget build(BuildContext context) {
    final SozAtlasColors colors = context.colors;
    return GlassCard(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  word.phonetic,
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: colors.accentLavender,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 4),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    word.word,
                    maxLines: 1,
                    style: context.textTheme.displayMedium?.copyWith(
                      fontSize: 36,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppConstants.space12),
          PressableScale(
            onTap: onPronounce,
            semanticLabel: 'Talaffuzni tinglash',
            child: Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: <Color>[
                    colors.accentLavender.withValues(alpha: 0.24),
                    colors.accentCyan.withValues(alpha: 0.18),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: Border.all(
                  color: colors.accentLavender.withValues(alpha: 0.38),
                ),
              ),
              child: Icon(
                Icons.volume_up_rounded,
                size: 22,
                color: colors.accentLavender,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AnswerFeedback extends StatelessWidget {
  const _AnswerFeedback({
    required this.isCorrect,
    required this.correctTranslation,
    required this.wasRetry,
  });

  final bool isCorrect;
  final String correctTranslation;
  final bool wasRetry;

  @override
  Widget build(BuildContext context) {
    final SozAtlasColors colors = context.colors;
    final Color accent = isCorrect ? colors.accentMint : colors.danger;
    final String title = isCorrect
        ? (wasRetry ? 'Barakalla! Endi eslab qoldingiz.' : 'To‘g‘ri javob!')
        : 'To‘g‘ri javob: $correctTranslation';
    final String subtitle = isCorrect
        ? 'Bu so‘z endi uzoqroq muddatga rejalashtirildi.'
        : 'Xafa bo‘lmang — bu so‘z keyingi mashqda yana takrorlanadi.';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: isCorrect ? colors.successContainer : colors.dangerContainer,
        border: Border.all(color: accent.withValues(alpha: 0.35)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(
            isCorrect
                ? Icons.check_circle_rounded
                : Icons.lightbulb_circle_rounded,
            size: 22,
            color: accent,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  title,
                  style: context.textTheme.titleMedium?.copyWith(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: isCorrect ? colors.accentMint : colors.danger,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: context.textTheme.bodySmall?.copyWith(
                    color: colors.textSecondary,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RecallFallback extends StatelessWidget {
  const _RecallFallback({required this.onHome});

  final VoidCallback onHome;

  @override
  Widget build(BuildContext context) {
    final SozAtlasColors colors = context.colors;
    return Scaffold(
      backgroundColor: colors.background,
      body: GradientBackground(
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Icon(
                    Icons.task_alt_rounded,
                    size: 44,
                    color: colors.accentMint,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Bu mashq yakunlangan.',
                    style: context.textTheme.titleMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  GradientButton(
                    label: 'Uy sahifasiga',
                    onPressed: onHome,
                    expand: false,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
