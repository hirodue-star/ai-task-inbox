import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../services/time_guard.dart';

/// ライオンの休息モード — 穏やかなアニメーション
class RestModePainter extends CustomPainter {
  final RestStatus status;
  final double animValue;

  RestModePainter({required this.status, required this.animValue});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    // 深い夜空
    final bgPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(0, -0.3),
        radius: 1.2,
        colors: [
          const Color(0xFF0A0A30),
          const Color(0xFF050515),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    // 穏やかな星
    final rng = math.Random(42);
    for (var i = 0; i < 40; i++) {
      final x = rng.nextDouble() * size.width;
      final y = rng.nextDouble() * size.height * 0.6;
      final r = 0.5 + rng.nextDouble() * 1.5;
      final twinkle = (math.sin(animValue * math.pi * 2 * 0.3 + i * 0.8) + 1) / 2;
      final paint = Paint()..color = Colors.white.withOpacity(0.2 + twinkle * 0.3);
      canvas.drawCircle(Offset(x, y), r, paint);
    }

    // 月
    final moonY = size.height * 0.2 + math.sin(animValue * math.pi * 2 * 0.1) * 5;
    final moonPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.2, -0.2),
        colors: [Colors.white, const Color(0xFFE8E8F0)],
      ).createShader(Rect.fromCircle(center: Offset(cx, moonY), radius: 40));
    canvas.drawCircle(Offset(cx, moonY), 40, moonPaint);

    // 月のグロー
    final moonGlow = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.white.withOpacity(0.08),
          Colors.white.withOpacity(0),
        ],
      ).createShader(Rect.fromCircle(center: Offset(cx, moonY), radius: 100));
    canvas.drawCircle(Offset(cx, moonY), 100, moonGlow);

    // 眠るライオン（シンプルな輪郭）
    _drawSleepingLion(canvas, cx, size.height * 0.6);

    // ZZZ
    final zzzAlpha = (math.sin(animValue * math.pi * 2 * 0.5) + 1) / 2;
    for (var i = 0; i < 3; i++) {
      final zx = cx + 60 + i * 15;
      final zy = size.height * 0.5 - i * 20 - animValue * 10;
      final zSize = 14.0 + i * 4;
      final tp = TextPainter(
        text: TextSpan(
          text: 'z',
          style: TextStyle(
            fontSize: zSize,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF6688AA).withOpacity(0.3 + zzzAlpha * 0.3 - i * 0.1),
            fontStyle: FontStyle.italic,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(zx, zy));
    }
  }

  void _drawSleepingLion(Canvas canvas, double cx, double cy) {
    // 体（丸い塊）
    final bodyPaint = Paint()
      ..color = const Color(0xFF3A2A10).withOpacity(0.5);
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, cy + 20), width: 120, height: 60),
      bodyPaint,
    );

    // たてがみ
    final manePaint = Paint()..color = const Color(0xFF5A3A10).withOpacity(0.4);
    canvas.drawCircle(Offset(cx - 20, cy - 5), 35, manePaint);

    // 頭
    final headPaint = Paint()..color = const Color(0xFF4A3A15).withOpacity(0.5);
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx - 20, cy), width: 45, height: 35),
      headPaint,
    );

    // 閉じた目（横線）
    final eyePaint = Paint()
      ..color = const Color(0xFF8B7355).withOpacity(0.4)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(cx - 30, cy - 3), Offset(cx - 20, cy - 3), eyePaint);
  }

  @override
  bool shouldRepaint(RestModePainter old) => animValue != old.animValue;
}

/// 休息モードオーバーレイ
class RestModeOverlay extends StatefulWidget {
  final RestStatus status;
  final VoidCallback? onParentOverride;

  const RestModeOverlay({super.key, required this.status, this.onParentOverride});

  @override
  State<RestModeOverlay> createState() => _RestModeOverlayState();
}

class _RestModeOverlayState extends State<RestModeOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return Stack(
            children: [
              CustomPaint(
                painter: RestModePainter(
                  status: widget.status,
                  animValue: _controller.value,
                ),
                size: Size.infinite,
              ),
              // メッセージ
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 200),
                      Text(
                        widget.status == RestStatus.nightTime
                            ? 'おやすみの じかんだよ'
                            : 'すこし やすもうね',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: Colors.white.withOpacity(0.7),
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        widget.status == RestStatus.nightTime
                            ? 'あしたまた あそぼう'
                            : 'めをやすめて、そとであそんでおいで',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.4),
                        ),
                      ),
                      const SizedBox(height: 40),
                      // 親の解除ボタン（小さく控えめ）
                      if (widget.onParentOverride != null)
                        GestureDetector(
                          onLongPress: widget.onParentOverride,
                          child: Text(
                            '保護者の方: 長押しで解除',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.white.withOpacity(0.15),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
