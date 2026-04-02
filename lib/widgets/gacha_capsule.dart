import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/ma_colors.dart';

/// 🦁 ライオン級：黄金ガチャカプセル
class GachaCapsule extends StatefulWidget {
  final double size;
  final bool isOpening;
  final VoidCallback? onTap;

  const GachaCapsule({super.key, this.size = 120, this.isOpening = false, this.onTap});

  @override
  State<GachaCapsule> createState() => _GachaCapsuleState();
}

class _GachaCapsuleState extends State<GachaCapsule>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _shakeAnim;
  late Animation<double> _glowAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _shakeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticIn),
    );
    _glowAnim = Tween<double>(begin: 0.3, end: 0.8).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    if (widget.isOpening) _controller.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(GachaCapsule old) {
    super.didUpdateWidget(old);
    if (widget.isOpening && !old.isOpening) {
      _controller.repeat(reverse: true);
    } else if (!widget.isOpening && old.isOpening) {
      _controller.stop();
      _controller.reset();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.size;

    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final shake = math.sin(_shakeAnim.value * math.pi * 4) * 3;
          return Transform.translate(
            offset: Offset(shake, 0),
            child: child,
          );
        },
        child: SizedBox(
          width: s,
          height: s * 1.3,
          child: CustomPaint(
            painter: _CapsulePainter(
              glowIntensity: widget.isOpening ? _glowAnim.value : 0.3,
            ),
          ),
        ),
      ),
    );
  }
}

class _CapsulePainter extends CustomPainter {
  final double glowIntensity;

  _CapsulePainter({required this.glowIntensity});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final topH = size.height * 0.5;
    final botH = size.height * 0.5;
    final r = size.width * 0.45;

    // 外側のグロー
    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          MaColors.lionGold.withValues(alpha: glowIntensity),
          MaColors.lionGold.withValues(alpha: 0),
        ],
      ).createShader(Rect.fromCircle(center: Offset(cx, size.height * 0.5), radius: r * 1.5));
    canvas.drawCircle(Offset(cx, size.height * 0.5), r * 1.5, glowPaint);

    // 上半球（王冠ゴールド）
    final topPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFFFF8DC), Color(0xFFFFD700), Color(0xFFB8860B)],
        stops: [0.0, 0.4, 1.0],
      ).createShader(Rect.fromLTWH(cx - r, 0, r * 2, topH));

    final topPath = Path()
      ..moveTo(cx - r, topH)
      ..lineTo(cx - r, topH * 0.4)
      ..arcToPoint(Offset(cx + r, topH * 0.4), radius: Radius.circular(r), clockwise: true)
      ..lineTo(cx + r, topH)
      ..close();
    canvas.drawPath(topPath, topPaint);

    // 下半球（濃いゴールド）
    final botPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFDAA520), Color(0xFFB8860B), Color(0xFF8B6914)],
        stops: [0.0, 0.5, 1.0],
      ).createShader(Rect.fromLTWH(cx - r, topH, r * 2, botH));

    final botPath = Path()
      ..moveTo(cx - r, topH)
      ..lineTo(cx - r, topH + botH * 0.6)
      ..arcToPoint(Offset(cx + r, topH + botH * 0.6), radius: Radius.circular(r), clockwise: false)
      ..lineTo(cx + r, topH)
      ..close();
    canvas.drawPath(botPath, botPaint);

    // 中央の分割ライン
    final linePaint = Paint()
      ..color = const Color(0xFF8B6914)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawLine(Offset(cx - r, topH), Offset(cx + r, topH), linePaint);

    // 金の帯
    final bandPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFFFD700), Color(0xFFFFF8DC), Color(0xFFFFD700)],
      ).createShader(Rect.fromLTWH(cx - r, topH - 6, r * 2, 12));
    canvas.drawRect(Rect.fromLTWH(cx - r + 4, topH - 5, r * 2 - 8, 10), bandPaint);

    // 上部ハイライト
    final hlPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Colors.white.withValues(alpha: 0.5), Colors.white.withValues(alpha: 0)],
      ).createShader(Rect.fromLTWH(cx - r * 0.5, topH * 0.15, r, topH * 0.4));
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx - r * 0.1, topH * 0.35), width: r * 0.8, height: topH * 0.35),
      hlPaint,
    );

    // 王冠マーク（上部）
    _drawCrown(canvas, Offset(cx, topH * 0.3), r * 0.3);
  }

  void _drawCrown(Canvas canvas, Offset center, double size) {
    final paint = Paint()..color = const Color(0xFFFFF8DC);
    final path = Path()
      ..moveTo(center.dx - size, center.dy + size * 0.4)
      ..lineTo(center.dx - size, center.dy - size * 0.2)
      ..lineTo(center.dx - size * 0.5, center.dy + size * 0.1)
      ..lineTo(center.dx, center.dy - size * 0.5)
      ..lineTo(center.dx + size * 0.5, center.dy + size * 0.1)
      ..lineTo(center.dx + size, center.dy - size * 0.2)
      ..lineTo(center.dx + size, center.dy + size * 0.4)
      ..close();
    canvas.drawPath(path, paint);

    // 宝石
    final gemPaint = Paint()..color = const Color(0xFFFF4444);
    canvas.drawCircle(Offset(center.dx, center.dy), size * 0.12, gemPaint);
  }

  @override
  bool shouldRepaint(_CapsulePainter old) => glowIntensity != old.glowIntensity;
}
