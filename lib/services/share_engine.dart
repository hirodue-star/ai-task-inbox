import 'dart:io';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;

/// 低コストSNSエンジン — 全処理オンデバイス、サーバー課金ゼロ

class ShareEngine {
  /// シェア用画像生成（ブランディング付き）
  /// 元画像 + MAロゴ + QRコード風マーク を合成
  static Future<String?> createBrandedImage(String sourcePath) async {
    try {
      final sourceBytes = await File(sourcePath).readAsBytes();
      final codec = await ui.instantiateImageCodec(sourceBytes);
      final frame = await codec.getNextFrame();
      final source = frame.image;

      final w = source.width.toDouble();
      final h = source.height.toDouble();
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder, Rect.fromLTWH(0, 0, w, h));

      // 元画像
      canvas.drawImage(source, Offset.zero, Paint());

      // 下部バナー（半透明）
      final bannerH = h * 0.08;
      final bannerPaint = Paint()..color = const Color(0xCC000000);
      canvas.drawRect(Rect.fromLTWH(0, h - bannerH, w, bannerH), bannerPaint);

      // MAロゴ（左）
      final logoPaint = Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xFFFFD700), Color(0xFFC8960C)],
        ).createShader(Rect.fromLTWH(12, h - bannerH + 4, bannerH - 8, bannerH - 8));
      canvas.drawCircle(
        Offset(12 + (bannerH - 8) / 2, h - bannerH / 2),
        (bannerH - 8) / 2,
        logoPaint,
      );

      // テキスト「MA-LOGIC」
      final textPainter = TextPainter(
        text: TextSpan(
          text: 'MA-LOGIC',
          style: TextStyle(
            fontSize: bannerH * 0.4,
            fontWeight: FontWeight.w800,
            color: const Color(0xFFFFD700),
            letterSpacing: 2,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      textPainter.paint(canvas, Offset(bannerH + 8, h - bannerH / 2 - textPainter.height / 2));

      // QRコード風マーク（右端に小さな四角パターン）
      final qrSize = bannerH * 0.6;
      final qrX = w - qrSize - 12;
      final qrY = h - bannerH / 2 - qrSize / 2;
      _drawMiniQR(canvas, qrX, qrY, qrSize);

      // 書き出し
      final picture = recorder.endRecording();
      final img = await picture.toImage(source.width, source.height);
      final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return null;

      final outPath = p.join(Directory.systemTemp.path, 'share_${DateTime.now().millisecondsSinceEpoch}.png');
      await File(outPath).writeAsBytes(byteData.buffer.asUint8List());
      return outPath;
    } catch (e) {
      debugPrint('ShareEngine error: $e');
      return null;
    }
  }

  /// ハッシュタグ自動生成 → クリップボードコピー
  static Future<String> generateAndCopyHashtags({
    required String stampLabel,
    bool isManga = false,
  }) async {
    final tags = <String>[
      '#MA_LOGIC',
      '#知育',
      '#育児日記',
    ];

    if (isManga) tags.addAll(['#育児漫画', '#漫画日記', '#子供の作品']);
    tags.addAll(['#子供の成長', '#お手伝い', '#非認知能力']);

    // スタンプ固有タグ
    switch (stampLabel) {
      case 'おもいやり': case 'おてつだい':
        tags.addAll(['#思いやり', '#ホスピタリティ']);
        break;
      case 'がんばった': case 'ちょうせん':
        tags.addAll(['#挑戦', '#私立小学校受験']);
        break;
      case 'つくった':
        tags.addAll(['#子供アート', '#巧緻性']);
        break;
      default:
        tags.add('#日常の発見');
    }

    final hashtagString = tags.join(' ');
    await Clipboard.setData(ClipboardData(text: hashtagString));
    return hashtagString;
  }

  /// テンポラリファイルのクリーンアップ
  static Future<int> cleanupTempFiles() async {
    final tempDir = Directory.systemTemp;
    int deleted = 0;
    await for (final entity in tempDir.list()) {
      if (entity is File && entity.path.contains('share_')) {
        final age = DateTime.now().difference(await entity.lastModified());
        if (age.inHours > 1) {
          await entity.delete();
          deleted++;
        }
      }
    }
    debugPrint('ShareEngine: cleaned $deleted temp files');
    return deleted;
  }

  /// ミニQRコード風パターン描画
  static void _drawMiniQR(Canvas canvas, double x, double y, double size) {
    final cellSize = size / 5;
    final paint = Paint()..color = Colors.white;

    // シンプルなQR風パターン（実際のQRではなく視覚的な装飾）
    const pattern = [
      [1,1,1,0,1],
      [1,0,1,0,0],
      [1,1,1,0,1],
      [0,0,0,0,1],
      [1,0,1,1,1],
    ];
    for (var row = 0; row < 5; row++) {
      for (var col = 0; col < 5; col++) {
        if (pattern[row][col] == 1) {
          canvas.drawRect(
            Rect.fromLTWH(x + col * cellSize, y + row * cellSize, cellSize * 0.9, cellSize * 0.9),
            paint,
          );
        }
      }
    }
  }
}
