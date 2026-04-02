import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/ma_colors.dart';

/// 🦁 黄金パーティクル演出 — ガチャ開封・レベルアップ時
class GoldParticlePainter extends CustomPainter {
  final double progress; // 0.0 ~ 1.0
  final int particleCount;

  GoldParticlePainter({required this.progress, this.particleCount = 50});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final rng = math.Random(12345);
    final maxRadius = size.width * 0.6;

    for (var i = 0; i < particleCount; i++) {
      final angle = rng.nextDouble() * math.pi * 2;
      final speed = 0.3 + rng.nextDouble() * 0.7;
      final dist = maxRadius * progress * speed;
      final x = cx + dist * math.cos(angle);
      final y = cy + dist * math.sin(angle);

      // パーティクルサイズ（放出後に縮小）
      final baseSize = 2.0 + rng.nextDouble() * 4;
      final sizeMultiplier = progress < 0.3
          ? progress / 0.3
          : 1.0 - ((progress - 0.3) / 0.7) * 0.8;
      final pSize = baseSize * sizeMultiplier.clamp(0.0, 1.0);

      // 色（金のバリエーション）
      final colors = [
        MaColors.lionGold,
        const Color(0xFFFFF8DC),
        const Color(0xFFDAA520),
        const Color(0xFFFFEA80),
        Colors.white,
      ];
      final color = colors[i % colors.length];
      final alpha = (1.0 - progress * 0.8).clamp(0.0, 1.0);

      final paint = Paint()..color = color.withValues(alpha: alpha);
      canvas.drawCircle(Offset(x, y), pSize, paint);

      // グロー
      if (pSize > 2) {
        final glowPaint = Paint()
          ..shader = RadialGradient(
            colors: [
              color.withValues(alpha: alpha * 0.3),
              color.withValues(alpha: 0),
            ],
          ).createShader(Rect.fromCircle(center: Offset(x, y), radius: pSize * 3));
        canvas.drawCircle(Offset(x, y), pSize * 3, glowPaint);
      }
    }

    // 中央の光球（開封時）
    if (progress < 0.5) {
      final coreSize = 30 * (1.0 - progress * 2).clamp(0.0, 1.0);
      final corePaint = Paint()
        ..shader = RadialGradient(
          colors: [
            Colors.white.withValues(alpha: 0.9),
            MaColors.lionGold.withValues(alpha: 0.5),
            MaColors.lionGold.withValues(alpha: 0),
          ],
        ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: coreSize));
      canvas.drawCircle(Offset(cx, cy), coreSize, corePaint);
    }
  }

  @override
  bool shouldRepaint(GoldParticlePainter old) => progress != old.progress;
}

/// パーティクルバーストウィジェット
class GoldParticleBurst extends StatefulWidget {
  final bool trigger;
  final VoidCallback? onComplete;
  final int particleCount;

  const GoldParticleBurst({
    super.key,
    required this.trigger,
    this.onComplete,
    this.particleCount = 50,
  });

  @override
  State<GoldParticleBurst> createState() => _GoldParticleBurstState();
}

class _GoldParticleBurstState extends State<GoldParticleBurst>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onComplete?.call();
      }
    });
    if (widget.trigger) _controller.forward();
  }

  @override
  void didUpdateWidget(GoldParticleBurst old) {
    super.didUpdateWidget(old);
    if (widget.trigger && !old.trigger) {
      _controller.forward(from: 0);
    }
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
          painter: GoldParticlePainter(
            progress: _controller.value,
            particleCount: widget.particleCount,
          ),
          size: Size.infinite,
        );
      },
    );
  }
}
