/// 世界復元率 + 時間帯 + 進化段階の統合モデル
class WorldState {
  final double restorePercent; // 0.0 ~ 100.0
  final int mandalaSlotsUnlocked; // 0~9
  final List<bool> mandalaCompleted; // 9セルの完了状態
  final int totalActions; // 累計アクション数
  final DateTime lastActionAt;

  const WorldState({
    this.restorePercent = 0.0,
    this.mandalaSlotsUnlocked = 1, // 中央セルのみ初期解放
    this.mandalaCompleted = const [false, false, false, false, false, false, false, false, false],
    this.totalActions = 0,
    required this.lastActionAt,
  });

  /// 時間帯判定
  TimeOfDayPhase get phase {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 10) return TimeOfDayPhase.morning;
    if (hour >= 10 && hour < 16) return TimeOfDayPhase.daytime;
    if (hour >= 16 && hour < 19) return TimeOfDayPhase.evening;
    return TimeOfDayPhase.night;
  }

  /// 進化段階（背景に描画される生命・建築物）
  EvolutionStage get evolutionStage {
    if (restorePercent >= 90) return EvolutionStage.golden;
    if (restorePercent >= 70) return EvolutionStage.civilization;
    if (restorePercent >= 45) return EvolutionStage.forest;
    if (restorePercent >= 20) return EvolutionStage.sprout;
    return EvolutionStage.barren;
  }

  /// マンダラ完全達成判定（Big Bang）
  bool get isMandalaComplete =>
      mandalaCompleted.every((c) => c) && mandalaSlotsUnlocked >= 9;

  /// 深海の渦の強度（ペンギン級への伏線）
  double get abyssIntensity {
    // 思考の重みが蓄積するほど渦が強くなる
    final weight = totalActions / 50.0;
    return weight.clamp(0.0, 1.0);
  }

  WorldState copyWith({
    double? restorePercent,
    int? mandalaSlotsUnlocked,
    List<bool>? mandalaCompleted,
    int? totalActions,
    DateTime? lastActionAt,
  }) {
    return WorldState(
      restorePercent: restorePercent ?? this.restorePercent,
      mandalaSlotsUnlocked: mandalaSlotsUnlocked ?? this.mandalaSlotsUnlocked,
      mandalaCompleted: mandalaCompleted ?? this.mandalaCompleted,
      totalActions: totalActions ?? this.totalActions,
      lastActionAt: lastActionAt ?? this.lastActionAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'restore_percent': restorePercent,
    'mandala_slots_unlocked': mandalaSlotsUnlocked,
    'mandala_completed': mandalaCompleted.map((b) => b ? 1 : 0).toList(),
    'total_actions': totalActions,
    'last_action_at': lastActionAt.toIso8601String(),
  };

  factory WorldState.fromJson(Map<String, dynamic> json) => WorldState(
    restorePercent: (json['restore_percent'] as num?)?.toDouble() ?? 0.0,
    mandalaSlotsUnlocked: json['mandala_slots_unlocked'] as int? ?? 1,
    mandalaCompleted: (json['mandala_completed'] as List?)
        ?.map((v) => v == 1).toList() ?? List.filled(9, false),
    totalActions: json['total_actions'] as int? ?? 0,
    lastActionAt: json['last_action_at'] != null
        ? DateTime.parse(json['last_action_at'] as String)
        : DateTime.now(),
  );
}

enum TimeOfDayPhase { morning, daytime, evening, night }

enum EvolutionStage {
  barren,       // 0-19%  荒野
  sprout,       // 20-44% 芽吹き
  forest,       // 45-69% 森林
  civilization, // 70-89% 文明
  golden,       // 90-100% 黄金時代
}
