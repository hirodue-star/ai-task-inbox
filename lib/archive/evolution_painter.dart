import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/user_level.dart';
import '../theme/ma_colors.dart';

/// 進化演出（エボリューション）— 級昇格時の全画面演出
class EvolutionPainter extends CustomPainter {
  final UiTier fromTier;
  final UiTier toTier;
  final double progress; // 0.0 → 1.0

  EvolutionPainter({
    required this.fromTier,
    required this.toTier,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    // フェーズ1: 旧世界が砕ける (0.0-0.3)
    // フェーズ2: 光の爆発 (0.3-0.6)
    // フェーズ3: 新世界が現れる (0.6-1.0)

    if (progress < 0.3) {
      _drawShatter(canvas, size, progress / 0.3);
    } else if (progress < 0.6) {
      _drawLightBurst(canvas, size, (progress - 0.3) / 0.3);
    } else {
      _drawNewWorld(canvas, size, (progress - 0.6) / 0.4);
    }
  }

  void _drawShatter(Canvas canvas, Size size, double t) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final rng = math.Random(42);

    // 旧背景が砕け散る
    final oldColor = _tierColor(fromTier);
    for (var i = 0; i < 20; i++) {
      final angle = rng.nextDouble() * math.pi * 2;
      final dist = t * size.width * 0.5 * rng.nextDouble();
      final x = cx + dist * math.cos(angle);
      final y = cy + dist * math.sin(angle);
      final shardSize = 20 + rng.nextDouble() * 40;
      final rotation = t * math.pi * rng.nextDouble();

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(rotation);
      final shardPaint = Paint()
        ..color = oldColor.withOpacity(1.0 - t);
      canvas.drawRect(
        Rect.fromCenter(center: Offset.zero, width: shardSize, height: shardSize * 0.6),
        shardPaint,
      );
      canvas.restore();
    }
  }

  void _drawLightBurst(Canvas canvas, Size size, double t) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final maxR = size.width;

    // 中心からの光
    final newColor = _tierColor(toTier);
    final burstR = maxR * t;
    final burstPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.white.withOpacity(0.9 * (1 - t)),
          newColor.withOpacity(0.5 * (1 - t)),
          Colors.transparent,
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: burstR));
    canvas.drawCircle(Offset(cx, cy), burstR, burstPaint);

    // 光線
    final rayPaint = Paint()
      ..color = Colors.white.withOpacity(0.3 * (1 - t))
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < 12; i++) {
      final angle = (i * math.pi * 2 / 12) + t * math.pi * 0.5;
      final r1 = burstR * 0.3;
      final r2 = burstR * 0.8;
      canvas.drawLine(
        Offset(cx + r1 * math.cos(angle), cy + r1 * math.sin(angle)),
        Offset(cx + r2 * math.cos(angle), cy + r2 * math.sin(angle)),
        rayPaint,
      );
    }
  }

  void _drawNewWorld(Canvas canvas, Size size, double t) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final newColor = _tierColor(toTier);

    // 新背景がフェードイン
    final bgPaint = Paint()
      ..color = _tierBgColor(toTier).withOpacity(t);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    // ティアのシンボル
    final symbolAlpha = t;

    switch (toTier) {
      case UiTier.intuitive:
        // バブル
        for (var i = 0; i < 8; i++) {
          final angle = i * math.pi * 2 / 8;
          final r = 100 * t;
          final x = cx + r * math.cos(angle);
          final y = cy + r * math.sin(angle);
          final bubbleR = 15 + i * 3.0;
          final colors = [MaColors.hiyokoPink, MaColors.hiyokoBlue, MaColors.hiyokoGreen, MaColors.hiyokoYellow];
          final paint = Paint()
            ..shader = RadialGradient(
              center: const Alignment(-0.3, -0.3),
              colors: [Colors.white.withOpacity(0.5 * symbolAlpha), colors[i % 4].withOpacity(0.4 * symbolAlpha)],
            ).createShader(Rect.fromCircle(center: Offset(x, y), radius: bubbleR));
          canvas.drawCircle(Offset(x, y), bubbleR, paint);
        }
        break;

      case UiTier.analytical:
        // 氷の結晶
        final crystalPaint = Paint()
          ..color = MaColors.penguinIce.withOpacity(0.5 * symbolAlpha)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2;
        for (var ring = 0; ring < 3; ring++) {
          final r = (40 + ring * 30) * t;
          final path = Path();
          for (var j = 0; j < 6; j++) {
            final a = (j * math.pi / 3) - math.pi / 2;
            final x = cx + r * math.cos(a);
            final y = cy + r * math.sin(a);
            if (j == 0) path.moveTo(x, y); else path.lineTo(x, y);
          }
          path.close();
          canvas.drawPath(path, crystalPaint);
        }
        break;

      case UiTier.abstract:
        // 黄金のマンダラ
        final mandalaPaint = Paint()
          ..color = MaColors.lionGold.withOpacity(0.6 * symbolAlpha)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2;
        for (var ring = 0; ring < 4; ring++) {
          canvas.drawCircle(Offset(cx, cy), (30 + ring * 25) * t, mandalaPaint);
        }
        // 光線
        for (var i = 0; i < 8; i++) {
          final angle = i * math.pi / 4;
          canvas.drawLine(
            Offset(cx, cy),
            Offset(cx + 120 * t * math.cos(angle), cy + 120 * t * math.sin(angle)),
            mandalaPaint,
          );
        }
        break;
    }

    // レベルテキスト
    if (t > 0.5) {
      final textAlpha = ((t - 0.5) * 2).clamp(0.0, 1.0);
      final tp = TextPainter(
        text: TextSpan(
          text: _tierName(toTier),
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w900,
            color: newColor.withOpacity(textAlpha),
            letterSpacing: 6,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(cx - tp.width / 2, cy + 140));
    }
  }

  Color _tierColor(UiTier tier) {
    switch (tier) {
      case UiTier.intuitive: return MaColors.hiyokoPink;
      case UiTier.analytical: return MaColors.penguinDeep;
      case UiTier.abstract: return MaColors.lionGold;
    }
  }

  Color _tierBgColor(UiTier tier) {
    switch (tier) {
      case UiTier.intuitive: return const Color(0xFFFFF8F0);
      case UiTier.analytical: return const Color(0xFFEAF4FC);
      case UiTier.abstract: return const Color(0xFF0B0B2B);
    }
  }

  String _tierName(UiTier tier) {
    switch (tier) {
      case UiTier.intuitive: return 'ひよこ級';
      case UiTier.analytical: return 'ペンギン級';
      case UiTier.abstract: return 'ライオン級';
    }
  }

  @override
  bool shouldRepaint(EvolutionPainter old) => progress != old.progress;
}

/// 進化演出ウィジェット
class EvolutionOverlay extends StatefulWidget {
  final UiTier fromTier;
  final UiTier toTier;
  final VoidCallback onComplete;

  const EvolutionOverlay({
    super.key,
    required this.fromTier,
    required this.toTier,
    required this.onComplete,
  });

  @override
  State<EvolutionOverlay> createState() => _EvolutionOverlayState();
}

class _EvolutionOverlayState extends State<EvolutionOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );
    _controller.addStatusListener((s) {
      if (s == AnimationStatus.completed) widget.onComplete();
    });
    _controller.forward();
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
          painter: EvolutionPainter(
            fromTier: widget.fromTier,
            toTier: widget.toTier,
            progress: _controller.value,
          ),
          size: Size.infinite,
        );
      },
    );
  }
}
