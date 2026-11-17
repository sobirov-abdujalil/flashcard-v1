import '../../data/models/word.dart';
import '../models/session_models.dart';

/// Builds the ordered word list for a session.
///
/// Priority rules from the product definition:
/// 1. Words whose review date has passed, oldest due date first.
/// 2. New words that have never been studied (A1 before A2).
/// 3. As a final fallback (e.g. everything reviewed recently and no new words
///    left), the least recently reviewed words so practice is always possible.
///
/// The result never exceeds [size] and never contains duplicate words.
abstract final class SessionComposer {
  static List<SessionWord> compose({
    required List<Word> dueWords,
    required List<Word> newWords,
    required List<Word> fallbackWords,
    required int size,
  }) {
    if (size <= 0) return const <SessionWord>[];

    final List<SessionWord> result = <SessionWord>[];
    final Set<int> usedIds = <int>{};

    void addFrom(
      List<Word> source, {
      required bool isNew,
      required bool isDue,
    }) {
      for (final Word word in source) {
        if (result.length >= size) return;
        if (!usedIds.add(word.id)) continue;
        result.add(SessionWord(word: word, isNew: isNew, isDue: isDue));
      }
    }

    addFrom(dueWords, isNew: false, isDue: true);
    addFrom(newWords, isNew: true, isDue: false);
    addFrom(fallbackWords, isNew: false, isDue: false);

    return List<SessionWord>.unmodifiable(result);
  }
}
