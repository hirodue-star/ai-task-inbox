import 'package:flutter/material.dart';
import '../../painters/background_painter.dart';
import '../../painters/gaogao_painter.dart';
import '../../widgets/squishy_button.dart';
import '../../theme/ma_colors.dart';
import 'hiyoko_otetsudai.dart';
import 'memory_input_screen.dart';

/// 🐣 ひよこ級ホーム — ぷにぷにボタン4つ + ガオガオ表示
class HiyokoHome extends StatefulWidget {
  const HiyokoHome({super.key});

  @override
  State<HiyokoHome> createState() => _HiyokoHomeState();
}

class _HiyokoHomeState extends State<HiyokoHome>
    with SingleTickerProviderStateMixin {
  late AnimationController _bgController;
  GaogaoMood _currentMood = GaogaoMood.happy;

  @override
  void initState() {
    super.initState();
    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
  }

  @override
  void dispose() {
    _bgController.dispose();
    super.dispose();
  }

  void _onButtonTap(int index) {
    setState(() {
      _currentMood = GaogaoMood.values[index];
    });

    if (index == 2) {
      // おてつだいボタン
      Navigator.push(context,
        MaterialPageRoute(builder: (_) => const HiyokoOtetsudai()));
    } else if (index == 3) {
      // ぼうけんボタン → 記憶の記録
      Navigator.push(context,
        MaterialPageRoute(builder: (_) => const MemoryInputScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _bgController,
        builder: (context, child) {
          return CustomPaint(
            painter: HiyokoBgPainter(animValue: _bgController.value),
            child: child,
          );
        },
        child: SafeArea(
          child: Column(
            children: [
              // ナビゲーションバー
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.7),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.arrow_back_rounded, color: Color(0xFF5C3D10)),
                      ),
                    ),
                    const Spacer(),
                    const Text(
                      'ひよこ級',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF5C3D10),
                      ),
                    ),
                    const Spacer(),
                    const SizedBox(width: 40),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ガオガオ（中央の大きな表情）
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                transitionBuilder: (child, anim) {
                  return ScaleTransition(
                    scale: CurvedAnimation(parent: anim, curve: Curves.elasticOut),
                    child: child,
                  );
                },
                child: GaogaoFace(
                  key: ValueKey(_currentMood),
                  mood: _currentMood,
                  size: 180,
                ),
              ),

              const SizedBox(height: 12),
              Text(
                _moodLabel(_currentMood),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF5C3D10),
                ),
              ),

              const Spacer(),

              // ぷにぷにボタン4色
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SquishyButtonRow(
                  buttonSize: 76,
                  onTap: _onButtonTap,
                ),
              ),

              const SizedBox(height: 16),

              // ガオガオ表情ミニプレビュー
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const GaogaoRow(faceSize: 50),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  String _moodLabel(GaogaoMood mood) {
    switch (mood) {
      case GaogaoMood.happy: return 'ガオガオ うれしい！';
      case GaogaoMood.shy: return 'ガオガオ てれてれ';
      case GaogaoMood.sleepy: return 'ガオガオ ねむねむ…';
      case GaogaoMood.excited: return 'ガオガオ わくわく！';
    }
  }
}
