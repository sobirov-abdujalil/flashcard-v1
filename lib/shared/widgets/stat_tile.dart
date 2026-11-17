import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';

/// Small glass statistic tile used on Home and on the completion screen.
class StatTile extends StatelessWidget {
  const StatTile({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.accent,
    this.compact = false,
    this.trailing,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color? accent;
  final bool compact;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final SozAtlasColors colors = context.colors;
    final Color tileAccent = accent ?? colors.accentLavender;
    return Container(
      padding: EdgeInsets.all(compact ? 12 : 14),
      decoration: BoxDecoration(
        color: colors.glassFill,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.glassBorder),
        gradient: LinearGradient(
          colors: <Color>[
            colors.glassFillStrong,
            colors.glassFill.withValues(alpha: 0.2),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: compact ? 30 : 36,
            height: compact ? 30 : 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: tileAccent.withValues(alpha: 0.14),
              border: Border.all(color: tileAccent.withValues(alpha: 0.22)),
            ),
            child: Icon(icon, size: compact ? 15 : 17, color: tileAccent),
          ),
          SizedBox(width: compact ? 8 : 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: <Widget>[
                    Flexible(
                      child: Text(
                        value,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.textTheme.titleMedium?.copyWith(
                          fontSize: compact ? 17 : 19,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    if (trailing != null) ...<Widget>[
                      const SizedBox(width: 4),
                      trailing!,
                    ],
                  ],
                ),
                const SizedBox(height: AppConstants.space4),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.textTheme.bodySmall?.copyWith(
                    fontSize: compact ? 11 : 12,
                    color: colors.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
