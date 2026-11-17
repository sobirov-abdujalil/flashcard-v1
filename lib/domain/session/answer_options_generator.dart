import 'dart:math';

import '../../data/models/word.dart';
import '../models/session_models.dart';

/// Creates recall questions with exactly one correct answer and plausible,
/// non-duplicated distractors.
class AnswerOptionsGenerator {
  const AnswerOptionsGenerator({this.optionCount = 4});

  final int optionCount;

  /// Builds a [SessionQuestion] for [target].
  ///
  /// Distractors are preferred from the same CEFR level and part of speech so
  /// the quiz feels honest, then from the same level, then anywhere in [pool].
  SessionQuestion createQuestion({
    required Word target,
    required List<Word> pool,
    required Random random,
    required bool isNew,
    bool isRetry = false,
  }) {
    final List<Word> sameLevelSamePos = <Word>[];
    final List<Word> sameLevel = <Word>[];
    final List<Word> other = <Word>[];
    final Set<String> seenTranslations = <String>{target.normalizedTranslation};

    for (final Word candidate in pool) {
      if (candidate.id == target.id) continue;
      final String normalized = candidate.normalizedTranslation;
      if (seenTranslations.contains(normalized)) continue;
      seenTranslations.add(normalized);
      if (candidate.cefrLevel == target.cefrLevel &&
          candidate.partOfSpeech == target.partOfSpeech) {
        sameLevelSamePos.add(candidate);
      } else if (candidate.cefrLevel == target.cefrLevel) {
        sameLevel.add(candidate);
      } else {
        other.add(candidate);
      }
    }

    sameLevelSamePos.shuffle(random);
    sameLevel.shuffle(random);
    other.shuffle(random);

    final List<String> translations = <String>[
      target.translation,
      for (final Word word in <Word>[
        ...sameLevelSamePos,
        ...sameLevel,
        ...other,
      ].take(optionCount - 1))
        word.translation,
    ];

    translations.shuffle(random);
    final int correctIndex = translations.indexOf(target.translation);

    return SessionQuestion(
      word: target,
      choices: List<AnswerChoice>.unmodifiable(
        translations.map(
          (String translation) => AnswerChoice(translation: translation),
        ),
      ),
      correctIndex: correctIndex,
      isNew: isNew,
      isRetry: isRetry,
    );
  }

  /// Builds one question per session word, in order.
  List<SessionQuestion> createQuestions({
    required List<SessionWord> words,
    required List<Word> pool,
    required Random random,
  }) {
    return List<SessionQuestion>.unmodifiable(
      words.map(
        (SessionWord entry) => createQuestion(
          target: entry.word,
          pool: pool,
          random: random,
          isNew: entry.isNew,
        ),
      ),
    );
  }
}
