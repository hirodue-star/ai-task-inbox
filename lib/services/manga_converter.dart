import 'dart:io';
import 'dart:math' as math;
import 'package:image/image.dart' as img;
import 'package:path/path.dart' as p;
import 'package:flutter/foundation.dart';

/// オンデバイス漫画変換 — 写真→線画（API課金ゼロ）
/// imageパッケージでピクセル操作、100%ローカル処理
class MangaConverter {
  /// 写真を漫画風線画に変換して保存
  /// Returns: 保存先パス
  static Future<String?> convert(String photoPath, String outputDir) async {
    return compute(_convertIsolate, _ConvertParams(photoPath, outputDir));
  }

  /// Isolateで実行（UIスレッドをブロックしない）
  static String? _convertIsolate(_ConvertParams params) {
    try {
      final bytes = File(params.photoPath).readAsBytesSync();
      var source = img.decodeImage(bytes);
      if (source == null) return null;

      // 1. リサイズ（800px幅、線画品質維持）
      if (source.width > 800) {
        source = img.copyResize(source, width: 800);
      }

      final w = source.width;
      final h = source.height;

      // 2. グレースケール化
      final gray = img.grayscale(source);

      // 3. Sobelエッジ検出
      final output = img.Image(width: w, height: h);

      for (var y = 1; y < h - 1; y++) {
        for (var x = 1; x < w - 1; x++) {
          // Sobel X
          final gx =
              -_lum(gray, x - 1, y - 1) + _lum(gray, x + 1, y - 1)
              - 2 * _lum(gray, x - 1, y) + 2 * _lum(gray, x + 1, y)
              - _lum(gray, x - 1, y + 1) + _lum(gray, x + 1, y + 1);

          // Sobel Y
          final gy =
              -_lum(gray, x - 1, y - 1) - 2 * _lum(gray, x, y - 1) - _lum(gray, x + 1, y - 1)
              + _lum(gray, x - 1, y + 1) + 2 * _lum(gray, x, y + 1) + _lum(gray, x + 1, y + 1);

          final edge = math.sqrt(gx * gx + gy * gy);
          final brightness = _lum(gray, x, y);

          int val;
          if (edge > 25) {
            // エッジ → 黒い線
            val = (255 - (edge * 2).clamp(0, 200)).round();
          } else if (brightness < 80) {
            // 暗い部分 → ドットトーン
            val = (x % 3 == 0 && y % 3 == 0) ? 180 : 245;
          } else {
            // 明るい部分 → 白
            val = 255;
          }

          output.setPixelRgb(x, y, val, val, val);
        }
      }

      // 4. PNG保存
      final outPath = p.join(params.outputDir, 'manga_${DateTime.now().millisecondsSinceEpoch}.png');
      File(outPath).writeAsBytesSync(img.encodePng(output));
      return outPath;
    } catch (e) {
      return null;
    }
  }

  static double _lum(img.Image image, int x, int y) {
    final pixel = image.getPixel(x, y);
    return pixel.r.toDouble();
  }
}

class _ConvertParams {
  final String photoPath;
  final String outputDir;
  const _ConvertParams(this.photoPath, this.outputDir);
}
