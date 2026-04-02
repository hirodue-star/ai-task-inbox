import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import '../models/bond_post.dart';

/// BOND-LOGローカルDB（Firebase同期前のオフラインストア）
class BondDatabase {
  static Database? _db;

  static Future<Database> get database async {
    _db ??= await _initDb();
    return _db!;
  }

  static Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    return openDatabase(
      p.join(dbPath, 'ma_logic_bond.db'),
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE posts (
            id TEXT PRIMARY KEY,
            author_id TEXT NOT NULL,
            author_name TEXT NOT NULL,
            author_role TEXT NOT NULL,
            created_at TEXT NOT NULL,
            stamp TEXT NOT NULL,
            text TEXT NOT NULL,
            photo_path TEXT,
            ai_illust_url TEXT,
            is_challenge INTEGER NOT NULL DEFAULT 0,
            is_mission INTEGER NOT NULL DEFAULT 0,
            parent_approved INTEGER NOT NULL DEFAULT 0,
            approved_at TEXT,
            like_count INTEGER NOT NULL DEFAULT 0,
            liked_by TEXT DEFAULT '',
            mission_tag TEXT
          )
        ''');
        await db.execute('CREATE INDEX idx_posts_date ON posts(created_at)');
      },
    );
  }

  static Future<void> insert(BondPost post) async {
    final db = await database;
    await db.insert('posts', post.toJson(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  /// タイムライン取得（新しい順）
  static Future<List<BondPost>> getFeed({int limit = 50}) async {
    final db = await database;
    final maps = await db.query('posts', orderBy: 'created_at DESC', limit: limit);
    return maps.map((m) => BondPost.fromJson(m)).toList();
  }

  /// 親が承認
  static Future<void> approve(String postId) async {
    final db = await database;
    await db.update('posts', {
      'parent_approved': 1,
      'approved_at': DateTime.now().toIso8601String(),
    }, where: 'id = ?', whereArgs: [postId]);
  }

  /// いいね
  static Future<void> like(String postId, String userId) async {
    final db = await database;
    final maps = await db.query('posts', where: 'id = ?', whereArgs: [postId]);
    if (maps.isEmpty) return;
    final post = BondPost.fromJson(maps.first);
    if (post.likedBy.contains(userId)) return;
    final newLiked = [...post.likedBy, userId];
    await db.update('posts', {
      'like_count': post.likeCount + 1,
      'liked_by': newLiked.join(','),
    }, where: 'id = ?', whereArgs: [postId]);
  }

  /// 未承認のミッション投稿
  static Future<List<BondPost>> getPendingMissions() async {
    final db = await database;
    final maps = await db.query('posts',
        where: 'is_mission = 1 AND parent_approved = 0',
        orderBy: 'created_at DESC');
    return maps.map((m) => BondPost.fromJson(m)).toList();
  }

  /// 今日の投稿数
  static Future<int> getTodayPostCount() async {
    final db = await database;
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day).toIso8601String();
    final result = await db.rawQuery(
        'SELECT COUNT(*) as c FROM posts WHERE created_at >= ?', [start]);
    return result.first['c'] as int;
  }
}
