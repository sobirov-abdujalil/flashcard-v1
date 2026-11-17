import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  test('sqflite ffi is available for host tests', () async {
    sqfliteFfiInit();
    final Database db = await databaseFactoryFfi.openDatabase(
      inMemoryDatabasePath,
    );
    await db.execute('CREATE TABLE t (id INTEGER PRIMARY KEY)');
    await db.insert('t', <String, Object?>{'id': 1});
    final List<Map<String, Object?>> rows = await db.query('t');
    expect(rows, hasLength(1));
    await db.close();
  });
}
