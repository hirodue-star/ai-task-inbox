/// 日記エントリ — マンダラ8マスにマッピング
class MemoryEntry {
  final String id;
  final DateTime date;
  final MemoryStamp stamp;
  final String text;
  final String? photoPath;

  const MemoryEntry({
    required this.id,
    required this.date,
    required this.stamp,
    required this.text,
    this.photoPath,
  });

  bool get isChallenge => stamp == MemoryStamp.challenge;

  /// マンダラの何番マスに対応するか（0=中央, 1-8=周囲）
  int get mandalaCell => stamp.mandalaCell;

  Map<String, dynamic> toJson() => {
    'id': id,
    'date': date.toIso8601String(),
    'stamp': stamp.name,
    'text': text,
    'photo_path': photoPath,
  };

  factory MemoryEntry.fromJson(Map<String, dynamic> json) => MemoryEntry(
    id: json['id'] as String,
    date: DateTime.parse(json['date'] as String),
    stamp: MemoryStamp.values.firstWhere(
      (s) => s.name == json['stamp'], orElse: () => MemoryStamp.kindness),
    text: json['text'] as String,
    photoPath: json['photo_path'] as String?,
  );
}

/// 8カテゴリー = マンダラ周囲8マス
/// 中央マスは全カテゴリーの集約（親ダッシュボードで自動算出）
enum MemoryStamp {
  kindness,    // おもいやり（マス1）
  logic,       // だんどり（マス2）
  creation,    // つくった（マス3）
  discovery,   // はっけん（マス4）
  challenge,   // ちょうせん（マス5）
  expression,  // つたえた（マス6）
  helping,     // おてつだい（マス7）
  nature,      // しぜん（マス8）
}

extension MemoryStampExt on MemoryStamp {
  String get emoji {
    switch (this) {
      case MemoryStamp.kindness: return '💝';
      case MemoryStamp.logic: return '🧩';
      case MemoryStamp.creation: return '🎨';
      case MemoryStamp.discovery: return '🔍';
      case MemoryStamp.challenge: return '⚔️';
      case MemoryStamp.expression: return '💬';
      case MemoryStamp.helping: return '🤝';
      case MemoryStamp.nature: return '🌿';
    }
  }

  String get label {
    switch (this) {
      case MemoryStamp.kindness: return 'おもいやり';
      case MemoryStamp.logic: return 'だんどり';
      case MemoryStamp.creation: return 'つくった';
      case MemoryStamp.discovery: return 'はっけん';
      case MemoryStamp.challenge: return 'ちょうせん';
      case MemoryStamp.expression: return 'つたえた';
      case MemoryStamp.helping: return 'おてつだい';
      case MemoryStamp.nature: return 'しぜん';
    }
  }

  /// マンダラセル番号（1-8, 0は中央=自動）
  int get mandalaCell {
    switch (this) {
      case MemoryStamp.kindness: return 1;
      case MemoryStamp.logic: return 2;
      case MemoryStamp.creation: return 3;
      case MemoryStamp.discovery: return 4;
      case MemoryStamp.challenge: return 5;
      case MemoryStamp.expression: return 6;
      case MemoryStamp.helping: return 7;
      case MemoryStamp.nature: return 8;
    }
  }

  /// 親ダッシュボード用: マンダラのマスラベル
  String get mandalaLabel {
    switch (this) {
      case MemoryStamp.kindness: return '思いやり';
      case MemoryStamp.logic: return '段取り力';
      case MemoryStamp.creation: return '創造力';
      case MemoryStamp.discovery: return '観察力';
      case MemoryStamp.challenge: return '挑戦心';
      case MemoryStamp.expression: return '表現力';
      case MemoryStamp.helping: return '奉仕の心';
      case MemoryStamp.nature: return '自然への感性';
    }
  }
}
