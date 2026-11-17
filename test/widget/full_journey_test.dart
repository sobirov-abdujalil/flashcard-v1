import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:soz_atlas/app.dart';
import 'package:soz_atlas/data/database/app_database.dart';
import 'package:soz_atlas/domain/models/session_models.dart';
import 'package:soz_atlas/domain/session/recall_engine.dart';
import 'package:soz_atlas/providers/app_providers.dart';
import 'package:soz_atlas/providers/session_provider.dart';
import 'package:soz_atlas/providers/session_state.dart';
import 'package:soz_atlas/providers/settings_provider.dart';
import 'package:soz_atlas/shared/widgets/answer_option.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../helpers/test_fonts.dart';
import '../helpers/test_platform.dart';

/// End-to-end widget test of the main user journey:
/// Home → Learn → Recall → Session Complete → Home.
///
/// The database is opened inside each test body (the fake-async widget test
/// zone) so SQLite futures resolve during pumping. The no-isolate FFI factory
/// keeps all database work in the test isolate.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    installPlatformChannelMocks();
    await loadTestFonts();
  });

  Future<ProviderContainer> pumpApp(WidgetTester tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    sqfliteFfiInit();
    final AppDatabase database = AppDatabase(
      databaseFactory: databaseFactoryFfiNoIsolate,
      path: inMemoryDatabasePath,
    );
    await database.database;

    tester.view.physicalSize = const Size(360 * 3, 800 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    final ProviderContainer container = ProviderContainer(
      overrides: [appDatabaseProvider.overrideWith((Ref ref) => database)],
    );
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const SozAtlasApp(),
      ),
    );
    await tester.pumpAndSettle();
    return container;
  }

  Future<void> learnAllWords(WidgetTester tester) async {
    for (int index = 0; index < 5; index++) {
      await tester.tap(find.text('Ma’nosini ko‘rish'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Tekshirish'));
      await tester.pumpAndSettle();
    }
  }

  /// Pumps until [condition] holds (database futures need a few event-loop
  /// turns in the fake-async widget test zone), then settles animations.
  Future<void> pumpUntil(
    WidgetTester tester,
    ProviderContainer container,
    bool Function(SessionState state) condition,
  ) async {
    for (int attempt = 0; attempt < 200; attempt++) {
      if (condition(container.read(sessionProvider))) break;
      await tester.pump(const Duration(milliseconds: 25));
    }
    await tester.pumpAndSettle();
  }

  Future<void> pumpUntilFound(WidgetTester tester, Finder finder) async {
    for (int attempt = 0; attempt < 200; attempt++) {
      if (finder.evaluate().isNotEmpty) break;
      await tester.pump(const Duration(milliseconds: 25));
    }
    await tester.pumpAndSettle();
  }

  testWidgets('completes a full learning journey with real persistence', (
    WidgetTester tester,
  ) async {
    final ProviderContainer container = await pumpApp(tester);

    // Home
    expect(find.text('Boshlash'), findsOneWidget);
    expect(find.text('0 / 5 bajarildi'), findsOneWidget);

    // Home → Learn
    await tester.tap(find.text('Boshlash'));
    await tester.pumpAndSettle();
    expect(find.text('O‘RGANISH'), findsOneWidget);
    expect(find.text('1 / 5'), findsOneWidget);

    SessionState state = container.read(sessionProvider);
    expect(state.phase, SessionPhase.learning);
    expect(find.text(state.currentLearnWord!.word.translation), findsNothing);

    // Learn: reveal + advance through all five words.
    for (int index = 0; index < 5; index++) {
      expect(find.text('Ma’nosini ko‘rish'), findsOneWidget);
      await tester.tap(find.text('Ma’nosini ko‘rish'));
      await tester.pumpAndSettle();
      state = container.read(sessionProvider);
      expect(state.meaningRevealed, isTrue);
      expect(
        find.text(state.currentLearnWord!.word.translation),
        findsOneWidget,
      );
      await tester.tap(find.text('Tekshirish'));
      await tester.pumpAndSettle();
    }

    // Learn → Recall
    expect(find.text('TEKSHIRISH'), findsOneWidget);
    state = container.read(sessionProvider);
    expect(state.phase, SessionPhase.recall);
    expect(state.recall!.totalQuestions, 5);

    // Answer every question correctly.
    for (int index = 0; index < 5; index++) {
      state = container.read(sessionProvider);
      final RecallEngine engine = state.recall!;
      final SessionQuestion question = engine.current!;

      // The "next" button is disabled before answering.
      final int answeredBefore = engine.answeredFirstAttempts;
      await tester.ensureVisible(find.text('Keyingi so‘z'));
      await tester.tap(find.text('Keyingi so‘z'));
      await tester.pump();
      expect(
        container.read(sessionProvider).recall!.answeredFirstAttempts,
        answeredBefore,
      );

      final Finder options = find.byType(AnswerOption);
      expect(options, findsNWidgets(4));
      final Finder correctOption = options.at(question.correctIndex);
      await tester.ensureVisible(correctOption);
      await tester.tap(correctOption);
      await pumpUntil(
        tester,
        container,
        (SessionState s) => s.recall?.isAnswered == true && !s.isSavingAnswer,
      );

      expect(find.textContaining('To‘g‘ri javob!'), findsOneWidget);
      state = container.read(sessionProvider);
      expect(state.recall!.correctFirstAttempts, index + 1);

      final int questionIndexBefore = engine.questionIndex;
      await tester.ensureVisible(find.text('Keyingi so‘z'));
      await tester.tap(find.text('Keyingi so‘z'));
      await pumpUntil(
        tester,
        container,
        (SessionState s) =>
            s.phase == SessionPhase.complete ||
            (s.recall?.questionIndex ?? 0) > questionIndexBefore,
      );
    }

    // Session Complete
    await pumpUntilFound(tester, find.text('Ajoyib!'));
    expect(find.text('Bugungi maqsad bajarildi.'), findsOneWidget);
    expect(find.text('Yana o‘rganish'), findsOneWidget);
    expect(find.text('Uy sahifasiga'), findsOneWidget);

    state = container.read(sessionProvider);
    expect(state.phase, SessionPhase.complete);
    final SessionSummary summary = state.summary!;
    expect(summary.totalExercises, 5);
    expect(summary.correctAnswers, 5);
    expect(summary.newWordsStudied, 5);
    expect(summary.currentStreak, 1);
    expect(summary.goalCompleted, isTrue);

    // Real data was written to SQLite.
    expect(
      await container.read(progressRepositoryProvider).totalWordsStudied(),
      5,
    );

    // Back to Home: progress is refreshed from the database.
    await tester.ensureVisible(find.text('Uy sahifasiga'));
    await tester.tap(find.text('Uy sahifasiga'));
    await pumpUntilFound(tester, find.text('5 / 5 bajarildi'));
    expect(find.text('Boshlash'), findsOneWidget);
    expect(container.read(sessionProvider).phase, SessionPhase.idle);
  });

  testWidgets('incorrect answers show the correct translation and a retry', (
    WidgetTester tester,
  ) async {
    final ProviderContainer container = await pumpApp(tester);
    await tester.tap(find.text('Boshlash'));
    await tester.pumpAndSettle();
    await learnAllWords(tester);

    final SessionState state = container.read(sessionProvider);
    final SessionQuestion question = state.recall!.current!;
    final int wrongIndex = (question.correctIndex + 1) % 4;
    final Finder options = find.byType(AnswerOption);
    await tester.ensureVisible(options.at(wrongIndex));
    await tester.tap(options.at(wrongIndex));
    await pumpUntil(
      tester,
      container,
      (SessionState s) => s.recall?.isAnswered == true && !s.isSavingAnswer,
    );

    expect(
      find.text('To‘g‘ri javob: ${question.correctTranslation}'),
      findsOneWidget,
    );
    final RecallEngine engine = container.read(sessionProvider).recall!;
    expect(engine.correctFirstAttempts, 0);
    expect(engine.answeredFirstAttempts, 1);
    expect(engine.retryAttempts, 0);
    expect(engine.isAnswered, isTrue);

    // Moving on takes the learner to the next question.
    final int questionIndexBefore = engine.questionIndex;
    await tester.tap(find.text('Keyingi so‘z'));
    await pumpUntil(
      tester,
      container,
      (SessionState s) => (s.recall?.questionIndex ?? 0) > questionIndexBefore,
    );
    expect(find.text('TEKSHIRISH'), findsOneWidget);
  });

  testWidgets('theme, daily goal and settings sheet work from Home', (
    WidgetTester tester,
  ) async {
    final ProviderContainer container = await pumpApp(tester);

    await tester.tap(find.byTooltip('Sozlamalar'));
    await tester.pumpAndSettle();
    expect(find.text('Sozlamalar'), findsOneWidget);

    // Change the theme to light.
    await tester.tap(find.text('Yorug‘'));
    await tester.pumpAndSettle();
    expect(
      Theme.of(tester.element(find.text('Sozlamalar'))).brightness,
      Brightness.light,
    );

    // Change the daily goal.
    await tester.tap(find.text('10 mashq'));
    await tester.pumpAndSettle();
    expect(container.read(settingsProvider).value?.dailyGoal, 10);

    // Back to dark and close the sheet.
    await tester.tap(find.text('Qorong‘i'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Yopish'));
    await tester.pumpAndSettle();
    expect(find.text('Boshlash'), findsOneWidget);
    await pumpUntilFound(tester, find.text('0 / 10 bajarildi'));
  });
}
