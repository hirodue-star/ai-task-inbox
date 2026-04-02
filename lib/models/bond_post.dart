import 'memory_entry.dart';

/// BOND-LOG投稿モデル
class BondPost {
  final String id;
  final String authorId;
  final String authorName;
  final AuthorRole authorRole;
  final DateTime createdAt;
  final MemoryStamp stamp;
  final String text;
  final String? photoPath;
  final String? aiIllustUrl;
  final bool isChallenge;
  final bool isMission;         // デイリーミッション投稿
  final bool parentApproved;
  final DateTime? approvedAt;
  final int likeCount;
  final List<String> likedBy;
  final String? missionTag;     // #ハッシュタグ

  const BondPost({
    required this.id,
    required this.authorId,
    required this.authorName,
    required this.authorRole,
    required this.createdAt,
    required this.stamp,
    required this.text,
    this.photoPath,
    this.aiIllustUrl,
    this.isChallenge = false,
    this.isMission = false,
    this.parentApproved = false,
    this.approvedAt,
    this.likeCount = 0,
    this.likedBy = const [],
    this.missionTag,
  });

  bool get isApproved => parentApproved;
  bool get unlockGacha => parentApproved && isMission;

  BondPost copyWith({
    bool? parentApproved,
    DateTime? approvedAt,
    int? likeCount,
    List<String>? likedBy,
  }) {
    return BondPost(
      id: id, authorId: authorId, authorName: authorName,
      authorRole: authorRole, createdAt: createdAt, stamp: stamp,
      text: text, photoPath: photoPath, aiIllustUrl: aiIllustUrl,
      isChallenge: isChallenge, isMission: isMission,
      parentApproved: parentApproved ?? this.parentApproved,
      approvedAt: approvedAt ?? this.approvedAt,
      likeCount: likeCount ?? this.likeCount,
      likedBy: likedBy ?? this.likedBy,
      missionTag: missionTag,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'author_id': authorId,
    'author_name': authorName,
    'author_role': authorRole.name,
    'created_at': createdAt.toIso8601String(),
    'stamp': stamp.name,
    'text': text,
    'photo_path': photoPath,
    'ai_illust_url': aiIllustUrl,
    'is_challenge': isChallenge ? 1 : 0,
    'is_mission': isMission ? 1 : 0,
    'parent_approved': parentApproved ? 1 : 0,
    'approved_at': approvedAt?.toIso8601String(),
    'like_count': likeCount,
    'liked_by': likedBy.join(','),
    'mission_tag': missionTag,
  };

  factory BondPost.fromJson(Map<String, dynamic> json) => BondPost(
    id: json['id'] as String,
    authorId: json['author_id'] as String,
    authorName: json['author_name'] as String,
    authorRole: AuthorRole.values.firstWhere(
      (r) => r.name == json['author_role'], orElse: () => AuthorRole.child),
    createdAt: DateTime.parse(json['created_at'] as String),
    stamp: MemoryStamp.values.firstWhere(
      (s) => s.name == json['stamp'], orElse: () => MemoryStamp.ate),
    text: json['text'] as String,
    photoPath: json['photo_path'] as String?,
    aiIllustUrl: json['ai_illust_url'] as String?,
    isChallenge: json['is_challenge'] == 1,
    isMission: json['is_mission'] == 1,
    parentApproved: json['parent_approved'] == 1,
    approvedAt: json['approved_at'] != null ? DateTime.parse(json['approved_at'] as String) : null,
    likeCount: json['like_count'] as int? ?? 0,
    likedBy: (json['liked_by'] as String?)?.split(',').where((s) => s.isNotEmpty).toList() ?? [],
    missionTag: json['mission_tag'] as String?,
  );

  /// MemoryEntry → BondPost変換（日記 = 投稿）
  factory BondPost.fromMemory(MemoryEntry memory, {
    required String authorId,
    required String authorName,
    String? missionTag,
  }) => BondPost(
    id: memory.id,
    authorId: authorId,
    authorName: authorName,
    authorRole: AuthorRole.child,
    createdAt: memory.date,
    stamp: memory.stamp,
    text: memory.text,
    photoPath: memory.photoPath,
    aiIllustUrl: memory.aiIllustUrl,
    isChallenge: memory.isChallenge,
    isMission: missionTag != null,
    missionTag: missionTag,
  );
}

enum AuthorRole { child, parent, family }

/// デイリーミッション
class DailyMission {
  final String tag;
  final String description;
  final MemoryStamp relatedStamp;
  final double bonusRestore;

  const DailyMission({
    required this.tag,
    required this.description,
    required this.relatedStamp,
    this.bonusRestore = 3.0,
  });
}

/// 今日のミッション生成
DailyMission todaysMission() {
  final day = DateTime.now().day;
  const missions = [
    DailyMission(tag: '#おそうじチャレンジ', description: 'おへやをきれいにしよう', relatedStamp: MemoryStamp.challenge, bonusRestore: 5.0),
    DailyMission(tag: '#おりょうりデビュー', description: 'おりょうりをてつだおう', relatedStamp: MemoryStamp.ate, bonusRestore: 3.0),
    DailyMission(tag: '#おさんぽたんけん', description: 'そとをたんけんしよう', relatedStamp: MemoryStamp.went, bonusRestore: 3.0),
    DailyMission(tag: '#どうぶつだいすき', description: 'どうぶつとなかよくしよう', relatedStamp: MemoryStamp.pet, bonusRestore: 3.0),
    DailyMission(tag: '#あたらしいあそび', description: 'あたらしいあそびをかんがえよう', relatedStamp: MemoryStamp.played, bonusRestore: 3.0),
    DailyMission(tag: '#ちょうせんのひ', description: 'にがてなことにちょうせん', relatedStamp: MemoryStamp.challenge, bonusRestore: 5.0),
    DailyMission(tag: '#かぞくのじかん', description: 'かぞくとすごす時間をたいせつに', relatedStamp: MemoryStamp.played, bonusRestore: 4.0),
  ];
  return missions[day % missions.length];
}
