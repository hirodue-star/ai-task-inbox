import 'memory_entry.dart';

/// 成長サマリーカード — 月次/年次の活動まとめ
class GrowthSummary {
  final DateTime periodStart;
  final DateTime periodEnd;
  final SummaryPeriod period;
  final int totalPosts;
  final int challengeCount;
  final Map<MemoryStamp, int> stampCounts;
  final String? highlightText;     // その期間で最も印象的な投稿
  final List<String> strengths;    // 分析された強み

  const GrowthSummary({
    required this.periodStart,
    required this.periodEnd,
    required this.period,
    required this.totalPosts,
    required this.challengeCount,
    required this.stampCounts,
    this.highlightText,
    this.strengths = const [],
  });

  String get periodLabel {
    switch (period) {
      case SummaryPeriod.monthly:
        return '${periodStart.year}年${periodStart.month}月';
      case SummaryPeriod.yearly:
        return '${periodStart.year}年';
    }
  }

  String get emotionalSummary {
    if (challengeCount >= 5) return '勇敢な挑戦者の月';
    if (totalPosts >= 20) return '記録の達人';
    if ((stampCounts[MemoryStamp.pet] ?? 0) > 3) return 'いのちの観察者';
    if ((stampCounts[MemoryStamp.went] ?? 0) > 3) return '冒険家の足跡';
    if (totalPosts >= 10) return '着実な成長';
    return 'はじまりの一歩';
  }
}

enum SummaryPeriod { monthly, yearly }

/// 創刊号（デジタル漫画本）
class FirstEdition {
  final String id;
  final DateTime createdAt;
  final int volumeNumber;
  final List<String> memoryIds; // 含まれる投稿ID
  final String title;
  final int pageCount;

  const FirstEdition({
    required this.id,
    required this.createdAt,
    required this.volumeNumber,
    required this.memoryIds,
    required this.title,
    required this.pageCount,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'created_at': createdAt.toIso8601String(),
    'volume_number': volumeNumber,
    'memory_ids': memoryIds.join(','),
    'title': title,
    'page_count': pageCount,
  };

  factory FirstEdition.fromJson(Map<String, dynamic> json) => FirstEdition(
    id: json['id'] as String,
    createdAt: DateTime.parse(json['created_at'] as String),
    volumeNumber: json['volume_number'] as int,
    memoryIds: (json['memory_ids'] as String).split(',').where((s) => s.isNotEmpty).toList(),
    title: json['title'] as String,
    pageCount: json['page_count'] as int,
  );
}
