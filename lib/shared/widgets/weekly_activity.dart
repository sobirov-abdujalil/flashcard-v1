import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import '../../data/models/home_snapshot.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/local_date.dart';

/// Seven-day activity chart. Bars grow in once, with a small stagger, and then
/// stay static (no looping animation).
class WeeklyActivity extends StatefulWidget {
  const WeeklyActivity({
    super.key,
    required this.days,
    required this.today,
    this.barAreaHeight = 64,
  });

  final List<DailyActivity> days;
  final DateTime today;
  final double barAreaHeight;

  @override
  State<WeeklyActivity> createState() => _WeeklyActivityState();
}

class _WeeklyActivityState extends State<WeeklyActivity>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 760),
  );

  @override
  void initState() {
    super.initState();
    _controller.forward();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final bool reduceMotion =
        MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    if (reduceMotion) {
      _controller.value = 1;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final SozAtlasColors colors = context.colors;
    final int maxExercises = widget.days.fold<int>(
      1,
      (int max, DailyActivity day) => day.exercises > max ? day.exercises : max,
    );

    return AnimatedBuilder(
      animation: _controller,
      builder: (BuildContext context, _) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            for (int index = 0; index < widget.days.length; index++)
              Expanded(
                child: _buildDay(
                  context: context,
                  colors: colors,
                  day: widget.days[index],
                  maxExercises: maxExercises,
                  index: index,
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildDay({
    required BuildContext context,
    required SozAtlasColors colors,
    required DailyActivity day,
    required int maxExercises,
    required int index,
  }) {
    final bool isToday = LocalDate.isSameDay(day.date, widget.today);
    final double ratio = day.exercises == 0
        ? 0
        : (day.exercises / maxExercises).clamp(0.12, 1.0);
    final double start = 0.08 + index * 0.05;
    final double end = (start + 0.55).clamp(0.2, 1.0);
    final double t = Curves.easeOutCubic.transform(
      Interval(start, end).transform(_controller.value),
    );
    final double barHeight = (widget.barAreaHeight - 12) * ratio * t;
    final bool active = day.exercises > 0;

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        SizedBox(
          height: widget.barAreaHeight,
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: 18,
              height: barHeight < 3 ? 3 : barHeight,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(9),
                gradient: active
                    ? LinearGradient(
                        colors: <Color>[
                          colors.accentLavender.withValues(
                            alpha: isToday ? 1 : 0.55,
                          ),
                          colors.accentCyan.withValues(
                            alpha: isToday ? 1 : 0.55,
                          ),
                          colors.accentMint.withValues(
                            alpha: isToday ? 1 : 0.6,
                          ),
                        ],
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                      )
                    : null,
                color: active ? null : colors.glassBorder,
              ),
            ),
          ),
        ),
        const SizedBox(height: AppConstants.space8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: isToday ? colors.glassFillStrong : Colors.transparent,
            border: isToday ? Border.all(color: colors.glassBorder) : null,
          ),
          child: Text(
            LocalDate.weekdayShortUz[day.date.weekday - 1],
            style: context.textTheme.labelMedium?.copyWith(
              fontSize: 11,
              color: isToday ? colors.textPrimary : colors.textMuted,
              fontWeight: isToday ? FontWeight.w800 : FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
