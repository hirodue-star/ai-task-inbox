import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/ma_colors.dart';

/// 🐧 ペンギン級：氷の結晶描画
class IceCrystalPainter extends CustomPainter {
  final double animValue;
  final int sides;

  IceCrystalPainter({this.animValue = 0, this.sides = 6});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width * 0.4;

    // 外側のグロー
    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          MaColors.penguinIce.withValues(alpha: 0.3),
          MaColors.penguinIce.withValues(alpha: 0),
        ],
      ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: r * 1.4));
    canvas.drawCircle(Offset(cx, cy), r * 1.4, glowPaint);

    // メイン六角形
    _drawHexagon(canvas, cx, cy, r, animValue);

    // 内側の結晶パターン
    _drawInnerPattern(canvas, cx, cy, r * 0.6, animValue);

    // 中央の光
    final corePaint = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.white.withValues(alpha: 0.8),
          MaColors.penguinIce.withValues(alpha: 0.3),
          MaColors.penguinIce.withValues(alpha: 0),
        ],
        stops: const [0.0, 0.3, 1.0],
      ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: r * 0.25));
    canvas.drawCircle(Offset(cx, cy), r * 0.25, corePaint);
  }

  void _drawHexagon(Canvas canvas, double cx, double cy, double r, double anim) {
    final rotation = anim * math.pi * 2 * 0.05; // ゆっくり回転

    // 外枠
    final borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..shader = LinearGradient(
        colors: [
          MaColors.penguinIce,
          Colors.white.withValues(alpha: 0.9),
          MaColors.penguinDeep,
        ],
      ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: r));

    // 面
    final fillPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.2, -0.3),
        colors: [
          Colors.white.withValues(alpha: 0.15),
          MaColors.penguinIce.withValues(alpha: 0.08),
          MaColors.penguinDeep.withValues(alpha: 0.05),
        ],
      ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: r));

    final path = Path();
    for (var i = 0; i < sides; i++) {
      final angle = (i * 2 * math.pi / sides) - math.pi / 2 + rotation;
      final x = cx + r * math.cos(angle);
      final y = cy + r * math.sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();

    canvas.drawPath(path, fillPaint);
    canvas.drawPath(path, borderPaint);
  }

  void _drawInnerPattern(Canvas canvas, double cx, double cy, double r, double anim) {
    final linePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..color = MaColors.penguinIce.withValues(alpha: 0.4);

    // 結晶の枝
    for (var i = 0; i < 6; i++) {
      final angle = (i * math.pi / 3) - math.pi / 2;
      final x = cx + r * math.cos(angle);
      final y = cy + r * math.sin(angle);
      canvas.drawLine(Offset(cx, cy), Offset(x, y), linePaint);

      // 枝の先のミニ六角形
      final miniR = r * 0.2;
      final twinkle = (math.sin(anim * math.pi * 2 + i) + 1) / 2;
      final miniPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0
        ..color = Colors.white.withValues(alpha: 0.3 + twinkle * 0.4);

      final miniPath = Path();
      for (var j = 0; j < 6; j++) {
        final a = (j * math.pi / 3) - math.pi / 2;
        final mx = x + miniR * math.cos(a);
        final my = y + miniR * math.sin(a);
        if (j == 0) {
          miniPath.moveTo(mx, my);
        } else {
          miniPath.lineTo(mx, my);
        }
      }
      miniPath.close();
      canvas.drawPath(miniPath, miniPaint);
    }
  }

  @override
  bool shouldRepaint(IceCrystalPainter old) => animValue != old.animValue;
}

/// 🐧 ペンギン級背景：氷のクリスタリン
class PenguinBgPainter extends CustomPainter {
  final double animValue;

  PenguinBgPainter({this.animValue = 0});

  @override
  void paint(Canvas canvas, Size size) {
    // ベースグラデーション
    final bgPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFFE8F4FF), Color(0xFFD0E8FF), Color(0xFFB8D8F8)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    // 浮遊する氷の結晶
    final rng = math.Random(77);
    for (var i = 0; i < 8; i++) {
      final cx = rng.nextDouble() * size.width;
      final baseY = rng.nextDouble() * size.height;
      final cy = (baseY - animValue * size.height * 0.15 * (0.5 + rng.nextDouble())) %
          (size.height + 40) - 20;
      final cr = 15 + rng.nextDouble() * 25;
      final rotation = animValue * math.pi * 2 * 0.1 + i * 0.5;

      canvas.save();
      canvas.translate(cx, cy);
      canvas.rotate(rotation);

      // ミニ六角形
      final hexPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..color = Colors.white.withValues(alpha: 0.3 + rng.nextDouble() * 0.3);

      final path = Path();
      for (var j = 0; j < 6; j++) {
        final angle = (j * math.pi / 3) - math.pi / 2;
        final x = cr * math.cos(angle);
        final y = cr * math.sin(angle);
        if (j == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      path.close();
      canvas.drawPath(path, hexPaint);

      // 光の反射
      final hlPaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.2);
      canvas.drawCircle(Offset(-cr * 0.2, -cr * 0.2), cr * 0.15, hlPaint);

      canvas.restore();
    }

    // 光のシャフト（上から差す光）
    for (var i = 0; i < 3; i++) {
      final sx = size.width * (0.2 + i * 0.3);
      final shimmer = (math.sin(animValue * math.pi * 2 + i * 1.5) + 1) / 2;
      final shaftPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.white.withValues(alpha: 0.1 * shimmer),
            Colors.white.withValues(alpha: 0),
          ],
        ).createShader(Rect.fromLTWH(sx - 30, 0, 60, size.height * 0.6));
      canvas.drawRect(Rect.fromLTWH(sx - 30, 0, 60, size.height * 0.6), shaftPaint);
    }
  }

  @override
  bool shouldRepaint(PenguinBgPainter old) => animValue != old.animValue;
}

/// 氷の結晶ウィジェット
class IceCrystal extends StatelessWidget {
  final double size;
  final double animValue;

  const IceCrystal({super.key, this.size = 120, this.animValue = 0});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: IceCrystalPainter(animValue: animValue)),
    );
  }
}
