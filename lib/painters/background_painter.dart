import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/ma_colors.dart';

/// 🐣 ひよこ級背景：パステルグラデーション + バブル
class HiyokoBgPainter extends CustomPainter {
  final double animValue;

  HiyokoBgPainter({this.animValue = 0});

  @override
  void paint(Canvas canvas, Size size) {
    // パステルグラデーション背景
    final bgPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFFFFF8F0), Color(0xFFFFECE0), Color(0xFFFFF0F5)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    // 浮遊するバブル
    final rng = math.Random(42);
    for (var i = 0; i < 12; i++) {
      final bx = rng.nextDouble() * size.width;
      final baseY = rng.nextDouble() * size.height;
      final by = (baseY + animValue * size.height * 0.3 * (0.5 + rng.nextDouble())) % (size.height + 40) - 20;
      final br = 8 + rng.nextDouble() * 20;

      // 虹色バブル
      final hue = (i * 30.0 + animValue * 360) % 360;
      final bubbleColor = HSLColor.fromAHSL(0.15, hue, 0.6, 0.8).toColor();
      final bubblePaint = Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.3, -0.3),
          colors: [Colors.white.withValues(alpha: 0.4), bubbleColor, bubbleColor.withValues(alpha: 0)],
          stops: const [0.0, 0.7, 1.0],
        ).createShader(Rect.fromCircle(center: Offset(bx, by), radius: br));
      canvas.drawCircle(Offset(bx, by), br, bubblePaint);

      // バブルのハイライト
      final hlPaint = Paint()..color = Colors.white.withValues(alpha: 0.5);
      canvas.drawCircle(Offset(bx - br * 0.25, by - br * 0.25), br * 0.2, hlPaint);
    }
  }

  @override
  bool shouldRepaint(HiyokoBgPainter old) => animValue != old.animValue;
}

/// 🦁 ライオン級背景：宇宙風ネイビー + 星 + パーティクル
class LionBgPainter extends CustomPainter {
  final double animValue;

  LionBgPainter({this.animValue = 0});

  @override
  void paint(Canvas canvas, Size size) {
    // ディープネイビーグラデーション
    final bgPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(0, -0.3),
        radius: 1.2,
        colors: [const Color(0xFF1A1A60), const Color(0xFF0B0B2B), const Color(0xFF050515)],
        stops: const [0.0, 0.6, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    // 星
    final rng = math.Random(99);
    for (var i = 0; i < 60; i++) {
      final sx = rng.nextDouble() * size.width;
      final sy = rng.nextDouble() * size.height;
      final sr = 0.5 + rng.nextDouble() * 2;
      final twinkle = (math.sin(animValue * math.pi * 2 + i * 0.5) + 1) / 2;
      final starPaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.3 + twinkle * 0.7);
      canvas.drawCircle(Offset(sx, sy), sr, starPaint);
    }

    // 金色パーティクル
    for (var i = 0; i < 15; i++) {
      final px = rng.nextDouble() * size.width;
      final baseY = rng.nextDouble() * size.height;
      final py = (baseY - animValue * size.height * 0.5 * (0.3 + rng.nextDouble())) % (size.height + 20);
      final pr = 1.5 + rng.nextDouble() * 3;
      final alpha = (math.sin(animValue * math.pi * 2 + i) + 1) / 2;

      final particlePaint = Paint()
        ..color = MaColors.lionGold.withValues(alpha: 0.2 + alpha * 0.6);
      canvas.drawCircle(Offset(px, py), pr, particlePaint);

      // グロー
      final glowPaint = Paint()
        ..shader = RadialGradient(
          colors: [
            MaColors.lionGold.withValues(alpha: 0.15 * alpha),
            MaColors.lionGold.withValues(alpha: 0),
          ],
        ).createShader(Rect.fromCircle(center: Offset(px, py), radius: pr * 4));
      canvas.drawCircle(Offset(px, py), pr * 4, glowPaint);
    }

    // 星雲（淡い金色の雲）
    for (var i = 0; i < 3; i++) {
      final nx = size.width * (0.2 + i * 0.3);
      final ny = size.height * (0.3 + rng.nextDouble() * 0.4);
      final nr = 40 + rng.nextDouble() * 60;
      final nebulaPaint = Paint()
        ..shader = RadialGradient(
          colors: [
            MaColors.lionGold.withValues(alpha: 0.06),
            MaColors.lionGold.withValues(alpha: 0),
          ],
        ).createShader(Rect.fromCircle(center: Offset(nx, ny), radius: nr));
      canvas.drawCircle(Offset(nx, ny), nr, nebulaPaint);
    }
  }

  @override
  bool shouldRepaint(LionBgPainter old) => animValue != old.animValue;
}

/// アニメーション付き背景ウィジェット
class AnimatedBackground extends StatefulWidget {
  final bool isLionLevel;
  final Widget child;

  const AnimatedBackground({super.key, this.isLionLevel = false, required this.child});

  @override
  State<AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
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
      builder: (context, child) {
        return CustomPaint(
          painter: widget.isLionLevel
              ? LionBgPainter(animValue: _controller.value)
              : HiyokoBgPainter(animValue: _controller.value),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}
