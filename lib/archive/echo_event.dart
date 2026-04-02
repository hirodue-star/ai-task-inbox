import 'dart:ui';

/// 親子共鳴イベント
class EchoEvent {
  final String id;
  final DateTime timestamp;
  final EchoType type;
  final String? message;
  final EmotionTag? emotion;

  const EchoEvent({
    required this.id,
    required this.timestamp,
    required this.type,
    this.message,
    this.emotion,
  });

  Map<String, dynamic> toJson() => {
    'id': id, 'timestamp': timestamp.toIso8601String(),
    'type': type.name, 'message': message, 'emotion': emotion?.name,
  };
}

enum EchoType { welcomeBack, reaction, heartbeat, teacherStamp }

enum EmotionTag {
  happy, proud, brave, kind, curious, tired,
}

extension EmotionTagExt on EmotionTag {
  String get emoji {
    switch (this) {
      case EmotionTag.happy: return '😊';
      case EmotionTag.proud: return '🏆';
      case EmotionTag.brave: return '⚔️';
      case EmotionTag.kind: return '💝';
      case EmotionTag.curious: return '🔍';
      case EmotionTag.tired: return '😴';
    }
  }

  String get label {
    switch (this) {
      case EmotionTag.happy: return 'うれしい';
      case EmotionTag.proud: return 'がんばった';
      case EmotionTag.brave: return 'ゆうかん';
      case EmotionTag.kind: return 'やさしい';
      case EmotionTag.curious: return 'きになる';
      case EmotionTag.tired: return 'つかれた';
    }
  }

  /// 背景エフェクト色
  List<Color> get effectColors {
    switch (this) {
      case EmotionTag.happy: return [const Color(0xFFFFE066), const Color(0xFFFFB5C5)];
      case EmotionTag.proud: return [const Color(0xFFFFD700), const Color(0xFFC8960C)];
      case EmotionTag.brave: return [const Color(0xFFFF6B35), const Color(0xFFFFD700)];
      case EmotionTag.kind: return [const Color(0xFFFFB5C5), const Color(0xFFE8B5FF)];
      case EmotionTag.curious: return [const Color(0xFFB5D8FF), const Color(0xFF90EE90)];
      case EmotionTag.tired: return [const Color(0xFF6B8EA0), const Color(0xFF4A6670)];
    }
  }
}

/// 保育士スタンプ（非認知能力）
class TeacherStamp {
  final String id;
  final String childId;
  final String teacherName;
  final DateTime timestamp;
  final NonCogSkill skill;
  final String? note;

  const TeacherStamp({
    required this.id, required this.childId, required this.teacherName,
    required this.timestamp, required this.skill, this.note,
  });

  Map<String, dynamic> toJson() => {
    'id': id, 'child_id': childId, 'teacher_name': teacherName,
    'timestamp': timestamp.toIso8601String(), 'skill': skill.name, 'note': note,
  };

  factory TeacherStamp.fromJson(Map<String, dynamic> j) => TeacherStamp(
    id: j['id'] as String, childId: j['child_id'] as String,
    teacherName: j['teacher_name'] as String,
    timestamp: DateTime.parse(j['timestamp'] as String),
    skill: NonCogSkill.values.firstWhere((s) => s.name == j['skill'], orElse: () => NonCogSkill.autonomy),
    note: j['note'] as String?,
  );
}

enum NonCogSkill { autonomy, cooperation, inquiry, empathy, persistence, creativity }

extension NonCogSkillExt on NonCogSkill {
  String get emoji {
    switch (this) {
      case NonCogSkill.autonomy: return '🌟';
      case NonCogSkill.cooperation: return '🤝';
      case NonCogSkill.inquiry: return '🔬';
      case NonCogSkill.empathy: return '💕';
      case NonCogSkill.persistence: return '💪';
      case NonCogSkill.creativity: return '🎨';
    }
  }

  String get label {
    switch (this) {
      case NonCogSkill.autonomy: return '自律';
      case NonCogSkill.cooperation: return '協調';
      case NonCogSkill.inquiry: return '探究';
      case NonCogSkill.empathy: return '共感';
      case NonCogSkill.persistence: return '粘り強さ';
      case NonCogSkill.creativity: return '創造性';
    }
  }

  String get comicMessage {
    switch (this) {
      case NonCogSkill.autonomy: return 'じぶんでかんがえて、できたね！';
      case NonCogSkill.cooperation: return 'おともだちとちからをあわせたね！';
      case NonCogSkill.inquiry: return 'すごい！よくしらべたね！';
      case NonCogSkill.empathy: return 'おともだちのきもちがわかるんだね';
      case NonCogSkill.persistence: return 'さいごまであきらめなかったね！';
      case NonCogSkill.creativity: return 'すてきなアイデアだね！';
    }
  }
}

/// 園との通信: 匿名化IDで家庭と園を繋ぐ
class InstitutionLink {
  final String anonymousChildId; // 園に渡すのはこのIDのみ
  final String institutionCode;  // 園固有コード
  final bool active;

  const InstitutionLink({
    required this.anonymousChildId,
    required this.institutionCode,
    this.active = true,
  });
}
