import 'package:flutter/material.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/local_date.dart';
import '../../../data/models/home_snapshot.dart';
import '../../../shared/widgets/glass_card.dart';
import '../../../shared/widgets/gradient_button.dart';

/// Premium Liquid Glass review card shown on Home.
///
/// Displays the actual due-review count and a clear "Review Now" action when
/// words are due. When nothing is due it shows an encouraging empty state
/// with the next scheduled review (when known).
class ReviewCard extends StatelessWidget {
  const ReviewCard({
    super.key,
    required this.snapshot,
    required this.onStartReview,
  });

  final HomeSnapshot snapshot;
  final VoidCallback onStartReview;

  @override
  Widget build(BuildContext context) {
    final SozAtlasColors colors = context.colors;
    final bool hasDue = snapshot.hasDueReviews;

    return GlassCard(
      shadow: true,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
      gradient: LinearGradient(
        colors: <Color>[
          colors.accentLavender.withValues(alpha: 0.10),
          colors.accentCyan.withValues(alpha: 0.06),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderColor: colors.glassBorder,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: <Color>[
                      colors.accentLavender.withValues(alpha: 0.22),
                      colors.accentCyan.withValues(alpha: 0.16),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  border: Border.all(
                    color: hasDue
                        ? colors.accentLavender.withValues(alpha: 0.35)
                        : colors.glassBorder,
                  ),
                ),
                child: Icon(
                  Icons.replay_rounded,
                  size: 20,
                  color: hasDue ? colors.accentLavender : colors.textMuted,
                ),
              ),
              const SizedBox(width: AppConstants.space12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      'Takrorlash vaqti',
                      style: context.textTheme.labelSmall?.copyWith(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.6,
                        color: colors.accentLavender,
                      ),
                    ),
                    const SizedBox(height: AppConstants.space8),
                    Text(
                      hasDue
                          ? '${snapshot.dueReviews} ta so‘z takrorlashga tayyor'
                          : 'Hozircha takrorlash kerak bo‘lgan so‘z yo‘q.',
                      style: context.textTheme.titleMedium?.copyWith(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: colors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.space20),
          if (hasDue) ...<Widget>[
            GradientButton(
              label: 'Takrorlashni boshlash',
              icon: Icons.play_arrow_rounded,
              trailingIcon: Icons.arrow_forward_rounded,
              onPressed: onStartReview,
              semanticLabel: 'So‘zlarni takrorlashni boshlash',
            ),
            const SizedBox(height: AppConstants.space12),
          ] else ...<Widget>[
            if (snapshot.nextReviewAt != null) ...<Widget>[
              Row(
                children: <Widget>[
                  Icon(
                    Icons.event_available_rounded,
                    size: 16,
                    color: colors.accentCyan,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Keyingi takrorlash ${_nextReviewLabel(snapshot.nextReviewAt!)}',
                      style: context.textTheme.bodySmall?.copyWith(
                        color: colors.textSecondary,
                        fontSize: 12.5,
                      ),
                    ),
                  ),
                ],
              ),
            ] else ...<Widget>[
              Text(
                'Yangi so‘zlarni o‘rgangan so‘ng takrorlashlar shu yerda chiqadi.',
                style: context.textTheme.bodySmall?.copyWith(
                  color: colors.textMuted,
                  fontSize: 12.5,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }

  String _nextReviewLabel(DateTime nextReviewAt) {
    final String relative = LocalDate.describeFutureUz(nextReviewAt);
    if (relative == 'Ertaga' ||
        relative == 'Bugun' ||
        relative.contains('so‘ng') ||
        relative == 'Keyingi hafta') {
      return relative;
    }
    return '${LocalDate.formatShortUz(nextReviewAt)} · $relative';
  }
}
