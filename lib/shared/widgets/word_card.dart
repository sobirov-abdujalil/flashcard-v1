import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/app_typography.dart';
import '../../data/models/word.dart';
import 'glass_card.dart';
import 'pressable_scale.dart';

/// The main vocabulary card used on the Learn screen.
///
/// Before the reveal it shows only the English word, IPA and word class; after
/// the reveal the Uzbek translation, a short English definition and a natural
/// example appear with a smooth height + fade animation.
class WordCard extends StatelessWidget {
  const WordCard({
    super.key,
    required this.word,
    required this.revealed,
    required this.onPronounce,
    this.isNewWord = false,
    this.showHint = true,
  });

  final Word word;
  final bool revealed;
  final VoidCallback onPronounce;
  final bool isNewWord;
  final bool showHint;

  @override
  Widget build(BuildContext context) {
    final SozAtlasColors colors = context.colors;
    final bool reduceMotion =
        MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    final Duration revealDuration = reduceMotion
        ? Duration.zero
        : AppConstants.reveal;

    return GlassCard(
      blur: false,
      shadow: true,
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
      gradient: LinearGradient(
        colors: <Color>[
          colors.isDark
              ? colors.glassFillStrong
              : colors.glassFillStrong.withValues(alpha: 0.98),
          colors.glassFill.withValues(alpha: colors.isDark ? 0.55 : 0.75),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      child: AnimatedSize(
        duration: revealDuration,
        alignment: Alignment.topCenter,
        curve: Curves.easeOutCubic,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Row(
              children: <Widget>[
                _LevelChip(level: word.cefrLevel, isNewWord: isNewWord),
                const SizedBox(width: AppConstants.space8),
                _PosChip(label: word.posLabelUz),
                const Spacer(),
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
            const SizedBox(height: AppConstants.space24),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                word.word,
                maxLines: 1,
                style: context.textTheme.displayLarge,
              ),
            ),
            const SizedBox(height: AppConstants.space8),
            Row(
              children: <Widget>[
                Text(
                  word.phonetic,
                  style: AppTypography.phonetic(colors.accentLavender),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.space20),
            if (!revealed && showHint) _HiddenHint(),
            if (revealed)
              TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0, end: 1),
                duration: reduceMotion
                    ? Duration.zero
                    : const Duration(milliseconds: 260),
                curve: Curves.easeOut,
                builder: (BuildContext context, double value, Widget? child) {
                  return Opacity(
                    opacity: value,
                    child: Transform.translate(
                      offset: Offset(0, 8 * (1 - value)),
                      child: child,
                    ),
                  );
                },
                child: _MeaningBlock(word: word),
              ),
          ],
        ),
      ),
    );
  }
}

class _HiddenHint extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final SozAtlasColors colors = context.colors;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: colors.isDark
            ? Colors.white.withValues(alpha: 0.03)
            : colors.accentLavender.withValues(alpha: 0.05),
        border: Border.all(color: colors.glassBorder),
      ),
      child: Row(
        children: <Widget>[
          Icon(Icons.visibility_off_rounded, size: 18, color: colors.textMuted),
          const SizedBox(width: AppConstants.space8),
          Expanded(
            child: Text(
              'Ma’nosi yashiringan. Avval o‘zingiz eslab ko‘ring.',
              style: context.textTheme.bodySmall?.copyWith(
                color: colors.textMuted,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MeaningBlock extends StatelessWidget {
  const _MeaningBlock({required this.word});

  final Word word;

  @override
  Widget build(BuildContext context) {
    final SozAtlasColors colors = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          height: 1,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: <Color>[
                colors.accentLavender.withValues(alpha: 0),
                colors.accentLavender.withValues(alpha: 0.5),
                colors.accentCyan.withValues(alpha: 0.4),
                colors.accentMint.withValues(alpha: 0),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppConstants.space20),
        Text(
          word.translation,
          style: context.textTheme.headlineMedium?.copyWith(
            color: colors.accentMint,
            fontWeight: FontWeight.w800,
            fontSize: 26,
          ),
        ),
        const SizedBox(height: AppConstants.space8),
        Text(
          word.definition,
          style: context.textTheme.bodyMedium?.copyWith(
            color: colors.textSecondary,
            height: 1.45,
          ),
        ),
        const SizedBox(height: AppConstants.space20),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            color: colors.isDark
                ? Colors.white.withValues(alpha: 0.035)
                : colors.accentLavender.withValues(alpha: 0.055),
            border: Border.all(color: colors.glassBorder),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                width: 3,
                height: 46,
                margin: const EdgeInsets.only(top: 2, right: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(2),
                  gradient: colors.primaryGradient,
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      word.example,
                      style: AppTypography.example(colors.textPrimary),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      word.exampleTranslation,
                      style: context.textTheme.bodySmall?.copyWith(
                        color: colors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _LevelChip extends StatelessWidget {
  const _LevelChip({required this.level, required this.isNewWord});

  final String level;
  final bool isNewWord;

  @override
  Widget build(BuildContext context) {
    final SozAtlasColors colors = context.colors;
    final Color accent = level == 'A1' ? colors.accentMint : colors.accentCyan;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: accent.withValues(alpha: 0.13),
        border: Border.all(color: accent.withValues(alpha: 0.4)),
      ),
      child: Text(
        isNewWord ? 'YANGI · $level' : level,
        style: TextStyle(
          fontFamily: AppTypography.fontFamily,
          fontSize: 11,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.7,
          color: accent,
        ),
      ),
    );
  }
}

class _PosChip extends StatelessWidget {
  const _PosChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final SozAtlasColors colors = context.colors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: colors.glassBorder),
        color: colors.glassFill,
      ),
      child: Text(
        label,
        style: context.textTheme.labelSmall?.copyWith(
          color: colors.textSecondary,
          fontSize: 11,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}
