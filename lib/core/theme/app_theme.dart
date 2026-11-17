import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../constants/app_constants.dart';
import 'app_colors.dart';
import 'app_typography.dart';

export 'app_colors.dart';

/// Builds the two hand-tuned Material 3 themes used by So‘z Atlas.
abstract final class AppTheme {
  static ThemeData dark() => _build(SozAtlasColors.dark);

  static ThemeData light() => _build(SozAtlasColors.light);

  static ThemeData _build(SozAtlasColors colors) {
    final TextTheme textTheme = AppTypography.darkTextTheme(
      colors.textPrimary,
      colors.textSecondary,
    );

    final ColorScheme scheme = ColorScheme(
      brightness: colors.isDark ? Brightness.dark : Brightness.light,
      primary: colors.accentLavender,
      onPrimary: colors.onGradient,
      primaryContainer: colors.glassFillStrong,
      onPrimaryContainer: colors.textPrimary,
      secondary: colors.accentCyan,
      onSecondary: colors.onGradient,
      secondaryContainer: colors.glassFill,
      onSecondaryContainer: colors.textPrimary,
      tertiary: colors.accentMint,
      onTertiary: colors.onGradient,
      error: colors.danger,
      onError: colors.isDark ? const Color(0xFF210812) : Colors.white,
      errorContainer: colors.dangerContainer,
      onErrorContainer: colors.danger,
      surface: colors.background,
      onSurface: colors.textPrimary,
      surfaceContainerHighest: colors.backgroundSecondary,
      onSurfaceVariant: colors.textSecondary,
      outline: colors.glassBorder,
      outlineVariant: colors.divider,
      shadow: colors.shadow,
      scrim: const Color(0x99000000),
      inverseSurface: colors.textPrimary,
      onInverseSurface: colors.background,
      inversePrimary: colors.accentLavender,
    );

    final ThemeData base = ThemeData(
      useMaterial3: true,
      brightness: colors.isDark ? Brightness.dark : Brightness.light,
      colorScheme: scheme,
      fontFamily: AppTypography.fontFamily,
      scaffoldBackgroundColor: colors.background,
      canvasColor: colors.background,
      splashFactory: InkSparkle.splashFactory,
      visualDensity: VisualDensity.standard,
      extensions: <ThemeExtension<dynamic>>[colors],
    );

    return base.copyWith(
      textTheme: textTheme,
      primaryTextTheme: textTheme,
      iconTheme: IconThemeData(color: colors.textPrimary, size: 22),
      dividerTheme: DividerThemeData(
        color: colors.divider,
        thickness: 1,
        space: 1,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: colors.backgroundElevated,
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: colors.textPrimary,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 0,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: colors.backgroundElevated,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.cardRadius),
        ),
        titleTextStyle: textTheme.headlineSmall,
        contentTextStyle: textTheme.bodyMedium,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: Colors.transparent,
        modalBackgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(),
        elevation: 0,
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: colors.accentLavender,
        linearTrackColor: colors.glassBorder,
        circularTrackColor: colors.glassBorder,
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: colors.accentLavender,
        selectionColor: colors.accentLavender.withValues(alpha: 0.3),
        selectionHandleColor: colors.accentLavender,
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: <TargetPlatform, PageTransitionsBuilder>{
          TargetPlatform.android: FadeForwardsPageTransitionsBuilder(),
        },
      ),
    );
  }

  /// System chrome that matches the app palette.
  static SystemUiOverlayStyle overlayStyle(SozAtlasColors colors) {
    return SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: colors.isDark
          ? Brightness.light
          : Brightness.dark,
      statusBarBrightness: colors.isDark ? Brightness.dark : Brightness.light,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: colors.isDark
          ? Brightness.light
          : Brightness.dark,
      systemNavigationBarContrastEnforced: false,
    );
  }
}

/// Convenient access to the app palette and motion rules from a [BuildContext].
extension SozAtlasThemeContext on BuildContext {
  SozAtlasColors get colors =>
      Theme.of(this).extension<SozAtlasColors>() ?? SozAtlasColors.dark;

  TextTheme get textTheme => Theme.of(this).textTheme;

  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;

  /// True when the operating system asks apps to reduce motion.
  bool get reduceMotion => MediaQuery.maybeDisableAnimationsOf(this) ?? false;

  /// Returns [duration] unless the user prefers reduced motion.
  Duration motion(Duration duration) => reduceMotion ? Duration.zero : duration;
}
