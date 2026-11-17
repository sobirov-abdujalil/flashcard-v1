import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';

import '../database/app_database.dart';
import '../models/word.dart';

/// Read access to the bundled vocabulary.
class VocabularyRepository {
  VocabularyRepository(this._database);

  final AppDatabase _database;

  Future<List<Word>> allWords() async {
    final Database db = await _database.database;
    final List<Map<String, Object?>> rows = await db.query(
      'words',
      orderBy: 'id ASC',
    );
    return rows.map(Word.fromMap).toList(growable: false);
  }

  /// Words whose `next_review_at` is at or before [now], oldest due first.
  Future<List<Word>> dueWords({
    required DateTime now,
    required int limit,
  }) async {
    if (limit <= 0) return const <Word>[];
    final Database db = await _database.database;
    final List<Map<String, Object?>> rows = await db.rawQuery(
      '''
      SELECT w.id, w.word, w.phonetic, w.part_of_speech, w.cefr_level,
             w.translation, w.definition, w.example, w.example_translation
      FROM word_progress p
      INNER JOIN words w ON w.id = p.word_id
      WHERE p.next_review_at <= ?
      ORDER BY p.next_review_at ASC, p.word_id ASC
      LIMIT ?
      ''',
      <Object?>[now.millisecondsSinceEpoch, limit],
    );
    return rows.map(Word.fromMap).toList(growable: false);
  }

  /// Words that have never been answered, A1 before A2.
  Future<List<Word>> newWords({required int limit}) async {
    if (limit <= 0) return const <Word>[];
    final Database db = await _database.database;
    final List<Map<String, Object?>> rows = await db.rawQuery(
      '''
      SELECT w.id, w.word, w.phonetic, w.part_of_speech, w.cefr_level,
             w.translation, w.definition, w.example, w.example_translation
      FROM words w
      LEFT JOIN word_progress p ON p.word_id = w.id
      WHERE p.word_id IS NULL
      ORDER BY CASE w.cefr_level WHEN 'A1' THEN 0 ELSE 1 END ASC, w.id ASC
      LIMIT ?
      ''',
      <Object?>[limit],
    );
    return rows.map(Word.fromMap).toList(growable: false);
  }

  /// Least recently reviewed words, used only when no due or new words remain.
  Future<List<Word>> leastRecentlyReviewed({required int limit}) async {
    if (limit <= 0) return const <Word>[];
    final Database db = await _database.database;
    final List<Map<String, Object?>> rows = await db.rawQuery(
      '''
      SELECT w.id, w.word, w.phonetic, w.part_of_speech, w.cefr_level,
             w.translation, w.definition, w.example, w.example_translation
      FROM word_progress p
      INNER JOIN words w ON w.id = p.word_id
      ORDER BY p.last_review_at ASC, p.word_id ASC
      LIMIT ?
      ''',
      <Object?>[limit],
    );
    return rows.map(Word.fromMap).toList(growable: false);
  }

  Future<int> count() async => _database.vocabularyCount();

  /// Used only by debugging helpers and tests.
  @visibleForTesting
  Future<List<int>> allWordIds() async {
    final Database db = await _database.database;
    final List<Map<String, Object?>> rows = await db.query(
      'words',
      columns: <String>['id'],
      orderBy: 'id ASC',
    );
    return rows.map((Map<String, Object?> row) => row['id'] as int).toList();
  }
}
