import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import 'glass_card.dart';
import 'progress_ring.dart';

/// Compact glass card that visualises progress towards a goal.
class GlassProgressCard extends StatelessWidget {
  const GlassProgressCard({
    super.key,
    required this.eyebrow,
    required this.title,
    required this.progressLabel,
    required this.progress,
    this.caption,
    this.footer,
    this.icon,
  });

  final String eyebrow;
  final String title;
  final String progressLabel;
  final double progress;
  final String? caption;
  final Widget? footer;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final SozAtlasColors colors = context.colors;
    return GlassCard(
      blur: true,
      blurSigma: 18,
      shadow: true,
      padding: const EdgeInsets.all(AppConstants.space20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        if (icon != null) ...<Widget>[
                          Icon(icon, size: 15, color: colors.accentLavender),
                          const SizedBox(width: 6),
                        ],
                        Flexible(
                          child: ShaderMask(
                            shaderCallback: (Rect bounds) =>
                                colors.horizontalGradient.createShader(bounds),
                            blendMode: BlendMode.srcIn,
                            child: Text(
                              eyebrow.toUpperCase(),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontFamily: 'Manrope',
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.3,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      title,
                      style: context.textTheme.headlineSmall?.copyWith(
                        fontSize: 22,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      progressLabel,
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppConstants.space12),
              ProgressRing(
                progress: progress,
                size: 78,
                strokeWidth: 7,
                semanticsLabel: eyebrow,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      '${(progress * 100).round()}%',
                      style: context.textTheme.titleMedium?.copyWith(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (caption != null) ...<Widget>[
            const SizedBox(height: AppConstants.space12),
            Text(
              caption!,
              style: context.textTheme.bodySmall?.copyWith(
                color: colors.textMuted,
              ),
            ),
          ],
          if (footer != null) ...<Widget>[
            const SizedBox(height: AppConstants.space20),
            footer!,
          ],
        ],
      ),
    );
  }
}
