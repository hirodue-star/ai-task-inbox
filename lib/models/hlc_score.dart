/// HLCスコアモデル（奉仕・論理・創造）
class HlcScore {
  final int hospitality; // 奉仕（H）
  final int logic;       // 論理（L）
  final int creativity;  // 創造（C）

  const HlcScore({
    this.hospitality = 0,
    this.logic = 0,
    this.creativity = 0,
  });

  int get total => hospitality + logic + creativity;

  /// 現在のレベル判定
  PlayerLevel get level {
    if (total >= 300) return PlayerLevel.lion;
    if (total >= 100) return PlayerLevel.penguin;
    return PlayerLevel.hiyoko;
  }

  /// レベルアップに必要な残りポイント
  int get pointsToNextLevel {
    switch (level) {
      case PlayerLevel.hiyoko:
        return 100 - total;
      case PlayerLevel.penguin:
        return 300 - total;
      case PlayerLevel.lion:
        return 0; // 最高レベル
    }
  }

  /// H/L/Cの最大値を基にした「強み」判定
  String get strength {
    if (hospitality >= logic && hospitality >= creativity) return '奉仕の心';
    if (logic >= hospitality && logic >= creativity) return '論理の力';
    return '創造の翼';
  }

  HlcScore copyWith({int? hospitality, int? logic, int? creativity}) {
    return HlcScore(
      hospitality: hospitality ?? this.hospitality,
      logic: logic ?? this.logic,
      creativity: creativity ?? this.creativity,
    );
  }

  HlcScore add({int h = 0, int l = 0, int c = 0}) {
    return HlcScore(
      hospitality: hospitality + h,
      logic: logic + l,
      creativity: creativity + c,
    );
  }

  Map<String, dynamic> toJson() => {
    'hospitality': hospitality,
    'logic': logic,
    'creativity': creativity,
  };

  factory HlcScore.fromJson(Map<String, dynamic> json) => HlcScore(
    hospitality: json['hospitality'] as int? ?? 0,
    logic: json['logic'] as int? ?? 0,
    creativity: json['creativity'] as int? ?? 0,
  );
}

enum PlayerLevel { hiyoko, penguin, lion }
