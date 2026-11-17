import 'package:flutter/material.dart';

/// Every colour used by the app lives in [SozAtlasColors].
///
/// Two hand-tuned palettes exist: a midnight "liquid glass" palette and a
/// separately designed light palette. They are not simple inversions of each
/// other — accents, gradients and shadows were adjusted for contrast.
@immutable
class SozAtlasColors extends ThemeExtension<SozAtlasColors> {
  const SozAtlasColors({
    required this.isDark,
    required this.background,
    required this.backgroundSecondary,
    required this.backgroundElevated,
    required this.glassFill,
    required this.glassFillStrong,
    required this.glassBorder,
    required this.glassHighlight,
    required this.solidSurface,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.onGradient,
    required this.onSolidAccent,
    required this.accentLavender,
    required this.accentCyan,
    required this.accentMint,
    required this.accentPink,
    required this.danger,
    required this.dangerContainer,
    required this.successContainer,
    required this.glowLavender,
    required this.glowCyan,
    required this.glowMint,
    required this.constellationLine,
    required this.constellationNode,
    required this.constellationNodeActive,
    required this.shadow,
    required this.divider,
  });

  final bool isDark;

  final Color background;
  final Color backgroundSecondary;
  final Color backgroundElevated;

  final Color glassFill;
  final Color glassFillStrong;
  final Color glassBorder;
  final Color glassHighlight;
  final Color solidSurface;

  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;
  final Color onGradient;
  final Color onSolidAccent;

  final Color accentLavender;
  final Color accentCyan;
  final Color accentMint;
  final Color accentPink;
  final Color danger;
  final Color dangerContainer;
  final Color successContainer;

  final Color glowLavender;
  final Color glowCyan;
  final Color glowMint;

  final Color constellationLine;
  final Color constellationNode;
  final Color constellationNodeActive;

  final Color shadow;
  final Color divider;

  /// The signature So‘z Atlas gradient used by primary buttons, progress rings
  /// and accent text.
  List<Color> get gradientColors => <Color>[
    accentLavender,
    accentCyan,
    accentMint,
  ];

  LinearGradient get primaryGradient => LinearGradient(
    colors: gradientColors,
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    stops: const <double>[0, 0.55, 1],
  );

  LinearGradient get horizontalGradient => LinearGradient(
    colors: gradientColors,
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    stops: const <double>[0, 0.55, 1],
  );

  LinearGradient get glassGradient => LinearGradient(
    colors: <Color>[glassFillStrong, glassFill],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  LinearGradient get pageGradient => LinearGradient(
    colors: <Color>[background, backgroundSecondary],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const SozAtlasColors dark = SozAtlasColors(
    isDark: true,
    background: Color(0xFF090E1D),
    backgroundSecondary: Color(0xFF111A2D),
    backgroundElevated: Color(0xFF16213A),
    glassFill: Color(0x14FFFFFF),
    glassFillStrong: Color(0x1FFFFFFF),
    glassBorder: Color(0x1FFFFFFF),
    glassHighlight: Color(0x0DFFFFFF),
    solidSurface: Color(0xFF151F35),
    textPrimary: Color(0xFFF4F6FF),
    textSecondary: Color(0xFFA3AECC),
    textMuted: Color(0xFF7E89A8),
    onGradient: Color(0xFF081120),
    onSolidAccent: Color(0xFF081120),
    accentLavender: Color(0xFF927CFF),
    accentCyan: Color(0xFF65C8F5),
    accentMint: Color(0xFF74E4C0),
    accentPink: Color(0xFFF09BCB),
    danger: Color(0xFFFF8AA8),
    dangerContainer: Color(0x24FF8AA8),
    successContainer: Color(0x2474E4C0),
    glowLavender: Color(0x33927CFF),
    glowCyan: Color(0x2665C8F5),
    glowMint: Color(0x1A74E4C0),
    constellationLine: Color(0x1F927CFF),
    constellationNode: Color(0xFF5D6B92),
    constellationNodeActive: Color(0xFF9CE9FF),
    shadow: Color(0x66000000),
    divider: Color(0x14FFFFFF),
  );

  static const SozAtlasColors light = SozAtlasColors(
    isDark: false,
    background: Color(0xFFF3F5FC),
    backgroundSecondary: Color(0xFFE7EBF9),
    backgroundElevated: Color(0xFFFFFFFF),
    glassFill: Color(0xCCFFFFFF),
    glassFillStrong: Color(0xF2FFFFFF),
    glassBorder: Color(0x14172039),
    glassHighlight: Color(0xFFFFFFFF),
    solidSurface: Color(0xFFFFFFFF),
    textPrimary: Color(0xFF172039),
    textSecondary: Color(0xFF69738C),
    textMuted: Color(0xFF8A93A9),
    onGradient: Color(0xFFFFFFFF),
    onSolidAccent: Color(0xFFFFFFFF),
    accentLavender: Color(0xFF705FE1),
    accentCyan: Color(0xFF2A6FB6),
    accentMint: Color(0xFF1B806B),
    accentPink: Color(0xFFB93E79),
    danger: Color(0xFFD1446C),
    dangerContainer: Color(0x1FD1446C),
    successContainer: Color(0x1F1B806B),
    glowLavender: Color(0x2E705FE1),
    glowCyan: Color(0x263D8FD6),
    glowMint: Color(0x1F2FA98C),
    constellationLine: Color(0x1A705FE1),
    constellationNode: Color(0xFFC2C9DB),
    constellationNodeActive: Color(0xFF705FE1),
    shadow: Color(0x1F4A3F8A),
    divider: Color(0x14172039),
  );

  Color get neutralOptionFill => isDark ? glassFill : const Color(0xE6FFFFFF);

  @override
  SozAtlasColors copyWith({
    bool? isDark,
    Color? background,
    Color? backgroundSecondary,
    Color? backgroundElevated,
    Color? glassFill,
    Color? glassFillStrong,
    Color? glassBorder,
    Color? glassHighlight,
    Color? solidSurface,
    Color? textPrimary,
    Color? textSecondary,
    Color? textMuted,
    Color? onGradient,
    Color? onSolidAccent,
    Color? accentLavender,
    Color? accentCyan,
    Color? accentMint,
    Color? accentPink,
    Color? danger,
    Color? dangerContainer,
    Color? successContainer,
    Color? glowLavender,
    Color? glowCyan,
    Color? glowMint,
    Color? constellationLine,
    Color? constellationNode,
    Color? constellationNodeActive,
    Color? shadow,
    Color? divider,
  }) {
    return SozAtlasColors(
      isDark: isDark ?? this.isDark,
      background: background ?? this.background,
      backgroundSecondary: backgroundSecondary ?? this.backgroundSecondary,
      backgroundElevated: backgroundElevated ?? this.backgroundElevated,
      glassFill: glassFill ?? this.glassFill,
      glassFillStrong: glassFillStrong ?? this.glassFillStrong,
      glassBorder: glassBorder ?? this.glassBorder,
      glassHighlight: glassHighlight ?? this.glassHighlight,
      solidSurface: solidSurface ?? this.solidSurface,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textMuted: textMuted ?? this.textMuted,
      onGradient: onGradient ?? this.onGradient,
      onSolidAccent: onSolidAccent ?? this.onSolidAccent,
      accentLavender: accentLavender ?? this.accentLavender,
      accentCyan: accentCyan ?? this.accentCyan,
      accentMint: accentMint ?? this.accentMint,
      accentPink: accentPink ?? this.accentPink,
      danger: danger ?? this.danger,
      dangerContainer: dangerContainer ?? this.dangerContainer,
      successContainer: successContainer ?? this.successContainer,
      glowLavender: glowLavender ?? this.glowLavender,
      glowCyan: glowCyan ?? this.glowCyan,
      glowMint: glowMint ?? this.glowMint,
      constellationLine: constellationLine ?? this.constellationLine,
      constellationNode: constellationNode ?? this.constellationNode,
      constellationNodeActive:
          constellationNodeActive ?? this.constellationNodeActive,
      shadow: shadow ?? this.shadow,
      divider: divider ?? this.divider,
    );
  }

  @override
  SozAtlasColors lerp(ThemeExtension<SozAtlasColors>? other, double t) {
    if (other is! SozAtlasColors) {
      return this;
    }
    Color mix(Color a, Color b) => Color.lerp(a, b, t) ?? a;
    return SozAtlasColors(
      isDark: t < 0.5 ? isDark : other.isDark,
      background: mix(background, other.background),
      backgroundSecondary: mix(backgroundSecondary, other.backgroundSecondary),
      backgroundElevated: mix(backgroundElevated, other.backgroundElevated),
      glassFill: mix(glassFill, other.glassFill),
      glassFillStrong: mix(glassFillStrong, other.glassFillStrong),
      glassBorder: mix(glassBorder, other.glassBorder),
      glassHighlight: mix(glassHighlight, other.glassHighlight),
      solidSurface: mix(solidSurface, other.solidSurface),
      textPrimary: mix(textPrimary, other.textPrimary),
      textSecondary: mix(textSecondary, other.textSecondary),
      textMuted: mix(textMuted, other.textMuted),
      onGradient: mix(onGradient, other.onGradient),
      onSolidAccent: mix(onSolidAccent, other.onSolidAccent),
      accentLavender: mix(accentLavender, other.accentLavender),
      accentCyan: mix(accentCyan, other.accentCyan),
      accentMint: mix(accentMint, other.accentMint),
      accentPink: mix(accentPink, other.accentPink),
      danger: mix(danger, other.danger),
      dangerContainer: mix(dangerContainer, other.dangerContainer),
      successContainer: mix(successContainer, other.successContainer),
      glowLavender: mix(glowLavender, other.glowLavender),
      glowCyan: mix(glowCyan, other.glowCyan),
      glowMint: mix(glowMint, other.glowMint),
      constellationLine: mix(constellationLine, other.constellationLine),
      constellationNode: mix(constellationNode, other.constellationNode),
      constellationNodeActive: mix(
        constellationNodeActive,
        other.constellationNodeActive,
      ),
      shadow: mix(shadow, other.shadow),
      divider: mix(divider, other.divider),
    );
  }
}
