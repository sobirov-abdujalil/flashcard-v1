import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import '../models/word.dart';
import '../seed/seed_vocabulary.dart';

/// Owns the local SQLite database: schema creation, migrations and one-time
/// vocabulary seeding.
///
/// The class is deliberately injectable ([databaseFactory], [path]) so the data
/// layer can be exercised by host-side unit tests with the FFI implementation.
class AppDatabase {
  AppDatabase({DatabaseFactory? databaseFactory, String? path})
    : _factory = databaseFactory ?? sqfliteDatabaseFactory,
      _customPath = path;

  static const String fileName = 'soz_atlas.db';
  static const int schemaVersion = 1;

  final DatabaseFactory _factory;
  final String? _customPath;

  Future<Database>? _databaseFuture;
  bool _closed = false;

  /// Opens (and caches) the database. Safe to call many times.
  Future<Database> get database => _databaseFuture ??= _open();

  Future<String> resolvePath() async {
    final String? custom = _customPath;
    if (custom != null) return custom;
    return p.join(await _factory.getDatabasesPath(), fileName);
  }

  Future<Database> _open() async {
    if (_closed) {
      throw StateError('AppDatabase has been closed and cannot be reopened.');
    }
    final String path = await resolvePath();
    final Database db = await _factory.openDatabase(
      path,
      options: OpenDatabaseOptions(
        version: schemaVersion,
        onConfigure: (Database db) async {
          await db.execute('PRAGMA foreign_keys = ON');
        },
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
        onOpen: (Database db) async {
          // Self-heal: if the vocabulary table was somehow emptied, seed it
          // again. Existing user progress is never touched by seeding.
          await _seedVocabularyIfNeeded(db);
        },
      ),
    );
    return db;
  }

  Future<void> _onCreate(Database db, int version) async {
    final Batch batch = db.batch();
    batch.execute('''
      CREATE TABLE words (
        id INTEGER PRIMARY KEY,
        word TEXT NOT NULL,
        phonetic TEXT NOT NULL,
        part_of_speech TEXT NOT NULL,
        cefr_level TEXT NOT NULL,
        translation TEXT NOT NULL,
        definition TEXT NOT NULL,
        example TEXT NOT NULL,
        example_translation TEXT NOT NULL
      )
    ''');
    batch.execute('''
      CREATE TABLE word_progress (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        word_id INTEGER NOT NULL UNIQUE REFERENCES words(id) ON DELETE CASCADE,
        last_review_at INTEGER NOT NULL,
        next_review_at INTEGER NOT NULL,
        successful_repetitions INTEGER NOT NULL DEFAULT 0,
        lapse_count INTEGER NOT NULL DEFAULT 0,
        total_correct INTEGER NOT NULL DEFAULT 0,
        total_attempts INTEGER NOT NULL DEFAULT 0
      )
    ''');
    batch.execute('''
      CREATE TABLE study_days (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        local_date TEXT NOT NULL UNIQUE,
        completed_exercises INTEGER NOT NULL DEFAULT 0,
        correct_answers INTEGER NOT NULL DEFAULT 0,
        new_words_studied INTEGER NOT NULL DEFAULT 0,
        session_completed INTEGER NOT NULL DEFAULT 0
      )
    ''');
    batch.execute('''
      CREATE UNIQUE INDEX idx_words_word_normalized
        ON words(word COLLATE NOCASE)
    ''');
    batch.execute('CREATE INDEX idx_words_level ON words(cefr_level)');
    batch.execute(
      'CREATE INDEX idx_progress_due ON word_progress(next_review_at)',
    );
    batch.execute('CREATE INDEX idx_study_days_date ON study_days(local_date)');
    await batch.commit(noResult: true);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Schema version 1 is the initial release. Future migrations must be added
    // here with explicit, ordered steps so user progress is never dropped.
    // Example:
    // if (oldVersion < 2) {
    //   await db.execute('ALTER TABLE words ADD COLUMN audio_url TEXT');
    // }
  }

  Future<void> _seedVocabularyIfNeeded(Database db) async {
    final int count =
        Sqflite.firstIntValue(
          await db.rawQuery('SELECT COUNT(*) FROM words'),
        ) ??
        0;
    if (count > 0) return;

    final List<Word> words = buildSeedVocabulary();
    assert(() {
      validateSeedVocabulary(words);
      return true;
    }());

    await db.transaction((Transaction txn) async {
      final Batch batch = txn.batch();
      for (final Word word in words) {
        batch.insert('words', word.toMap());
      }
      await batch.commit(noResult: true);
    });
  }

  /// Removes learning progress while keeping the bundled vocabulary intact.
  Future<void> resetLearningProgress() async {
    final Database db = await database;
    await db.transaction((Transaction txn) async {
      await txn.delete('word_progress');
      await txn.delete('study_days');
    });
  }

  Future<int> vocabularyCount() async {
    final Database db = await database;
    return Sqflite.firstIntValue(
          await db.rawQuery('SELECT COUNT(*) FROM words'),
        ) ??
        0;
  }

  /// Closes the database. Only used on app shutdown and in tests.
  Future<void> close() async {
    _closed = true;
    final Future<Database>? future = _databaseFuture;
    _databaseFuture = null;
    if (future == null) return;
    try {
      final Database db = await future;
      await db.close();
    } catch (_) {
      // The database may never have been opened successfully.
    }
  }

  /// Deletes the database file. Used by tests only.
  Future<void> deleteDatabaseFile() async {
    await close();
    try {
      await _factory.deleteDatabase(await resolvePath());
    } catch (_) {
      // Nothing to delete.
    }
  }
}

/// The default sqflite factory, isolated so tests can inject an FFI factory.
final DatabaseFactory sqfliteDatabaseFactory = databaseFactory;
