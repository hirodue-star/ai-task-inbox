import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../painters/ice_painter.dart';
import '../../painters/penguin_painter.dart';
import '../../providers/hlc_provider.dart';
import '../../theme/ma_colors.dart';
import '../../widgets/ice_button.dart';
import 'penguin_logic_puzzle.dart';

/// 🐧 ペンギン級ホーム
class PenguinHome extends ConsumerStatefulWidget {
  const PenguinHome({super.key});

  @override
  ConsumerState<PenguinHome> createState() => _PenguinHomeState();
}

class _PenguinHomeState extends ConsumerState<PenguinHome>
    with SingleTickerProviderStateMixin {
  late AnimationController _bgController;
  PenguinMood _currentMood = PenguinMood.focus;

  @override
  void initState() {
    super.initState();
    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();
  }

  @override
  void dispose() {
    _bgController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final score = ref.watch(hlcScoreProvider);
    final deep = MaColors.penguinDeep;
    final ice = MaColors.penguinIce;

    return Scaffold(
      body: AnimatedBuilder(
        animation: _bgController,
        builder: (context, child) {
          return CustomPaint(
            painter: PenguinBgPainter(animValue: _bgController.value),
            child: child,
          );
        },
        child: SafeArea(
          child: Column(
            children: [
              // ナビゲーション
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: ice.withOpacity(0.5)),
                        ),
                        child: Icon(Icons.arrow_back_rounded, color: deep),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'ペンギン級',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: deep,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: ice),
                      ),
                      child: Text(
                        'L:${score.logic}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: deep,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // ペンギン + 結晶
              SizedBox(
                width: 200,
                height: 200,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    AnimatedBuilder(
                      animation: _bgController,
                      builder: (context, _) {
                        return IceCrystal(size: 200, animValue: _bgController.value);
                      },
                    ),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 400),
                      transitionBuilder: (child, anim) => ScaleTransition(
                        scale: CurvedAnimation(parent: anim, curve: Curves.elasticOut),
                        child: child,
                      ),
                      child: PenguinFace(
                        key: ValueKey(_currentMood),
                        mood: _currentMood,
                        size: 110,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),
              Text(
                _moodLabel(_currentMood),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: deep,
                ),
              ),

              const SizedBox(height: 32),

              // メニュー
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    IceButton(
                      label: 'くつをそろえる',
                      icon: Icons.checkroom_rounded,
                      width: double.infinity,
                      height: 56,
                      onTap: () {
                        setState(() => _currentMood = PenguinMood.clean);
                        ref.read(hlcScoreProvider.notifier).completeHelp(points: 10);
                      },
                    ),
                    const SizedBox(height: 12),
                    IceButton(
                      label: 'ろんりパズル',
                      icon: Icons.extension_rounded,
                      width: double.infinity,
                      height: 56,
                      onTap: () {
                        setState(() => _currentMood = PenguinMood.focus);
                        Navigator.push(context,
                          MaterialPageRoute(builder: (_) => const PenguinLogicPuzzle()));
                      },
                    ),
                    const SizedBox(height: 12),
                    IceButton(
                      label: 'こうさく',
                      icon: Icons.content_cut_rounded,
                      width: double.infinity,
                      height: 56,
                      onTap: () {
                        setState(() => _currentMood = PenguinMood.craft);
                        ref.read(hlcScoreProvider.notifier).createSomething(points: 8);
                      },
                    ),
                    const SizedBox(height: 12),
                    IceButton(
                      label: 'プロフィール',
                      icon: Icons.person_rounded,
                      width: double.infinity,
                      height: 56,
                      onTap: () => setState(() => _currentMood = PenguinMood.success),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // 表情プレビュー
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: ice.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: PenguinMood.values.map((m) {
                    return GestureDetector(
                      onTap: () => setState(() => _currentMood = m),
                      child: PenguinFace(mood: m, size: 50),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  String _moodLabel(PenguinMood mood) {
    switch (mood) {
      case PenguinMood.focus: return 'フォーカス！';
      case PenguinMood.clean: return 'すっきり！';
      case PenguinMood.craft: return 'こうさくちゅう…';
      case PenguinMood.success: return 'やったー！';
    }
  }
}
