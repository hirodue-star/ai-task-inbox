import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import '../theme/ma_colors.dart';

/// 🐧 ペンギン級：氷のシャキシャキボタン
/// タップで「パキッ」と割れるような硬質エフェクト
class IceButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final VoidCallback? onTap;
  final double width;
  final double height;

  const IceButton({
    super.key,
    required this.label,
    required this.icon,
    this.onTap,
    this.width = 140,
    this.height = 50,
  });

  @override
  State<IceButton> createState() => _IceButtonState();
}

class _IceButtonState extends State<IceButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _cracking = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _controller.reverse();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTap() {
    setState(() => _cracking = true);
    _controller.forward(from: 0);
    widget.onTap?.call();
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) setState(() => _cracking = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _onTap,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final shake = math.sin(_controller.value * math.pi * 6) * 2 * (1 - _controller.value);
          return Transform.translate(
            offset: Offset(shake, 0),
            child: child,
          );
        },
        child: Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withValues(alpha: 0.9),
                MaColors.penguinIce.withValues(alpha: 0.7),
                MaColors.penguinDeep.withValues(alpha: 0.4),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: MaColors.penguinIce.withValues(alpha: 0.8),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: MaColors.penguinDeep.withValues(alpha: _cracking ? 0.4 : 0.15),
                blurRadius: _cracking ? 16 : 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Stack(
            children: [
              // 氷のひび（タップ時）
              if (_cracking)
                CustomPaint(
                  size: Size(widget.width, widget.height),
                  painter: _IceCrackPainter(progress: _controller.value),
                ),
              // ハイライト
              Positioned(
                top: 3,
                left: 8,
                right: 8,
                child: Container(
                  height: widget.height * 0.3,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.white.withValues(alpha: 0.5),
                        Colors.white.withValues(alpha: 0),
                      ],
                    ),
                  ),
                ),
              ),
              // コンテンツ
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(widget.icon, size: 20, color: MaColors.penguinDeep),
                    const SizedBox(width: 8),
                    Text(
                      widget.label,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: MaColors.penguinDeep,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 氷のひび割れ描画
class _IceCrackPainter extends CustomPainter {
  final double progress;

  _IceCrackPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) return;
    final cx = size.width / 2;
    final cy = size.height / 2;
    final maxLen = size.width * 0.3 * progress;
    final crackPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.8 * (1 - progress))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    final rng = math.Random(42);
    for (var i = 0; i < 5; i++) {
      final angle = rng.nextDouble() * math.pi * 2;
      final len = maxLen * (0.5 + rng.nextDouble() * 0.5);
      canvas.drawLine(
        Offset(cx, cy),
        Offset(cx + len * math.cos(angle), cy + len * math.sin(angle)),
        crackPaint,
      );
    }
  }

  @override
  bool shouldRepaint(_IceCrackPainter old) => progress != old.progress;
}
