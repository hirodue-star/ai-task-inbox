/// 日常の記憶エントリ
class MemoryEntry {
  final String id;
  final DateTime date;
  final MemoryStamp stamp;
  final String text;
  final String? photoPath;      // ローカル写真パス
  final String? aiIllustUrl;    // AI生成イラストURL
  final bool isChallenge;       // 「挑戦」フラグ → 黄金粒子永続化

  const MemoryEntry({
    required this.id,
    required this.date,
    required this.stamp,
    required this.text,
    this.photoPath,
    this.aiIllustUrl,
    this.isChallenge = false,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'date': date.toIso8601String(),
    'stamp': stamp.name,
    'text': text,
    'photo_path': photoPath,
    'ai_illust_url': aiIllustUrl,
    'is_challenge': isChallenge ? 1 : 0,
  };

  factory MemoryEntry.fromJson(Map<String, dynamic> json) => MemoryEntry(
    id: json['id'] as String,
    date: DateTime.parse(json['date'] as String),
    stamp: MemoryStamp.values.firstWhere(
      (s) => s.name == json['stamp'],
      orElse: () => MemoryStamp.ate,
    ),
    text: json['text'] as String,
    photoPath: json['photo_path'] as String?,
    aiIllustUrl: json['ai_illust_url'] as String?,
    isChallenge: json['is_challenge'] == 1,
  );
}

enum MemoryStamp {
  ate,        // 食べた
  went,       // 行った
  played,     // 遊んだ
  pet,        // ペット
  challenge,  // 挑戦
}

extension MemoryStampExt on MemoryStamp {
  String get emoji {
    switch (this) {
      case MemoryStamp.ate: return '🍽️';
      case MemoryStamp.went: return '🚶';
      case MemoryStamp.played: return '🎮';
      case MemoryStamp.pet: return '🐾';
      case MemoryStamp.challenge: return '⚔️';
    }
  }

  String get label {
    switch (this) {
      case MemoryStamp.ate: return 'たべた';
      case MemoryStamp.went: return 'いった';
      case MemoryStamp.played: return 'あそんだ';
      case MemoryStamp.pet: return 'ペット';
      case MemoryStamp.challenge: return 'ちょうせん';
    }
  }

  /// 挑戦スタンプは世界復元率を大きく上昇させる
  double get restorePoints {
    switch (this) {
      case MemoryStamp.ate: return 1.0;
      case MemoryStamp.went: return 1.5;
      case MemoryStamp.played: return 1.0;
      case MemoryStamp.pet: return 1.5;
      case MemoryStamp.challenge: return 5.0;
    }
  }
}
