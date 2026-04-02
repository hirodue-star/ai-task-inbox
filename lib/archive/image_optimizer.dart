import 'dart:io';
import 'dart:ui' as ui;
import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;

/// ストレージ・エコノミー — 画像圧縮・リサイズ
/// 線画の解像度を維持しつつ容量を最小化
class ImageOptimizer {
  /// 写真を保存用にリサイズ + 圧縮
  /// - 日常写真: 800px幅に縮小（容量節約）
  /// - 線画変換後: 1200px幅を維持（資産価値保持）
  static Future<String?> optimizeAndSave(
    String sourcePath, {
    required String destDir,
    int maxWidth = 800,
    int quality = 75,
    bool isLineArt = false,
  }) async {
    try {
      final file = File(sourcePath);
      if (!await file.exists()) return null;

      final bytes = await file.readAsBytes();
      final codec = await ui.instantiateImageCodec(bytes);
      final frame = await codec.getNextFrame();
      final image = frame.image;

      // リサイズ幅決定
      final targetWidth = isLineArt ? 1200 : maxWidth;
      final scale = image.width > targetWidth ? targetWidth / image.width : 1.0;
      final newW = (image.width * scale).round();
      final newH = (image.height * scale).round();

      // リサイズ（PictureRecorder経由）
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder, Rect.fromLTWH(0, 0, newW.toDouble(), newH.toDouble()));
      canvas.drawImageRect(
        image,
        Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
        Rect.fromLTWH(0, 0, newW.toDouble(), newH.toDouble()),
        Paint()..filterQuality = FilterQuality.medium,
      );
      final picture = recorder.endRecording();
      final resized = await picture.toImage(newW, newH);

      // PNG書き出し
      final byteData = await resized.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return null;

      final destFile = File(p.join(destDir, '${DateTime.now().millisecondsSinceEpoch}.png'));
      await destFile.writeAsBytes(byteData.buffer.asUint8List());

      // 元ファイルサイズとの比較ログ
      final origSize = await file.length();
      final newSize = await destFile.length();
      debugPrint('ImageOptimizer: ${origSize ~/ 1024}KB → ${newSize ~/ 1024}KB '
          '(${((1 - newSize / origSize) * 100).toStringAsFixed(0)}% saved)');

      return destFile.path;
    } catch (e) {
      debugPrint('ImageOptimizer error: $e');
      return null;
    }
  }

  /// ストレージ使用量概算
  static Future<StorageReport> getStorageReport(String baseDir) async {
    final dir = Directory(baseDir);
    if (!await dir.exists()) {
      return const StorageReport(totalFiles: 0, totalBytes: 0, photoBytes: 0, lineArtBytes: 0);
    }

    int totalFiles = 0;
    int totalBytes = 0;
    int photoBytes = 0;
    int lineArtBytes = 0;

    await for (final entity in dir.list(recursive: true)) {
      if (entity is File) {
        totalFiles++;
        final size = await entity.length();
        totalBytes += size;
        if (entity.path.contains('lineart')) {
          lineArtBytes += size;
        } else {
          photoBytes += size;
        }
      }
    }

    return StorageReport(
      totalFiles: totalFiles,
      totalBytes: totalBytes,
      photoBytes: photoBytes,
      lineArtBytes: lineArtBytes,
    );
  }
}

class StorageReport {
  final int totalFiles;
  final int totalBytes;
  final int photoBytes;
  final int lineArtBytes;

  const StorageReport({
    required this.totalFiles,
    required this.totalBytes,
    required this.photoBytes,
    required this.lineArtBytes,
  });

  String get totalMB => '${(totalBytes / 1024 / 1024).toStringAsFixed(1)} MB';
  String get photoMB => '${(photoBytes / 1024 / 1024).toStringAsFixed(1)} MB';
  String get lineArtMB => '${(lineArtBytes / 1024 / 1024).toStringAsFixed(1)} MB';
}
