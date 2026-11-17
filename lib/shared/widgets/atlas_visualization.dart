import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

/// The Vocabulary Atlas: a small, lightweight constellation rendered locally
/// with a [CustomPainter].
///
/// Every node represents one of the user's learned words (scaled against the
/// bundled vocabulary). Lit nodes glow sequentially once, then the layer stays
/// static so it never drains battery or distracts the learner.
class AtlasVisualization extends StatefulWidget {
  const AtlasVisualization({
    super.key,
    required this.learnedWords,
    required this.totalWords,
    this.height = 132,
    this.nodeCount = 26,
  });

  final int learnedWords;
  final int totalWords;
  final double height;
  final int nodeCount;

  @override
  State<AtlasVisualization> createState() => _AtlasVisualizationState();
}

class _AtlasVisualizationState extends State<AtlasVisualization>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1050),
  );

  @override
  void initState() {
    super.initState();
    _controller.forward();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.maybeDisableAnimationsOf(context) ?? false) {
      _controller.value = 1;
    }
  }

  @override
  void didUpdateWidget(covariant AtlasVisualization oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.learnedWords != widget.learnedWords) {
      _controller
        ..reset()
        ..forward();
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
    final int total = widget.totalWords <= 0 ? 1 : widget.totalWords;
    final double ratio = (widget.learnedWords / total).clamp(0.0, 1.0);
    final int litNodes = (ratio * widget.nodeCount).round().clamp(
      0,
      widget.nodeCount,
    );

    return Semantics(
      label:
          'So‘z koinoti: ${widget.learnedWords} ta so‘z '
          '${widget.totalWords} tadan o‘rganilgan',
      child: SizedBox(
        height: widget.height,
        width: double.infinity,
        child: RepaintBoundary(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (BuildContext context, _) {
              return CustomPaint(
                painter: _AtlasPainter(
                  animation: _controller.value,
                  litNodes: litNodes,
                  nodeCount: widget.nodeCount,
                  lineColor: colors.constellationLine,
                  dimNodeColor: colors.constellationNode.withValues(alpha: 0.4),
                  activeColors: colors.gradientColors,
                  starColor: colors.textPrimary,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _AtlasPainter extends CustomPainter {
  _AtlasPainter({
    required this.animation,
    required this.litNodes,
    required this.nodeCount,
    required this.lineColor,
    required this.dimNodeColor,
    required this.activeColors,
    required this.starColor,
  });

  final double animation;
  final int litNodes;
  final int nodeCount;
  final Color lineColor;
  final Color dimNodeColor;
  final List<Color> activeColors;
  final Color starColor;

  static const List<Offset> _layout = <Offset>[
    Offset(0.05, 0.62),
    Offset(0.14, 0.30),
    Offset(0.22, 0.72),
    Offset(0.31, 0.18),
    Offset(0.38, 0.50),
    Offset(0.45, 0.84),
    Offset(0.51, 0.28),
    Offset(0.58, 0.62),
    Offset(0.65, 0.12),
    Offset(0.70, 0.44),
    Offset(0.78, 0.78),
    Offset(0.85, 0.28),
    Offset(0.93, 0.58),
    Offset(0.09, 0.86),
    Offset(0.29, 0.40),
    Offset(0.43, 0.10),
    Offset(0.55, 0.94),
    Offset(0.68, 0.86),
    Offset(0.80, 0.12),
    Offset(0.95, 0.86),
    Offset(0.17, 0.10),
    Offset(0.35, 0.96),
    Offset(0.48, 0.60),
    Offset(0.61, 0.42),
    Offset(0.73, 0.30),
    Offset(0.89, 0.94),
  ];

  static const List<List<int>> _links = <List<int>>[
    <int>[0, 1],
    <int>[1, 2],
    <int>[2, 3],
    <int>[3, 4],
    <int>[4, 5],
    <int>[5, 6],
    <int>[6, 7],
    <int>[7, 8],
    <int>[8, 9],
    <int>[9, 10],
    <int>[10, 11],
    <int>[11, 12],
    <int>[0, 13],
    <int>[2, 14],
    <int>[14, 15],
    <int>[15, 6],
    <int>[6, 16],
    <int>[7, 17],
    <int>[11, 18],
    <int>[12, 19],
    <int>[20, 1],
    <int>[16, 21],
    <int>[4, 22],
    <int>[22, 23],
    <int>[23, 9],
    <int>[9, 24],
    <int>[24, 11],
    <int>[19, 25],
    <int>[17, 25],
    <int>[13, 14],
    <int>[16, 17],
    <int>[20, 3],
    <int>[18, 24],
    <int>[21, 2],
    <int>[5, 22],
    <int>[10, 17],
  ];

  double _brightness(int index) {
    if (index >= litNodes) return 0;
    final double staged = animation * litNodes - index;
    return staged.clamp(0.0, 1.0);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final int count = math.min(nodeCount, _layout.length);
    final List<Offset> points = <Offset>[
      for (int index = 0; index < count; index++)
        Offset(_layout[index].dx * size.width, _layout[index].dy * size.height),
    ];

    // Links.
    for (final List<int> link in _links) {
      if (link[0] >= points.length || link[1] >= points.length) continue;
      final double strength = math.min(
        _brightness(link[0]),
        _brightness(link[1]),
      );
      final Paint paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.9
        ..color = strength > 0
            ? Color.lerp(
                lineColor,
                activeColors[1],
                0.55,
              )!.withValues(alpha: 0.10 + 0.5 * strength)
            : lineColor.withValues(alpha: 0.16);
      canvas.drawLine(points[link[0]], points[link[1]], paint);
    }

    // Nodes.
    for (int index = 0; index < points.length; index++) {
      final double brightness = _brightness(index);
      if (brightness <= 0) {
        canvas.drawCircle(points[index], 1.9, Paint()..color = dimNodeColor);
        continue;
      }
      final Color color = Color.lerp(
        activeColors.first,
        activeColors.last,
        count <= 1 ? 1 : index / (count - 1),
      )!;
      final Paint glow = Paint()
        ..color = color.withValues(alpha: 0.30 * brightness)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
      canvas.drawCircle(points[index], 5.5 * brightness + 2, glow);
      canvas.drawCircle(
        points[index],
        2.2 + 1.6 * brightness,
        Paint()..color = color.withValues(alpha: 0.55 + 0.45 * brightness),
      );
      // A tiny white core makes lit words feel like real stars.
      canvas.drawCircle(
        points[index],
        0.9,
        Paint()..color = starColor.withValues(alpha: 0.65 * brightness),
      );
    }
  }

  @override
  bool shouldRepaint(_AtlasPainter oldDelegate) =>
      oldDelegate.animation != animation ||
      oldDelegate.litNodes != litNodes ||
      oldDelegate.nodeCount != nodeCount ||
      oldDelegate.lineColor != lineColor ||
      oldDelegate.activeColors != activeColors;
}
