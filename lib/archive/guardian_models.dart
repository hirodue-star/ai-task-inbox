/// ジオフェンス（聖域）
class Sanctuary {
  final String id;
  final String name;
  final String emoji;
  final double latitude;
  final double longitude;
  final double radiusMeters;
  final SanctuaryType type;

  const Sanctuary({
    required this.id, required this.name, required this.emoji,
    required this.latitude, required this.longitude,
    this.radiusMeters = 100, required this.type,
  });

  Map<String, dynamic> toJson() => {
    'id': id, 'name': name, 'emoji': emoji,
    'latitude': latitude, 'longitude': longitude,
    'radius': radiusMeters, 'type': type.name,
  };

  factory Sanctuary.fromJson(Map<String, dynamic> j) => Sanctuary(
    id: j['id'] as String, name: j['name'] as String,
    emoji: j['emoji'] as String? ?? '📍',
    latitude: (j['latitude'] as num).toDouble(),
    longitude: (j['longitude'] as num).toDouble(),
    radiusMeters: (j['radius'] as num?)?.toDouble() ?? 100,
    type: SanctuaryType.values.firstWhere(
      (t) => t.name == j['type'], orElse: () => SanctuaryType.custom),
  );
}

enum SanctuaryType { home, school, park, grandparents, custom }

extension SanctuaryTypeExt on SanctuaryType {
  String get defaultEmoji {
    switch (this) {
      case SanctuaryType.home: return '🏠';
      case SanctuaryType.school: return '🏫';
      case SanctuaryType.park: return '🌳';
      case SanctuaryType.grandparents: return '👴';
      case SanctuaryType.custom: return '📍';
    }
  }

  String get label {
    switch (this) {
      case SanctuaryType.home: return 'おうち';
      case SanctuaryType.school: return 'えん';
      case SanctuaryType.park: return 'こうえん';
      case SanctuaryType.grandparents: return 'おじいちゃんのいえ';
      case SanctuaryType.custom: return 'とくべつなばしょ';
    }
  }
}

/// 冒険地図のポイント（プライバシー配慮: 番地なし）
class AdventurePoint {
  final DateTime timestamp;
  final double latitude;
  final double longitude;
  final String? landmarkName; // 番地ではなくランドマーク
  final String? emoji;

  const AdventurePoint({
    required this.timestamp, required this.latitude,
    required this.longitude, this.landmarkName, this.emoji,
  });
}

/// チェックポイントミッション
class Checkpoint {
  final String id;
  final String name;
  final double latitude;
  final double longitude;
  final double radiusMeters;
  final String rewardEmoji;
  final int xpReward;
  final bool discovered;

  const Checkpoint({
    required this.id, required this.name,
    required this.latitude, required this.longitude,
    this.radiusMeters = 30, this.rewardEmoji = '🎁',
    this.xpReward = 10, this.discovered = false,
  });

  Checkpoint discover() => Checkpoint(
    id: id, name: name, latitude: latitude, longitude: longitude,
    radiusMeters: radiusMeters, rewardEmoji: rewardEmoji,
    xpReward: xpReward, discovered: true,
  );
}

/// SOS イベント
class SosEvent {
  final DateTime timestamp;
  final double latitude;
  final double longitude;
  final String? audioPath; // 10秒音声

  const SosEvent({
    required this.timestamp, required this.latitude,
    required this.longitude, this.audioPath,
  });
}
