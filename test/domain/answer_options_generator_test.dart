import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:soz_atlas/core/constants/part_of_speech.dart';
import 'package:soz_atlas/data/models/word.dart';
import 'package:soz_atlas/data/seed/seed_vocabulary.dart';
import 'package:soz_atlas/domain/models/session_models.dart';
import 'package:soz_atlas/domain/session/answer_options_generator.dart';

Word customWord({
  required int id,
  required String word,
  required String translation,
  String level = 'A1',
  String pos = PartOfSpeech.noun,
}) => Word(
  id: id,
  word: word,
  phonetic: '/test/',
  partOfSpeech: pos,
  cefrLevel: level,
  translation: translation,
  definition: 'definition',
  example: 'Example.',
  exampleTranslation: 'Misol.',
);

void main() {
  const AnswerOptionsGenerator generator = AnswerOptionsGenerator();
  final List<Word> vocabulary = buildSeedVocabulary();

  test('every seeded word produces exactly four valid options', () {
    final Random random = Random(7);
    for (final Word target in vocabulary) {
      final SessionQuestion question = generator.createQuestion(
        target: target,
        pool: vocabulary,
        random: random,
        isNew: true,
      );
      expect(
        question.choices,
        hasLength(4),
        reason: 'wrong option count for ${target.word}',
      );
      expect(question.correctIndex, inInclusiveRange(0, 3));
      expect(
        question.choices[question.correctIndex].translation,
        target.translation,
      );

      final List<String> translations = question.choices
          .map((AnswerChoice choice) => choice.translation.trim().toLowerCase())
          .toList();
      expect(
        translations.toSet(),
        hasLength(4),
        reason: 'duplicate options for ${target.word}',
      );
      expect(translations, contains(target.translation.toLowerCase()));
    }
  });

  test('option order is randomised (correct index is not constant)', () {
    final Set<int> seenCorrectIndexes = <int>{};
    for (int seed = 0; seed < 80; seed++) {
      final SessionQuestion question = generator.createQuestion(
        target: vocabulary.first,
        pool: vocabulary,
        random: Random(seed),
        isNew: true,
      );
      seenCorrectIndexes.add(question.correctIndex);
    }
    expect(seenCorrectIndexes.length, greaterThan(2));
  });

  test('distractors are plausible: same level and word class preferred', () {
    final Word target = customWord(id: 1, word: 'apple', translation: 'olma');
    final List<Word> pool = <Word>[
      target,
      for (int id = 2; id <= 6; id++)
        customWord(
          id: id,
          word: 'noun$id',
          translation: 'ot$id',
          level: 'A1',
          pos: PartOfSpeech.noun,
        ),
      for (int id = 20; id <= 23; id++)
        customWord(
          id: id,
          word: 'verb$id',
          translation: 'fel$id',
          level: 'A2',
          pos: PartOfSpeech.verb,
        ),
    ];
    final SessionQuestion question = generator.createQuestion(
      target: target,
      pool: pool,
      random: Random(1),
      isNew: false,
    );
    final List<String> options = question.choices
        .map((AnswerChoice choice) => choice.translation)
        .toList();
    expect(options, containsAll(<String>['ot2', 'ot3', 'ot4']));
    expect(options, isNot(contains('olma ')));
  });

  test('duplicate translations in the pool are never used twice', () {
    final Word target = customWord(id: 1, word: 'one', translation: 'bir');
    final List<Word> pool = <Word>[
      target,
      customWord(id: 2, word: 'two', translation: 'ikki'),
      customWord(id: 3, word: 'two-b', translation: 'ikki'),
      customWord(id: 4, word: 'three', translation: 'uch'),
      customWord(id: 5, word: 'four', translation: 'to‘rt'),
    ];
    final SessionQuestion question = generator.createQuestion(
      target: target,
      pool: pool,
      random: Random(3),
      isNew: true,
    );
    final List<String> options = question.choices
        .map((AnswerChoice choice) => choice.translation)
        .toList();
    expect(options.toSet(), hasLength(options.length));
    expect(options.length, 4);
  });

  test('pools that are too small still keep the correct answer', () {
    final Word target = customWord(id: 1, word: 'only', translation: 'yagona');
    final SessionQuestion question = generator.createQuestion(
      target: target,
      pool: <Word>[
        target,
        customWord(id: 2, word: 'x', translation: 'x'),
      ],
      random: Random(2),
      isNew: true,
    );
    expect(question.choices, hasLength(2));
    expect(question.choices[question.correctIndex].translation, 'yagona');
  });

  test('the same generator instance can create a whole question set', () {
    final List<SessionWord> words = <SessionWord>[
      for (int index = 0; index < 5; index++)
        SessionWord(word: vocabulary[index], isNew: true, isDue: false),
    ];
    final List<SessionQuestion> questions = generator.createQuestions(
      words: words,
      pool: vocabulary,
      random: Random(42),
    );
    expect(questions, hasLength(5));
    for (int index = 0; index < questions.length; index++) {
      expect(questions[index].word.id, words[index].word.id);
      expect(questions[index].isNew, isTrue);
      expect(questions[index].isRetry, isFalse);
    }
  });
}
