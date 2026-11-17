import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_constants.dart';
import '../../core/constants/routes.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/local_date.dart';
import '../../domain/models/session_models.dart';
import '../../domain/summary/share_text_builder.dart';
import '../../features/session/session_launcher.dart';
import '../../providers/app_providers.dart';
import '../../providers/session_provider.dart';
import '../../providers/session_state.dart';
import '../../shared/utils/dialogs.dart';
import '../../shared/widgets/glass_button.dart';
import '../../shared/widgets/glass_card.dart';
import '../../shared/widgets/gradient_background.dart';
import '../../shared/widgets/gradient_button.dart';
import '../../shared/widgets/progress_ring.dart';
import '../../shared/widgets/stat_tile.dart';
import 'widgets/completion_badge.dart';

/// Screen 4 — Session Complete.
class SummaryScreen extends ConsumerStatefulWidget {
  const SummaryScreen({super.key});

  @override
  ConsumerState<SummaryScreen> createState() => _SummaryScreenState();
}

class _SummaryScreenState extends ConsumerState<SummaryScreen> {
  bool _sharing = false;

  Future<void> _share(SessionSummary summary) async {
    if (_sharing) return;
    setState(() => _sharing = true);
    final RenderBox? box = context.findRenderObject() is RenderBox
        ? context.findRenderObject() as RenderBox
        : null;
    final bool shared = await ref
        .read(shareServiceProvider)
        .shareText(
          text: buildSessionShareText(summary),
          subject: 'So‘z Atlas — kundalik natija',
          sharePositionOrigin: box == null
              ? null
              : box.localToGlobal(Offset.zero) & box.size,
        );
    if (!mounted) return;
    setState(() => _sharing = false);
    if (shared) {
      showAppSnack(context, 'Natija ulashildi.');
    }
  }

  Future<void> _restart() async {
    await launchLearnSession(context, ref, replaceCurrentRoute: true);
  }

  void _goHome() {
    ref.read(sessionProvider.notifier).reset();
    Navigator.of(context).popUntil(ModalRoute.withName(AppRoutes.home));
  }

  @override
  Widget build(BuildContext context) {
    final SozAtlasColors colors = context.colors;
    final SessionState state = ref.watch(sessionProvider);
    final SessionSummary? summary = state.summary;
    final bool starting = state.phase == SessionPhase.loading;

    if (summary == null) {
      return Scaffold(
        backgroundColor: colors.background,
        body: GradientBackground(
          child: SafeArea(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Icon(
                    Icons.auto_awesome_outlined,
                    size: 44,
                    color: colors.textMuted,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Natija topilmadi.',
                    style: context.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 24),
                  GradientButton(
                    label: 'Uy sahifasiga',
                    onPressed: _goHome,
                    expand: false,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    final double goalProgressToday = summary.dailyGoal <= 0
        ? 0
        : (summary.completedToday / summary.dailyGoal).clamp(0.0, 1.0);

    return Scaffold(
      backgroundColor: colors.background,
      body: GradientBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(
              AppConstants.screenPadding,
              12,
              AppConstants.screenPadding,
              28,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                CompletionBadge(onClose: _goHome),
                const SizedBox(height: AppConstants.space16),
                ShaderMask(
                  shaderCallback: (Rect bounds) =>
                      colors.horizontalGradient.createShader(bounds),
                  blendMode: BlendMode.srcIn,
                  child: Text(
                    'Ajoyib!',
                    textAlign: TextAlign.center,
                    style: context.textTheme.headlineLarge?.copyWith(
                      fontSize: 34,
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(height: AppConstants.space8),
                Text(
                  summary.goalCompleted
                      ? 'Bugungi maqsad bajarildi.'
                      : 'Mashq yakunlandi. Maqsad sari davom eting!',
                  textAlign: TextAlign.center,
                  style: context.textTheme.bodyLarge?.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppConstants.space8),
                Text(
                  'Har kuni oz-ozdan — katta natijalarga.',
                  textAlign: TextAlign.center,
                  style: context.textTheme.bodySmall?.copyWith(
                    color: colors.accentLavender,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                if (state.warningMessage != null) ...<Widget>[
                  const SizedBox(height: AppConstants.space16),
                  _WarningBanner(message: state.warningMessage!),
                ],
                const SizedBox(height: AppConstants.space24),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: StatTile(
                        icon: Icons.checklist_rounded,
                        label: 'Mashqlar',
                        value: '${summary.totalExercises}',
                        accent: colors.accentLavender,
                      ),
                    ),
                    const SizedBox(width: AppConstants.space8),
                    Expanded(
                      child: StatTile(
                        icon: Icons.task_alt_rounded,
                        label: 'To‘g‘ri javob',
                        value: '${summary.correctAnswers}',
                        accent: colors.accentMint,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppConstants.space8),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: StatTile(
                        icon: Icons.auto_awesome_rounded,
                        label: 'Yangi so‘z',
                        value: '${summary.newWordsStudied}',
                        accent: colors.accentCyan,
                      ),
                    ),
                    const SizedBox(width: AppConstants.space8),
                    Expanded(
                      child: StatTile(
                        icon: Icons.local_fire_department_rounded,
                        label: 'Seriya',
                        value: '${summary.currentStreak} kun',
                        accent: colors.accentPink,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppConstants.space16),
                GlassCard(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          ProgressRing(
                            progress: summary.accuracy,
                            size: 66,
                            strokeWidth: 6,
                            semanticsLabel: 'Aniqlik',
                            child: Text(
                              '${(summary.accuracy * 100).round()}%',
                              style: context.textTheme.labelLarge?.copyWith(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          const SizedBox(width: AppConstants.space16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  'Aniqlik',
                                  style: context.textTheme.titleMedium
                                      ?.copyWith(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                      ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  '${summary.correctAnswers} / ${summary.totalExercises} ta to‘g‘ri javob',
                                  style: context.textTheme.bodySmall?.copyWith(
                                    color: colors.textMuted,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: SizedBox(
                                    height: 5,
                                    child: Stack(
                                      fit: StackFit.expand,
                                      children: <Widget>[
                                        ColoredBox(color: colors.glassBorder),
                                        FractionallySizedBox(
                                          alignment: Alignment.centerLeft,
                                          widthFactor: goalProgressToday,
                                          child: DecoratedBox(
                                            decoration: BoxDecoration(
                                              gradient:
                                                  colors.horizontalGradient,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Bugungi maqsad: ${summary.completedToday.clamp(0, summary.dailyGoal)} / ${summary.dailyGoal}',
                                  style: context.textTheme.bodySmall?.copyWith(
                                    color: colors.textMuted,
                                    fontSize: 11.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppConstants.space16),
                      Divider(color: colors.divider, height: 1),
                      const SizedBox(height: AppConstants.space12),
                      Row(
                        children: <Widget>[
                          Icon(
                            Icons.event_available_rounded,
                            size: 17,
                            color: colors.accentCyan,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Keyingi takrorlash',
                              style: context.textTheme.bodySmall?.copyWith(
                                color: colors.textSecondary,
                              ),
                            ),
                          ),
                          Text(
                            _nextReviewLabel(summary.nextReviewAt),
                            style: context.textTheme.labelLarge?.copyWith(
                              fontSize: 13,
                              color: colors.textPrimary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      if (summary.retryCount > 0) ...<Widget>[
                        const SizedBox(height: AppConstants.space8),
                        Row(
                          children: <Widget>[
                            Icon(
                              Icons.replay_rounded,
                              size: 17,
                              color: colors.accentPink,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Qayta mashq qilingan so‘zlar',
                                style: context.textTheme.bodySmall?.copyWith(
                                  color: colors.textSecondary,
                                ),
                              ),
                            ),
                            Text(
                              '${summary.retryCount} ta',
                              style: context.textTheme.labelLarge?.copyWith(
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: AppConstants.space16),
                GlassButton(
                  label: _sharing ? 'Ulashilmoqda…' : 'Natijani ulashish',
                  icon: Icons.share_rounded,
                  expand: true,
                  onPressed: _sharing ? null : () => _share(summary),
                ),
                const SizedBox(height: AppConstants.space12),
                GradientButton(
                  label: 'Yana o‘rganish',
                  icon: Icons.auto_awesome_rounded,
                  trailingIcon: Icons.arrow_forward_rounded,
                  isLoading: starting,
                  onPressed: starting ? null : _restart,
                ),
                const SizedBox(height: AppConstants.space8),
                TextButton(
                  onPressed: _goHome,
                  style: TextButton.styleFrom(
                    minimumSize: const Size.fromHeight(
                      AppConstants.minTouchTarget,
                    ),
                    foregroundColor: colors.textSecondary,
                  ),
                  child: Text(
                    'Uy sahifasiga',
                    style: context.textTheme.labelLarge?.copyWith(
                      color: colors.textSecondary,
                      fontSize: 15,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _nextReviewLabel(DateTime? nextReviewAt) {
    if (nextReviewAt == null) return '—';
    final String relative = LocalDate.describeFutureUz(nextReviewAt);
    if (relative == 'Ertaga' ||
        relative == 'Bugun' ||
        relative.contains('so‘ng') ||
        relative == 'Keyingi hafta') {
      return relative;
    }
    return '${LocalDate.formatShortUz(nextReviewAt)} · $relative';
  }
}

class _WarningBanner extends StatelessWidget {
  const _WarningBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final SozAtlasColors colors = context.colors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: colors.dangerContainer,
        border: Border.all(color: colors.danger.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(Icons.info_outline_rounded, size: 18, color: colors.danger),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: context.textTheme.bodySmall?.copyWith(
                color: colors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
