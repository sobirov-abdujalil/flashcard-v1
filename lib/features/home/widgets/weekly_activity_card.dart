import 'package:flutter/material.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/home_snapshot.dart';
import '../../../shared/widgets/glass_card.dart';
import '../../../shared/widgets/weekly_activity.dart';

/// Glass card wrapping the seven-day activity chart.
class WeeklyActivityCard extends StatelessWidget {
  const WeeklyActivityCard({super.key, required this.snapshot});

  final HomeSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final SozAtlasColors colors = context.colors;
    final int totalExercises = snapshot.weekActivity.fold<int>(
      0,
      (int sum, DailyActivity day) => sum + day.exercises,
    );

    return GlassCard(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 14),
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
                  color: colors.accentCyan.withValues(alpha: 0.12),
                  border: Border.all(
                    color: colors.accentCyan.withValues(alpha: 0.22),
                  ),
                ),
                child: Icon(
                  Icons.insights_rounded,
                  size: 16,
                  color: colors.accentCyan,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Haftalik ritm',
                      style: context.textTheme.titleMedium?.copyWith(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'Oxirgi 7 kun',
                      style: context.textTheme.bodySmall?.copyWith(
                        color: colors.textMuted,
                        fontSize: 11.5,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: colors.glassFill,
                  border: Border.all(color: colors.glassBorder),
                ),
                child: Text(
                  '$totalExercises mashq',
                  style: context.textTheme.labelSmall?.copyWith(
                    color: colors.textSecondary,
                    letterSpacing: 0.2,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.space12),
          WeeklyActivity(days: snapshot.weekActivity, today: snapshot.today),
        ],
      ),
    );
  }
}
