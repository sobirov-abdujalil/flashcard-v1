import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/app_haptics.dart';

/// Primary call-to-action with the So‘z Atlas gradient.
///
/// Pressing scales the button down slightly and deepens the glow; text colour is
/// chosen per theme so contrast always stays high.
class GradientButton extends StatefulWidget {
  const GradientButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.trailingIcon = Icons.arrow_forward_rounded,
    this.isLoading = false,
    this.height = AppConstants.primaryButtonHeight,
    this.expand = true,
    this.semanticLabel,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final IconData? trailingIcon;
  final bool isLoading;
  final double height;
  final bool expand;
  final String? semanticLabel;

  @override
  State<GradientButton> createState() => _GradientButtonState();
}

class _GradientButtonState extends State<GradientButton> {
  bool _pressed = false;

  bool get _enabled => widget.onPressed != null && !widget.isLoading;

  @override
  Widget build(BuildContext context) {
    final SozAtlasColors colors = context.colors;
    final bool reduceMotion =
        MediaQuery.maybeDisableAnimationsOf(context) ?? false;

    final Widget content = Row(
      mainAxisSize: widget.expand ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        if (widget.isLoading)
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2.2,
              valueColor: AlwaysStoppedAnimation<Color>(colors.onGradient),
            ),
          )
        else if (widget.icon != null) ...<Widget>[
          Icon(widget.icon, size: 20, color: colors.onGradient),
          const SizedBox(width: AppConstants.space8),
        ],
        Flexible(
          child: Text(
            widget.isLoading ? 'Tayyorlanmoqda…' : widget.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.textTheme.labelLarge?.copyWith(
              color: colors.onGradient,
              fontSize: 16,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.1,
            ),
          ),
        ),
        if (widget.trailingIcon != null &&
            !widget.isLoading &&
            widget.icon == null) ...<Widget>[
          const SizedBox(width: AppConstants.space8),
          Icon(widget.trailingIcon, size: 20, color: colors.onGradient),
        ],
      ],
    );

    return Semantics(
      button: true,
      enabled: _enabled,
      label: widget.semanticLabel ?? widget.label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: _enabled ? (_) => setState(() => _pressed = true) : null,
        onTapUp: _enabled ? (_) => setState(() => _pressed = false) : null,
        onTapCancel: _enabled ? () => setState(() => _pressed = false) : null,
        onTap: _enabled
            ? () {
                AppHaptics.light();
                widget.onPressed?.call();
              }
            : null,
        child: AnimatedScale(
          scale: _pressed && !reduceMotion ? 0.98 : 1,
          duration: reduceMotion
              ? Duration.zero
              : const Duration(milliseconds: 120),
          curve: Curves.easeOutCubic,
          child: AnimatedContainer(
            duration: reduceMotion
                ? Duration.zero
                : const Duration(milliseconds: 160),
            height: widget.height,
            width: widget.expand ? double.infinity : null,
            padding: const EdgeInsets.symmetric(horizontal: 22),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppConstants.buttonRadius),
              gradient: colors.horizontalGradient,
              boxShadow: _enabled
                  ? <BoxShadow>[
                      BoxShadow(
                        color: colors.accentLavender.withValues(alpha: 0.35),
                        blurRadius: _pressed ? 12 : 22,
                        offset: const Offset(0, 8),
                        spreadRadius: _pressed ? 0 : 1,
                      ),
                      BoxShadow(
                        color: colors.accentMint.withValues(alpha: 0.18),
                        blurRadius: 30,
                        offset: const Offset(0, 14),
                      ),
                    ]
                  : null,
            ),
            child: Center(child: content),
          ),
        ),
      ),
    );
  }
}
