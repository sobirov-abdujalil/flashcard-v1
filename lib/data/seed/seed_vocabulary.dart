import '../models/word.dart';
import 'a1_words.dart';
import 'a2_words.dart';

/// The complete bundled vocabulary: 50 A1 words and 50 A2 words.
///
/// This list is only ever inserted into the database when the `words` table is
/// empty, so user progress can never be wiped by a reseed.
List<Word> buildSeedVocabulary() =>
    List<Word>.unmodifiable(<Word>[...a1Words, ...a2Words]);

/// Validates the bundled dataset. Throws [StateError] with a descriptive
/// message when content rules are broken; used by the seeder (debug builds)
/// and by unit tests.
void validateSeedVocabulary(List<Word> words) {
  final List<String> problems = <String>[];
  final Set<int> ids = <int>{};
  final Set<String> normalizedWords = <String>{};
  final Set<String> normalizedTranslations = <String>{};

  for (final Word word in words) {
    if (!ids.add(word.id)) {
      problems.add('Duplicate id ${word.id} (${word.word})');
    }
    if (!normalizedWords.add(word.normalizedWord)) {
      problems.add('Duplicate word "${word.word}"');
    }
    if (!normalizedTranslations.add(word.normalizedTranslation)) {
      problems.add('Duplicate Uzbek translation "${word.translation}"');
    }
    void requireText(String field, String value) {
      if (value.trim().isEmpty) {
        problems.add('Empty $field for "${word.word}"');
      }
    }

    requireText('word', word.word);
    requireText('phonetic', word.phonetic);
    requireText('part of speech', word.partOfSpeech);
    requireText('cefr level', word.cefrLevel);
    requireText('translation', word.translation);
    requireText('definition', word.definition);
    requireText('example', word.example);
    requireText('example translation', word.exampleTranslation);

    if (word.cefrLevel != 'A1' && word.cefrLevel != 'A2') {
      problems.add(
        'Unexpected CEFR level "${word.cefrLevel}" for ${word.word}',
      );
    }
    if (!word.phonetic.startsWith('/') || !word.phonetic.endsWith('/')) {
      problems.add('Phonetic for "${word.word}" is not wrapped in /slashes/');
    }
    if (word.exampleTranslation == word.example) {
      problems.add('Example translation for "${word.word}" matches English');
    }
  }

  if (words.isEmpty) {
    problems.add('Seed vocabulary is empty');
  }
  final int a1Count = words.where((Word w) => w.cefrLevel == 'A1').length;
  final int a2Count = words.where((Word w) => w.cefrLevel == 'A2').length;
  if (a1Count != 50) problems.add('Expected 50 A1 words, found $a1Count');
  if (a2Count != 50) problems.add('Expected 50 A2 words, found $a2Count');

  if (problems.isNotEmpty) {
    throw StateError(
      'Seed vocabulary validation failed:\n${problems.join('\n')}',
    );
  }
}
