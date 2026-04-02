import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../painters/background_painter.dart';
import '../../widgets/gacha_capsule.dart';
import '../../theme/ma_colors.dart';

/// 🦁 ライオン級：ガチャ演出画面
class LionGacha extends StatefulWidget {
  const LionGacha({super.key});

  @override
  State<LionGacha> createState() => _LionGachaState();
}

class _LionGachaState extends State<LionGacha>
    with TickerProviderStateMixin {
  late AnimationController _bgController;
  late AnimationController _sequenceController;
  late Animation<double> _capsuleRise;
  late Animation<double> _capsuleShake;
  late Animation<double> _burstScale;
  late Animation<double> _resultOpacity;

  _GachaPhase _phase = _GachaPhase.ready;
  String? _reward;

  static const _rewards = [
    '王冠', '望遠鏡', '黄金の星', 'コンパス', 'ロケット',
    '知恵の書', '勇気のメダル', '友情の絆',
  ];

  @override
  void initState() {
    super.initState();
    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    _sequenceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    );

    _capsuleRise = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _sequenceController, curve: const Interval(0, 0.3, curve: Curves.easeOut)),
    );
    _capsuleShake = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _sequenceController, curve: const Interval(0.3, 0.6, curve: Curves.linear)),
    );
    _burstScale = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _sequenceController, curve: const Interval(0.6, 0.8, curve: Curves.elasticOut)),
    );
    _resultOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _sequenceController, curve: const Interval(0.75, 1.0, curve: Curves.easeIn)),
    );

    _sequenceController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() => _phase = _GachaPhase.result);
      }
    });
  }

  @override
  void dispose() {
    _bgController.dispose();
    _sequenceController.dispose();
    super.dispose();
  }

  void _startGacha() {
    final rng = math.Random();
    _reward = _rewards[rng.nextInt(_rewards.length)];
    setState(() => _phase = _GachaPhase.animating);
    _sequenceController.forward(from: 0);
  }

  void _reset() {
    setState(() => _phase = _GachaPhase.ready);
    _sequenceController.reset();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: Listenable.merge([_bgController, _sequenceController]),
        builder: (context, _) {
          return CustomPaint(
            painter: LionBgPainter(animValue: _bgController.value),
            child: SafeArea(
              child: Column(
                children: [
                  // ヘッダー
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: MaColors.lionGold.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(Icons.arrow_back_rounded, color: MaColors.lionGold.withValues(alpha: 0.9)),
                          ),
                        ),
                        const Spacer(),
                        ShaderMask(
                          shaderCallback: (b) => MaColors.goldGradient.createShader(b),
                          child: const Text(
                            'びっくらポン',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: 3,
                            ),
                          ),
                        ),
                        const Spacer(),
                        const SizedBox(width: 40),
                      ],
                    ),
                  ),

                  const Spacer(),

                  // ガチャ演出エリア
                  SizedBox(
                    height: 300,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // 光のバースト
                        if (_phase != _GachaPhase.ready)
                          Transform.scale(
                            scale: _burstScale.value * 3,
                            child: Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: RadialGradient(
                                  colors: [
                                    MaColors.lionGold.withValues(alpha: 0.6 * _burstScale.value),
                                    MaColors.lionGold.withValues(alpha: 0),
                                  ],
                                ),
                              ),
                            ),
                          ),

                        // カプセル
                        if (_phase != _GachaPhase.result)
                          Transform.translate(
                            offset: Offset(
                              math.sin(_capsuleShake.value * math.pi * 8) * 10,
                              -_capsuleRise.value * 80,
                            ),
                            child: GachaCapsule(
                              size: 110,
                              isOpening: _phase == _GachaPhase.animating &&
                                  _sequenceController.value > 0.3,
                            ),
                          ),

                        // 結果表示
                        if (_phase == _GachaPhase.result || _resultOpacity.value > 0)
                          Opacity(
                            opacity: _resultOpacity.value,
                            child: Transform.scale(
                              scale: 0.5 + _resultOpacity.value * 0.5,
                              child: _RewardDisplay(reward: _reward ?? ''),
                            ),
                          ),
                      ],
                    ),
                  ),

                  const Spacer(),

                  // アクションボタン
                  Padding(
                    padding: const EdgeInsets.all(32),
                    child: GestureDetector(
                      onTap: _phase == _GachaPhase.ready
                          ? _startGacha
                          : _phase == _GachaPhase.result
                              ? _reset
                              : null,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        decoration: BoxDecoration(
                          gradient: MaColors.goldGradient,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: MaColors.lionGold.withValues(alpha: 0.4),
                              blurRadius: 20,
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            _phase == _GachaPhase.ready
                                ? 'ガチャをまわす！'
                                : _phase == _GachaPhase.result
                                    ? 'もういちど！'
                                    : '...',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF5C3D10),
                              letterSpacing: 2,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

enum _GachaPhase { ready, animating, result }

class _RewardDisplay extends StatelessWidget {
  final String reward;
  const _RewardDisplay({required this.reward});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: MaColors.goldGradient,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: MaColors.lionGold.withValues(alpha: 0.6),
            blurRadius: 40,
            spreadRadius: 10,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.auto_awesome, size: 40, color: Color(0xFF5C3D10)),
          const SizedBox(height: 8),
          Text(
            reward,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Color(0xFF5C3D10),
            ),
          ),
        ],
      ),
    );
  }
}
