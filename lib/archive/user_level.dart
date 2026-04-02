/// ユーザーレベル（1-10）とUI段階のマッピング
class UserLevel {
  final int level; // 1-10
  final int totalXp;

  const UserLevel({required this.level, required this.totalXp});

  /// UI段階
  UiTier get tier {
    if (level <= 3) return UiTier.intuitive;   // ひよこ：直感UI
    if (level <= 7) return UiTier.analytical;   // ペンギン：比較・論理UI
    return UiTier.abstract;                      // ライオン：抽象思考UI
  }

  /// 次のレベルに必要なXP
  int get xpForNext => _xpTable[level.clamp(1, 10)] ?? 999;

  /// 現レベル内の進捗率
  double get progress {
    final prev = level > 1 ? (_xpTable[level - 1] ?? 0) : 0;
    final next = xpForNext;
    if (next <= prev) return 1.0;
    return ((totalXp - prev) / (next - prev)).clamp(0.0, 1.0);
  }

  /// レベルアップ判定
  bool get shouldLevelUp => totalXp >= xpForNext && level < 10;

  UserLevel addXp(int xp) {
    final newXp = totalXp + xp;
    var newLevel = level;
    while (newLevel < 10 && newXp >= (_xpTable[newLevel] ?? 999)) {
      newLevel++;
    }
    return UserLevel(level: newLevel, totalXp: newXp);
  }

  /// 日記の問いかけレベル
  QuestionDepth get questionDepth {
    if (level <= 3) return QuestionDepth.concrete;
    if (level <= 7) return QuestionDepth.comparative;
    return QuestionDepth.philosophical;
  }

  static const _xpTable = {
    1: 30,
    2: 80,
    3: 150,
    4: 250,
    5: 400,
    6: 600,
    7: 850,
    8: 1200,
    9: 1600,
    10: 9999,
  };
}

enum UiTier {
  intuitive,   // Lv1-3 直感UI（ボタン少、音声・エフェクト主体）
  analytical,  // Lv4-7 比較・論理UI（2画面分割、D&D）
  abstract,    // Lv8-10 抽象思考UI（マンダラ中心）
}

enum QuestionDepth {
  concrete,       // 具体物の名前（なにをたべた？）
  comparative,    // 特徴の比較（どっちがおおきい？なぜ？）
  philosophical,  // 存在の理由（なぜそれがたいせつ？）
}

extension QuestionDepthExt on QuestionDepth {
  List<String> questionsForStamp(String stamp) {
    switch (this) {
      case QuestionDepth.concrete:
        return _concreteQuestions(stamp);
      case QuestionDepth.comparative:
        return _comparativeQuestions(stamp);
      case QuestionDepth.philosophical:
        return _philosophicalQuestions(stamp);
    }
  }

  static List<String> _concreteQuestions(String stamp) {
    switch (stamp) {
      case 'ate': return ['なにをたべた？', 'どんないろだった？'];
      case 'went': return ['どこにいった？', 'なにがあった？'];
      case 'played': return ['なにであそんだ？', 'だれとあそんだ？'];
      case 'pet': return ['どんなどうぶつ？', 'なにをした？'];
      case 'challenge': return ['なにをした？', 'できた？'];
      default: return ['なにをした？'];
    }
  }

  static List<String> _comparativeQuestions(String stamp) {
    switch (stamp) {
      case 'ate': return ['きのうたべたものとくらべて、どこがちがう？', 'なぜこれをえらんだの？'];
      case 'went': return ['まえにいったところとくらべてどうだった？', 'いちばんちがったところは？'];
      case 'played': return ['ほかのあそびとくらべてどこがおもしろい？', 'もしルールをかえるならどうする？'];
      case 'pet': return ['ほかのどうぶつとくらべてどうちがう？', 'にんげんとどこがおなじ？'];
      case 'challenge': return ['まえのちょうせんとくらべてどうだった？', 'なにがいちばんむずかしかった？'];
      default: return ['まえとくらべてどうだった？'];
    }
  }

  static List<String> _philosophicalQuestions(String stamp) {
    switch (stamp) {
      case 'ate': return ['「おいしい」ってどういうことだとおもう？', 'たべものがあることは、あたりまえ？'];
      case 'went': return ['その場所はなぜそこにあるんだろう？', 'もしその場所がなかったら、せかいはどうかわる？'];
      case 'played': return ['あそびはなぜたのしいんだろう？', 'もしあそびがない世界だったら？'];
      case 'pet': return ['どうぶつにも「きもち」はあるとおもう？', 'いのちをたいせつにするってどういうこと？'];
      case 'challenge': return ['ちょうせんするゆうきはどこからくるの？', 'しっぱいはわるいこと？それともいいこと？'];
      default: return ['それはなぜたいせつ？'];
    }
  }
}
