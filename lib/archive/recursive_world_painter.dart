import 'dart:math' as math;
import 'package:flutter/material.dart';

/// 自己拡張型背景 — ユーザーの行動データをシード値として模様を動的生成
/// 「この画面は世界に一つ、自分の思考の写し鏡」
class RecursiveWorldPainter extends CustomPainter {
  final int actionSeed;     // 累計アクション数ベースのシード
  final double animValue;
  final double windSpeed;   // 親のアンビエント接続（風速）
  final int starCount;      // 親のアンビエント接続（星の数）

  RecursiveWorldPainter({
    required this.actionSeed,
    required this.animValue,
    this.windSpeed = 1.0,
    this.starCount = 30,
  });

  @override
  void paint(Canvas canvas, Size size) {
    _drawPersonalConstellation(canvas, size);
    _drawFlowField(canvas, size);
    _drawAmbientWind(canvas, size);
  }

  /// ユーザー固有の星座パターン（行動データの写し鏡）
  void _drawPersonalConstellation(Canvas canvas, Size size) {
    final rng = math.Random(actionSeed);
    final nodeCount = 8 + (actionSeed % 7);

    final nodes = <Offset>[];
    for (var i = 0; i < nodeCount; i++) {
      nodes.add(Offset(
        size.width * (0.1 + rng.nextDouble() * 0.8),
        size.height * (0.05 + rng.nextDouble() * 0.5),
      ));
    }

    // 接続線（シード依存のトポロジー）
    final linePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    for (var i = 0; i < nodes.length; i++) {
      for (var j = i + 1; j < nodes.length; j++) {
        final dist = (nodes[i] - nodes[j]).distance;
        if (dist < size.width * 0.3 && rng.nextDouble() > 0.4) {
          final hue = (actionSeed * 13 + i * 40 + j * 60) % 360;
          final pulse = (math.sin(animValue * math.pi * 2 + i + j * 0.5) + 1) / 2;
          linePaint.color = HSLColor.fromAHSL(0.08 + pulse * 0.08, hue.toDouble(), 0.4, 0.7).toColor();
          canvas.drawLine(nodes[i], nodes[j], linePaint);
        }
      }
    }

    // ノード（各行動の結晶）
    for (var i = 0; i < nodes.length; i++) {
      final hue = (actionSeed * 7 + i * 50) % 360;
      final pulse = (math.sin(animValue * math.pi * 2 + i * 1.3) + 1) / 2;
      final r = 2 + pulse * 2;

      final nodePaint = Paint()
        ..color = HSLColor.fromAHSL(0.2 + pulse * 0.3, hue.toDouble(), 0.5, 0.7).toColor();
      canvas.drawCircle(nodes[i], r, nodePaint);

      // グロー
      final glowPaint = Paint()
        ..shader = RadialGradient(
          colors: [
            HSLColor.fromAHSL(0.06 * pulse, hue.toDouble(), 0.5, 0.7).toColor(),
            HSLColor.fromAHSL(0, hue.toDouble(), 0.5, 0.7).toColor(),
          ],
        ).createShader(Rect.fromCircle(center: nodes[i], radius: r * 6));
      canvas.drawCircle(nodes[i], r * 6, glowPaint);
    }
  }

  /// フローフィールド（思考の流れ）
  void _drawFlowField(Canvas canvas, Size size) {
    final rng = math.Random(actionSeed + 1000);
    final linePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8
      ..strokeCap = StrokeCap.round;

    for (var i = 0; i < 12; i++) {
      var x = rng.nextDouble() * size.width;
      var y = size.height * 0.3 + rng.nextDouble() * size.height * 0.4;
      final path = Path()..moveTo(x, y);

      final hue = (actionSeed * 3 + i * 30) % 360;
      linePaint.color = HSLColor.fromAHSL(0.06, hue.toDouble(), 0.3, 0.6).toColor();

      for (var step = 0; step < 30; step++) {
        // パーリンノイズ風のフロー
        final angle = math.sin(x * 0.01 + actionSeed * 0.1) * math.cos(y * 0.01) * math.pi * 2
            + animValue * math.pi * 2 * 0.1;
        x += math.cos(angle) * 4 * windSpeed;
        y += math.sin(angle) * 4;
        path.lineTo(x, y);
      }
      canvas.drawPath(path, linePaint);
    }
  }

  /// アンビエント風（親の存在の揺らぎ）
  void _drawAmbientWind(Canvas canvas, Size size) {
    if (windSpeed <= 0.5) return;

    final windPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.6
      ..strokeCap = StrokeCap.round;

    final intensity = ((windSpeed - 0.5) / 1.5).clamp(0.0, 1.0);

    for (var i = 0; i < (8 * intensity).round(); i++) {
      final y = size.height * (0.2 + i * 0.08);
      final path = Path();
      final offset = animValue * size.width * windSpeed * 0.3 + i * 50;

      for (var x = -50.0; x < size.width + 50; x += 2) {
        final waveY = y + math.sin((x + offset) * 0.02) * 8 * windSpeed;
        if (x == -50) path.moveTo(x, waveY); else path.lineTo(x, waveY);
      }

      windPaint.color = Colors.white.withOpacity(0.03 * intensity);
      canvas.drawPath(path, windPaint);
    }
  }

  @override
  bool shouldRepaint(RecursiveWorldPainter old) =>
      actionSeed != old.actionSeed ||
      animValue != old.animValue ||
      windSpeed != old.windSpeed;
}
