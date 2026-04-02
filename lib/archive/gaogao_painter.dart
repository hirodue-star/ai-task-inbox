import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/ma_colors.dart';

/// 🐣 ガオガオ表情タイプ
enum GaogaoMood { happy, shy, sleepy, excited }

/// ガオガオ（赤ちゃんキャラ）をCustomPainterで描画
class GaogaoPainter extends CustomPainter {
  final GaogaoMood mood;

  GaogaoPainter({required this.mood});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width * 0.38;

    // 頭（丸い肌色）
    final headPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.2, -0.3),
        radius: 1.0,
        colors: [
          const Color(0xFFFFEDD5),
          MaColors.hiyokoSkin,
          const Color(0xFFE8C890),
        ],
      ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: r));
    canvas.drawCircle(Offset(cx, cy), r, headPaint);

    // 頬のピンク
    final cheekPaint = Paint()..color = MaColors.hiyokoCheek.withValues(alpha: 0.5);
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx - r * 0.55, cy + r * 0.15), width: r * 0.35, height: r * 0.25),
      cheekPaint,
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx + r * 0.55, cy + r * 0.15), width: r * 0.35, height: r * 0.25),
      cheekPaint,
    );

    // 目
    _drawEyes(canvas, cx, cy, r);

    // 口
    _drawMouth(canvas, cx, cy, r);

    // 髪の毛（ちょこん）
    _drawHairTuft(canvas, cx, cy, r);

    // ハイライト
    final highlightPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.4)
      ..style = PaintingStyle.fill;
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx - r * 0.2, cy - r * 0.4),
        width: r * 0.4,
        height: r * 0.2,
      ),
      highlightPaint,
    );
  }

  void _drawEyes(Canvas canvas, double cx, double cy, double r) {
    final eyePaint = Paint()..color = const Color(0xFF3D2C1E);
    final whitePaint = Paint()..color = Colors.white;
    final eyeY = cy - r * 0.1;
    final eyeSpacing = r * 0.3;

    switch (mood) {
      case GaogaoMood.happy:
        // 笑顔 — アーチ型
        final eyeArc = Paint()
          ..color = const Color(0xFF3D2C1E)
          ..style = PaintingStyle.stroke
          ..strokeWidth = r * 0.06
          ..strokeCap = StrokeCap.round;
        for (final dx in [-eyeSpacing, eyeSpacing]) {
          final path = Path()
            ..moveTo(cx + dx - r * 0.1, eyeY)
            ..quadraticBezierTo(cx + dx, eyeY - r * 0.12, cx + dx + r * 0.1, eyeY);
          canvas.drawPath(path, eyeArc);
        }
        break;

      case GaogaoMood.shy:
        // 照れ — 丸目 + ハート頬
        for (final dx in [-eyeSpacing, eyeSpacing]) {
          canvas.drawCircle(Offset(cx + dx, eyeY), r * 0.07, eyePaint);
          canvas.drawCircle(Offset(cx + dx - r * 0.02, eyeY - r * 0.03), r * 0.025, whitePaint);
        }
        break;

      case GaogaoMood.sleepy:
        // 眠い — 半目（横線）
        final sleepyPaint = Paint()
          ..color = const Color(0xFF3D2C1E)
          ..style = PaintingStyle.stroke
          ..strokeWidth = r * 0.05
          ..strokeCap = StrokeCap.round;
        for (final dx in [-eyeSpacing, eyeSpacing]) {
          canvas.drawLine(
            Offset(cx + dx - r * 0.08, eyeY),
            Offset(cx + dx + r * 0.08, eyeY),
            sleepyPaint,
          );
        }
        // ZZZ
        final zzz = TextPainter(
          text: TextSpan(
            text: 'z',
            style: TextStyle(fontSize: r * 0.2, color: const Color(0xFF88BBEE), fontWeight: FontWeight.bold),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        zzz.paint(canvas, Offset(cx + r * 0.6, cy - r * 0.6));
        break;

      case GaogaoMood.excited:
        // わくわく — キラキラ星目
        for (final dx in [-eyeSpacing, eyeSpacing]) {
          _drawStar(canvas, Offset(cx + dx, eyeY), r * 0.1, const Color(0xFF3D2C1E));
        }
        break;
    }
  }

  void _drawMouth(Canvas canvas, double cx, double cy, double r) {
    final mouthY = cy + r * 0.25;
    final mouthPaint = Paint()
      ..color = const Color(0xFF3D2C1E)
      ..style = PaintingStyle.stroke
      ..strokeWidth = r * 0.04
      ..strokeCap = StrokeCap.round;

    switch (mood) {
      case GaogaoMood.happy:
      case GaogaoMood.excited:
        // 大きな笑顔
        final fillPaint = Paint()..color = const Color(0xFFFF8888);
        final path = Path()
          ..moveTo(cx - r * 0.2, mouthY - r * 0.05)
          ..quadraticBezierTo(cx, mouthY + r * 0.15, cx + r * 0.2, mouthY - r * 0.05);
        canvas.drawPath(path, fillPaint);
        canvas.drawPath(path, mouthPaint);
        break;

      case GaogaoMood.shy:
        // 小さいにっこり
        final path = Path()
          ..moveTo(cx - r * 0.1, mouthY)
          ..quadraticBezierTo(cx, mouthY + r * 0.08, cx + r * 0.1, mouthY);
        canvas.drawPath(path, mouthPaint);
        break;

      case GaogaoMood.sleepy:
        // 小さな「o」
        canvas.drawOval(
          Rect.fromCenter(center: Offset(cx, mouthY), width: r * 0.12, height: r * 0.1),
          mouthPaint,
        );
        break;
    }
  }

  void _drawHairTuft(Canvas canvas, double cx, double cy, double r) {
    final hairPaint = Paint()..color = const Color(0xFFDEB070);
    final path = Path()
      ..moveTo(cx - r * 0.08, cy - r * 0.95)
      ..quadraticBezierTo(cx, cy - r * 1.3, cx + r * 0.08, cy - r * 0.95)
      ..close();
    canvas.drawPath(path, hairPaint);

    final path2 = Path()
      ..moveTo(cx + r * 0.05, cy - r * 0.92)
      ..quadraticBezierTo(cx + r * 0.2, cy - r * 1.2, cx + r * 0.15, cy - r * 0.88)
      ..close();
    canvas.drawPath(path2, hairPaint);
  }

  void _drawStar(Canvas canvas, Offset center, double size, Color color) {
    final paint = Paint()..color = color;
    final path = Path();
    for (var i = 0; i < 10; i++) {
      final angle = (i * 36 - 90) * math.pi / 180;
      final r = i.isEven ? size : size * 0.4;
      final x = center.dx + r * math.cos(angle);
      final y = center.dy + r * math.sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(GaogaoPainter oldDelegate) => mood != oldDelegate.mood;
}

/// ガオガオウィジェット
class GaogaoFace extends StatelessWidget {
  final GaogaoMood mood;
  final double size;

  const GaogaoFace({super.key, required this.mood, this.size = 120});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: GaogaoPainter(mood: mood)),
    );
  }
}

/// 4表情を横に並べて表示
class GaogaoRow extends StatelessWidget {
  final double faceSize;

  const GaogaoRow({super.key, this.faceSize = 80});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: GaogaoMood.values.map((m) {
        return GaogaoFace(mood: m, size: faceSize);
      }).toList(),
    );
  }
}
