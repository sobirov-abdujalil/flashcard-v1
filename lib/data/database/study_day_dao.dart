import 'package:sqflite/sqflite.dart';

import '../models/study_day.dart';

/// Small helper shared by repositories that update the `study_days` aggregate
/// table inside an existing transaction.
abstract final class StudyDayDao {
  static Future<StudyDay?> read(
    DatabaseExecutor executor,
    String dateKey,
  ) async {
    final List<Map<String, Object?>> rows = await executor.query(
      'study_days',
      where: 'local_date = ?',
      whereArgs: <Object?>[dateKey],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return StudyDay.fromMap(rows.first);
  }

  /// Adds activity to a day, creating the row when it does not exist yet.
  static Future<StudyDay> increment(
    DatabaseExecutor executor, {
    required String dateKey,
    int exercises = 0,
    int correctAnswers = 0,
    int newWords = 0,
    bool? sessionCompleted,
  }) async {
    final StudyDay? existing = await read(executor, dateKey);
    if (existing == null) {
      final StudyDay created = StudyDay(
        localDate: dateKey,
        completedExercises: exercises,
        correctAnswers: correctAnswers,
        newWordsStudied: newWords,
        sessionCompleted: sessionCompleted ?? false,
      );
      await executor.insert('study_days', created.toMap());
      return created;
    }
    final StudyDay updated = existing.copyWith(
      completedExercises: existing.completedExercises + exercises,
      correctAnswers: existing.correctAnswers + correctAnswers,
      newWordsStudied: existing.newWordsStudied + newWords,
      sessionCompleted: sessionCompleted == null
          ? null
          : (existing.sessionCompleted || sessionCompleted),
    );
    await executor.update(
      'study_days',
      updated.toMap(),
      where: 'local_date = ?',
      whereArgs: <Object?>[dateKey],
    );
    return updated;
  }

  static Future<void> markSessionCompleted(
    DatabaseExecutor executor,
    String dateKey,
  ) async {
    final StudyDay? existing = await read(executor, dateKey);
    if (existing == null) {
      // A session with zero exercises must never create a "completed" day.
      return;
    }
    if (existing.sessionCompleted) return;
    await executor.update(
      'study_days',
      <String, Object?>{'session_completed': 1},
      where: 'local_date = ?',
      whereArgs: <Object?>[dateKey],
    );
  }
}
