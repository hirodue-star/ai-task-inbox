import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import '../models/thought_record.dart';
import '../models/hlc_score.dart';

/// 思考資産データベース — 過去の入力を永続化し再利用
class ThoughtDatabase {
  static Database? _db;

  static Future<Database> get database async {
    _db ??= await _initDb();
    return _db!;
  }

  static Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    return openDatabase(
      p.join(dbPath, 'ma_logic_thoughts.db'),
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE thoughts (
            id TEXT PRIMARY KEY,
            created_at TEXT NOT NULL,
            category TEXT NOT NULL,
            question TEXT NOT NULL,
            answer TEXT NOT NULL,
            mandala_cell INTEGER NOT NULL,
            parent_note TEXT
          )
        ''');
        await db.execute('''
          CREATE TABLE hlc_scores (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            hospitality INTEGER NOT NULL DEFAULT 0,
            logic INTEGER NOT NULL DEFAULT 0,
            creativity INTEGER NOT NULL DEFAULT 0,
            updated_at TEXT NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE help_records (
            id TEXT PRIMARY KEY,
            category TEXT NOT NULL,
            completed_at TEXT NOT NULL,
            approved_by TEXT,
            approved_at TEXT
          )
        ''');
      },
    );
  }

  // === 思考資産 CRUD ===

  static Future<void> insertThought(ThoughtRecord record) async {
    final db = await database;
    await db.insert('thoughts', record.toJson(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static Future<List<ThoughtRecord>> getThoughtsByCategory(ThoughtCategory category) async {
    final db = await database;
    final maps = await db.query(
      'thoughts',
      where: 'category = ?',
      whereArgs: [category.name],
      orderBy: 'created_at DESC',
    );
    return maps.map((m) => ThoughtRecord.fromJson(m)).toList();
  }

  static Future<List<ThoughtRecord>> getThoughtsByCell(int cellIndex) async {
    final db = await database;
    final maps = await db.query(
      'thoughts',
      where: 'mandala_cell = ?',
      whereArgs: [cellIndex],
      orderBy: 'created_at DESC',
    );
    return maps.map((m) => ThoughtRecord.fromJson(m)).toList();
  }

  static Future<List<ThoughtRecord>> getAllThoughts() async {
    final db = await database;
    final maps = await db.query('thoughts', orderBy: 'created_at DESC');
    return maps.map((m) => ThoughtRecord.fromJson(m)).toList();
  }

  /// レベルアップ時：過去の思考を基にした問いかけを生成
  static Future<String> generateLevelUpQuestion(ThoughtCategory category) async {
    final pastRecords = await getThoughtsByCategory(category);
    return category.levelUpQuestion(pastRecords);
  }

  // === HLCスコア ===

  static Future<void> saveScore(HlcScore score) async {
    final db = await database;
    await db.insert('hlc_scores', {
      ...score.toJson(),
      'updated_at': DateTime.now().toIso8601String(),
    });
  }

  static Future<HlcScore> getLatestScore() async {
    final db = await database;
    final maps = await db.query('hlc_scores', orderBy: 'id DESC', limit: 1);
    if (maps.isEmpty) return const HlcScore();
    return HlcScore.fromJson(maps.first);
  }

  // === お手伝い記録 ===

  static Future<void> recordHelp(String id, String category) async {
    final db = await database;
    await db.insert('help_records', {
      'id': id,
      'category': category,
      'completed_at': DateTime.now().toIso8601String(),
    });
  }

  static Future<void> approveHelp(String id, String approvedBy) async {
    final db = await database;
    await db.update(
      'help_records',
      {
        'approved_by': approvedBy,
        'approved_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  static Future<int> getCompletedHelpCount() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM help_records');
    return result.first['count'] as int;
  }
}
