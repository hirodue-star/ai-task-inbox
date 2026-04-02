import 'dart:math' as math;
import 'package:flutter/material.dart';

/// 可変報酬フラクタルパーティクル
/// タップごとに異なるフラクタル図形を0.2秒だけ表示
class FractalBurstPainter extends CustomPainter {
  final double progress; // 0.0 → 1.0
  final int seed;        // 毎回変わるシード値

  FractalBurstPainter({required this.progress, required this.seed});

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0 || progress >= 1) return;

    final cx = size.width / 2;
    final cy = size.height / 2;
    final rng = math.Random(seed);
    final maxR = size.width * 0.4;

    // フラクタルタイプを毎回ランダムに選択
    final type = seed % 4;
    // 彩度・色相を毎回微妙に変える
    final hue = (seed * 37.0) % 360;
    final saturation = 0.5 + rng.nextDouble() * 0.4;
    final baseColor = HSLColor.fromAHSL(1, hue, saturation, 0.65).toColor();
    final alpha = (1.0 - progress).clamp(0.0, 1.0);
    final scale = 0.3 + progress * 0.7;

    canvas.save();
    canvas.translate(cx, cy);

    switch (type) {
      case 0:
        _drawKochSnowflake(canvas, maxR * scale, 3, baseColor, alpha, rng);
        break;
      case 1:
        _drawSpiralFractal(canvas, maxR * scale, baseColor, alpha, rng);
        break;
      case 2:
        _drawSierpinskiTriangle(canvas, maxR * scale, 3, baseColor, alpha, rng);
        break;
      case 3:
        _drawJuliaCloud(canvas, maxR * scale, baseColor, alpha, rng);
        break;
    }

    canvas.restore();
  }

  /// コッホ雪片風
  void _drawKochSnowflake(Canvas canvas, double r, int depth, Color color, double alpha, math.Random rng) {
    final sides = 5 + rng.nextInt(3); // 5-7角形
    final paint = Paint()
      ..color = color.withOpacity(alpha * 0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    for (var d = 0; d < depth; d++) {
      final scale = 1.0 - d * 0.3;
      final rotation = d * math.pi / sides * 0.5;
      final path = Path();
      for (var i = 0; i <= sides; i++) {
        final angle = (i * 2 * math.pi / sides) + rotation;
        final x = r * scale * math.cos(angle);
        final y = r * scale * math.sin(angle);
        if (i == 0) path.moveTo(x, y); else path.lineTo(x, y);
      }
      path.close();
      paint.color = HSLColor.fromColor(color)
          .withHue((HSLColor.fromColor(color).hue + d * 20) % 360)
          .toColor()
          .withOpacity(alpha * (0.8 - d * 0.2));
      canvas.drawPath(path, paint);
    }

    // ノードの点
    final dotPaint = Paint()..color = color.withOpacity(alpha);
    for (var i = 0; i < sides; i++) {
      final angle = i * 2 * math.pi / sides;
      canvas.drawCircle(Offset(r * math.cos(angle), r * math.sin(angle)), 2, dotPaint);
    }
  }

  /// 黄金螺旋フラクタル
  void _drawSpiralFractal(Canvas canvas, double r, Color color, double alpha, math.Random rng) {
    final arms = 3 + rng.nextInt(4);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round;

    for (var arm = 0; arm < arms; arm++) {
      final baseAngle = arm * 2 * math.pi / arms;
      final path = Path();
      final hueShift = arm * (360 / arms);

      for (var t = 0.0; t < math.pi * 4; t += 0.1) {
        final radius = r * (t / (math.pi * 4));
        final angle = t + baseAngle;
        final x = radius * math.cos(angle);
        final y = radius * math.sin(angle);
        if (t == 0) path.moveTo(x, y); else path.lineTo(x, y);
      }

      paint.color = HSLColor.fromColor(color)
          .withHue((HSLColor.fromColor(color).hue + hueShift) % 360)
          .toColor()
          .withOpacity(alpha * 0.6);
      canvas.drawPath(path, paint);
    }

    // 中心のパルス
    final corePaint = Paint()
      ..shader = RadialGradient(
        colors: [
          color.withOpacity(alpha * 0.5),
          color.withOpacity(0),
        ],
      ).createShader(Rect.fromCircle(center: Offset.zero, radius: r * 0.2));
    canvas.drawCircle(Offset.zero, r * 0.2, corePaint);
  }

  /// シェルピンスキー三角形風
  void _drawSierpinskiTriangle(Canvas canvas, double r, int depth, Color color, double alpha, math.Random rng) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    void drawTriangle(double cx, double cy, double size, int d) {
      if (d <= 0 || size < 3) return;
      final h = size * math.sqrt(3) / 2;

      final p1 = Offset(cx, cy - h * 0.6);
      final p2 = Offset(cx - size / 2, cy + h * 0.4);
      final p3 = Offset(cx + size / 2, cy + h * 0.4);

      final path = Path()..moveTo(p1.dx, p1.dy)..lineTo(p2.dx, p2.dy)..lineTo(p3.dx, p3.dy)..close();
      paint.color = HSLColor.fromColor(color)
          .withHue((HSLColor.fromColor(color).hue + (3 - d) * 30) % 360)
          .toColor()
          .withOpacity(alpha * (0.3 + d * 0.2));
      canvas.drawPath(path, paint);

      final ns = size / 2;
      drawTriangle(cx, cy - h * 0.3, ns, d - 1);
      drawTriangle(cx - ns / 2, cy + h * 0.2, ns, d - 1);
      drawTriangle(cx + ns / 2, cy + h * 0.2, ns, d - 1);
    }

    drawTriangle(0, 0, r * 1.5, depth);
  }

  /// ジュリア集合風の雲
  void _drawJuliaCloud(Canvas canvas, double r, Color color, double alpha, math.Random rng) {
    final cReal = -0.7 + rng.nextDouble() * 0.4;
    final cImag = 0.2 + rng.nextDouble() * 0.2;
    final paint = Paint()..strokeWidth = 1;

    for (var i = 0; i < 60; i++) {
      var zr = (rng.nextDouble() - 0.5) * 2;
      var zi = (rng.nextDouble() - 0.5) * 2;

      var iter = 0;
      while (zr * zr + zi * zi < 4 && iter < 12) {
        final newZr = zr * zr - zi * zi + cReal;
        zi = 2 * zr * zi + cImag;
        zr = newZr;
        iter++;
      }

      if (iter > 2 && iter < 12) {
        final x = zr * r * 0.3;
        final y = zi * r * 0.3;
        final hueShift = iter * 25.0;
        paint.color = HSLColor.fromColor(color)
            .withHue((HSLColor.fromColor(color).hue + hueShift) % 360)
            .toColor()
            .withOpacity(alpha * (iter / 12));
        canvas.drawCircle(Offset(x, y), 1.5 + iter * 0.3, paint);
      }
    }
  }

  @override
  bool shouldRepaint(FractalBurstPainter old) => progress != old.progress || seed != old.seed;
}

/// フラクタルバーストウィジェット
class FractalBurst extends StatefulWidget {
  final bool trigger;
  final Offset? position;
  final VoidCallback? onComplete;

  const FractalBurst({super.key, required this.trigger, this.position, this.onComplete});

  @override
  State<FractalBurst> createState() => _FractalBurstState();
}

class _FractalBurstState extends State<FractalBurst>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  int _seed = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _controller.addStatusListener((s) {
      if (s == AnimationStatus.completed) widget.onComplete?.call();
    });
    if (widget.trigger) _fire();
  }

  @override
  void didUpdateWidget(FractalBurst old) {
    super.didUpdateWidget(old);
    if (widget.trigger && !old.trigger) _fire();
  }

  void _fire() {
    _seed = DateTime.now().microsecondsSinceEpoch;
    _controller.forward(from: 0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return CustomPaint(
          painter: FractalBurstPainter(
            progress: _controller.value,
            seed: _seed,
          ),
          size: Size.infinite,
        );
      },
    );
  }
}
