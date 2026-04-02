import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import '../models/memory_entry.dart';

/// 記憶の宮殿DB — 日常の記憶を日付順に永続化
class MemoryDatabase {
  static Database? _db;

  static Future<Database> get database async {
    _db ??= await _initDb();
    return _db!;
  }

  static Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    return openDatabase(
      p.join(dbPath, 'ma_logic_memories.db'),
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE memories (
            id TEXT PRIMARY KEY,
            date TEXT NOT NULL,
            stamp TEXT NOT NULL,
            text TEXT NOT NULL,
            photo_path TEXT,
            ai_illust_url TEXT,
            is_challenge INTEGER NOT NULL DEFAULT 0
          )
        ''');
        await db.execute('CREATE INDEX idx_memories_date ON memories(date)');
      },
    );
  }

  /// 記憶を保存
  static Future<void> insert(MemoryEntry entry) async {
    final db = await database;
    await db.insert('memories', entry.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  /// 今日の記憶一覧
  static Future<List<MemoryEntry>> getToday() async {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day).toIso8601String();
    final end = DateTime(now.year, now.month, now.day + 1).toIso8601String();
    return _query(where: 'date >= ? AND date < ?', whereArgs: [start, end]);
  }

  /// 昨日の記憶一覧（タイムトラベル用）
  static Future<List<MemoryEntry>> getYesterday() async {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day - 1).toIso8601String();
    final end = DateTime(now.year, now.month, now.day).toIso8601String();
    return _query(where: 'date >= ? AND date < ?', whereArgs: [start, end]);
  }

  /// 全ての挑戦記録（黄金粒子の永続源）
  static Future<List<MemoryEntry>> getAllChallenges() async {
    return _query(where: 'is_challenge = 1');
  }

  /// 日付指定で取得
  static Future<List<MemoryEntry>> getByDate(DateTime date) async {
    final start = DateTime(date.year, date.month, date.day).toIso8601String();
    final end = DateTime(date.year, date.month, date.day + 1).toIso8601String();
    return _query(where: 'date >= ? AND date < ?', whereArgs: [start, end]);
  }

  /// 全記憶数
  static Future<int> getTotalCount() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) as c FROM memories');
    return result.first['c'] as int;
  }

  /// 挑戦数（黄金粒子の累計）
  static Future<int> getChallengeCount() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) as c FROM memories WHERE is_challenge = 1');
    return result.first['c'] as int;
  }

  static Future<List<MemoryEntry>> _query({
    String? where,
    List<Object?>? whereArgs,
  }) async {
    final db = await database;
    final maps = await db.query('memories',
        where: where, whereArgs: whereArgs, orderBy: 'date DESC');
    return maps.map((m) => MemoryEntry.fromJson(m)).toList();
  }
}
