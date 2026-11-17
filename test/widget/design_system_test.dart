import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soz_atlas/core/theme/app_theme.dart';
import 'package:soz_atlas/data/models/word.dart';
import 'package:soz_atlas/shared/widgets/answer_option.dart';
import 'package:soz_atlas/shared/widgets/glass_progress_card.dart';
import 'package:soz_atlas/shared/widgets/gradient_button.dart';
import 'package:soz_atlas/shared/widgets/progress_ring.dart';
import 'package:soz_atlas/shared/widgets/streak_indicator.dart';
import 'package:soz_atlas/shared/widgets/word_card.dart';

import '../helpers/test_fonts.dart';
import '../helpers/test_platform.dart';

const Word _word = Word(
  id: 1,
  word: 'apple',
  phonetic: '/ˈæp.əl/',
  partOfSpeech: 'noun',
  cefrLevel: 'A1',
  translation: 'olma',
  definition: 'a round fruit',
  example: 'She eats an apple every morning.',
  exampleTranslation: 'U har kuni ertalab olma yeydi.',
);

Widget _wrap(Widget child) {
  return MaterialApp(
    theme: AppTheme.dark(),
    darkTheme: AppTheme.dark(),
    themeMode: ThemeMode.dark,
    home: Scaffold(
      backgroundColor: const Color(0xFF090E1D),
      body: SingleChildScrollView(child: child),
    ),
  );
}

void main() {
  setUpAll(() async {
    installPlatformChannelMocks();
    await loadTestFonts();
  });

  group('GradientButton', () {
    testWidgets('triggers the callback when pressed', (
      WidgetTester tester,
    ) async {
      int taps = 0;
      await tester.pumpWidget(
        _wrap(GradientButton(label: 'Boshlash', onPressed: () => taps++)),
      );
      expect(find.text('Boshlash'), findsOneWidget);
      await tester.tap(find.text('Boshlash'));
      await tester.pumpAndSettle();
      expect(taps, 1);
    });

    testWidgets('does nothing when disabled', (WidgetTester tester) async {
      int taps = 0;
      await tester.pumpWidget(
        _wrap(GradientButton(label: 'Boshlash', onPressed: null)),
      );
      await tester.tap(find.text('Boshlash'));
      await tester.pumpAndSettle();
      expect(taps, 0);
    });

    testWidgets('shows a loading state and blocks taps', (
      WidgetTester tester,
    ) async {
      int taps = 0;
      await tester.pumpWidget(
        _wrap(
          GradientButton(
            label: 'Boshlash',
            isLoading: true,
            onPressed: () => taps++,
          ),
        ),
      );
      expect(find.text('Tayyorlanmoqda…'), findsOneWidget);
      await tester.tap(find.text('Tayyorlanmoqda…'));
      await tester.pump();
      expect(taps, 0);
    });
  });

  group('AnswerOption', () {
    testWidgets('calls onTap when idle', (WidgetTester tester) async {
      int taps = 0;
      await tester.pumpWidget(
        _wrap(
          AnswerOption(
            letter: 'A',
            label: 'olma',
            state: AnswerVisualState.idle,
            onTap: () => taps++,
          ),
        ),
      );
      await tester.tap(find.text('olma'));
      await tester.pumpAndSettle();
      expect(taps, 1);
    });

    testWidgets('shows a check icon for the correct answer', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          const AnswerOption(
            letter: 'B',
            label: 'olma',
            state: AnswerVisualState.correct,
            onTap: null,
          ),
        ),
      );
      expect(find.byIcon(Icons.check_circle_rounded), findsOneWidget);
    });

    testWidgets('shows a cancel icon for an incorrect answer', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          const AnswerOption(
            letter: 'C',
            label: 'non',
            state: AnswerVisualState.incorrect,
            onTap: null,
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.byIcon(Icons.cancel_rounded), findsOneWidget);
    });
  });

  group('WordCard', () {
    testWidgets('keeps the meaning hidden until revealed', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _wrap(WordCard(word: _word, revealed: false, onPronounce: () {})),
      );
      expect(find.text('apple'), findsOneWidget);
      expect(find.text('/ˈæp.əl/'), findsOneWidget);
      expect(find.text('olma'), findsNothing);
      expect(find.text('She eats an apple every morning.'), findsNothing);
    });

    testWidgets('reveals translation, definition and example', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _wrap(WordCard(word: _word, revealed: true, onPronounce: () {})),
      );
      await tester.pumpAndSettle();
      expect(find.text('olma'), findsOneWidget);
      expect(find.text('a round fruit'), findsOneWidget);
      expect(find.text('She eats an apple every morning.'), findsOneWidget);
      expect(find.text('U har kuni ertalab olma yeydi.'), findsOneWidget);
    });

    testWidgets('pronunciation button works', (WidgetTester tester) async {
      int taps = 0;
      await tester.pumpWidget(
        _wrap(
          WordCard(word: _word, revealed: false, onPronounce: () => taps++),
        ),
      );
      await tester.tap(find.byIcon(Icons.volume_up_rounded));
      await tester.pumpAndSettle();
      expect(taps, 1);
    });
  });

  group('small widgets', () {
    testWidgets('streak shows zero gently', (WidgetTester tester) async {
      await tester.pumpWidget(_wrap(const StreakIndicator(streak: 0)));
      expect(find.text('0 kun'), findsOneWidget);
    });

    testWidgets('streak shows the real count', (WidgetTester tester) async {
      await tester.pumpWidget(_wrap(const StreakIndicator(streak: 3)));
      expect(find.text('3 kun'), findsOneWidget);
    });

    testWidgets('progress ring animates to the final value', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _wrap(const ProgressRing(progress: 0.6, child: Text('60%'))),
      );
      await tester.pumpAndSettle();
      expect(find.text('60%'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('360dp home-style layout does not overflow', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(360 * 3, 740 * 3);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.dark(),
          home: Scaffold(
            backgroundColor: const Color(0xFF090E1D),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  GlassProgressCard(
                    eyebrow: 'Bugungi maqsad',
                    title: '5 ta mashq',
                    progressLabel: '2 / 5 bajarildi',
                    progress: 0.4,
                    caption: 'Kuniga 5 ta mashq · taxminan 3 daqiqa',
                    icon: Icons.flag_rounded,
                    footer: GradientButton(label: 'Boshlash', onPressed: () {}),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: const <Widget>[
                      Expanded(child: StreakIndicator(streak: 2)),
                      Expanded(child: StreakIndicator(streak: 4)),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('Boshlash'), findsOneWidget);
      expect(find.text('2 / 5 bajarildi'), findsOneWidget);
    });
  });

  group('themes', () {
    testWidgets('light and dark themes expose their own palettes', (
      WidgetTester tester,
    ) async {
      expect(AppTheme.dark().extension<SozAtlasColors>()!.isDark, isTrue);
      expect(AppTheme.light().extension<SozAtlasColors>()!.isDark, isFalse);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light(),
          home: Builder(
            builder: (BuildContext context) {
              final SozAtlasColors colors = context.colors;
              return Scaffold(
                body: Text(colors.background.toARGB32().toRadixString(16)),
              );
            },
          ),
        ),
      );
      expect(find.text('fff3f5fc'), findsOneWidget);
    });
  });
}
