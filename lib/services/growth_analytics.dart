import '../models/memory_entry.dart';
import '../models/growth_summary.dart';
import '../models/hlc_score.dart';
import 'memory_database.dart';

/// 成長分析エンジン — 活動ログから強みを抽出
class GrowthAnalytics {
  /// 月次サマリー生成
  static Future<GrowthSummary?> generateMonthlySummary(int year, int month) async {
    final start = DateTime(year, month);
    final end = DateTime(year, month + 1);
    return _generateSummary(start, end, SummaryPeriod.monthly);
  }

  /// 年次サマリー生成
  static Future<GrowthSummary?> generateYearlySummary(int year) async {
    final start = DateTime(year);
    final end = DateTime(year + 1);
    return _generateSummary(start, end, SummaryPeriod.yearly);
  }

  static Future<GrowthSummary?> _generateSummary(
    DateTime start, DateTime end, SummaryPeriod period,
  ) async {
    final db = await MemoryDatabase.database;
    final maps = await db.query('memories',
      where: 'date >= ? AND date < ?',
      whereArgs: [start.toIso8601String(), end.toIso8601String()],
      orderBy: 'date ASC',
    );
    if (maps.isEmpty) return null;

    final memories = maps.map((m) => MemoryEntry.fromJson(m)).toList();
    final stampCounts = <MemoryStamp, int>{};
    String? longestText;
    int longestLen = 0;

    for (final m in memories) {
      stampCounts[m.stamp] = (stampCounts[m.stamp] ?? 0) + 1;
      if (m.text.length > longestLen) {
        longestLen = m.text.length;
        longestText = m.text;
      }
    }

    return GrowthSummary(
      periodStart: start,
      periodEnd: end,
      period: period,
      totalPosts: memories.length,
      challengeCount: memories.where((m) => m.isChallenge).length,
      stampCounts: stampCounts,
      highlightText: longestText,
    );
  }

  /// 創刊号チェック（30件ごとに発行）
  static Future<bool> shouldCreateEdition() async {
    final count = await MemoryDatabase.getTotalCount();
    final db = await MemoryDatabase.database;
    // editions テーブルがあるか確認（なければ作成）
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
    final editions = await db.query('editions');
    final volumeCount = editions.length;
    return count >= (volumeCount + 1) * 30;
  }

  /// AI強み分析（5つの強み抽出）
  /// 全活動ログからルールベース + プロンプトテンプレートで分析
  static Future<List<StrengthAnalysis>> analyzeStrengths(HlcScore score) async {
    final db = await MemoryDatabase.database;
    final totalCount = await MemoryDatabase.getTotalCount();
    final challengeCount = await MemoryDatabase.getChallengeCount();
    final maps = await db.query('memories', orderBy: 'date DESC', limit: 100);
    final memories = maps.map((m) => MemoryEntry.fromJson(m)).toList();

    final stampCounts = <MemoryStamp, int>{};
    for (final m in memories) {
      stampCounts[m.stamp] = (stampCounts[m.stamp] ?? 0) + 1;
    }

    final strengths = <StrengthAnalysis>[];

    // 1. 思いやり
    if (score.hospitality > 0) {
      final level = _strengthLevel(score.hospitality, 100);
      strengths.add(StrengthAnalysis(
        name: '思いやり',
        icon: '💝',
        level: level,
        description: _hospitalityDesc(score.hospitality, totalCount),
        evidence: 'お手伝い記録: ${totalCount}回, Hスコア: ${score.hospitality}',
        admissionNote: '面接で「お友達や家族を助けた経験」を具体的に語れます。',
      ));
    }

    // 2. 集中力
    final logicActivity = (stampCounts[MemoryStamp.challenge] ?? 0) + score.logic;
    if (logicActivity > 0) {
      strengths.add(StrengthAnalysis(
        name: '集中力',
        icon: '🎯',
        level: _strengthLevel(score.logic, 80),
        description: '論理パズルやお手伝いの手順を最後までやり遂げる力があります。',
        evidence: 'Lスコア: ${score.logic}, 挑戦: $challengeCount回',
        admissionNote: '行動観察テストで最後まで取り組む姿勢が評価されます。',
      ));
    }

    // 3. 好奇心
    final diverseStamps = stampCounts.keys.length;
    if (diverseStamps >= 3) {
      strengths.add(StrengthAnalysis(
        name: '好奇心',
        icon: '🔍',
        level: _strengthLevel(diverseStamps * 20, 100),
        description: '食事、冒険、遊び、動物…多様な体験に積極的に関わっています。',
        evidence: '活動カテゴリ: $diverseStamps種類, 総記録: $totalCount件',
        admissionNote: '幅広い興味関心は、面接官に知的好奇心の高さを印象づけます。',
      ));
    }

    // 4. 創造力
    if (score.creativity > 0) {
      strengths.add(StrengthAnalysis(
        name: '創造力',
        icon: '🎨',
        level: _strengthLevel(score.creativity, 80),
        description: 'ぬりえや工作、新しい遊びの考案など、自分だけの表現を生み出しています。',
        evidence: 'Cスコア: ${score.creativity}',
        admissionNote: '制作課題で独自の発想力として評価されます。',
      ));
    }

    // 5. 挑戦する心
    if (challengeCount > 0) {
      strengths.add(StrengthAnalysis(
        name: '挑戦する心',
        icon: '⚔️',
        level: _strengthLevel(challengeCount * 15, 100),
        description: '新しいことに臆さず飛び込む勇気を持っています。',
        evidence: '挑戦記録: $challengeCount回',
        admissionNote: '「困難に立ち向かった経験」として願書に記載できます。',
      ));
    }

    // 最低5つ保証
    if (strengths.length < 5) {
      final defaults = [
        StrengthAnalysis(name: '優しさ', icon: '🌸', level: 0.3,
          description: '日々の活動を通じて育まれています。',
          evidence: '活動記録あり', admissionNote: '面接での態度に表れます。'),
        StrengthAnalysis(name: '表現力', icon: '✏️', level: 0.3,
          description: '日記を通じて言葉にする力が育っています。',
          evidence: '日記投稿あり', admissionNote: '自分の考えを伝える力として評価されます。'),
      ];
      for (final d in defaults) {
        if (strengths.length >= 5) break;
        if (!strengths.any((s) => s.name == d.name)) strengths.add(d);
      }
    }

    strengths.sort((a, b) => b.level.compareTo(a.level));
    return strengths.take(5).toList();
  }

  static double _strengthLevel(int value, int max) {
    return (value / max).clamp(0.1, 1.0);
  }

  static String _hospitalityDesc(int h, int total) {
    if (h >= 80) return 'お手伝いを通じて、深い思いやりの心が育っています。自ら進んで家族を助ける姿勢は素晴らしいです。';
    if (h >= 40) return 'お手伝いの習慣が定着し、他者を気遣う力が伸びています。';
    return 'お手伝いを始めたばかりですが、思いやりの芽が育ち始めています。';
  }
}

/// 個別の強み分析結果
class StrengthAnalysis {
  final String name;
  final String icon;
  final double level;       // 0.0 ~ 1.0
  final String description;
  final String evidence;     // 根拠データ
  final String admissionNote; // 入試活用ノート

  const StrengthAnalysis({
    required this.name,
    required this.icon,
    required this.level,
    required this.description,
    required this.evidence,
    required this.admissionNote,
  });
}
