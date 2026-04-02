import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import '../models/memory_entry.dart';

/// 日記DB（MVP: SQLiteのみ、Firebase同期は後で追加）
class MemoryDatabase {
  static Database? _db;

  static Future<Database> get database async {
    _db ??= await _initDb();
    return _db!;
  }

  static Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    return openDatabase(
      p.join(dbPath, 'ma_logic.db'),
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE memories (
            id TEXT PRIMARY KEY,
            date TEXT NOT NULL,
            stamp TEXT NOT NULL,
            text TEXT NOT NULL,
            photo_path TEXT
          )
        ''');
      },
    );
  }

  static Future<void> insert(MemoryEntry entry) async {
    final db = await database;
    await db.insert('memories', entry.toJson(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static Future<List<MemoryEntry>> getAll() async {
    final db = await database;
    final maps = await db.query('memories', orderBy: 'date DESC');
    return maps.map((m) => MemoryEntry.fromJson(m)).toList();
  }

  static Future<int> getCount() async {
    final db = await database;
    final r = await db.rawQuery('SELECT COUNT(*) as c FROM memories');
    return r.first['c'] as int;
  }
}
