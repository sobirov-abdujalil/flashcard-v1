import 'dart:ui';

import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import 'pressable_scale.dart';

/// A translucent liquid-glass surface.
///
/// The default implementation uses layered translucent gradients and a fine
/// border (cheap to render). Backdrop blur is opt-in through [blur] and only
/// used on a few hero surfaces because it is expensive on low-end Android
/// devices.
class GlassCard extends StatelessWidget {
  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppConstants.space20),
    this.borderRadius = AppConstants.cardRadius,
    this.blur = false,
    this.blurSigma = 16,
    this.fill,
    this.borderColor,
    this.shadow = false,
    this.gradient,
    this.onTap,
    this.semanticLabel,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final bool blur;
  final double blurSigma;
  final Color? fill;
  final Color? borderColor;
  final bool shadow;
  final Gradient? gradient;
  final VoidCallback? onTap;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final SozAtlasColors colors = context.colors;
    final BorderRadius radius = BorderRadius.circular(borderRadius);

    final BoxDecoration decoration = BoxDecoration(
      borderRadius: radius,
      gradient: gradient ?? colors.glassGradient,
      color: gradient == null ? fill : null,
      border: Border.all(color: borderColor ?? colors.glassBorder, width: 1),
      boxShadow: shadow
          ? <BoxShadow>[
              BoxShadow(
                color: colors.shadow.withValues(
                  alpha: colors.isDark ? 0.28 : 0.1,
                ),
                blurRadius: 28,
                offset: const Offset(0, 14),
              ),
              BoxShadow(
                color: colors.glowLavender.withValues(alpha: 0.10),
                blurRadius: 44,
                offset: const Offset(0, 8),
              ),
            ]
          : null,
    );

    Widget content = DecoratedBox(
      decoration: decoration,
      child: Padding(padding: padding, child: child),
    );

    if (blur) {
      content = ClipRRect(
        borderRadius: radius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
          child: content,
        ),
      );
    } else {
      content = ClipRRect(borderRadius: radius, child: content);
    }

    if (onTap != null) {
      content = PressableScale(
        onTap: onTap,
        semanticLabel: semanticLabel,
        child: content,
      );
    }
    return content;
  }
}
