import 'package:flutter/material.dart';
import 'cost_guard.dart';
import 'memory_database.dart';
import 'growth_analytics.dart';
import '../models/memory_entry.dart';

/// バッチ処理エンジン — API呼び出しをまとめてトークン消費最小化
/// 投稿ごとではなく、アプリ起動時 or 6時間間隔で一括処理
class BatchProcessor {
  /// アプリ起動時に呼ばれるバッチ処理
  static Future<BatchResult> runStartupBatch() async {
    if (!await CostGuard.shouldRunBatch()) {
      debugPrint('BatchProcessor: skipped (last run < 6h ago)');
      return const BatchResult(processed: 0, skipped: true);
    }

    debugPrint('BatchProcessor: running startup batch...');
    int processed = 0;

    // 1. 成長サマリー更新（月次）
    final now = DateTime.now();
    final summary = await GrowthAnalytics.generateMonthlySummary(now.year, now.month);
    if (summary != null) processed++;

    // 2. 創刊号チェック
    final shouldCreate = await GrowthAnalytics.shouldCreateEdition();
    if (shouldCreate) {
      await _createNewEdition();
      processed++;
    }

    // 3. 未処理の日記にAIイラストURL付与（バッチ）
    final unprocessed = await _getUnprocessedMemories();
    for (final memory in unprocessed) {
      // オンデバイス処理のみ（API呼び出しなし）
      // 将来: ここでGemini APIをバッチ呼び出し
      processed++;
    }

    await CostGuard.markBatchRun();
    debugPrint('BatchProcessor: completed, processed=$processed');
    return BatchResult(processed: processed, skipped: false);
  }

  /// 未処理の記憶を取得（AIイラストURLが未設定のもの）
  static Future<List<MemoryEntry>> _getUnprocessedMemories() async {
    final db = await MemoryDatabase.database;
    final maps = await db.query('memories',
      where: 'ai_illust_url IS NULL OR ai_illust_url = ?',
      whereArgs: [''],
      orderBy: 'date DESC',
      limit: 20, // バッチサイズ制限
    );
    return maps.map((m) => MemoryEntry.fromJson(m)).toList();
  }

  /// 創刊号の自動生成
  static Future<void> _createNewEdition() async {
    final db = await MemoryDatabase.database;

    // editionsテーブル確保
    await db.execute('''
      CREATE TABLE IF NOT EXISTS editions (
        id TEXT PRIMARY KEY,
        created_at TEXT NOT NULL,
        volume_number INTEGER NOT NULL,
        memory_ids TEXT NOT NULL,
        title TEXT NOT NULL,
        page_count INTEGER NOT NULL
      )
    ''');

    final editions = await db.query('editions', orderBy: 'volume_number DESC', limit: 1);
    final nextVolume = editions.isEmpty ? 1 : (editions.first['volume_number'] as int) + 1;

    // 直近30件を取得
    final offset = (nextVolume - 1) * 30;
    final memories = await db.query('memories',
      orderBy: 'date ASC', limit: 30, offset: offset);

    if (memories.length < 30) return;

    final memoryIds = memories.map((m) => m['id'] as String).toList();
    final firstDate = DateTime.parse(memories.first['date'] as String);
    final lastDate = DateTime.parse(memories.last['date'] as String);

    await db.insert('editions', {
      'id': 'edition_$nextVolume',
      'created_at': DateTime.now().toIso8601String(),
      'volume_number': nextVolume,
      'memory_ids': memoryIds.join(','),
      'title': '${firstDate.month}月〜${lastDate.month}月の冒険 第$nextVolume巻',
      'page_count': (memories.length / 4).ceil() + 2, // コンテンツ + 表紙 + 目次
    });

    debugPrint('BatchProcessor: created edition vol.$nextVolume');
  }
}

class BatchResult {
  final int processed;
  final bool skipped;
  const BatchResult({required this.processed, required this.skipped});
}
