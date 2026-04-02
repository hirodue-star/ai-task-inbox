import 'dart:math' as math;
import '../models/memory_entry.dart';

/// 地頭育成エンジン — 4つの力を無意識に鍛える

// === 1. 観察力：デイリーミッション生成 ===

class DailyMission {
  final String message;
  final String target;
  final int goalCount;

  const DailyMission({required this.message, required this.target, this.goalCount = 3});
}

DailyMission todaysMission() {
  final day = DateTime.now().day;
  const missions = [
    DailyMission(message: 'きょうは「あかくてまるいもの」を3つみつけて漫画にしよう！', target: '赤くて丸い'),
    DailyMission(message: 'きょうは「いいにおいのするもの」を2つみつけよう！', target: '良い匂い', goalCount: 2),
    DailyMission(message: 'きょうは「おとがするもの」を3つあつめよう！', target: '音がする'),
    DailyMission(message: 'きょうは「やわらかいもの」を3つさわってみよう！', target: '柔らかい'),
    DailyMission(message: 'きょうは「そらにあるもの」を2つみつけよう！', target: '空にある', goalCount: 2),
    DailyMission(message: 'きょうは「ちいさいいきもの」を3つかんさつしよう！', target: '小さい生き物'),
    DailyMission(message: 'きょうは「かげのかたち」を3つみつけよう！', target: '影の形'),
    DailyMission(message: 'きょうは「おともだちのいいところ」を2つみつけよう！', target: '友達の良いところ', goalCount: 2),
    DailyMission(message: 'きょうは「きのうなかったもの」を3つみつけよう！', target: '昨日なかった'),
    DailyMission(message: 'きょうは「3つかぞえられるもの」をあつめよう！', target: '数えられる'),
  ];
  return missions[day % missions.length];
}

// === 2. 表現力：擬音語・擬態語の自動生成 ===

class ExpressionEnhancer {
  /// テキストから擬音語・擬態語を自動検出/提案
  static List<String> suggestOnomatopoeia(String text, MemoryStamp stamp) {
    final suggestions = <String>[];

    // スタンプに応じた基本提案
    switch (stamp) {
      case MemoryStamp.kindness:
        suggestions.addAll(['ほっこり', 'にこにこ', 'ぎゅっ']);
        break;
      case MemoryStamp.logic:
        suggestions.addAll(['てきぱき', 'さくさく', 'ぴったり']);
        break;
      case MemoryStamp.creation:
        suggestions.addAll(['ぐるぐる', 'ぺたぺた', 'きらきら']);
        break;
      case MemoryStamp.discovery:
        suggestions.addAll(['きょろきょろ', 'じーっ', 'はっ！']);
        break;
      case MemoryStamp.challenge:
        suggestions.addAll(['どきどき', 'えいっ！', 'やったー！']);
        break;
      case MemoryStamp.expression:
        suggestions.addAll(['はきはき', 'すらすら', 'じーん']);
        break;
      case MemoryStamp.helping:
        suggestions.addAll(['ごしごし', 'ぴかぴか', 'てきぱき']);
        break;
      case MemoryStamp.nature:
        suggestions.addAll(['さわさわ', 'ぽかぽか', 'ざーざー']);
        break;
    }

    // テキスト内容に応じた追加提案
    final lower = text.toLowerCase();
    if (lower.contains('走') || lower.contains('はし')) suggestions.add('ダッシュ！');
    if (lower.contains('食') || lower.contains('たべ')) suggestions.add('もぐもぐ');
    if (lower.contains('笑') || lower.contains('わら')) suggestions.add('ケラケラ');
    if (lower.contains('泣') || lower.contains('ない')) suggestions.add('えーん');
    if (lower.contains('驚') || lower.contains('びっくり')) suggestions.add('ガーン！');

    return suggestions.take(3).toList();
  }
}

// === 3. メタ認知：マンダラ・リフレクション ===

class MandalaReflection {
  /// 1週間のマンダラ埋まり具合を分析
  static ReflectionResult analyze(List<MemoryEntry> weekEntries) {
    final cellCounts = <int, int>{};
    for (final e in weekEntries) {
      cellCounts[e.mandalaCell] = (cellCounts[e.mandalaCell] ?? 0) + 1;
    }

    // 最も多いカテゴリ（強み）
    int? strongestCell;
    int maxCount = 0;
    cellCounts.forEach((cell, count) {
      if (count > maxCount) {
        maxCount = count;
        strongestCell = cell;
      }
    });

    // 最も少ない（0含む）カテゴリ（次の冒険）
    int? weakestCell;
    int minCount = 999;
    for (var i = 1; i <= 8; i++) {
      final count = cellCounts[i] ?? 0;
      if (count < minCount) {
        minCount = count;
        weakestCell = i;
      }
    }

    final filledCells = cellCounts.keys.length;
    final strongStamp = strongestCell != null
        ? MemoryStamp.values.firstWhere((s) => s.mandalaCell == strongestCell)
        : null;
    final weakStamp = weakestCell != null
        ? MemoryStamp.values.firstWhere((s) => s.mandalaCell == weakestCell)
        : null;

    return ReflectionResult(
      totalEntries: weekEntries.length,
      filledCells: filledCells,
      strongestStamp: strongStamp,
      weakestStamp: weakStamp,
      praise: _generatePraise(strongStamp),
      suggestion: _generateSuggestion(weakStamp),
    );
  }

  static String _generatePraise(MemoryStamp? stamp) {
    if (stamp == null) return 'こんしゅうもがんばったね！';
    return 'きみは「${stamp.label}」のてんさいだね！';
  }

  static String _generateSuggestion(MemoryStamp? stamp) {
    if (stamp == null) return 'あたらしいぼうけんにでかけよう！';
    return 'つぎは「${stamp.label}」のぼうけんにいこうか！';
  }
}

class ReflectionResult {
  final int totalEntries;
  final int filledCells;
  final MemoryStamp? strongestStamp;
  final MemoryStamp? weakestStamp;
  final String praise;
  final String suggestion;

  const ReflectionResult({
    required this.totalEntries,
    required this.filledCells,
    this.strongestStamp,
    this.weakestStamp,
    required this.praise,
    required this.suggestion,
  });
}

// === 4. 洞察力：Why-Reasoning検出 ===

class WhyDetector {
  static const _logicalWords = [
    'なぜなら', 'だから', 'なので', 'それで', 'つまり',
    'おもったから', 'かんがえて', 'きがついた', 'わかった',
    'りゆうは', 'どうしてかというと',
  ];

  /// テキスト内に論理的接続詞が含まれるか判定
  static bool hasReasoning(String text) {
    final lower = text.toLowerCase();
    return _logicalWords.any((w) => lower.contains(w));
  }

  /// 検出された接続詞リスト
  static List<String> findReasoningWords(String text) {
    final lower = text.toLowerCase();
    return _logicalWords.where((w) => lower.contains(w)).toList();
  }
}
