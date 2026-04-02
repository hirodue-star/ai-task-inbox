/// 日記エントリ（MVP: シンプル）
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
      (s) => s.name == json['stamp'], orElse: () => MemoryStamp.ate),
    text: json['text'] as String,
    photoPath: json['photo_path'] as String?,
  );
}

enum MemoryStamp { ate, went, played, pet, challenge }

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
}
