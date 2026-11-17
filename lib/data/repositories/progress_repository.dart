import 'package:sqflite/sqflite.dart';

import '../database/app_database.dart';
import '../database/study_day_dao.dart';
import '../models/study_day.dart';
import '../models/word_progress.dart';

/// Persists and reads per-word spaced repetition state.
class ProgressRepository {
  ProgressRepository(this._database);

  final AppDatabase _database;

  Future<WordProgress?> progressFor(int wordId) async {
    final Database db = await _database.database;
    final List<Map<String, Object?>> rows = await db.query(
      'word_progress',
      where: 'word_id = ?',
      whereArgs: <Object?>[wordId],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return WordProgress.fromMap(rows.first);
  }

  Future<Map<int, WordProgress>> allProgress() async {
    final Database db = await _database.database;
    final List<Map<String, Object?>> rows = await db.query('word_progress');
    final Map<int, WordProgress> result = <int, WordProgress>{};
    for (final Map<String, Object?> row in rows) {
      final WordProgress progress = WordProgress.fromMap(row);
      result[progress.wordId] = progress;
    }
    return result;
  }

  Future<int> dueReviewCount(DateTime now) async {
    final Database db = await _database.database;
    return Sqflite.firstIntValue(
          await db.rawQuery(
            'SELECT COUNT(*) FROM word_progress WHERE next_review_at <= ?',
            <Object?>[now.millisecondsSinceEpoch],
          ),
        ) ??
        0;
  }

  Future<int> totalWordsStudied() async {
    final Database db = await _database.database;
    return Sqflite.firstIntValue(
          await db.rawQuery('SELECT COUNT(*) FROM word_progress'),
        ) ??
        0;
  }

  Future<int> rememberedWords() async {
    final Database db = await _database.database;
    return Sqflite.firstIntValue(
          await db.rawQuery(
            'SELECT COUNT(*) FROM word_progress WHERE successful_repetitions >= 1',
          ),
        ) ??
        0;
  }

  Future<StudyDay?> studyDay(String dateKey) async {
    final Database db = await _database.database;
    return StudyDayDao.read(db, dateKey);
  }

  Future<Map<String, StudyDay>> studyDaysBetween({
    required String startKey,
    required String endKey,
  }) async {
    final Database db = await _database.database;
    final List<Map<String, Object?>> rows = await db.query(
      'study_days',
      where: 'local_date >= ? AND local_date <= ?',
      whereArgs: <Object?>[startKey, endKey],
    );
    final Map<String, StudyDay> result = <String, StudyDay>{};
    for (final Map<String, Object?> row in rows) {
      final StudyDay day = StudyDay.fromMap(row);
      result[day.localDate] = day;
    }
    return result;
  }

  Future<List<String>> completedSessionDateKeys({int limit = 400}) async {
    final Database db = await _database.database;
    final List<Map<String, Object?>> rows = await db.query(
      'study_days',
      columns: <String>['local_date'],
      where: 'session_completed = 1',
      orderBy: 'local_date DESC',
      limit: limit,
    );
    return rows
        .map((Map<String, Object?> row) => row['local_date'] as String)
        .toList(growable: false);
  }

  Future<void> resetLearningProgress() => _database.resetLearningProgress();
}
