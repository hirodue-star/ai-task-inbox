import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/ma_colors.dart';

/// ガオガオが弾けるリアクション（投稿完了時）
class GaogaoReaction extends StatefulWidget {
  final VoidCallback onComplete;
  const GaogaoReaction({super.key, required this.onComplete});

  @override
  State<GaogaoReaction> createState() => _GaogaoReactionState();
}

class _GaogaoReactionState extends State<GaogaoReaction>
    with TickerProviderStateMixin {
  late AnimationController _bounceController;
  late AnimationController _particleController;

  @override
  void initState() {
    super.initState();
    _bounceController = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _particleController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));

    _bounceController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _particleController.forward();
    });
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) widget.onComplete();
    });
  }

  @override
  void dispose() {
    _bounceController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withOpacity(0.3),
      child: Center(
        child: AnimatedBuilder(
          animation: Listenable.merge([_bounceController, _particleController]),
          builder: (context, _) {
            return Stack(
              alignment: Alignment.center,
              children: [
                // パーティクル（星やハート）
                ...List.generate(12, (i) {
                  final angle = i * math.pi * 2 / 12;
                  final dist = 80 * _particleController.value;
                  final alpha = (1.0 - _particleController.value).clamp(0.0, 1.0);
                  final emojis = ['⭐', '💖', '✨', '🌟', '💕', '⭐'];
                  return Transform.translate(
                    offset: Offset(dist * math.cos(angle), dist * math.sin(angle)),
                    child: Opacity(
                      opacity: alpha,
                      child: Text(emojis[i % emojis.length], style: const TextStyle(fontSize: 20)),
                    ),
                  );
                }),

                // ガオガオ本体
                ScaleTransition(
                  scale: CurvedAnimation(parent: _bounceController, curve: Curves.elasticOut),
                  child: Container(
                    width: 140, height: 140,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFFFFE4B5),
                      boxShadow: [BoxShadow(color: MaColors.gold.withOpacity(0.3), blurRadius: 24)],
                    ),
                    child: const Stack(
                      alignment: Alignment.center,
                      children: [
                        // 顔
                        Positioned(top: 40, child: Text('😆', style: TextStyle(fontSize: 60))),
                      ],
                    ),
                  ),
                ),

                // テキスト
                Positioned(
                  bottom: MediaQuery.of(context).size.height * 0.25,
                  child: Opacity(
                    opacity: _particleController.value.clamp(0.0, 1.0),
                    child: const Text(
                      'すごい！きろくできたよ！',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        shadows: [Shadow(color: Colors.black26, blurRadius: 8)],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
