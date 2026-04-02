import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/bond_post.dart';
import '../../models/memory_entry.dart';
import '../../models/world_state.dart';
import '../../painters/world_bg_painter.dart';
import '../../painters/particle_painter.dart';
import '../../providers/bond_provider.dart';
import '../../providers/world_provider.dart';
import '../../theme/ma_colors.dart';
import '../hiyoko/memory_input_screen.dart';

/// BOND-LOG タイムライン画面
class BondFeedScreen extends ConsumerStatefulWidget {
  const BondFeedScreen({super.key});

  @override
  ConsumerState<BondFeedScreen> createState() => _BondFeedScreenState();
}

class _BondFeedScreenState extends ConsumerState<BondFeedScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _bgController;
  String? _likeParticlePostId;

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
    final feed = ref.watch(bondFeedProvider);
    final world = ref.watch(worldStateProvider);
    final mission = ref.watch(dailyMissionProvider);

    return Scaffold(
      body: AnimatedBuilder(
        animation: _bgController,
        builder: (context, child) {
          return CustomPaint(
            painter: WorldBgPainter(
              phase: world.phase,
              evolution: world.evolutionStage,
              animValue: _bgController.value,
            ),
            child: child,
          );
        },
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
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(Icons.arrow_back_rounded, color: _textColor(world.phase)),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'BOND-LOG',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: _textColor(world.phase),
                        letterSpacing: 3,
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => Navigator.push(context,
                          MaterialPageRoute(builder: (_) => const MemoryInputScreen())),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          gradient: MaColors.goldGradient,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.edit_rounded, color: Color(0xFF5C3D10), size: 20),
                      ),
                    ),
                  ],
                ),
              ),

              // デイリーミッション
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      MaColors.lionGold.withOpacity(0.15),
                      MaColors.lionGold.withOpacity(0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: MaColors.lionGold.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Text('⭐', style: TextStyle(fontSize: 24)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'きょうのミッション',
                            style: TextStyle(
                              fontSize: 11,
                              color: MaColors.lionGold.withOpacity(0.7),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            mission.description,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: _textColor(world.phase),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: MaColors.lionGold.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        mission.tag,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: MaColors.lionGold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              // フィード
              Expanded(
                child: feed.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.auto_stories_rounded, size: 48,
                                color: _textColor(world.phase).withOpacity(0.3)),
                            const SizedBox(height: 8),
                            Text(
                              'まだ投稿がありません\nきおくを記録してシェアしよう',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                color: _textColor(world.phase).withOpacity(0.4),
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        itemCount: feed.length,
                        itemBuilder: (context, index) {
                          return _PostCard(
                            post: feed[index],
                            phase: world.phase,
                            showParticle: _likeParticlePostId == feed[index].id,
                            onLike: () {
                              ref.read(bondFeedProvider.notifier).like(feed[index].id, 'parent_1');
                              setState(() => _likeParticlePostId = feed[index].id);
                              Future.delayed(const Duration(seconds: 2), () {
                                if (mounted) setState(() => _likeParticlePostId = null);
                              });
                            },
                            onApprove: () {
                              ref.read(bondFeedProvider.notifier).approve(feed[index].id);
                            },
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _textColor(TimeOfDayPhase p) {
    switch (p) {
      case TimeOfDayPhase.morning: return const Color(0xFF5C3D10);
      case TimeOfDayPhase.daytime: return const Color(0xFF2C3E50);
      case TimeOfDayPhase.evening: return const Color(0xFFFFE0C0);
      case TimeOfDayPhase.night: return const Color(0xFFE0E8FF);
    }
  }
}

/// 投稿カード
class _PostCard extends StatelessWidget {
  final BondPost post;
  final dynamic phase;
  final bool showParticle;
  final VoidCallback onLike;
  final VoidCallback onApprove;

  const _PostCard({
    required this.post,
    required this.phase,
    required this.showParticle,
    required this.onLike,
    required this.onApprove,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: post.isChallenge
                  ? MaColors.lionGold.withOpacity(0.4)
                  : Colors.white.withOpacity(0.15),
              width: post.isChallenge ? 2 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ヘッダー（著者 + 時刻）
              Row(
                children: [
                  Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: post.authorRole == AuthorRole.child
                          ? MaColors.hiyokoYellow.withOpacity(0.3)
                          : MaColors.penguinIce.withOpacity(0.3),
                    ),
                    child: Center(
                      child: Text(
                        post.authorRole == AuthorRole.child ? '🐣' : '👨‍👩‍👧',
                        style: const TextStyle(fontSize: 18),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          post.authorName,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                        Text(
                          _timeAgo(post.createdAt),
                          style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.4)),
                        ),
                      ],
                    ),
                  ),
                  Text(post.stamp.emoji, style: const TextStyle(fontSize: 24)),
                ],
              ),

              const SizedBox(height: 12),

              // テキスト
              Text(
                post.text,
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.white.withOpacity(0.85),
                  height: 1.5,
                ),
              ),

              // ミッションタグ
              if (post.missionTag != null) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: MaColors.lionGold.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    post.missionTag!,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: MaColors.lionGold,
                    ),
                  ),
                ),
              ],

              // 挑戦バッジ
              if (post.isChallenge) ...[
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    gradient: MaColors.goldGradient,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    '⚔️ CHALLENGE',
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFF5C3D10)),
                  ),
                ),
              ],

              const SizedBox(height: 12),

              // アクションバー
              Row(
                children: [
                  // いいね
                  GestureDetector(
                    onTap: onLike,
                    child: Row(
                      children: [
                        Icon(
                          post.likeCount > 0 ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                          size: 20,
                          color: post.likeCount > 0 ? const Color(0xFFFF6B6B) : Colors.white.withOpacity(0.4),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          post.likeCount > 0 ? '${post.likeCount}' : '',
                          style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.5)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 20),

                  // 承認ステータス
                  if (post.isMission)
                    GestureDetector(
                      onTap: post.parentApproved ? null : onApprove,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: post.parentApproved
                              ? MaColors.lionGold.withOpacity(0.2)
                              : Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: post.parentApproved
                                ? MaColors.lionGold.withOpacity(0.5)
                                : Colors.white.withOpacity(0.2),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              post.parentApproved ? Icons.check_circle_rounded : Icons.pending_rounded,
                              size: 14,
                              color: post.parentApproved ? MaColors.lionGold : Colors.white.withOpacity(0.4),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              post.parentApproved ? 'しょうにん済み → ガチャ解放！' : 'しょうにんまち',
                              style: TextStyle(
                                fontSize: 11,
                                color: post.parentApproved
                                    ? MaColors.lionGold
                                    : Colors.white.withOpacity(0.4),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),

        // いいねパーティクル演出
        if (showParticle)
          Positioned.fill(
            child: IgnorePointer(
              child: GoldParticleBurst(trigger: true, particleCount: 20),
            ),
          ),
      ],
    );
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'たった今';
    if (diff.inMinutes < 60) return '${diff.inMinutes}分まえ';
    if (diff.inHours < 24) return '${diff.inHours}時間まえ';
    return '${diff.inDays}日まえ';
  }
}
