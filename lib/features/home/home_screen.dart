import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/home_snapshot.dart';
import '../../providers/app_providers.dart';
import '../../providers/home_providers.dart';
import '../../providers/session_provider.dart';
import '../../providers/session_state.dart';
import '../../features/session/session_launcher.dart';
import '../../features/settings/settings_sheet.dart';
import '../../shared/widgets/app_logo.dart';
import '../../shared/widgets/glass_card.dart';
import '../../shared/widgets/glass_progress_card.dart';
import '../../shared/widgets/gradient_background.dart';
import '../../shared/widgets/gradient_button.dart';
import 'widgets/atlas_card.dart';
import 'widgets/home_header.dart';
import 'widgets/weekly_activity_card.dart';

/// Screen 1 — Home.
///
/// One clear primary action ("Boshlash") plus calm, real statistics.
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // The calendar day (and therefore "today's progress") may have changed
    // while the app was in the background.
    if (state == AppLifecycleState.resumed) {
      ref.invalidate(homeSnapshotProvider);
    }
  }

  @override
  Widget build(BuildContext context) {
    final SozAtlasColors colors = context.colors;
    final AsyncValue<HomeSnapshot> home = ref.watch(homeSnapshotProvider);
    final bool starting = ref.watch(
      sessionProvider.select(
        (SessionState state) => state.phase == SessionPhase.loading,
      ),
    );

    return Scaffold(
      backgroundColor: colors.background,
      body: GradientBackground(
        child: SafeArea(
          child: home.when(
            data: (HomeSnapshot snapshot) => _HomeContent(
              snapshot: snapshot,
              startingSession: starting,
              onStart: () => launchLearnSession(context, ref),
              onOpenSettings: () => showSettingsSheet(context),
            ),
            loading: () => const _HomeLoading(),
            error: (Object error, StackTrace stackTrace) => _HomeError(
              onRetry: () {
                ref.invalidate(appBootstrapProvider);
                ref.invalidate(homeSnapshotProvider);
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _HomeContent extends StatelessWidget {
  const _HomeContent({
    required this.snapshot,
    required this.startingSession,
    required this.onStart,
    required this.onOpenSettings,
  });

  final HomeSnapshot snapshot;
  final bool startingSession;
  final VoidCallback onStart;
  final VoidCallback onOpenSettings;

  @override
  Widget build(BuildContext context) {
    final SozAtlasColors colors = context.colors;
    final int goal = snapshot.dailyGoal;
    final int completed = math.min(snapshot.completedToday, goal);
    final int remaining = snapshot.remainingToday;
    final int estimatedMinutes = math.max(1, (remaining * 0.8).ceil());

    final String caption;
    if (snapshot.goalMet) {
      caption = 'Bugungi maqsad bajarildi. Yana mashq qilib, bilimni mustahkamlashingiz mumkin.';
    } else if (snapshot.dueReviews > 0) {
      final int dueToday = math.min(snapshot.dueReviews, remaining);
      caption =
          'Avval $dueToday ta takrorlash so‘zi taklif etiladi · taxminan $estimatedMinutes daqiqa';
    } else {
      caption = 'Kuniga $goal ta mashq · taxminan $estimatedMinutes daqiqa';
    }

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(
        AppConstants.screenPadding,
        14,
        AppConstants.screenPadding,
        28,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          HomeHeader(onOpenSettings: onOpenSettings, date: snapshot.today),
          const SizedBox(height: AppConstants.space24),
          GlassProgressCard(
            eyebrow: 'Bugungi maqsad',
            title: '$goal ta mashq',
            progressLabel: '$completed / $goal bajarildi',
            progress: snapshot.goalProgress,
            caption: caption,
            icon: Icons.flag_rounded,
            footer: GradientButton(
              label: 'Boshlash',
              icon: Icons.auto_awesome_rounded,
              trailingIcon: Icons.arrow_forward_rounded,
              isLoading: startingSession,
              onPressed: startingSession ? null : onStart,
              semanticLabel: 'Bugungi mashqni boshlash',
            ),
          ),
          const SizedBox(height: AppConstants.space16),
          Row(
            children: <Widget>[
              Expanded(
                child: _HomeStat(
                  icon: Icons.local_fire_department_rounded,
                  value: '${snapshot.currentStreak}',
                  label: 'Kunlik seriya',
                  accent: colors.accentPink,
                ),
              ),
              const SizedBox(width: AppConstants.space8),
              Expanded(
                child: _HomeStat(
                  icon: Icons.menu_book_rounded,
                  value: '${snapshot.totalWordsStudied}',
                  label: 'O‘rganilgan',
                  accent: colors.accentLavender,
                ),
              ),
              const SizedBox(width: AppConstants.space8),
              Expanded(
                child: _HomeStat(
                  icon: Icons.replay_rounded,
                  value: '${snapshot.dueReviews}',
                  label: 'Takrorlash',
                  accent: colors.accentMint,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.space20),
          WeeklyActivityCard(snapshot: snapshot),
          const SizedBox(height: AppConstants.space16),
          AtlasCard(
            learnedWords: snapshot.rememberedWords,
            totalWords: snapshot.totalVocabulary,
          ),
          const SizedBox(height: AppConstants.space20),
          Center(
            child: Text(
              'Har kuni oz-ozdan — katta natijalarga.',
              textAlign: TextAlign.center,
              style: context.textTheme.bodySmall?.copyWith(
                color: colors.textMuted,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HomeStat extends StatelessWidget {
  const _HomeStat({
    required this.icon,
    required this.value,
    required this.label,
    required this.accent,
  });

  final IconData icon;
  final String value;
  final String label;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final SozAtlasColors colors = context.colors;
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 10, 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: colors.glassFill,
        border: Border.all(color: colors.glassBorder),
        gradient: LinearGradient(
          colors: <Color>[
            colors.glassFillStrong,
            colors.glassFill.withValues(alpha: 0.18),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: accent.withValues(alpha: 0.14),
              border: Border.all(color: accent.withValues(alpha: 0.24)),
            ),
            child: Icon(icon, size: 15, color: accent),
          ),
          const SizedBox(height: AppConstants.space12),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.textTheme.headlineSmall?.copyWith(
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.textTheme.bodySmall?.copyWith(
              color: colors.textMuted,
              fontSize: 11.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _HomeLoading extends StatelessWidget {
  const _HomeLoading();

  @override
  Widget build(BuildContext context) {
    final SozAtlasColors colors = context.colors;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const SozAtlasLogo(size: 76),
          const SizedBox(height: AppConstants.space20),
          Text(
            'So‘z Atlas',
            style: context.textTheme.titleLarge?.copyWith(letterSpacing: 0.5),
          ),
          const SizedBox(height: 8),
          Text(
            'Shaxsiy so‘z koinotingiz yuklanmoqda…',
            style: context.textTheme.bodySmall?.copyWith(
              color: colors.textMuted,
            ),
          ),
          const SizedBox(height: AppConstants.space20),
          SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(
              strokeWidth: 2.4,
              valueColor: AlwaysStoppedAnimation<Color>(colors.accentLavender),
            ),
          ),
        ],
      ),
    );
  }
}

class _HomeError extends StatelessWidget {
  const _HomeError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final SozAtlasColors colors = context.colors;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: GlassCard(
          blur: true,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colors.dangerContainer,
                  border: Border.all(
                    color: colors.danger.withValues(alpha: 0.25),
                  ),
                ),
                child: Icon(
                  Icons.cloud_off_rounded,
                  size: 21,
                  color: colors.danger,
                ),
              ),
              const SizedBox(height: AppConstants.space16),
              Text(
                'Ma’lumotlarni yuklab bo‘lmadi',
                style: context.textTheme.headlineSmall?.copyWith(fontSize: 20),
              ),
              const SizedBox(height: 8),
              Text(
                'Mahalliy so‘zlar bazasini ochishda muammo yuz berdi. '
                'Qayta urinib ko‘ring.',
                style: context.textTheme.bodyMedium?.copyWith(
                  color: colors.textSecondary,
                ),
              ),
              const SizedBox(height: AppConstants.space20),
              GradientButton(
                label: 'Qayta urinish',
                icon: Icons.refresh_rounded,
                trailingIcon: null,
                onPressed: onRetry,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
