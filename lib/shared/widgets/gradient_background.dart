import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

/// The signature So‘z Atlas background.
///
/// A midnight (or light) gradient, a few soft radial glows and a very subtle
/// static constellation. Nothing here animates, so the layer is cheap to keep
/// on screen. Expensive blur is deliberately avoided.
class GradientBackground extends StatelessWidget {
  const GradientBackground({
    super.key,
    required this.child,
    this.showConstellation = true,
    this.showGlows = true,
    this.glowIntensity = 1,
  });

  final Widget child;
  final bool showConstellation;
  final bool showGlows;
  final double glowIntensity;

  @override
  Widget build(BuildContext context) {
    final SozAtlasColors colors = context.colors;
    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        DecoratedBox(decoration: BoxDecoration(gradient: colors.pageGradient)),
        if (showGlows) ...<Widget>[
          Positioned(
            top: -140,
            right: -120,
            child: _Glow(
              diameter: 420,
              color: colors.glowLavender.withValues(
                alpha: colors.glowLavender.a * glowIntensity,
              ),
            ),
          ),
          Positioned(
            bottom: -180,
            left: -140,
            child: _Glow(
              diameter: 460,
              color: colors.glowCyan.withValues(
                alpha: colors.glowCyan.a * glowIntensity,
              ),
            ),
          ),
          Positioned(
            top: 220,
            left: -160,
            child: _Glow(
              diameter: 320,
              color: colors.glowMint.withValues(
                alpha: colors.glowMint.a * glowIntensity,
              ),
            ),
          ),
        ],
        if (showConstellation)
          Positioned.fill(
            child: IgnorePointer(
              child: RepaintBoundary(
                child: CustomPaint(
                  painter: BackgroundConstellationPainter(
                    lineColor: colors.constellationLine,
                    nodeColor: colors.constellationNode.withValues(alpha: 0.35),
                  ),
                ),
              ),
            ),
          ),
        Positioned.fill(child: child),
      ],
    );
  }
}

class _Glow extends StatelessWidget {
  const _Glow({required this.diameter, required this.color});

  final double diameter;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: diameter,
        height: diameter,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: <Color>[color, color.withValues(alpha: 0)],
            stops: const <double>[0, 1],
          ),
        ),
      ),
    );
  }
}

/// Static, extremely light constellation used behind every screen.
class BackgroundConstellationPainter extends CustomPainter {
  BackgroundConstellationPainter({
    required this.lineColor,
    required this.nodeColor,
  });

  final Color lineColor;
  final Color nodeColor;

  static const List<Offset> _points = <Offset>[
    Offset(0.06, 0.14),
    Offset(0.22, 0.09),
    Offset(0.38, 0.17),
    Offset(0.55, 0.08),
    Offset(0.72, 0.15),
    Offset(0.9, 0.07),
    Offset(0.12, 0.36),
    Offset(0.34, 0.31),
    Offset(0.58, 0.4),
    Offset(0.82, 0.33),
    Offset(0.95, 0.44),
    Offset(0.05, 0.58),
    Offset(0.27, 0.63),
    Offset(0.5, 0.55),
    Offset(0.7, 0.68),
    Offset(0.92, 0.62),
    Offset(0.18, 0.82),
    Offset(0.42, 0.78),
    Offset(0.64, 0.86),
    Offset(0.86, 0.8),
  ];

  static const List<List<int>> _links = <List<int>>[
    <int>[0, 1],
    <int>[1, 2],
    <int>[2, 3],
    <int>[3, 4],
    <int>[4, 5],
    <int>[1, 7],
    <int>[7, 8],
    <int>[8, 9],
    <int>[9, 10],
    <int>[6, 12],
    <int>[12, 13],
    <int>[13, 14],
    <int>[14, 15],
    <int>[2, 6],
    <int>[8, 13],
    <int>[11, 16],
    <int>[16, 17],
    <int>[17, 18],
    <int>[18, 19],
    <int>[12, 17],
    <int>[7, 12],
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final Paint linePaint = Paint()
      ..color = lineColor
      ..strokeWidth = 0.8
      ..style = PaintingStyle.stroke;
    final Paint nodePaint = Paint()..color = nodeColor;

    final List<Offset> scaled = _points
        .map(
          (Offset point) =>
              Offset(point.dx * size.width, point.dy * size.height),
        )
        .toList(growable: false);

    for (final List<int> link in _links) {
      // Skip long links so the background reads as small local constellations
      // instead of huge lines crossing the whole screen and the content.
      final Offset a = scaled[link[0]];
      final Offset b = scaled[link[1]];
      if ((a - b).distance > size.shortestSide * 0.42) continue;
      canvas.drawLine(a, b, linePaint);
    }
    for (int index = 0; index < scaled.length; index++) {
      final double radius = index.isEven ? 1.2 : 1.7;
      canvas.drawCircle(scaled[index], radius, nodePaint);
    }
  }

  @override
  bool shouldRepaint(BackgroundConstellationPainter oldDelegate) =>
      oldDelegate.lineColor != lineColor || oldDelegate.nodeColor != nodeColor;
}

/// A glowing "aurora" arc used behind the completion screen.
class AuroraArcPainter extends CustomPainter {
  AuroraArcPainter({
    required this.progress,
    required this.colors,
    required this.isDark,
  });

  final double progress;
  final List<Color> colors;
  final bool isDark;

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = Offset(size.width / 2, size.height / 2);
    final double radius = math.min(size.width, size.height) * 0.42;
    final Rect rect = Rect.fromCircle(center: center, radius: radius);
    final Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 2 + 2 * progress
      ..shader = SweepGradient(
        colors: <Color>[
          colors.first.withValues(alpha: 0.0),
          colors.first.withValues(alpha: 0.9),
          colors[1].withValues(alpha: 0.9),
          colors.last.withValues(alpha: 0.9),
          colors.last.withValues(alpha: 0.0),
        ],
        stops: const <double>[0, 0.25, 0.55, 0.8, 1],
        transform: GradientRotation(-math.pi / 2 + progress * math.pi * 1.4),
      ).createShader(rect);

    canvas.drawArc(rect, -math.pi / 2, math.pi * 2 * progress, false, paint);

    final Paint glow = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 10 * progress
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14)
      ..color = colors[1].withValues(alpha: isDark ? 0.25 : 0.2);
    canvas.drawArc(rect, -math.pi / 2, math.pi * 2 * progress, false, glow);
  }

  @override
  bool shouldRepaint(AuroraArcPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
