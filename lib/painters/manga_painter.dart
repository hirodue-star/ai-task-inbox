import 'dart:async';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

/// オンデバイス漫画変換エンジン（API課金ゼロ）
/// Sobelエッジ検出 + ドットトーンで写真→漫画線画に変換
class MangaConverter {
  /// 画像をモノクロ漫画風に変換
  /// 完全オンデバイス処理 — ネットワーク不要
  static Future<ui.Image> convertToManga(ui.Image source, {
    double edgeThreshold = 30,
    int dotSpacing = 4,
    double dotMaxRadius = 1.5,
  }) async {
    final w = source.width;
    final h = source.height;

    // ピクセルデータ取得
    final byteData = await source.toByteData(format: ui.ImageByteFormat.rawRgba);
    if (byteData == null) return source;
    final pixels = byteData.buffer.asUint8List();

    // グレースケール変換
    final gray = Float64List(w * h);
    for (var y = 0; y < h; y++) {
      for (var x = 0; x < w; x++) {
        final i = (y * w + x) * 4;
        gray[y * w + x] = pixels[i] * 0.299 + pixels[i + 1] * 0.587 + pixels[i + 2] * 0.114;
      }
    }

    // Sobelエッジ検出
    final edges = Float64List(w * h);
    for (var y = 1; y < h - 1; y++) {
      for (var x = 1; x < w - 1; x++) {
        // Sobel X
        final gx = -gray[(y - 1) * w + (x - 1)] + gray[(y - 1) * w + (x + 1)]
                  - 2 * gray[y * w + (x - 1)] + 2 * gray[y * w + (x + 1)]
                  - gray[(y + 1) * w + (x - 1)] + gray[(y + 1) * w + (x + 1)];
        // Sobel Y
        final gy = -gray[(y - 1) * w + (x - 1)] - 2 * gray[(y - 1) * w + x] - gray[(y - 1) * w + (x + 1)]
                  + gray[(y + 1) * w + (x - 1)] + 2 * gray[(y + 1) * w + x] + gray[(y + 1) * w + (x + 1)];
        edges[y * w + x] = math.sqrt(gx * gx + gy * gy);
      }
    }

    // 出力ピクセル生成
    final output = Uint8List(w * h * 4);
    for (var y = 0; y < h; y++) {
      for (var x = 0; x < w; x++) {
        final i = (y * w + x) * 4;
        final edge = edges[y * w + x];

        int val;
        if (edge > edgeThreshold) {
          // エッジ → 黒い線
          val = 0;
        } else {
          // ドットトーン（網点）
          final brightness = gray[y * w + x] / 255.0;
          if (x % dotSpacing == 0 && y % dotSpacing == 0) {
            final dotR = (1.0 - brightness) * dotMaxRadius;
            final dx = (x % dotSpacing).toDouble();
            final dy = (y % dotSpacing).toDouble();
            if (dx * dx + dy * dy < dotR * dotR * dotSpacing * dotSpacing) {
              val = (brightness * 200).round().clamp(0, 255);
            } else {
              val = 255;
            }
          } else {
            // 明るさに応じたグレー（ベタ塗り部分）
            val = brightness > 0.7 ? 255 : (brightness * 300).round().clamp(180, 255);
          }
        }

        output[i] = val;     // R
        output[i + 1] = val; // G
        output[i + 2] = val; // B
        output[i + 3] = 255; // A
      }
    }

    // Uint8List → ui.Image
    final completer = Completer<ui.Image>();
    ui.decodeImageFromPixels(
      output, w, h, ui.PixelFormat.rgba8888,
      (img) => completer.complete(img),
    );
    return completer.future;
  }

  /// 線画のみ抽出（スケッチデジタイザー用）
  /// 白背景を透過にして線だけをマンガスタンプ化
  static Future<ui.Image> extractLines(ui.Image source, {
    double threshold = 40,
  }) async {
    final w = source.width;
    final h = source.height;
    final byteData = await source.toByteData(format: ui.ImageByteFormat.rawRgba);
    if (byteData == null) return source;
    final pixels = byteData.buffer.asUint8List();

    final gray = Float64List(w * h);
    for (var y = 0; y < h; y++) {
      for (var x = 0; x < w; x++) {
        final i = (y * w + x) * 4;
        gray[y * w + x] = pixels[i] * 0.299 + pixels[i + 1] * 0.587 + pixels[i + 2] * 0.114;
      }
    }

    final edges = Float64List(w * h);
    for (var y = 1; y < h - 1; y++) {
      for (var x = 1; x < w - 1; x++) {
        final gx = -gray[(y - 1) * w + (x - 1)] + gray[(y - 1) * w + (x + 1)]
                  - 2 * gray[y * w + (x - 1)] + 2 * gray[y * w + (x + 1)]
                  - gray[(y + 1) * w + (x - 1)] + gray[(y + 1) * w + (x + 1)];
        final gy = -gray[(y - 1) * w + (x - 1)] - 2 * gray[(y - 1) * w + x] - gray[(y - 1) * w + (x + 1)]
                  + gray[(y + 1) * w + (x - 1)] + 2 * gray[(y + 1) * w + x] + gray[(y + 1) * w + (x + 1)];
        edges[y * w + x] = math.sqrt(gx * gx + gy * gy);
      }
    }

    // 線のみ残し、背景は透過
    final output = Uint8List(w * h * 4);
    for (var y = 0; y < h; y++) {
      for (var x = 0; x < w; x++) {
        final i = (y * w + x) * 4;
        if (edges[y * w + x] > threshold) {
          output[i] = 30;      // R
          output[i + 1] = 30;  // G
          output[i + 2] = 30;  // B
          output[i + 3] = ((edges[y * w + x] / 255) * 255).round().clamp(100, 255); // A
        } else {
          output[i] = 0;
          output[i + 1] = 0;
          output[i + 2] = 0;
          output[i + 3] = 0; // 透過
        }
      }
    }

    final completer = Completer<ui.Image>();
    ui.decodeImageFromPixels(
      output, w, h, ui.PixelFormat.rgba8888,
      (img) => completer.complete(img),
    );
    return completer.future;
  }
}

/// 漫画コマ描画 — 吹き出し + コマ割り
class MangaPanelPainter extends CustomPainter {
  final String text;
  final bool isNarration;

  MangaPanelPainter({required this.text, this.isNarration = false});

  @override
  void paint(Canvas canvas, Size size) {
    // コマ枠
    final borderPaint = Paint()
      ..color = const Color(0xFF1A1A1A)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(2, 2, size.width - 4, size.height - 4),
        const Radius.circular(4),
      ),
      borderPaint,
    );

    if (isNarration) {
      // ナレーション枠（上部の四角い枠）
      final narrationRect = Rect.fromLTWH(8, 8, size.width * 0.6, 30);
      final narPaint = Paint()..color = const Color(0xFFF5F5F5);
      final narBorder = Paint()
        ..color = const Color(0xFF1A1A1A)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1;
      canvas.drawRect(narrationRect, narPaint);
      canvas.drawRect(narrationRect, narBorder);
    }
  }

  @override
  bool shouldRepaint(MangaPanelPainter old) => text != old.text;
}

/// 吹き出し描画
class BalloonPainter extends CustomPainter {
  final bool isSpeech; // true: 吹き出し, false: 思考泡

  BalloonPainter({this.isSpeech = true});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final rx = size.width * 0.45;
    final ry = size.height * 0.38;

    // 吹き出し本体
    final fillPaint = Paint()..color = Colors.white;
    final borderPaint = Paint()
      ..color = const Color(0xFF1A1A1A)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawOval(Rect.fromCenter(center: Offset(cx, cy), width: rx * 2, height: ry * 2), fillPaint);
    canvas.drawOval(Rect.fromCenter(center: Offset(cx, cy), width: rx * 2, height: ry * 2), borderPaint);

    if (isSpeech) {
      // しっぽ（三角形）
      final tailPath = Path()
        ..moveTo(cx - 10, cy + ry - 2)
        ..lineTo(cx - 20, cy + ry + 15)
        ..lineTo(cx + 5, cy + ry - 2);
      canvas.drawPath(tailPath, fillPaint);
      canvas.drawPath(tailPath, borderPaint);
    } else {
      // 思考泡（小さい丸）
      canvas.drawCircle(Offset(cx - 15, cy + ry + 5), 5, fillPaint);
      canvas.drawCircle(Offset(cx - 15, cy + ry + 5), 5, borderPaint);
      canvas.drawCircle(Offset(cx - 22, cy + ry + 14), 3, fillPaint);
      canvas.drawCircle(Offset(cx - 22, cy + ry + 14), 3, borderPaint);
    }
  }

  @override
  bool shouldRepaint(BalloonPainter old) => isSpeech != old.isSpeech;
}
