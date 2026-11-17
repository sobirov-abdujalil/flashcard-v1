import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_constants.dart';
import '../../core/constants/routes.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/word.dart';
import '../../domain/models/session_models.dart';
import '../../providers/session_provider.dart';
import '../../providers/session_state.dart';
import '../../shared/utils/dialogs.dart';
import '../../features/session/session_launcher.dart';
import '../../shared/widgets/gradient_background.dart';
import '../../shared/widgets/gradient_button.dart';
import '../../shared/widgets/session_progress_header.dart';
import '../../shared/widgets/word_card.dart';

/// Screen 2 — Learn.
///
/// One English word at a time: pronunciation, IPA, word class and — after a
/// deliberate reveal — the meaning, definition and example.
class LearnScreen extends ConsumerStatefulWidget {
  const LearnScreen({super.key});

  @override
  ConsumerState<LearnScreen> createState() => _LearnScreenState();
}

class _LearnScreenState extends ConsumerState<LearnScreen> {
  bool _pronouncing = false;

  Future<void> _pronounce(Word word) async {
    if (_pronouncing) return;
    setState(() => _pronouncing = true);
    final bool ok = await ref.read(sessionProvider.notifier).pronounceCurrent();
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

  void _advance(SessionState state) {
    final SessionController controller = ref.read(sessionProvider.notifier);
    if (!state.meaningRevealed) {
      controller.revealMeaning();
      return;
    }
    final bool wasLast = state.isLastLearnWord;
    controller.nextLearnWord();
    if (wasLast) {
      Navigator.of(context).pushReplacementNamed(AppRoutes.recall);
    }
  }

  @override
  Widget build(BuildContext context) {
    final SozAtlasColors colors = context.colors;
    final SessionState state = ref.watch(sessionProvider);
    final SessionWord? entry = state.currentLearnWord;

    if (state.phase != SessionPhase.learning || entry == null) {
      return _LearnFallback(
        message: state.errorMessage ?? 'Mashq ma’lumotlari topilmadi.',
        onHome: () {
          ref.read(sessionProvider.notifier).reset();
          Navigator.of(context).popUntil(ModalRoute.withName(AppRoutes.home));
        },
      );
    }

    final Word word = entry.word;

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
                  title: 'O‘rganish',
                  counterLabel:
                      '${state.learnProgressNumber} / ${state.learnCount}',
                  progress: state.learnProgress,
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
                            AnimatedSwitcher(
                              duration:
                                  MediaQuery.maybeDisableAnimationsOf(
                                        context,
                                      ) ??
                                      false
                                  ? Duration.zero
                                  : const Duration(milliseconds: 260),
                              switchInCurve: Curves.easeOutCubic,
                              switchOutCurve: Curves.easeInCubic,
                              transitionBuilder:
                                  (Widget child, Animation<double> animation) {
                                    return FadeTransition(
                                      opacity: animation,
                                      child: SlideTransition(
                                        position: Tween<Offset>(
                                          begin: const Offset(0, 0.03),
                                          end: Offset.zero,
                                        ).animate(animation),
                                        child: child,
                                      ),
                                    );
                                  },
                              child: WordCard(
                                key: ValueKey<int>(word.id),
                                word: word,
                                revealed: state.meaningRevealed,
                                isNewWord: entry.isNew,
                                onPronounce: () => _pronounce(word),
                              ),
                            ),
                            const SizedBox(height: AppConstants.space16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Icon(
                                  Icons.tips_and_updates_outlined,
                                  size: 14,
                                  color: colors.textMuted,
                                ),
                                const SizedBox(width: 6),
                                Flexible(
                                  child: Text(
                                    state.meaningRevealed
                                        ? 'Ma’noni o‘qib, keyingi bosqichga o‘ting.'
                                        : 'Talaffuzni tinglab, ma’nosini eslashga harakat qiling.',
                                    style: context.textTheme.bodySmall
                                        ?.copyWith(color: colors.textMuted),
                                  ),
                                ),
                              ],
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
                  label: state.meaningRevealed
                      ? 'Tekshirish'
                      : 'Ma’nosini ko‘rish',
                  icon: state.meaningRevealed
                      ? Icons.fact_check_outlined
                      : Icons.visibility_rounded,
                  trailingIcon: state.meaningRevealed
                      ? Icons.arrow_forward_rounded
                      : null,
                  onPressed: () => _advance(state),
                  semanticLabel: state.meaningRevealed
                      ? 'So‘zni tekshirish'
                      : 'Ma’nosini ko‘rish',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LearnFallback extends StatelessWidget {
  const _LearnFallback({required this.message, required this.onHome});

  final String message;
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
                    Icons.auto_stories_outlined,
                    size: 44,
                    color: colors.textMuted,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: context.textTheme.bodyMedium,
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
