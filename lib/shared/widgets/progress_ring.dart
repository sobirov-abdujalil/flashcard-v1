import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import 'pressable_scale.dart';

/// Premium progress ring with a gradient sweep and a soft glow.
///
/// The arc animates from zero to [progress] on first build. When the platform
/// requests reduced motion, the final value is rendered immediately.
class ProgressRing extends StatelessWidget {
  const ProgressRing({
    super.key,
    required this.progress,
    this.size = 76,
    this.strokeWidth = 7,
    this.child,
    this.colors,
    this.trackColor,
    this.animate = true,
    this.semanticsLabel,
  });

  final double progress;
  final double size;
  final double strokeWidth;
  final Widget? child;
  final List<Color>? colors;
  final Color? trackColor;
  final bool animate;
  final String? semanticsLabel;

  @override
  Widget build(BuildContext context) {
    final SozAtlasColors palette = context.colors;
    final bool reduceMotion =
        MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    final double target = progress.clamp(0.0, 1.0);
    final Widget ring = TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: target),
      duration: (animate && !reduceMotion)
          ? const Duration(milliseconds: 900)
          : Duration.zero,
      curve: Curves.easeOutCubic,
      builder: (BuildContext context, double value, Widget? _) {
        return CustomPaint(
          size: Size.square(size),
          painter: _ProgressRingPainter(
            progress: value,
            strokeWidth: strokeWidth,
            gradientColors: colors ?? palette.gradientColors,
            trackColor: trackColor ?? palette.glassBorder,
          ),
          child: Center(
            child: SizedBox(
              width: size - strokeWidth * 2 - 10,
              height: size - strokeWidth * 2 - 10,
              child: FittedBox(fit: BoxFit.scaleDown, child: child),
            ),
          ),
        );
      },
    );

    return Semantics(
      label: semanticsLabel,
      value: '${(target * 100).round()}%',
      child: SizedBox.square(dimension: size, child: ring),
    );
  }
}

class _ProgressRingPainter extends CustomPainter {
  _ProgressRingPainter({
    required this.progress,
    required this.strokeWidth,
    required this.gradientColors,
    required this.trackColor,
  });

  final double progress;
  final double strokeWidth;
  final List<Color> gradientColors;
  final Color trackColor;

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = size.center(Offset.zero);
    final double radius = (size.shortestSide - strokeWidth) / 2;
    final Rect rect = Rect.fromCircle(center: center, radius: radius);

    final Paint track = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..color = trackColor;
    canvas.drawArc(rect, 0, math.pi * 2, false, track);

    if (progress <= 0.001) return;

    final Paint glow = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth * 1.8
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8)
      ..shader = SweepGradient(
        colors: gradientColors,
        startAngle: -math.pi / 2,
        endAngle: math.pi * 1.5,
        transform: const GradientRotation(-math.pi / 2),
      ).createShader(rect);
    final double sweep = math.pi * 2 * progress;
    canvas.drawArc(rect, -math.pi / 2, sweep, false, glow);

    final Paint arc = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..shader = SweepGradient(
        colors: gradientColors,
        startAngle: 0,
        endAngle: math.pi * 2,
        transform: const GradientRotation(-math.pi / 2),
      ).createShader(rect);
    canvas.drawArc(rect, -math.pi / 2, sweep, false, arc);
  }

  @override
  bool shouldRepaint(_ProgressRingPainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.strokeWidth != strokeWidth ||
      oldDelegate.gradientColors != gradientColors ||
      oldDelegate.trackColor != trackColor;
}

/// Small circular icon button in the glass style (close, settings, sound…).
class GlassIconButton extends StatelessWidget {
  const GlassIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.size = 44,
    this.tooltip,
    this.respectSafeArea = false,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final double size;
  final String? tooltip;

  final bool respectSafeArea;

  @override
  Widget build(BuildContext context) {
    final SozAtlasColors colors = context.colors;
    final Widget button = PressableScale(
      onTap: onPressed,
      semanticLabel: tooltip,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: colors.glassFill,
          border: Border.all(color: colors.glassBorder),
          gradient: LinearGradient(
            colors: <Color>[
              colors.glassFillStrong,
              colors.glassFill.withValues(alpha: 0.25),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Icon(
          icon,
          size: size * 0.45,
          color: onPressed == null ? colors.textMuted : colors.textPrimary,
        ),
      ),
    );
    if (tooltip == null) return button;
    return Tooltip(message: tooltip!, child: button);
  }
}
