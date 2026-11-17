import 'package:flutter/material.dart';

/// Typography for So‘z Atlas.
///
/// Manrope is bundled inside the app (assets/fonts) so typography never needs
/// a network request at runtime.
abstract final class AppTypography {
  static const String fontFamily = 'Manrope';

  static TextTheme darkTextTheme(Color primary, Color secondary) =>
      _build(primary, secondary);

  static TextTheme lightTextTheme(Color primary, Color secondary) =>
      _build(primary, secondary);

  static TextTheme _build(Color primary, Color secondary) {
    return TextTheme(
      // The main vocabulary word on the Learn screen.
      displayLarge: TextStyle(
        fontFamily: fontFamily,
        fontSize: 48,
        height: 1.06,
        fontWeight: FontWeight.w800,
        letterSpacing: -1.4,
        color: primary,
      ),
      // The word on the Recall screen and large numbers.
      displayMedium: TextStyle(
        fontFamily: fontFamily,
        fontSize: 38,
        height: 1.08,
        fontWeight: FontWeight.w800,
        letterSpacing: -1.0,
        color: primary,
      ),
      displaySmall: TextStyle(
        fontFamily: fontFamily,
        fontSize: 32,
        height: 1.1,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.8,
        color: primary,
      ),
      // Screen titles.
      headlineLarge: TextStyle(
        fontFamily: fontFamily,
        fontSize: 28,
        height: 1.15,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.6,
        color: primary,
      ),
      headlineMedium: TextStyle(
        fontFamily: fontFamily,
        fontSize: 24,
        height: 1.2,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.4,
        color: primary,
      ),
      headlineSmall: TextStyle(
        fontFamily: fontFamily,
        fontSize: 21,
        height: 1.25,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.2,
        color: primary,
      ),
      // Section headings.
      titleLarge: TextStyle(
        fontFamily: fontFamily,
        fontSize: 19,
        height: 1.3,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.1,
        color: primary,
      ),
      titleMedium: TextStyle(
        fontFamily: fontFamily,
        fontSize: 16,
        height: 1.35,
        fontWeight: FontWeight.w600,
        color: primary,
      ),
      titleSmall: TextStyle(
        fontFamily: fontFamily,
        fontSize: 14,
        height: 1.35,
        fontWeight: FontWeight.w600,
        color: secondary,
      ),
      bodyLarge: TextStyle(
        fontFamily: fontFamily,
        fontSize: 16,
        height: 1.5,
        fontWeight: FontWeight.w500,
        color: primary,
      ),
      bodyMedium: TextStyle(
        fontFamily: fontFamily,
        fontSize: 14,
        height: 1.5,
        fontWeight: FontWeight.w500,
        color: secondary,
      ),
      bodySmall: TextStyle(
        fontFamily: fontFamily,
        fontSize: 13,
        height: 1.45,
        fontWeight: FontWeight.w500,
        color: secondary,
      ),
      labelLarge: TextStyle(
        fontFamily: fontFamily,
        fontSize: 15,
        height: 1.2,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.1,
        color: primary,
      ),
      labelMedium: TextStyle(
        fontFamily: fontFamily,
        fontSize: 13,
        height: 1.2,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.2,
        color: secondary,
      ),
      labelSmall: TextStyle(
        fontFamily: fontFamily,
        fontSize: 11,
        height: 1.2,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.0,
        color: secondary,
      ),
    );
  }

  /// Small caps "eyebrow" label used above sections.
  static TextStyle eyebrow(Color color) => TextStyle(
    fontFamily: fontFamily,
    fontSize: 11,
    fontWeight: FontWeight.w700,
    letterSpacing: 1.6,
    color: color,
  );

  /// IPA transcription style.
  static TextStyle phonetic(Color color) => TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.2,
    color: color,
  );

  /// Italic example sentence style.
  static TextStyle example(Color color) => TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    height: 1.5,
    fontWeight: FontWeight.w500,
    fontStyle: FontStyle.italic,
    letterSpacing: 0.1,
    color: color,
  );
}
