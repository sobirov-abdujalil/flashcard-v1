import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:soz_atlas/data/database/app_database.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// Helper that opens a real SQLite database on the host through the FFI
/// factory, so repository and persistence behaviour can be tested for real.
class TestDatabaseHandle {
  TestDatabaseHandle._(this.database, this.directory, this.path);

  final AppDatabase database;
  final Directory directory;
  final String path;

  static bool _ffiInitialised = false;

  static void initFfi() {
    if (_ffiInitialised) return;
    sqfliteFfiInit();
    _ffiInitialised = true;
  }

  static Future<TestDatabaseHandle> create() async {
    initFfi();
    final Directory directory = await Directory.systemTemp.createTemp(
      'soz_atlas_test_',
    );
    final String path = p.join(directory.path, 'soz_atlas_test.db');
    final AppDatabase database = AppDatabase(
      databaseFactory: databaseFactoryFfi,
      path: path,
    );
    await database.database;
    return TestDatabaseHandle._(database, directory, path);
  }

  /// Reopens the same file with a brand new [AppDatabase] instance, simulating
  /// an app restart.
  static Future<AppDatabase> reopen(String path) async {
    initFfi();
    final AppDatabase database = AppDatabase(
      databaseFactory: databaseFactoryFfi,
      path: path,
    );
    await database.database;
    return database;
  }

  Future<void> dispose() async {
    await database.deleteDatabaseFile();
    if (directory.existsSync()) {
      await directory.delete(recursive: true);
    }
  }
}
