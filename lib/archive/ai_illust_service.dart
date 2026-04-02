import 'dart:math' as math;

/// AI イラスト生成プロキシ
/// 将来: Gemini API に写真+テキストを送信し、ファンタジー調イラストURLを取得
/// 現在: プレースホルダー実装（ローカルでダミーURLを返す）
class AiIllustService {
  /// 写真とテキストからAIイラストURLを生成
  /// [photoPath] ローカル写真パス
  /// [description] ユーザーの入力テキスト
  /// [stamp] 記憶のスタンプタイプ
  ///
  /// Returns: AIイラストのURL（将来はGemini APIから取得）
  static Future<String> generateIllust({
    required String? photoPath,
    required String description,
    required String stamp,
  }) async {
    // === PLACEHOLDER: Gemini API 連携用 ===
    // 将来の実装:
    // 1. photoPath の画像をBase64エンコード
    // 2. Gemini API (gemini-2.0-flash) に送信
    //    prompt: "この写真と説明「$description」を元に、
    //            ファンタジー調の水彩イラストを生成してください"
    // 3. 生成された画像URLを返す
    //
    // final response = await http.post(
    //   Uri.parse('https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent'),
    //   headers: {'Content-Type': 'application/json'},
    //   body: jsonEncode({
    //     'contents': [{
    //       'parts': [
    //         {'text': 'ファンタジー調の水彩イラストとして再解釈: $description'},
    //         if (photoPath != null) {'inline_data': {'mime_type': 'image/jpeg', 'data': base64Image}},
    //       ]
    //     }]
    //   }),
    // );
    // return parseImageUrl(response.body);

    // ダミー: スタンプに応じた疑似URLを返す
    await Future.delayed(const Duration(milliseconds: 500)); // API遅延シミュレート
    final seed = description.hashCode;
    return 'memory://generated/$stamp/$seed';
  }

  /// ダミーURLからAIイラストの「テーマカラー」を導出
  /// （実際のURL画像が利用可能になるまでのフォールバック）
  static FantasyTheme themeFromUrl(String url) {
    final hash = url.hashCode.abs();
    final themes = FantasyTheme.values;
    return themes[hash % themes.length];
  }
}

/// AIイラストのファンタジーテーマ（CustomPainterで描画する代替表現）
enum FantasyTheme {
  enchantedForest,   // 魔法の森
  crystalCave,       // 水晶の洞窟
  skyKingdom,        // 天空の王国
  oceanDepths,       // 深海の宮殿
  starryDesert,      // 星降る砂漠
}
