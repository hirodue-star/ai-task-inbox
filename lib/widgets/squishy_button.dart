import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import '../painters/fractal_painter.dart';
import '../theme/ma_colors.dart';

/// 🐣 ひよこ級：ぷにぷにマシュマロボタン
/// SpringSimulation + 横膨張でマシュマロの弾性を再現
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
    with TickerProviderStateMixin {
  late AnimationController _verticalController;
  late AnimationController _horizontalController;
  bool _pressed = false;
  bool _showFractal = false;

  @override
  void initState() {
    super.initState();
    _verticalController = AnimationController.unbounded(vsync: this, value: 1.0);
    _horizontalController = AnimationController.unbounded(vsync: this, value: 1.0);
  }

  @override
  void dispose() {
    _verticalController.dispose();
    _horizontalController.dispose();
    super.dispose();
  }

  void _pressDown() {
    setState(() => _pressed = true);
    _verticalController.stop();
    _horizontalController.stop();
    // 縦に縮む + 横に広がる = マシュマロが押された質感
    _verticalController.value = 0.85;
    _horizontalController.value = 1.12;
  }

  void _releaseSpring() {
    setState(() => _pressed = false);
    // 縦方向：やわらかく戻る（低めのstiffnessで「ぷにっ」感）
    final vertSpring = SpringDescription(mass: 1.0, stiffness: 300.0, damping: 8.0);
    _verticalController.animateWith(SpringSimulation(vertSpring, 0.85, 1.0, 2.0));
    // 横方向：少し遅れて戻る（体積保存っぽさ）
    final horizSpring = SpringDescription(mass: 1.2, stiffness: 250.0, damping: 9.0);
    _horizontalController.animateWith(SpringSimulation(horizSpring, 1.12, 1.0, -1.5));
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
        setState(() => _showFractal = true);
        Future.delayed(const Duration(milliseconds: 250), () {
          if (mounted) setState(() => _showFractal = false);
        });
        widget.onTap?.call();
      },
      onTapCancel: () => _releaseSpring(),
      child: AnimatedBuilder(
        animation: Listenable.merge([_verticalController, _horizontalController]),
        builder: (context, child) {
          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..scale(_horizontalController.value, _verticalController.value),
            child: child,
          );
        },
        child: Container(
          width: s,
          height: s,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              center: const Alignment(-0.3, -0.3),
              radius: 0.9,
              colors: [lighter, widget.color, darker],
              stops: const [0.0, 0.6, 1.0],
            ),
            boxShadow: [
              BoxShadow(
                color: darker.withValues(alpha: 0.4),
                blurRadius: _pressed ? 4 : 12,
                offset: _pressed ? const Offset(0, 2) : const Offset(0, 6),
              ),
              BoxShadow(
                color: lighter.withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // フラクタルバースト（可変報酬）
              if (_showFractal)
                Positioned.fill(
                  child: FractalBurst(trigger: true),
                ),
              // 光沢ハイライト
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
