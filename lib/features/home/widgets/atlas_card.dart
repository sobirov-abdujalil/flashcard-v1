import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/atlas_visualization.dart';
import '../../../shared/widgets/glass_card.dart';

/// The compact Vocabulary Atlas card for Home.
class AtlasCard extends StatelessWidget {
  const AtlasCard({
    super.key,
    required this.learnedWords,
    required this.totalWords,
  });

  final int learnedWords;
  final int totalWords;

  @override
  Widget build(BuildContext context) {
    final SozAtlasColors colors = context.colors;
    return GlassCard(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: <Color>[
                      colors.accentLavender.withValues(alpha: 0.22),
                      colors.accentMint.withValues(alpha: 0.16),
                    ],
                  ),
                  border: Border.all(
                    color: colors.accentLavender.withValues(alpha: 0.24),
                  ),
                ),
                child: Icon(
                  Icons.blur_on_rounded,
                  size: 16,
                  color: colors.accentLavender,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Yodda qolgan so‘zlar',
                      style: context.textTheme.titleMedium?.copyWith(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'Har bir yulduz — bitta so‘z',
                      style: context.textTheme.bodySmall?.copyWith(
                        color: colors.textMuted,
                        fontSize: 11.5,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '$learnedWords / $totalWords',
                style: context.textTheme.labelLarge?.copyWith(
                  fontSize: 13,
                  color: colors.accentMint,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          AtlasVisualization(
            learnedWords: learnedWords,
            totalWords: totalWords,
            height: 124,
          ),
          if (learnedWords == 0)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                'Birinchi mashqdan so‘ng koinotingiz yonib boshlaydi.',
                style: context.textTheme.bodySmall?.copyWith(
                  color: colors.textMuted,
                  fontSize: 11.5,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
