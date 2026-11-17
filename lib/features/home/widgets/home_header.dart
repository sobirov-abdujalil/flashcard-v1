import 'package:flutter/material.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/local_date.dart';
import '../../../shared/widgets/app_logo.dart';
import '../../../shared/widgets/progress_ring.dart';

/// Brand header, greeting, date and the settings entry point.
class HomeHeader extends StatelessWidget {
  const HomeHeader({
    super.key,
    required this.onOpenSettings,
    required this.date,
  });

  final VoidCallback onOpenSettings;
  final DateTime date;

  @override
  Widget build(BuildContext context) {
    final SozAtlasColors colors = context.colors;
    final DateTime now = DateTime.now();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            const Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: SozAtlasWordmark(),
              ),
            ),
            const SizedBox(width: AppConstants.space12),
            const Spacer(),
            GlassIconButton(
              icon: Icons.tune_rounded,
              tooltip: 'Sozlamalar',
              onPressed: onOpenSettings,
            ),
          ],
        ),
        const SizedBox(height: AppConstants.space24),
        Row(
          children: <Widget>[
            Icon(Icons.wb_sunny_outlined, size: 14, color: colors.accentCyan),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                '${LocalDate.greetingUz(now)}, ${LocalDate.formatLongUz(date)}',
                style: context.textTheme.bodySmall?.copyWith(
                  color: colors.textSecondary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppConstants.space8),
        ShaderMask(
          shaderCallback: (Rect bounds) =>
              colors.horizontalGradient.createShader(bounds),
          blendMode: BlendMode.srcIn,
          child: Text(
            'Bugun yangi imkoniyatlar sari bir qadam.',
            style: context.textTheme.headlineMedium?.copyWith(
              fontSize: 25,
              height: 1.22,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -0.5,
            ),
          ),
        ),
      ],
    );
  }
}
