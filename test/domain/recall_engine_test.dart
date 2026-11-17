import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:soz_atlas/core/constants/part_of_speech.dart';
import 'package:soz_atlas/data/models/word.dart';
import 'package:soz_atlas/domain/models/session_models.dart';
import 'package:soz_atlas/domain/session/recall_engine.dart';

Word word(int id) => Word(
  id: id,
  word: 'word$id',
  phonetic: '/wɜːd/',
  partOfSpeech: PartOfSpeech.noun,
  cefrLevel: 'A1',
  translation: 'tarjima$id',
  definition: 'definition',
  example: 'Example.',
  exampleTranslation: 'Misol.',
);

SessionQuestion question(int id, {bool isRetry = false}) {
  return SessionQuestion(
    word: word(id),
    choices: <AnswerChoice>[
      AnswerChoice(translation: 'tarjima$id'),
      AnswerChoice(translation: 'boshqa$id-a'),
      AnswerChoice(translation: 'boshqa$id-b'),
      AnswerChoice(translation: 'boshqa$id-c'),
    ],
    correctIndex: 0,
    isNew: true,
    isRetry: isRetry,
  );
}

List<SessionQuestion> fiveQuestions() => <SessionQuestion>[
  for (int index = 1; index <= 5; index++) question(index),
];

void main() {
  group('RecallEngine', () {
    test('starts on the first question and tracks progress', () {
      final RecallEngine engine = RecallEngine(questions: fiveQuestions());
      expect(engine.current!.word.id, 1);
      expect(engine.currentNumber, 1);
      expect(engine.totalQuestions, 5);
      expect(engine.firstAttemptProgress, 0);
      expect(engine.isAnswered, isFalse);
      expect(engine.isComplete, isFalse);
    });

    test('a correct answer is recorded exactly once', () {
      final RecallEngine engine = RecallEngine(questions: fiveQuestions());
      final AnswerOutcome outcome = engine.answer(0);
      expect(outcome.isCorrect, isTrue);
      expect(engine.isAnswered, isTrue);
      expect(engine.correctFirstAttempts, 1);
      expect(engine.answeredFirstAttempts, 1);
      expect(engine.retryAttempts, 0);
    });

    test('answering the same question twice throws and changes nothing', () {
      final RecallEngine engine = RecallEngine(questions: fiveQuestions());
      engine.answer(1);
      expect(engine.answeredFirstAttempts, 1);
      expect(engine.correctFirstAttempts, 0);
      expect(() => engine.answer(0), throwsStateError);
      expect(engine.answeredFirstAttempts, 1);
    });

    test('incorrect answers queue one retry at the end of the session', () {
      final RecallEngine engine = RecallEngine(questions: fiveQuestions());
      final AnswerOutcome outcome = engine.answer(2);
      expect(outcome.isCorrect, isFalse);
      expect(outcome.retryScheduled, isTrue);
      expect(engine.retryAttempts, 0);

      // Move through the remaining first-attempt questions.
      for (int index = 1; index < 5; index++) {
        engine.next();
        engine.answer(0);
      }
      engine.next();
      expect(engine.current, isNotNull);
      expect(engine.current!.isRetry, isTrue);
      expect(engine.isLastQuestion, isTrue);
      expect(engine.totalQuestions, 5, reason: 'retries do not change total');
    });

    test('a retry is never retried a second time', () {
      final RecallEngine engine = RecallEngine(questions: fiveQuestions());
      engine.answer(1); // wrong → retry queued
      for (int index = 1; index < 5; index++) {
        engine.next();
        engine.answer(0);
      }
      engine.next(); // move to the retry
      expect(engine.isCurrentRetry, isTrue);
      final AnswerOutcome retryOutcome = engine.answer(1); // wrong again
      expect(retryOutcome.isCorrect, isFalse);
      expect(retryOutcome.wasRetry, isTrue);
      expect(retryOutcome.retryScheduled, isFalse);
      engine.next();
      expect(engine.isComplete, isTrue);
      expect(engine.retryAttempts, 1);
    });

    test('a correct retry is counted separately from first attempts', () {
      final RecallEngine engine = RecallEngine(questions: fiveQuestions());
      engine.answer(1);
      for (int index = 1; index < 5; index++) {
        engine.next();
        engine.answer(0);
      }
      engine.next();
      final AnswerOutcome retry = engine.answer(0);
      expect(retry.isCorrect, isTrue);
      expect(engine.correctFirstAttempts, 4);
      expect(engine.retryAttempts, 1);
      expect(engine.retryCorrect, 1);
      engine.next();
      expect(engine.isComplete, isTrue);
    });

    test('moving on before answering throws', () {
      final RecallEngine engine = RecallEngine(questions: fiveQuestions());
      expect(engine.next, throwsStateError);
    });

    test('completes after the last first-attempt question', () {
      final RecallEngine engine = RecallEngine(questions: fiveQuestions());
      for (int index = 0; index < 5; index++) {
        engine.answer(0);
        engine.next();
      }
      expect(engine.isComplete, isTrue);
      expect(engine.answeredFirstAttempts, 5);
      expect(engine.correctFirstAttempts, 5);
    });

    test('outcomes never expose a wrong correct-index', () {
      final Random random = Random(11);
      for (int run = 0; run < 20; run++) {
        final RecallEngine engine = RecallEngine(questions: fiveQuestions());
        final int choice = random.nextInt(4);
        final AnswerOutcome outcome = engine.answer(choice);
        expect(outcome.correctIndex, 0);
        expect(outcome.isCorrect, choice == 0);
        expect(outcome.correctTranslation, 'tarjima1');
      }
    });
  });
}
