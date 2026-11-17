import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/gradient_background.dart';
import '../../../shared/widgets/progress_ring.dart';

/// Elegant completion animation: an aurora arc sweeps around a glass medallion
/// while a ring of sparkles fades in. Runs once, then stays still.
class CompletionBadge extends StatefulWidget {
  const CompletionBadge({super.key, required this.onClose});

  final VoidCallback onClose;

  @override
  State<CompletionBadge> createState() => _CompletionBadgeState();
}

class _CompletionBadgeState extends State<CompletionBadge>
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
    if (MediaQuery.maybeDisableAnimationsOf(context) ?? false) {
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
    final bool isDark = context.isDarkMode;

    return SizedBox(
      height: 188,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Positioned(
            top: 0,
            right: 0,
            child: GlassIconButton(
              icon: Icons.close_rounded,
              tooltip: 'Yopish',
              onPressed: widget.onClose,
            ),
          ),
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (BuildContext context, _) {
                final double t = Curves.easeOutCubic.transform(
                  _controller.value,
                );
                return Stack(
                  alignment: Alignment.center,
                  children: <Widget>[
                    Positioned.fill(
                      child: RepaintBoundary(
                        child: CustomPaint(
                          painter: AuroraArcPainter(
                            progress: t,
                            colors: colors.gradientColors,
                            isDark: isDark,
                          ),
                        ),
                      ),
                    ),
                    Positioned.fill(
                      child: RepaintBoundary(
                        child: CustomPaint(
                          painter: _SparklesPainter(
                            progress: t,
                            colors: colors.gradientColors,
                          ),
                        ),
                      ),
                    ),
                    Transform.scale(
                      scale: 0.82 + 0.18 * t,
                      child: Opacity(opacity: t, child: const _Medallion()),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _Medallion extends StatelessWidget {
  const _Medallion();

  @override
  Widget build(BuildContext context) {
    final SozAtlasColors colors = context.colors;
    return Container(
      width: 104,
      height: 104,
      padding: const EdgeInsets.all(2.5),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: colors.primaryGradient,
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: colors.accentLavender.withValues(alpha: 0.35),
            blurRadius: 26,
            spreadRadius: 2,
          ),
          BoxShadow(
            color: colors.accentMint.withValues(alpha: 0.18),
            blurRadius: 40,
            spreadRadius: 4,
          ),
        ],
      ),
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: colors.isDark
              ? colors.backgroundSecondary
              : colors.solidSurface,
          border: Border.all(
            color: Colors.white.withValues(alpha: colors.isDark ? 0.08 : 0.6),
          ),
        ),
        child: Center(
          child: ShaderMask(
            shaderCallback: (Rect bounds) =>
                colors.horizontalGradient.createShader(bounds),
            blendMode: BlendMode.srcIn,
            child: const Icon(
              Icons.check_rounded,
              size: 46,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

class _SparklesPainter extends CustomPainter {
  _SparklesPainter({required this.progress, required this.colors});

  final double progress;
  final List<Color> colors;

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = size.center(Offset.zero);
    final double radius = math.min(size.width, size.height) * 0.44;
    final Paint paint = Paint();
    for (int index = 0; index < 12; index++) {
      final double appear = (progress * 12 - index * 0.55).clamp(0.0, 1.0);
      if (appear <= 0) continue;
      final double angle = -math.pi / 2 + index * math.pi / 6;
      final double distance = radius * (0.86 + 0.14 * appear);
      final Offset point =
          center +
          Offset(distance * math.cos(angle), distance * math.sin(angle));
      paint.color = colors[index % colors.length].withValues(
        alpha: 0.75 * appear,
      );
      canvas.drawCircle(point, 1.4 + 1.8 * appear, paint);
    }
  }

  @override
  bool shouldRepaint(_SparklesPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.colors != colors;
}
