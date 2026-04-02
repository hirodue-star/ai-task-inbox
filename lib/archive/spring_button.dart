import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';

/// 物理演算ベースのスプリングボタン
/// SpringSimulation で自然な弾力を実現
class SpringButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double springMass;
  final double springStiffness;
  final double springDamping;

  const SpringButton({
    super.key,
    required this.child,
    this.onTap,
    this.springMass = 1.0,
    this.springStiffness = 300.0,
    this.springDamping = 10.0,
  });

  @override
  State<SpringButton> createState() => _SpringButtonState();
}

class _SpringButtonState extends State<SpringButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      // upperBound/lowerBoundは使わず、simulationで制御
    );
    _scaleAnim = _controller.drive(Tween(begin: 1.0, end: 1.0));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails _) {
    // 押下時：0.85に縮小
    _controller.stop();
    _scaleAnim = Tween<double>(begin: _scaleAnim.value, end: 0.85).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ),
    );
    _controller.duration = const Duration(milliseconds: 100);
    _controller.forward(from: 0);
  }

  void _onTapUp(TapUpDetails _) {
    _releaseSpring();
    widget.onTap?.call();
  }

  void _onTapCancel() {
    _releaseSpring();
  }

  void _releaseSpring() {
    // SpringSimulation で弾力のある戻りアニメーション
    final spring = SpringDescription(
      mass: widget.springMass,
      stiffness: widget.springStiffness,
      damping: widget.springDamping,
    );
    final simulation = SpringSimulation(spring, 0.85, 1.0, 0);

    _controller.stop();

    // SpringSimulationを使ったカスタムアニメーション
    _scaleAnim = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        // SpringCurveで物理的な弾力を再現
        curve: _SpringCurve(spring),
      ),
    );
    _controller.duration = const Duration(milliseconds: 600);
    _controller.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedBuilder(
        animation: _scaleAnim,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnim.value,
            child: child,
          );
        },
        child: widget.child,
      ),
    );
  }
}

/// SpringDescriptionからCurveを生成
class _SpringCurve extends Curve {
  final SpringDescription spring;
  late final SpringSimulation _sim;

  _SpringCurve(this.spring) {
    _sim = SpringSimulation(spring, 0, 1, 0);
  }

  @override
  double transformInternal(double t) {
    // 600ms * t でシミュレーション
    return _sim.x(t * 0.6).clamp(0.0, 1.0);
  }
}
