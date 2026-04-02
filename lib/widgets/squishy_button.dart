import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import '../theme/ma_colors.dart';

/// 🐣 ひよこ級：ぷにぷにマシュマロボタン
/// 3D光沢 + Inner Shadow でゼリーのような質感を表現
class SquishyButton extends StatefulWidget {
  final Color color;
  final String label;
  final VoidCallback? onTap;
  final double size;

  const SquishyButton({
    super.key,
    required this.color,
    required this.label,
    this.onTap,
    this.size = 100,
  });

  @override
  State<SquishyButton> createState() => _SquishyButtonState();
}

class _SquishyButtonState extends State<SquishyButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;
  bool _pressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController.unbounded(vsync: this);
    _scaleAnim = AlwaysStoppedAnimation(1.0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _pressDown() {
    setState(() => _pressed = true);
    _controller.stop();
    _controller.value = 0.9;
    _scaleAnim = AlwaysStoppedAnimation(0.9);
  }

  void _releaseSpring() {
    setState(() => _pressed = false);
    // SpringSimulation: 弾力のある戻り
    final spring = SpringDescription(
      mass: 1.0,
      stiffness: 400.0,
      damping: 12.0,
    );
    final sim = SpringSimulation(spring, 0.9, 1.0, 0);
    _scaleAnim = _controller.drive(Tween(begin: 0.9, end: 1.0));
    _controller.animateWith(sim);
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.size;
    final lighter = Color.lerp(widget.color, Colors.white, 0.5)!;
    final darker = Color.lerp(widget.color, Colors.black, 0.25)!;

    return GestureDetector(
      onTapDown: (_) => _pressDown(),
      onTapUp: (_) {
        _releaseSpring();
        widget.onTap?.call();
      },
      onTapCancel: () => _releaseSpring(),
      child: AnimatedBuilder(
        animation: _scaleAnim,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnim.value,
            child: child,
          );
        },
        child: Container(
          width: s,
          height: s,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            // 外側のメインカラー + 立体感
            gradient: RadialGradient(
              center: const Alignment(-0.3, -0.3),
              radius: 0.9,
              colors: [lighter, widget.color, darker],
              stops: const [0.0, 0.6, 1.0],
            ),
            boxShadow: [
              // 外側の影（浮き上がり）
              BoxShadow(
                color: darker.withValues(alpha: 0.4),
                blurRadius: _pressed ? 4 : 12,
                offset: _pressed ? const Offset(0, 2) : const Offset(0, 6),
              ),
              // 下部のハイライト反射
              BoxShadow(
                color: lighter.withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Stack(
            children: [
              // 光沢ハイライト（上部の白い反射）
              Positioned(
                top: s * 0.1,
                left: s * 0.2,
                child: Container(
                  width: s * 0.5,
                  height: s * 0.25,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(
                      Radius.elliptical(s * 0.25, s * 0.12),
                    ),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.white.withValues(alpha: 0.7),
                        Colors.white.withValues(alpha: 0.0),
                      ],
                    ),
                  ),
                ),
              ),
              // ラベル
              Center(
                child: Text(
                  widget.label,
                  style: TextStyle(
                    fontSize: s * 0.18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white.withValues(alpha: 0.9),
                    shadows: [
                      Shadow(
                        color: darker.withValues(alpha: 0.5),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// ぷにぷにボタン4色の横並びウィジェット
class SquishyButtonRow extends StatelessWidget {
  final double buttonSize;
  final void Function(int index)? onTap;

  const SquishyButtonRow({super.key, this.buttonSize = 80, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(4, (i) {
        return SquishyButton(
          color: MaColors.hiyokoButtons[i],
          label: MaColors.hiyokoButtonLabels[i],
          size: buttonSize,
          onTap: () => onTap?.call(i),
        );
      }),
    );
  }
}
