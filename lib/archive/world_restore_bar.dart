import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/world_state.dart';
import '../providers/world_provider.dart';
import '../theme/ma_colors.dart';

/// 画面上部の『世界復元率（World Restore %）』バー
class WorldRestoreBar extends ConsumerWidget {
  const WorldRestoreBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final world = ref.watch(worldStateProvider);
    final percent = world.restorePercent;
    final stage = world.evolutionStage;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _stageColor(stage).withOpacity(0.4),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Text(
                _stageEmoji(stage),
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(width: 6),
              Text(
                'World Restore',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Colors.white.withOpacity(0.7),
                  letterSpacing: 1,
                ),
              ),
              const Spacer(),
              Text(
                '${percent.toStringAsFixed(1)}%',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: _stageColor(stage),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          // プログレスバー
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: SizedBox(
              height: 6,
              child: Stack(
                children: [
                  // 背景
                  Container(
                    color: Colors.white.withOpacity(0.1),
                  ),
                  // プログレス
                  FractionallySizedBox(
                    widthFactor: (percent / 100).clamp(0, 1),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            _stageColor(stage).withOpacity(0.8),
                            _stageColor(stage),
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: _stageColor(stage).withOpacity(0.5),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            _stageName(stage),
            style: TextStyle(
              fontSize: 10,
              color: Colors.white.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }

  Color _stageColor(EvolutionStage stage) {
    switch (stage) {
      case EvolutionStage.barren: return const Color(0xFF8B7355);
      case EvolutionStage.sprout: return const Color(0xFF90EE90);
      case EvolutionStage.forest: return const Color(0xFF228B22);
      case EvolutionStage.civilization: return const Color(0xFFDEB887);
      case EvolutionStage.golden: return MaColors.lionGold;
    }
  }

  String _stageEmoji(EvolutionStage stage) {
    switch (stage) {
      case EvolutionStage.barren: return '🏜️';
      case EvolutionStage.sprout: return '🌱';
      case EvolutionStage.forest: return '🌳';
      case EvolutionStage.civilization: return '🏛️';
      case EvolutionStage.golden: return '✨';
    }
  }

  String _stageName(EvolutionStage stage) {
    switch (stage) {
      case EvolutionStage.barren: return '荒野 — 世界はまだ眠っている';
      case EvolutionStage.sprout: return '芽吹き — いのちが目覚めはじめた';
      case EvolutionStage.forest: return '森林 — 緑が世界を包む';
      case EvolutionStage.civilization: return '文明 — 知恵が形になった';
      case EvolutionStage.golden: return '黄金時代 — 世界は輝いている';
    }
  }
}
