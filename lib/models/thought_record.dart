/// 思考資産レコード — 過去の入力データを永続化
class ThoughtRecord {
  final String id;
  final DateTime createdAt;
  final ThoughtCategory category;
  final String question;     // 問いかけ
  final String answer;       // ユーザーの回答
  final int mandalaCell;     // マンダラグリッドのセル位置 (0-8)
  final String? parentNote;  // 親からのコメント（承認時）

  const ThoughtRecord({
    required this.id,
    required this.createdAt,
    required this.category,
    required this.question,
    required this.answer,
    required this.mandalaCell,
    this.parentNote,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'created_at': createdAt.toIso8601String(),
    'category': category.name,
    'question': question,
    'answer': answer,
    'mandala_cell': mandalaCell,
    'parent_note': parentNote,
  };

  factory ThoughtRecord.fromJson(Map<String, dynamic> json) => ThoughtRecord(
    id: json['id'] as String,
    createdAt: DateTime.parse(json['created_at'] as String),
    category: ThoughtCategory.values.firstWhere(
      (c) => c.name == json['category'],
      orElse: () => ThoughtCategory.discovery,
    ),
    question: json['question'] as String,
    answer: json['answer'] as String,
    mandalaCell: json['mandala_cell'] as int,
    parentNote: json['parent_note'] as String?,
  );
}

enum ThoughtCategory {
  pride,      // 自慢
  analysis,   // 分析
  creation,   // 創造
  discovery,  // 発見
  core,       // 核心
  direction,  // 方向
  wisdom,     // 知恵
  expression, // 表現
  mastery,    // マスター
}

/// マンダラセルと思考カテゴリのマッピング
extension ThoughtCategoryExt on ThoughtCategory {
  int get cellIndex => index;

  String get displayName {
    switch (this) {
      case ThoughtCategory.pride: return '自慢';
      case ThoughtCategory.analysis: return '分析';
      case ThoughtCategory.creation: return '創造';
      case ThoughtCategory.discovery: return '発見';
      case ThoughtCategory.core: return '核心';
      case ThoughtCategory.direction: return '方向';
      case ThoughtCategory.wisdom: return '知恵';
      case ThoughtCategory.expression: return '表現';
      case ThoughtCategory.mastery: return 'マスター';
    }
  }

  /// レベルアップ時の問いかけテンプレート
  String levelUpQuestion(List<ThoughtRecord> pastRecords) {
    if (pastRecords.isEmpty) return defaultQuestion;
    final latest = pastRecords.last;
    switch (this) {
      case ThoughtCategory.pride:
        return '「${latest.answer}」をもっと上手にするには？';
      case ThoughtCategory.analysis:
        return '「${latest.answer}」の理由をもっと深く考えてみよう';
      case ThoughtCategory.creation:
        return '「${latest.answer}」を使って新しいものを作るなら？';
      case ThoughtCategory.discovery:
        return '「${latest.answer}」から何が見つかった？';
      case ThoughtCategory.core:
        return '「${latest.answer}」の中でいちばん大事なことは？';
      case ThoughtCategory.direction:
        return '「${latest.answer}」の次にめざすことは？';
      case ThoughtCategory.wisdom:
        return '「${latest.answer}」を誰かに教えるとしたら？';
      case ThoughtCategory.expression:
        return '「${latest.answer}」を絵や言葉でどう伝える？';
      case ThoughtCategory.mastery:
        return '「${latest.answer}」を完ぺきにするための最後の一歩は？';
    }
  }

  String get defaultQuestion {
    switch (this) {
      case ThoughtCategory.pride: return 'じぶんのとくいなことは？';
      case ThoughtCategory.analysis: return 'どうしてそうなると思う？';
      case ThoughtCategory.creation: return 'あたらしいアイデアは？';
      case ThoughtCategory.discovery: return '最近みつけたことは？';
      case ThoughtCategory.core: return 'いちばんたいせつなことは？';
      case ThoughtCategory.direction: return 'これからどうしたい？';
      case ThoughtCategory.wisdom: return 'しっていることを教えて';
      case ThoughtCategory.expression: return 'どうやって伝える？';
      case ThoughtCategory.mastery: return 'かんぺきにするには？';
    }
  }
}
