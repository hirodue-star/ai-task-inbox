import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/world_state.dart';
import '../painters/world_bg_painter.dart';
import '../painters/recursive_world_painter.dart';
import '../providers/hlc_provider.dart';
import '../providers/world_provider.dart';
import '../providers/ambient_provider.dart';
import '../providers/memory_provider.dart';
import '../theme/ma_colors.dart';
import '../widgets/world_restore_bar.dart';
import 'hiyoko/hiyoko_home.dart';
import 'penguin/penguin_home.dart';
import 'lion/lion_home.dart';
import 'bond/bond_feed_screen.dart';
import 'parent/parent_dashboard.dart';
import 'collection_book_screen.dart';
import 'manga/coloring_screen.dart';
import 'manga/comic_album_screen.dart';
import '../providers/level_provider.dart';
import '../models/user_level.dart';
import '../painters/evolution_painter.dart';
import '../widgets/adaptive_nav.dart';

/// ホーム画面：動的世界背景 + 級選択 + 世界復元率
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _bgController;
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _showEvolution = false;
  UiTier? _evolutionFrom;
  UiTier? _evolutionTo;

  @override
  void initState() {
    super.initState();
    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
  }

  @override
  void dispose() {
    _bgController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final world = ref.watch(worldStateProvider);
    final score = ref.watch(hlcScoreProvider);
    final ambient = ref.watch(ambientProvider);
    final challengeCount = ref.watch(challengeCountProvider).valueOrNull ?? 0;

    return Scaffold(
      key: _scaffoldKey,
      drawer: const AdaptiveDrawer(),
      body: Stack(
        children: [
          AnimatedBuilder(
        animation: _bgController,
        builder: (context, child) {
          return CustomPaint(
            painter: WorldBgPainter(
              phase: world.phase,
              evolution: world.evolutionStage,
              animValue: _bgController.value,
              abyssIntensity: world.abyssIntensity,
              challengeCount: challengeCount,
            ),
            foregroundPainter: RecursiveWorldPainter(
              actionSeed: world.totalActions,
              animValue: _bgController.value,
              windSpeed: ambient.windSpeed,
              starCount: ambient.starCount,
            ),
            child: child,
          );
        },
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const SizedBox(height: 12),

                // 世界復元率バー
                const WorldRestoreBar(),

                const SizedBox(height: 16),

                // メニュー + ヘッダー
                GestureDetector(
                  onTap: () => _scaffoldKey.currentState?.openDrawer(),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.menu_rounded, color: _textColor(world.phase), size: 22),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'MA-LOGIC',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: _textColor(world.phase),
                    letterSpacing: 4,
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 4),

                // HLCスコアバー
                _HlcScoreBar(phase: world.phase),

                const SizedBox(height: 8),

                Text(
                  _phaseGreeting(world.phase),
                  style: TextStyle(
                    fontSize: 14,
                    color: _textColor(world.phase).withOpacity(0.7),
                  ),
                ),

                const SizedBox(height: 24),

                // 級選択カード
                _LevelCard(
                  title: 'ひよこ級',
                  subtitle: _phaseSubtitle(world.phase, 'hiyoko'),
                  emoji: '🐣',
                  gradient: LinearGradient(
                    colors: world.phase == TimeOfDayPhase.morning
                        ? [const Color(0xFFFFF8F0), const Color(0xFFFFE8D0)]
                        : [const Color(0xFFFFF0E0), const Color(0xFFFFE0EC)],
                  ),
                  shadowColor: MaColors.hiyokoPink,
                  onTap: () {
                    ref.read(worldStateProvider.notifier).performAction(restorePoints: 0.5);
                    Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const HiyokoHome()));
                  },
                ),
                const SizedBox(height: 16),

                _LevelCard(
                  title: 'ペンギン級',
                  subtitle: _phaseSubtitle(world.phase, 'penguin'),
                  emoji: '🐧',
                  gradient: const LinearGradient(
                    colors: [Color(0xFFE8F4FF), Color(0xFFD0E8FF)],
                  ),
                  shadowColor: MaColors.penguinDeep,
                  locked: world.abyssIntensity < 0.3,
                  onTap: () {
                    if (world.abyssIntensity < 0.3) {
                      _showAbyssMessage();
                      return;
                    }
                    ref.read(worldStateProvider.notifier).performAction(restorePoints: 0.5);
                    Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const PenguinHome()));
                  },
                ),
                const SizedBox(height: 16),

                _LevelCard(
                  title: 'ライオン級',
                  subtitle: _phaseSubtitle(world.phase, 'lion'),
                  emoji: '🦁',
                  gradient: world.phase == TimeOfDayPhase.night
                      ? const LinearGradient(
                          colors: [Color(0xFFFFE880), Color(0xFFFFD700), Color(0xFFC8960C)],
                        )
                      : MaColors.goldGradient,
                  shadowColor: MaColors.lionDeepGold,
                  glowing: world.phase == TimeOfDayPhase.night,
                  onTap: () {
                    ref.read(worldStateProvider.notifier).performAction(restorePoints: 0.5);
                    Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const LionHome()));
                  },
                ),

                const Spacer(),

                // 下部メニュー
                Row(
                  children: [
                    Expanded(child: _BottomButton(
                      icon: Icons.people_rounded, label: 'BOND-LOG',
                      color: _textColor(world.phase),
                      onTap: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const BondFeedScreen())),
                    )),
                    const SizedBox(width: 8),
                    Expanded(child: _BottomButton(
                      icon: Icons.menu_book_rounded, label: 'マンガ',
                      color: _textColor(world.phase),
                      onTap: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const ComicAlbumScreen())),
                    )),
                    const SizedBox(width: 8),
                    Expanded(child: _BottomButton(
                      icon: Icons.brush_rounded, label: 'ぬりえ',
                      color: _textColor(world.phase),
                      onTap: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const ColoringScreen())),
                    )),
                    const SizedBox(width: 8),
                    Expanded(child: _BottomButton(
                      icon: Icons.bar_chart_rounded, label: '成長',
                      color: _textColor(world.phase),
                      onTap: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const ParentDashboard())),
                    )),
                  ],
                ),
                const SizedBox(height: 8),

                // 深海の渦のヒント
                if (world.abyssIntensity > 0.1 && world.abyssIntensity < 0.3)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Text(
                      '画面の奥深くに、何かが蠢いている…',
                      style: TextStyle(
                        fontSize: 12,
                        color: MaColors.penguinDeep.withOpacity(0.4),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
          // 進化演出オーバーレイ
          if (_showEvolution && _evolutionFrom != null && _evolutionTo != null)
            Positioned.fill(
              child: EvolutionOverlay(
                fromTier: _evolutionFrom!,
                toTier: _evolutionTo!,
                onComplete: () => setState(() => _showEvolution = false),
              ),
            ),
        ],
      ),
    );
  }

  void _showAbyssMessage() {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF0A1020).withOpacity(0.95),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: MaColors.penguinIce.withOpacity(0.3)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.waves_rounded, size: 48, color: MaColors.penguinIce.withOpacity(0.6)),
              const SizedBox(height: 12),
              Text(
                '深海はまだ遠い…',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: MaColors.penguinIce,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '思考の重みを蓄積させよ。\nお手伝いや思考記録を重ねることで、\n深海への道が開かれる。',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: MaColors.penguinIce.withOpacity(0.6),
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () => Navigator.pop(ctx),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  decoration: BoxDecoration(
                    border: Border.all(color: MaColors.penguinIce.withOpacity(0.3)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'わかった',
                    style: TextStyle(color: MaColors.penguinIce.withOpacity(0.7)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _textColor(TimeOfDayPhase phase) {
    switch (phase) {
      case TimeOfDayPhase.morning: return const Color(0xFF5C3D10);
      case TimeOfDayPhase.daytime: return const Color(0xFF2C3E50);
      case TimeOfDayPhase.evening: return const Color(0xFFFFE0C0);
      case TimeOfDayPhase.night: return const Color(0xFFE0E8FF);
    }
  }

  String _phaseGreeting(TimeOfDayPhase phase) {
    switch (phase) {
      case TimeOfDayPhase.morning: return 'おはよう。今日も世界を育てよう';
      case TimeOfDayPhase.daytime: return '太陽が見守っている';
      case TimeOfDayPhase.evening: return '夕暮れの静けさの中で';
      case TimeOfDayPhase.night: return '星が知恵を囁いている';
    }
  }

  String _phaseSubtitle(TimeOfDayPhase phase, String level) {
    if (level == 'lion' && phase == TimeOfDayPhase.night) return 'Gold blazing in starlight';
    if (level == 'hiyoko' && phase == TimeOfDayPhase.morning) return 'Crystal clear pastel dawn';
    if (level == 'penguin') return 'Ice & Crystalline';
    if (level == 'hiyoko') return 'Squishy & Pastel';
    return 'Gold & Particles';
  }
}

// === HLCスコアバー ===

class _HlcScoreBar extends ConsumerWidget {
  final TimeOfDayPhase phase;
  const _HlcScoreBar({required this.phase});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final score = ref.watch(hlcScoreProvider);
    final isNight = phase == TimeOfDayPhase.night || phase == TimeOfDayPhase.evening;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isNight ? Colors.white.withOpacity(0.1) : Colors.white.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _ScoreChip(label: 'H', value: score.hospitality, color: MaColors.hiyokoPink),
          _ScoreChip(label: 'L', value: score.logic, color: MaColors.penguinDeep),
          _ScoreChip(label: 'C', value: score.creativity, color: MaColors.lionGold),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              gradient: MaColors.goldGradient,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              score.level.name.toUpperCase(),
              style: const TextStyle(
                fontSize: 10,
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
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w700)),
        const SizedBox(width: 2),
        Text('$value', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: color)),
      ],
    );
  }
}

class _BottomButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _BottomButton({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: color.withOpacity(0.6)),
            const SizedBox(height: 2),
            Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: color.withOpacity(0.5))),
          ],
        ),
      ),
    );
  }
}

// === レベルカード ===

class _LevelCard extends StatefulWidget {
  final String title;
  final String subtitle;
  final String emoji;
  final Gradient gradient;
  final Color shadowColor;
  final VoidCallback onTap;
  final bool locked;
  final bool glowing;

  const _LevelCard({
    required this.title,
    required this.subtitle,
    required this.emoji,
    required this.gradient,
    required this.shadowColor,
    required this.onTap,
    this.locked = false,
    this.glowing = false,
  });

  @override
  State<_LevelCard> createState() => _LevelCardState();
}

class _LevelCardState extends State<_LevelCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
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
        animation: _controller,
        builder: (context, child) {
          final scale = 1.0 - _controller.value * 0.05;
          return Transform.scale(scale: scale, child: child);
        },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
          decoration: BoxDecoration(
            gradient: widget.gradient,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: widget.shadowColor.withOpacity(widget.glowing ? 0.5 : 0.25),
                blurRadius: widget.glowing ? 24 : 12,
                offset: const Offset(0, 4),
                spreadRadius: widget.glowing ? 2 : 0,
              ),
            ],
          ),
          child: Row(
            children: [
              Text(widget.emoji, style: const TextStyle(fontSize: 36)),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF3D2C1E),
                      ),
                    ),
                    Text(
                      widget.subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: const Color(0xFF3D2C1E).withOpacity(0.5),
                      ),
                    ),
                  ],
                ),
              ),
              if (widget.locked)
                Icon(Icons.lock_rounded,
                    color: const Color(0xFF3D2C1E).withOpacity(0.3), size: 22)
              else
                Icon(Icons.arrow_forward_ios_rounded,
                    color: const Color(0xFF3D2C1E).withOpacity(0.3), size: 18),
            ],
          ),
        ),
      ),
    );
  }
}
