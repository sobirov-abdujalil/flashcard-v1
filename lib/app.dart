import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/constants/app_constants.dart';
import 'core/constants/routes.dart';
import 'core/theme/app_theme.dart';
import 'data/models/app_settings.dart';
import 'features/home/home_screen.dart';
import 'features/learn/learn_screen.dart';
import 'features/recall/recall_screen.dart';
import 'features/settings/privacy_policy_screen.dart';
import 'features/summary/summary_screen.dart';
import 'providers/app_providers.dart';
import 'providers/settings_provider.dart';
import 'shared/widgets/app_logo.dart';
import 'shared/widgets/gradient_background.dart';

/// Root widget: themes, routes and the database bootstrap gate.
class SozAtlasApp extends ConsumerWidget {
  const SozAtlasApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppSettings settings =
        ref.watch(settingsProvider).value ?? AppSettings.defaults;

    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: settings.themeMode,
      builder: (BuildContext context, Widget? child) {
        final Brightness brightness = Theme.of(context).brightness;
        final SozAtlasColors colors = brightness == Brightness.dark
            ? SozAtlasColors.dark
            : SozAtlasColors.light;
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: AppTheme.overlayStyle(colors),
          child: child ?? const SizedBox.shrink(),
        );
      },
      home: const _AppGate(),
      onGenerateRoute: _generateRoute,
    );
  }

  Route<dynamic>? _generateRoute(RouteSettings settings) {
    final WidgetBuilder? builder = switch (settings.name) {
      AppRoutes.learn => (BuildContext context) => const LearnScreen(),
      AppRoutes.recall => (BuildContext context) => const RecallScreen(),
      AppRoutes.summary => (BuildContext context) => const SummaryScreen(),
      AppRoutes.privacy => (
        BuildContext context,
      ) => const PrivacyPolicyScreen(),
      _ => null,
    };
    if (builder == null) return null;
    return _fadeSlideRoute(builder, settings);
  }

  /// Lightweight custom transition (180–280 ms) shared by all screens.
  static Route<dynamic> _fadeSlideRoute(
    WidgetBuilder builder,
    RouteSettings settings,
  ) {
    return PageRouteBuilder<dynamic>(
      settings: settings,
      transitionDuration: AppConstants.screen,
      reverseTransitionDuration: AppConstants.short,
      pageBuilder: (
        BuildContext context,
        Animation<double> animation,
        Animation<double> secondaryAnimation,
      ) => builder(context),
      transitionsBuilder:
          (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
            Widget child,
          ) {
            if (MediaQuery.maybeDisableAnimationsOf(context) ?? false) {
              return child;
            }
            final CurvedAnimation curved = CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
              reverseCurve: Curves.easeInCubic,
            );
            return FadeTransition(
              opacity: curved,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.035),
                  end: Offset.zero,
                ).animate(curved),
                child: child,
              ),
            );
          },
    );
  }
}

/// Waits for the local database and shows a branded splash while it opens.
class _AppGate extends ConsumerWidget {
  const _AppGate();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref
        .watch(appBootstrapProvider)
        .when(
          data: (_) => const HomeScreen(),
          loading: () => const _SplashScreen(),
          error: (Object error, StackTrace stackTrace) => _BootstrapError(
            onRetry: () => ref.invalidate(appBootstrapProvider),
          ),
        );
  }
}

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    final SozAtlasColors colors = context.colors;
    return Scaffold(
      backgroundColor: colors.background,
      body: GradientBackground(
        child: SafeArea(
          child: Center(
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0, end: 1),
              duration: const Duration(milliseconds: 520),
              curve: Curves.easeOutCubic,
              builder: (BuildContext context, double value, Widget? child) {
                return Opacity(
                  opacity: value,
                  child: Transform.scale(
                    scale: 0.92 + 0.08 * value,
                    child: child,
                  ),
                );
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const SozAtlasLogo(size: 108),
                  const SizedBox(height: AppConstants.space24),
                  Text(
                    'SO‘Z ATLAS',
                    style: context.textTheme.titleLarge?.copyWith(
                      letterSpacing: 6,
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Ingliz so‘zlari — sizning koinotingizda',
                    style: context.textTheme.bodySmall?.copyWith(
                      color: colors.textMuted,
                    ),
                  ),
                  const SizedBox(height: AppConstants.space32),
                  SizedBox(
                    width: 26,
                    height: 26,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.4,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        colors.accentLavender,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BootstrapError extends StatelessWidget {
  const _BootstrapError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final SozAtlasColors colors = context.colors;
    return Scaffold(
      backgroundColor: colors.background,
      body: GradientBackground(
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Icon(Icons.storage_rounded, size: 44, color: colors.danger),
                  const SizedBox(height: AppConstants.space16),
                  Text(
                    'So‘zlar bazasini ochib bo‘lmadi',
                    textAlign: TextAlign.center,
                    style: context.textTheme.headlineSmall?.copyWith(
                      fontSize: 20,
                    ),
                  ),
                  const SizedBox(height: AppConstants.space8),
                  Text(
                    'Ilovani qayta ochib ko‘ring. Muammo davom etsa, '
                    'qurilmada bo‘sh joy borligini tekshiring.',
                    textAlign: TextAlign.center,
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppConstants.space24),
                  FilledButton.tonal(
                    onPressed: onRetry,
                    child: const Text('Qayta urinish'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
