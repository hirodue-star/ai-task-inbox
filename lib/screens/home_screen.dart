import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../painters/background_painter.dart';
import '../providers/hlc_provider.dart';
import '../models/hlc_score.dart';
import '../theme/ma_colors.dart';
import 'hiyoko/hiyoko_home.dart';
import 'lion/lion_home.dart';

/// ホーム画面：級選択 + HLCスコア表示
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _bgController;

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
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const SizedBox(height: 40),
                // ヘッダー
                const Text(
                  'MA-LOGIC',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF5C3D10),
                    letterSpacing: 4,
                  ),
                ),
                const SizedBox(height: 12),
                // HLCスコアバー
                _HlcScoreBar(),
                const SizedBox(height: 8),
                const Text(
                  'レベルをえらんでね',
                  style: TextStyle(fontSize: 16, color: Color(0xFF8B7355)),
                ),
                const SizedBox(height: 32),
                // 級選択カード
                _LevelCard(
                  title: 'ひよこ級',
                  subtitle: 'Squishy & Pastel',
                  emoji: '🐣',
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFF0E0), Color(0xFFFFE0EC)],
                  ),
                  shadowColor: MaColors.hiyokoPink,
                  onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const HiyokoHome())),
                ),
                const SizedBox(height: 20),
                _LevelCard(
                  title: 'ペンギン級',
                  subtitle: 'Ice & Crystalline',
                  emoji: '🐧',
                  gradient: const LinearGradient(
                    colors: [Color(0xFFE8F4FF), Color(0xFFD0E8FF)],
                  ),
                  shadowColor: MaColors.penguinDeep,
                  onTap: () {}, // TODO: ペンギン級画面
                ),
                const SizedBox(height: 20),
                _LevelCard(
                  title: 'ライオン級',
                  subtitle: 'Gold & Particles',
                  emoji: '🦁',
                  gradient: MaColors.goldGradient,
                  shadowColor: MaColors.lionDeepGold,
                  onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const LionHome())),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LevelCard extends StatefulWidget {
  final String title;
  final String subtitle;
  final String emoji;
  final Gradient gradient;
  final Color shadowColor;
  final VoidCallback onTap;

  const _LevelCard({
    required this.title,
    required this.subtitle,
    required this.emoji,
    required this.gradient,
    required this.shadowColor,
    required this.onTap,
  });

  @override
  State<_LevelCard> createState() => _LevelCardState();
}

class _LevelCardState extends State<_LevelCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap();
      },
      onTapCancel: () => _controller.reverse(),
      child: AnimatedBuilder(
        animation: _scaleAnim,
        builder: (context, child) {
          return Transform.scale(scale: _scaleAnim.value, child: child);
        },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          decoration: BoxDecoration(
            gradient: widget.gradient,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: widget.shadowColor.withValues(alpha: 0.3),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              Text(widget.emoji, style: const TextStyle(fontSize: 40)),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF3D2C1E),
                    ),
                  ),
                  Text(
                    widget.subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: const Color(0xFF3D2C1E).withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: const Color(0xFF3D2C1E).withValues(alpha: 0.4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// HLCスコア表示バー
class _HlcScoreBar extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final score = ref.watch(hlcScoreProvider);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _ScoreChip(label: 'H 奉仕', value: score.hospitality, color: MaColors.hiyokoPink),
          _ScoreChip(label: 'L 論理', value: score.logic, color: MaColors.penguinDeep),
          _ScoreChip(label: 'C 創造', value: score.creativity, color: MaColors.lionGold),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              gradient: MaColors.goldGradient,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'Lv.${score.level.name}',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: Color(0xFF5C3D10),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ScoreChip extends StatelessWidget {
  final String label;
  final int value;
  final Color color;

  const _ScoreChip({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w600),
        ),
        Text(
          '$value',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: color),
        ),
      ],
    );
  }
}
