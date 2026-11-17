import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../widgets/glass_card.dart';
import '../widgets/glass_button.dart';
import '../widgets/gradient_button.dart';

/// Shows a light snackbar message.
void showAppSnack(
  BuildContext context,
  String message, {
  bool isError = false,
  IconData? icon,
}) {
  final ScaffoldMessengerState? messenger = ScaffoldMessenger.maybeOf(context);
  if (messenger == null) return;
  final SozAtlasColors colors = context.colors;
  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Row(
          children: <Widget>[
            Icon(
              icon ??
                  (isError
                      ? Icons.info_outline_rounded
                      : Icons.check_circle_outline_rounded),
              size: 19,
              color: isError ? colors.danger : colors.accentMint,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: context.textTheme.bodyMedium?.copyWith(
                  color: colors.textPrimary,
                ),
              ),
            ),
          ],
        ),
        duration: const Duration(seconds: 3),
      ),
    );
}

/// A glass, animated confirmation dialog. Returns true only when confirmed.
Future<bool> showAppConfirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  required String confirmLabel,
  String cancelLabel = 'Bekor qilish',
  bool isDanger = false,
}) async {
  final bool? result = await showGeneralDialog<bool>(
    context: context,
    barrierDismissible: true,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: Colors.black.withValues(alpha: 0.62),
    transitionDuration: const Duration(milliseconds: 200),
    pageBuilder:
        (
          BuildContext context,
          Animation<double> animation,
          Animation<double> secondaryAnimation,
        ) {
          return _ConfirmDialog(
            title: title,
            message: message,
            confirmLabel: confirmLabel,
            cancelLabel: cancelLabel,
            isDanger: isDanger,
          );
        },
    transitionBuilder:
        (
          BuildContext context,
          Animation<double> animation,
          Animation<double> secondaryAnimation,
          Widget child,
        ) {
          final CurvedAnimation curved = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
            reverseCurve: Curves.easeInCubic,
          );
          return FadeTransition(
            opacity: curved,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.94, end: 1).animate(curved),
              child: child,
            ),
          );
        },
  );
  return result ?? false;
}

class _ConfirmDialog extends StatelessWidget {
  const _ConfirmDialog({
    required this.title,
    required this.message,
    required this.confirmLabel,
    required this.cancelLabel,
    required this.isDanger,
  });

  final String title;
  final String message;
  final String confirmLabel;
  final String cancelLabel;
  final bool isDanger;

  @override
  Widget build(BuildContext context) {
    final SozAtlasColors colors = context.colors;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: GlassCard(
            blur: true,
            blurSigma: 20,
            shadow: true,
            padding: const EdgeInsets.fromLTRB(24, 26, 24, 22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: (isDanger ? colors.danger : colors.accentLavender)
                        .withValues(alpha: 0.14),
                    border: Border.all(
                      color: (isDanger ? colors.danger : colors.accentLavender)
                          .withValues(alpha: 0.3),
                    ),
                  ),
                  child: Icon(
                    isDanger
                        ? Icons.delete_outline_rounded
                        : Icons.help_outline_rounded,
                    size: 22,
                    color: isDanger ? colors.danger : colors.accentLavender,
                  ),
                ),
                const SizedBox(height: AppConstants.space16),
                Text(title, style: context.textTheme.headlineSmall),
                const SizedBox(height: AppConstants.space8),
                Text(
                  message,
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: colors.textSecondary,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: AppConstants.space24),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: GlassButton(
                        label: cancelLabel,
                        onPressed: () => Navigator.of(context).pop(false),
                        expand: true,
                        height: 50,
                      ),
                    ),
                    const SizedBox(width: AppConstants.space12),
                    Expanded(
                      child: isDanger
                          ? GlassButton(
                              label: confirmLabel,
                              onPressed: () => Navigator.of(context).pop(true),
                              expand: true,
                              danger: true,
                              height: 50,
                            )
                          : GradientButton(
                              label: confirmLabel,
                              onPressed: () => Navigator.of(context).pop(true),
                              height: 50,
                              trailingIcon: null,
                            ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// "Leave session?" confirmation. Answers already given are persisted.
Future<bool> showExitSessionDialog(BuildContext context) {
  return showAppConfirmDialog(
    context,
    title: 'Mashqni tark etasizmi?',
    message: 'Berilgan javoblar saqlanadi, lekin bu mashq yakunlanmagan hisoblanadi.',
    confirmLabel: 'Chiqish',
    cancelLabel: 'Davom etish',
    isDanger: true,
  );
}
