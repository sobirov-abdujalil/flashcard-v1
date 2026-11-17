import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

/// Streak display with a gradient-filled flame icon.
///
/// A streak of zero is shown gently ("Boshlashga tayyor") rather than with
/// guilt-inducing copy.
class StreakIndicator extends StatelessWidget {
  const StreakIndicator({super.key, required this.streak, this.compact = true});

  final int streak;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final SozAtlasColors colors = context.colors;
    final bool active = streak > 0;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        ShaderMask(
          shaderCallback: (Rect bounds) =>
              colors.horizontalGradient.createShader(bounds),
          blendMode: BlendMode.srcIn,
          child: Icon(
            Icons.local_fire_department_rounded,
            size: compact ? 18 : 22,
            color: Colors.white,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          active ? '$streak kun' : '0 kun',
          style: context.textTheme.labelLarge?.copyWith(
            fontSize: compact ? 14 : 16,
            fontWeight: FontWeight.w800,
            color: active ? colors.textPrimary : colors.textMuted,
          ),
        ),
      ],
    );
  }
}
