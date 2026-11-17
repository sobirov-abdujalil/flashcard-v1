import 'package:flutter_test/flutter_test.dart';
import 'package:soz_atlas/core/constants/part_of_speech.dart';
import 'package:soz_atlas/data/models/word.dart';
import 'package:soz_atlas/data/seed/a1_words.dart';
import 'package:soz_atlas/data/seed/seed_vocabulary.dart';

void main() {
  final List<Word> vocabulary = buildSeedVocabulary();

  group('bundled vocabulary', () {
    test('contains exactly 100 words: 50 A1 and 50 A2', () {
      expect(vocabulary, hasLength(100));
      final int a1Count = vocabulary
          .where((Word word) => word.cefrLevel == 'A1')
          .length;
      final int a2Count = vocabulary
          .where((Word word) => word.cefrLevel == 'A2')
          .length;
      expect(a1Count, 50);
      expect(a2Count, 50);
      expect(a1Words, hasLength(50));
    });

    test('passes the full content validation rules', () {
      // Throws StateError with details when anything is wrong.
      expect(
        () => validateSeedVocabulary(buildSeedVocabulary()),
        returnsNormally,
      );
    });

    test('has unique ids, words and Uzbek translations', () {
      final List<int> ids = vocabulary.map((Word word) => word.id).toList();
      final List<String> words = vocabulary
          .map((Word word) => word.word.toLowerCase())
          .toList();
      final List<String> translations = vocabulary
          .map((Word word) => word.translation.toLowerCase())
          .toList();
      expect(ids.toSet(), hasLength(100));
      expect(words.toSet(), hasLength(100));
      expect(translations.toSet(), hasLength(100));
    });

    test('every field is non-empty and meaningful', () {
      for (final Word word in vocabulary) {
        expect(word.word.trim(), isNotEmpty);
        expect(word.phonetic.trim(), isNotEmpty);
        expect(word.translation.trim(), isNotEmpty);
        expect(word.definition.trim(), isNotEmpty);
        expect(word.example.trim(), isNotEmpty);
        expect(word.exampleTranslation.trim(), isNotEmpty);
        expect(word.example, isNot(equals(word.exampleTranslation)));
        expect(word.phonetic, startsWith('/'));
        expect(word.phonetic, endsWith('/'));
        expect(<String>[
          PartOfSpeech.noun,
          PartOfSpeech.verb,
          PartOfSpeech.adjective,
          PartOfSpeech.adverb,
          PartOfSpeech.preposition,
          PartOfSpeech.conjunction,
          PartOfSpeech.pronoun,
          PartOfSpeech.interjection,
        ], contains(word.partOfSpeech));
      }
    });

    test('Uzbek translations use consistent apostrophes', () {
      for (final Word word in vocabulary) {
        expect(
          word.translation.contains('ʻ') || word.translation.contains('’'),
          isFalse,
          reason:
              'Use the ‘ character for Uzbek letters in "${word.word}" '
              '(${word.translation})',
        );
      }
    });

    test('English examples look like real sentences', () {
      for (final Word word in vocabulary) {
        final String example = word.example;
        expect(example.trim().length, greaterThan(10));
        expect(
          example.trim().endsWith('.') ||
              example.trim().endsWith('?') ||
              example.trim().endsWith('!'),
          isTrue,
        );
        expect(word.exampleTranslation.trim().length, greaterThan(5));
      }
    });

    test('A1 words come before A2 words by id', () {
      final List<int> a1Ids = a1Words.map((Word word) => word.id).toList();
      expect(a1Ids.first, 1);
      expect(a1Ids.last, 50);
      expect(a1Ids, orderedEquals(List<int>.generate(50, (int i) => i + 1)));
    });

    test('validation catches bad content', () {
      final List<Word> broken = <Word>[
        ...vocabulary.take(99),
        vocabulary.first,
      ];
      expect(() => validateSeedVocabulary(broken), throwsStateError);
    });
  });
}
