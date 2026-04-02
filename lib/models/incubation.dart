/// マンダラセルの孵化（インキュベーション）管理
/// ツァイガルニク効果：不完全な状態を意図的に維持
class Incubation {
  final int cellIndex;
  final DateTime startedAt;
  final Duration requiredTime; // 孵化に必要な時間
  final String? seedThought;  // ユーザーが植えた思考の種

  const Incubation({
    required this.cellIndex,
    required this.startedAt,
    required this.requiredTime,
    this.seedThought,
  });

  /// 孵化完了判定
  bool get isReady => DateTime.now().difference(startedAt) >= requiredTime;

  /// 残り時間
  Duration get remaining {
    final elapsed = DateTime.now().difference(startedAt);
    final left = requiredTime - elapsed;
    return left.isNegative ? Duration.zero : left;
  }

  /// 進行率 (0.0 → 1.0)
  double get progress {
    final elapsed = DateTime.now().difference(startedAt).inSeconds;
    final total = requiredTime.inSeconds;
    return (elapsed / total).clamp(0.0, 1.0);
  }

  /// 孵化中のステータスメッセージ
  String get statusMessage {
    if (isReady) return '孵化完了！タップして開こう';
    final r = remaining;
    if (r.inHours > 0) return 'あと${r.inHours}時間${r.inMinutes % 60}分…思考が育っている';
    if (r.inMinutes > 0) return 'あと${r.inMinutes}分…もうすぐ生まれる';
    return 'あと${r.inSeconds}秒…';
  }

  Map<String, dynamic> toJson() => {
    'cell_index': cellIndex,
    'started_at': startedAt.toIso8601String(),
    'required_seconds': requiredTime.inSeconds,
    'seed_thought': seedThought,
  };

  factory Incubation.fromJson(Map<String, dynamic> json) => Incubation(
    cellIndex: json['cell_index'] as int,
    startedAt: DateTime.parse(json['started_at'] as String),
    requiredTime: Duration(seconds: json['required_seconds'] as int),
    seedThought: json['seed_thought'] as String?,
  );
}

/// セルごとの孵化時間設定
/// 外周セルほど長い → 中央から広がる世界観
Duration incubationTimeForCell(int cellIndex) {
  switch (cellIndex) {
    case 4: return const Duration(minutes: 5);     // 中央：すぐ
    case 1: case 3: case 5: case 7:
      return const Duration(hours: 1);              // 十字：1時間
    case 0: case 2: case 6: case 8:
      return const Duration(hours: 3);              // 角：3時間
    default: return const Duration(hours: 1);
  }
}
