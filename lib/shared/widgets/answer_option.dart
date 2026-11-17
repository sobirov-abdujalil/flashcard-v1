import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import 'pressable_scale.dart';

/// Visual state of a single quiz answer.
enum AnswerVisualState {
  /// Unanswered.
  idle,

  /// The correct answer (selected correctly, or revealed after a mistake).
  correct,

  /// The wrong answer the learner tapped.
  incorrect,

  /// Faded out after the question has been answered.
  muted,
}

/// One of the four Uzbek answer options in the Recall screen.
///
/// Reacts to state changes with a gentle glow for correct answers and a short
/// horizontal shake for incorrect ones. Both are disabled when the platform
/// requests reduced motion.
class AnswerOption extends StatefulWidget {
  const AnswerOption({
    super.key,
    required this.letter,
    required this.label,
    required this.state,
    required this.onTap,
    this.enabled = true,
  });

  final String letter;
  final String label;
  final AnswerVisualState state;
  final VoidCallback? onTap;
  final bool enabled;

  @override
  State<AnswerOption> createState() => _AnswerOptionState();
}

class _AnswerOptionState extends State<AnswerOption>
    with SingleTickerProviderStateMixin {
  late final AnimationController _shake = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 380),
  );

  @override
  void didUpdateWidget(covariant AnswerOption oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.state != widget.state &&
        widget.state == AnswerVisualState.incorrect &&
        !(MediaQuery.maybeDisableAnimationsOf(context) ?? false)) {
      _shake
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    _shake.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final SozAtlasColors colors = context.colors;
    final AnswerVisualState state = widget.state;
    final bool isCorrect = state == AnswerVisualState.correct;
    final bool isIncorrect = state == AnswerVisualState.incorrect;
    final bool muted = state == AnswerVisualState.muted;

    final Color borderColor = isCorrect
        ? colors.accentMint
        : isIncorrect
        ? colors.danger
        : colors.glassBorder;
    final Color fillColor = isCorrect
        ? colors.successContainer
        : isIncorrect
        ? colors.dangerContainer
        : colors.neutralOptionFill;
    final Color contentColor = muted ? colors.textMuted : colors.textPrimary;
    final Color badgeFill = isCorrect
        ? colors.accentMint
        : isIncorrect
        ? colors.danger
        : colors.glassFillStrong;
    final Color badgeText = isCorrect || isIncorrect
        ? colors.onGradient
        : colors.textSecondary;

    final Widget content = AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      constraints: const BoxConstraints(minHeight: 60),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: fillColor,
        border: Border.all(
          color: borderColor,
          width: isCorrect || isIncorrect ? 1.6 : 1,
        ),
        boxShadow: isCorrect
            ? <BoxShadow>[
                BoxShadow(
                  color: colors.accentMint.withValues(alpha: 0.28),
                  blurRadius: 22,
                  spreadRadius: 1,
                ),
              ]
            : null,
      ),
      child: Row(
        children: <Widget>[
          AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: 30,
            height: 30,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: badgeFill,
              border: Border.all(
                color: isCorrect || isIncorrect
                    ? Colors.transparent
                    : colors.glassBorder,
              ),
            ),
            child: Text(
              widget.letter,
              style: TextStyle(
                fontFamily: 'Manrope',
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: badgeText,
              ),
            ),
          ),
          const SizedBox(width: AppConstants.space12),
          Expanded(
            child: AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 180),
              style:
                  (context.textTheme.titleMedium ??
                          const TextStyle(fontSize: 16))
                      .copyWith(
                        color: contentColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        height: 1.25,
                      ),
              child: Text(widget.label),
            ),
          ),
          if (isCorrect) ...<Widget>[
            const SizedBox(width: 8),
            Icon(
              Icons.check_circle_rounded,
              size: 22,
              color: colors.accentMint,
            ),
          ] else if (isIncorrect) ...<Widget>[
            const SizedBox(width: 8),
            Icon(Icons.cancel_rounded, size: 22, color: colors.danger),
          ],
        ],
      ),
    );

    final bool tappable = widget.enabled && state == AnswerVisualState.idle;

    return Opacity(
      opacity: muted ? 0.55 : 1,
      child: PressableScale(
        onTap: tappable ? widget.onTap : null,
        scale: 0.985,
        child: AnimatedBuilder(
          animation: _shake,
          builder: (BuildContext context, Widget? child) {
            final double progress = _shake.value;
            final double dx =
                math.sin(progress * math.pi * 6) * 5 * (1 - progress);
            return Transform.translate(offset: Offset(dx, 0), child: child);
          },
          child: content,
        ),
      ),
    );
  }
}
