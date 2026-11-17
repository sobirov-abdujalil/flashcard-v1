import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import 'pressable_scale.dart';

/// Secondary glass action used for share, settings, cancel and other quieter
/// actions.
class GlassButton extends StatelessWidget {
  const GlassButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.height = AppConstants.secondaryButtonHeight,
    this.expand = false,
    this.danger = false,
    this.semanticLabel,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final double height;
  final bool expand;
  final bool danger;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final SozAtlasColors colors = context.colors;
    final Color foreground = danger ? colors.danger : colors.textPrimary;
    final bool enabled = onPressed != null;

    return Opacity(
      opacity: enabled ? 1 : 0.5,
      child: PressableScale(
        onTap: onPressed,
        semanticLabel: semanticLabel ?? label,
        child: Container(
          height: height,
          width: expand ? double.infinity : null,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: colors.glassFill,
            borderRadius: BorderRadius.circular(AppConstants.buttonRadius),
            border: Border.all(
              color: danger
                  ? colors.danger.withValues(alpha: 0.35)
                  : colors.glassBorder,
            ),
            gradient: LinearGradient(
              colors: <Color>[
                colors.glassFillStrong,
                colors.glassFill.withValues(alpha: 0.4),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Row(
            mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              if (icon != null) ...<Widget>[
                Icon(icon, size: 19, color: foreground),
                const SizedBox(width: AppConstants.space8),
              ],
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.textTheme.labelLarge?.copyWith(
                    color: foreground,
                    fontSize: 15,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
