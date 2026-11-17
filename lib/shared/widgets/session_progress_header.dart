import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import 'progress_ring.dart';

/// Shared top bar for the Learn and Recall screens: close button, phase title,
/// step counter and a thin gradient progress line.
class SessionProgressHeader extends StatelessWidget {
  const SessionProgressHeader({
    super.key,
    required this.title,
    required this.counterLabel,
    required this.progress,
    required this.onClose,
    this.progressLabel,
  });

  final String title;
  final String counterLabel;
  final double progress;
  final VoidCallback onClose;
  final String? progressLabel;

  @override
  Widget build(BuildContext context) {
    final SozAtlasColors colors = context.colors;
    final bool reduceMotion =
        MediaQuery.maybeDisableAnimationsOf(context) ?? false;

    return Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            GlassIconButton(
              icon: Icons.close_rounded,
              tooltip: 'Chiqish',
              onPressed: onClose,
            ),
            Expanded(
              child: Column(
                children: <Widget>[
                  Text(
                    title.toUpperCase(),
                    style: context.textTheme.labelSmall?.copyWith(
                      color: colors.textMuted,
                      letterSpacing: 1.8,
                    ),
                  ),
                  if (progressLabel != null) ...<Widget>[
                    const SizedBox(height: 2),
                    Text(
                      progressLabel!,
                      style: context.textTheme.titleMedium?.copyWith(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Container(
              constraints: const BoxConstraints(minWidth: 44),
              height: 40,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                color: colors.glassFill,
                border: Border.all(color: colors.glassBorder),
              ),
              child: Text(
                counterLabel,
                style: context.textTheme.labelLarge?.copyWith(
                  fontSize: 14,
                  color: colors.textPrimary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppConstants.space16),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: SizedBox(
            height: 5,
            child: Stack(
              fit: StackFit.expand,
              children: <Widget>[
                ColoredBox(color: colors.glassBorder),
                TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0, end: progress.clamp(0.0, 1.0)),
                  duration: reduceMotion
                      ? Duration.zero
                      : const Duration(milliseconds: 380),
                  curve: Curves.easeOutCubic,
                  builder: (BuildContext context, double value, _) {
                    return Align(
                      alignment: Alignment.centerLeft,
                      child: FractionallySizedBox(
                        widthFactor: value,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: colors.horizontalGradient,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
