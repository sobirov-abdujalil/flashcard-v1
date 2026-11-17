import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// The So‘z Atlas brand mark: an open book with three connected constellation
/// nodes. Rendered with a custom painter so it stays sharp at any size and
/// needs no image asset.
class SozAtlasLogo extends StatelessWidget {
  const SozAtlasLogo({super.key, this.size = 36, this.showGlow = true});

  final double size;
  final bool showGlow;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: RepaintBoundary(
        child: CustomPaint(painter: _LogoPainter(showGlow: showGlow)),
      ),
    );
  }
}

class _LogoPainter extends CustomPainter {
  const _LogoPainter({required this.showGlow});

  final bool showGlow;

  static const List<Color> _gradient = <Color>[
    Color(0xFF927CFF),
    Color(0xFF65C8F5),
    Color(0xFF74E4C0),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final double scale = size.shortestSide;
    final Rect gradientRect = Rect.fromLTWH(0, 0, size.width, size.height);
    final Shader shader = LinearGradient(
      colors: _gradient,
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      stops: const <double>[0, 0.55, 1],
    ).createShader(gradientRect);

    // Three constellation nodes above the book.
    final List<Offset> nodes = <Offset>[
      Offset(0.29 * scale, 0.27 * scale),
      Offset(0.5 * scale, 0.15 * scale),
      Offset(0.71 * scale, 0.27 * scale),
    ];
    final Paint linkPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = scale * 0.024
      ..strokeCap = StrokeCap.round
      ..color = _gradient[1].withValues(alpha: 0.65);
    canvas.drawLine(nodes[0], nodes[1], linkPaint);
    canvas.drawLine(nodes[1], nodes[2], linkPaint);
    canvas.drawLine(nodes[0], nodes[2], linkPaint);

    final Paint nodeGlow = Paint()
      ..color = _gradient[1].withValues(alpha: 0.35)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, scale * 0.035);
    final Paint nodeFill = Paint()..shader = shader;
    for (final Offset node in nodes) {
      if (showGlow) {
        canvas.drawCircle(node, scale * 0.06, nodeGlow);
      }
      canvas.drawCircle(node, scale * 0.042, nodeFill);
    }

    // Open book: two softly curved pages.
    final Path leftPage = Path()
      ..moveTo(0.13 * scale, 0.62 * scale)
      ..quadraticBezierTo(0.3 * scale, 0.55 * scale, 0.48 * scale, 0.62 * scale)
      ..lineTo(0.48 * scale, 0.86 * scale)
      ..quadraticBezierTo(0.3 * scale, 0.79 * scale, 0.13 * scale, 0.86 * scale)
      ..close();
    final Path rightPage = Path()
      ..moveTo(0.87 * scale, 0.62 * scale)
      ..quadraticBezierTo(0.7 * scale, 0.55 * scale, 0.52 * scale, 0.62 * scale)
      ..lineTo(0.52 * scale, 0.86 * scale)
      ..quadraticBezierTo(0.7 * scale, 0.79 * scale, 0.87 * scale, 0.86 * scale)
      ..close();

    final Paint pageFill = Paint()
      ..shader = shader
      ..style = PaintingStyle.fill;
    final Paint pageGlow = Paint()
      ..color = _gradient[0].withValues(alpha: showGlow ? 0.25 : 0)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, scale * 0.03)
      ..style = PaintingStyle.fill;

    for (final Path page in <Path>[leftPage, rightPage]) {
      canvas.drawPath(page, pageGlow);
      canvas.drawPath(page, pageFill);
    }

    // Spine highlight.
    final Paint spine = Paint()
      ..color = Colors.white.withValues(alpha: 0.55)
      ..style = PaintingStyle.stroke
      ..strokeWidth = scale * 0.018
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(0.5 * scale, 0.53 * scale),
      Offset(0.5 * scale, 0.88 * scale),
      spine,
    );

    // A tiny star accent in the top-right corner.
    final Offset star = Offset(0.87 * scale, 0.14 * scale);
    final Paint starPaint = Paint()..color = _gradient.last;
    final Path starPath = Path();
    const int points = 4;
    for (int index = 0; index < points * 2; index++) {
      final double radius = index.isEven ? scale * 0.045 : scale * 0.017;
      final double angle = -math.pi / 2 + index * math.pi / points;
      final Offset point =
          star + Offset(radius * math.cos(angle), radius * math.sin(angle));
      if (index == 0) {
        starPath.moveTo(point.dx, point.dy);
      } else {
        starPath.lineTo(point.dx, point.dy);
      }
    }
    starPath.close();
    canvas.drawPath(starPath, starPaint);
  }

  @override
  bool shouldRepaint(_LogoPainter oldDelegate) =>
      oldDelegate.showGlow != showGlow;
}

/// Compact brand lockup used in screen headers.
class SozAtlasWordmark extends StatelessWidget {
  const SozAtlasWordmark({
    super.key,
    this.logoSize = 34,
    this.showTagline = true,
  });

  final double logoSize;
  final bool showTagline;

  @override
  Widget build(BuildContext context) {
    final SozAtlasColors colors = Theme.of(context)
        .extension<SozAtlasColors>()!;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        SozAtlasLogo(size: logoSize),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              'SO‘Z ATLAS',
              style: TextStyle(
                fontFamily: 'Manrope',
                fontSize: 12,
                fontWeight: FontWeight.w800,
                letterSpacing: 2.4,
                color: colors.textPrimary,
              ),
            ),
            if (showTagline)
              Text(
                'shaxsiy so‘z koinotingiz',
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.2,
                  color: colors.textMuted,
                ),
              ),
          ],
        ),
      ],
    );
  }
}
