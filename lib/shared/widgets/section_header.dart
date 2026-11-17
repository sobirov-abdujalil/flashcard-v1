import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/app_typography.dart';

/// Section heading with a small gradient "eyebrow" label.
class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.eyebrow,
    this.subtitle,
    this.trailing,
  });

  final String title;
  final String? eyebrow;
  final String? subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final SozAtlasColors colors = context.colors;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              if (eyebrow != null) ...<Widget>[
                ShaderMask(
                  shaderCallback: (Rect bounds) =>
                      colors.horizontalGradient.createShader(bounds),
                  blendMode: BlendMode.srcIn,
                  child: Text(
                    eyebrow!.toUpperCase(),
                    style: AppTypography.eyebrow(Colors.white),
                  ),
                ),
                const SizedBox(height: AppConstants.space8),
              ],
              Text(title, style: context.textTheme.titleLarge),
              if (subtitle != null) ...<Widget>[
                const SizedBox(height: 4),
                Text(subtitle!, style: context.textTheme.bodySmall),
              ],
            ],
          ),
        ),
        if (trailing != null) ...<Widget>[
          const SizedBox(width: AppConstants.space12),
          trailing!,
        ],
      ],
    );
  }
}
