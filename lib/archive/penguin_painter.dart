import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/ma_colors.dart';

/// 🐧 ペンギン表情タイプ
enum PenguinMood { focus, clean, craft, success }

/// ペンギンキャラをCustomPainterで描画
class PenguinPainter extends CustomPainter {
  final PenguinMood mood;

  PenguinPainter({required this.mood});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width * 0.38;

    // 体（水色の丸）
    final bodyPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.2, -0.3),
        radius: 1.0,
        colors: [
          MaColors.penguinIce,
          MaColors.penguinDeep,
          const Color(0xFF4A9DD8),
        ],
      ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: r));
    canvas.drawCircle(Offset(cx, cy), r, bodyPaint);

    // お腹（白い楕円）
    final bellyPaint = Paint()..color = Colors.white.withValues(alpha: 0.85);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx, cy + r * 0.15),
        width: r * 1.1,
        height: r * 1.2,
      ),
      bellyPaint,
    );

    // 目
    _drawEyes(canvas, cx, cy, r);

    // くちばし
    _drawBeak(canvas, cx, cy, r);

    // 頬のピンク
    final cheekPaint = Paint()..color = const Color(0xFFFFB5C5).withValues(alpha: 0.4);
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx - r * 0.5, cy + r * 0.1), width: r * 0.3, height: r * 0.2),
      cheekPaint,
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx + r * 0.5, cy + r * 0.1), width: r * 0.3, height: r * 0.2),
      cheekPaint,
    );

    // 頭のハイライト
    final hlPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.3);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx - r * 0.15, cy - r * 0.45),
        width: r * 0.4,
        height: r * 0.2,
      ),
      hlPaint,
    );
  }

  void _drawEyes(Canvas canvas, double cx, double cy, double r) {
    final eyePaint = Paint()..color = const Color(0xFF2C3E50);
    final whitePaint = Paint()..color = Colors.white;
    final eyeY = cy - r * 0.15;
    final spacing = r * 0.28;

    switch (mood) {
      case PenguinMood.focus:
        // 集中 — 真剣な丸目
        for (final dx in [-spacing, spacing]) {
          canvas.drawCircle(Offset(cx + dx, eyeY), r * 0.09, eyePaint);
          canvas.drawCircle(Offset(cx + dx - r * 0.025, eyeY - r * 0.035), r * 0.03, whitePaint);
        }
        break;
      case PenguinMood.clean:
        // すっきり — にっこりアーチ
        final arcPaint = Paint()
          ..color = const Color(0xFF2C3E50)
          ..style = PaintingStyle.stroke
          ..strokeWidth = r * 0.06
          ..strokeCap = StrokeCap.round;
        for (final dx in [-spacing, spacing]) {
          final path = Path()
            ..moveTo(cx + dx - r * 0.08, eyeY)
            ..quadraticBezierTo(cx + dx, eyeY - r * 0.1, cx + dx + r * 0.08, eyeY);
          canvas.drawPath(path, arcPaint);
        }
        break;
      case PenguinMood.craft:
        // 工作 — ><目（集中）
        final craftPaint = Paint()
          ..color = const Color(0xFF2C3E50)
          ..style = PaintingStyle.stroke
          ..strokeWidth = r * 0.05
          ..strokeCap = StrokeCap.round;
        for (final dx in [-spacing, spacing]) {
          canvas.drawLine(
            Offset(cx + dx - r * 0.06, eyeY - r * 0.05),
            Offset(cx + dx + r * 0.06, eyeY + r * 0.05),
            craftPaint,
          );
          canvas.drawLine(
            Offset(cx + dx - r * 0.06, eyeY + r * 0.05),
            Offset(cx + dx + r * 0.06, eyeY - r * 0.05),
            craftPaint,
          );
        }
        break;
      case PenguinMood.success:
        // 成功 — キラキラ星目
        for (final dx in [-spacing, spacing]) {
          _drawStar(canvas, Offset(cx + dx, eyeY), r * 0.09, const Color(0xFF2C3E50));
        }
        break;
    }
  }

  void _drawBeak(Canvas canvas, double cx, double cy, double r) {
    final beakPaint = Paint()..color = const Color(0xFFFF9F43);
    final beakY = cy + r * 0.1;

    switch (mood) {
      case PenguinMood.success:
        // 開いた口
        final path = Path()
          ..moveTo(cx - r * 0.12, beakY)
          ..quadraticBezierTo(cx, beakY + r * 0.15, cx + r * 0.12, beakY);
        canvas.drawPath(path, beakPaint);
        final innerPaint = Paint()..color = const Color(0xFFFF6B6B);
        final inner = Path()
          ..moveTo(cx - r * 0.08, beakY + r * 0.02)
          ..quadraticBezierTo(cx, beakY + r * 0.1, cx + r * 0.08, beakY + r * 0.02);
        canvas.drawPath(inner, innerPaint);
        break;
      default:
        // 閉じたくちばし
        final path = Path()
          ..moveTo(cx - r * 0.1, beakY)
          ..lineTo(cx, beakY + r * 0.1)
          ..lineTo(cx + r * 0.1, beakY)
          ..close();
        canvas.drawPath(path, beakPaint);
    }
  }

  void _drawStar(Canvas canvas, Offset center, double size, Color color) {
    final paint = Paint()..color = color;
    final path = Path();
    for (var i = 0; i < 10; i++) {
      final angle = (i * 36 - 90) * math.pi / 180;
      final r = i.isEven ? size : size * 0.4;
      final x = center.dx + r * math.cos(angle);
      final y = center.dy + r * math.sin(angle);
      if (i == 0) path.moveTo(x, y); else path.lineTo(x, y);
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(PenguinPainter old) => mood != old.mood;
}

/// ペンギンウィジェット
class PenguinFace extends StatelessWidget {
  final PenguinMood mood;
  final double size;

  const PenguinFace({super.key, required this.mood, this.size = 120});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: PenguinPainter(mood: mood)),
    );
  }
}
