import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_constants.dart';
import '../../core/constants/routes.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/app_settings.dart';
import '../../providers/app_providers.dart';
import '../../providers/session_provider.dart';
import '../../providers/settings_provider.dart';
import '../../shared/utils/dialogs.dart';
import '../../shared/widgets/glass_card.dart';
import '../../shared/widgets/pressable_scale.dart';
import '../../shared/widgets/progress_ring.dart';

/// Opens the polished settings bottom sheet.
Future<void> showSettingsSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    useSafeArea: true,
    barrierColor: Colors.black.withValues(alpha: 0.58),
    builder: (BuildContext context) => const SettingsSheet(),
  );
}

/// Theme, daily goal, reset and app information. Intentionally small.
class SettingsSheet extends ConsumerWidget {
  const SettingsSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final SozAtlasColors colors = context.colors;
    final AppSettings settings =
        ref.watch(settingsProvider).value ?? AppSettings.defaults;

    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 0, 10, 12),
      child: GlassCard(
        blur: true,
        blurSigma: 22,
        borderRadius: AppConstants.sheetRadius,
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.sizeOf(context).height * 0.8,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: colors.glassBorder,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: AppConstants.space16),
                Row(
                  children: <Widget>[
                    Text('Sozlamalar', style: context.textTheme.headlineSmall),
                    const Spacer(),
                    GlassIconButton(
                      icon: Icons.close_rounded,
                      tooltip: 'Yopish',
                      size: 36,
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: AppConstants.space24),
                _SectionLabel(label: 'Ko‘rinish'),
                const SizedBox(height: AppConstants.space8),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: _OptionTile(
                        label: 'Tizim',
                        icon: Icons.brightness_auto_rounded,
                        selected: settings.themeMode == ThemeMode.system,
                        onTap: () => ref
                            .read(settingsProvider.notifier)
                            .setThemeMode(ThemeMode.system),
                      ),
                    ),
                    const SizedBox(width: AppConstants.space8),
                    Expanded(
                      child: _OptionTile(
                        label: 'Yorug‘',
                        icon: Icons.light_mode_rounded,
                        selected: settings.themeMode == ThemeMode.light,
                        onTap: () => ref
                            .read(settingsProvider.notifier)
                            .setThemeMode(ThemeMode.light),
                      ),
                    ),
                    const SizedBox(width: AppConstants.space8),
                    Expanded(
                      child: _OptionTile(
                        label: 'Qorong‘i',
                        icon: Icons.dark_mode_rounded,
                        selected: settings.themeMode == ThemeMode.dark,
                        onTap: () => ref
                            .read(settingsProvider.notifier)
                            .setThemeMode(ThemeMode.dark),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppConstants.space24),
                _SectionLabel(label: 'Kunlik maqsad'),
                const SizedBox(height: AppConstants.space8),
                Row(
                  children: <Widget>[
                    for (final int goal
                        in AppConstants.dailyGoalOptions) ...<Widget>[
                      Expanded(
                        child: _OptionTile(
                          label: '$goal mashq',
                          icon: goal == 5
                              ? Icons.bolt_rounded
                              : goal == 10
                              ? Icons.local_fire_department_rounded
                              : Icons.workspace_premium_rounded,
                          selected: settings.dailyGoal == goal,
                          onTap: () => ref
                              .read(settingsProvider.notifier)
                              .setDailyGoal(goal),
                        ),
                      ),
                      if (goal != AppConstants.dailyGoalOptions.last)
                        const SizedBox(width: AppConstants.space8),
                    ],
                  ],
                ),
                const SizedBox(height: AppConstants.space8),
                Text(
                  'Bir mashq taxminan 4–5 daqiqa vaqt oladi.',
                  style: context.textTheme.bodySmall?.copyWith(
                    color: colors.textMuted,
                  ),
                ),
                const SizedBox(height: AppConstants.space20),
                Divider(color: colors.divider, height: 1),
                const SizedBox(height: AppConstants.space8),
                _ResetRow(onReset: () => _confirmReset(context, ref)),
                Divider(color: colors.divider, height: 1),
                const SizedBox(height: AppConstants.space8),
                _InfoRow(
                  icon: Icons.auto_stories_rounded,
                  title: 'So‘z Atlas',
                  subtitle:
                      'Versiya ${AppConstants.appVersion} (${AppConstants.appBuildNumber}) · To‘liq offline',
                ),
                _InfoRow(
                  icon: Icons.shield_outlined,
                  title: 'Maxfiylik siyosati',
                  subtitle: 'Ma’lumotlar faqat qurilmangizda saqlanadi',
                  onTap: () {
                    final NavigatorState navigator = Navigator.of(
                      context,
                      rootNavigator: true,
                    );
                    navigator.pop();
                    navigator.pushNamed(AppRoutes.privacy);
                  },
                ),
                const SizedBox(height: AppConstants.space12),
                Center(
                  child: Text(
                    'Har kuni oz-ozdan — katta natijalarga.',
                    style: context.textTheme.bodySmall?.copyWith(
                      color: colors.textMuted,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
                SizedBox(height: MediaQuery.viewInsetsOf(context).bottom + 4),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _confirmReset(BuildContext context, WidgetRef ref) async {
    final bool confirmed = await showAppConfirmDialog(
      context,
      title: 'O‘rganish tarixini tozalash',
      message:
          'Barcha natijalar, seriya va takrorlash jadvali o‘chiriladi. '
          'So‘zlar bazasi va sozlamalar saqlanadi. Bu amalni qaytarib bo‘lmaydi.',
      confirmLabel: 'Tozalash',
      isDanger: true,
    );
    if (!confirmed || !context.mounted) return;

    try {
      await ref.read(progressRepositoryProvider).resetLearningProgress();
      ref.read(progressRevisionProvider.notifier).bump();
      ref.read(sessionProvider.notifier).reset();
      if (!context.mounted) return;
      showAppSnack(context, 'O‘rganish tarixi tozalandi.');
    } catch (_) {
      if (!context.mounted) return;
      showAppSnack(
        context,
        'Tarixni tozalashda xatolik yuz berdi.',
        isError: true,
      );
    }
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      style: context.textTheme.labelSmall?.copyWith(
        color: context.colors.textMuted,
        letterSpacing: 1.4,
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  const _OptionTile({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final SozAtlasColors colors = context.colors;
    return PressableScale(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        constraints: const BoxConstraints(minHeight: 56),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: selected ? null : colors.glassFill,
          gradient: selected ? colors.horizontalGradient : null,
          border: Border.all(
            color: selected
                ? Colors.white.withValues(alpha: 0.25)
                : colors.glassBorder,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(
              icon,
              size: 19,
              color: selected ? colors.onGradient : colors.textSecondary,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: context.textTheme.labelMedium?.copyWith(
                fontSize: 12,
                color: selected ? colors.onGradient : colors.textSecondary,
                fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ResetRow extends StatelessWidget {
  const _ResetRow({required this.onReset});

  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    final SozAtlasColors colors = context.colors;
    return PressableScale(
      onTap: onReset,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: <Widget>[
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colors.dangerContainer,
                border: Border.all(
                  color: colors.danger.withValues(alpha: 0.28),
                ),
              ),
              child: Icon(
                Icons.restart_alt_rounded,
                size: 19,
                color: colors.danger,
              ),
            ),
            const SizedBox(width: AppConstants.space12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'O‘rganish tarixini tozalash',
                    style: context.textTheme.titleMedium?.copyWith(
                      fontSize: 15,
                      color: colors.danger,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Progress, seriya va takrorlash jadvali o‘chadi.',
                    style: context.textTheme.bodySmall?.copyWith(
                      color: colors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: colors.textMuted,
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final SozAtlasColors colors = context.colors;
    final Widget row = Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: <Widget>[
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: colors.glassFill,
              border: Border.all(color: colors.glassBorder),
            ),
            child: Icon(icon, size: 19, color: colors.accentCyan),
          ),
          const SizedBox(width: AppConstants.space12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  title,
                  style: context.textTheme.titleMedium?.copyWith(fontSize: 15),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: context.textTheme.bodySmall?.copyWith(
                    color: colors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          if (onTap != null)
            Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: colors.textMuted,
            ),
        ],
      ),
    );
    if (onTap == null) return row;
    return PressableScale(onTap: onTap, child: row);
  }
}
