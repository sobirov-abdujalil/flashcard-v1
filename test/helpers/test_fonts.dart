import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Loads the bundled Manrope font files into the test engine.
///
/// Widget tests use a placeholder font (Ahem-like) by default, which makes every
/// glyph a square and produces misleading overflow errors. Loading the real
/// bundled fonts gives tests realistic text metrics.
Future<void> loadTestFonts() async {
  final FontLoader loader = FontLoader('Manrope');
  for (final String fileName in <String>[
    'Manrope-Regular.ttf',
    'Manrope-Medium.ttf',
    'Manrope-SemiBold.ttf',
    'Manrope-Bold.ttf',
    'Manrope-ExtraBold.ttf',
  ]) {
    loader.addFont(rootBundle.load('assets/fonts/$fileName'));
  }
  await loader.load();
}
