import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/memory_entry.dart';
import '../../providers/hlc_provider.dart';
import '../../services/memory_database.dart';
import '../../theme/ma_colors.dart';

/// 親ダッシュボード（MVP: 投稿一覧 + HLC簡易表示 + いいね）
class ParentDashboard extends ConsumerStatefulWidget {
  const ParentDashboard({super.key});

  @override
  ConsumerState<ParentDashboard> createState() => _ParentDashboardState();
}

class _ParentDashboardState extends ConsumerState<ParentDashboard> {
  List<MemoryEntry> _memories = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final m = await MemoryDatabase.getAll();
    setState(() => _memories = m);
  }

  @override
  Widget build(BuildContext context) {
    final score = ref.watch(hlcScoreProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F0),
      body: SafeArea(
        child: Column(
          children: [
            // ヘッダー
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.arrow_back_rounded, color: Color(0xFF2C3E50)),
                  ),
                  const SizedBox(width: 12),
                  const Text('成長ダッシュボード',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF2C3E50))),
                ],
              ),
            ),

            // HLCスコア
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _ScoreItem(label: 'H 思いやり', value: score.hospitality, color: MaColors.pastelPink),
                    _ScoreItem(label: 'L 継続力', value: score.logic, color: MaColors.pastelBlue),
                    _ScoreItem(label: 'C 創造性', value: score.creativity, color: MaColors.gold),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                '投稿数: ${score.postCount} ・ いいね: ${score.likeCount}',
                style: TextStyle(fontSize: 12, color: const Color(0xFF2C3E50).withOpacity(0.4)),
              ),
            ),

            const SizedBox(height: 16),

            // 投稿一覧（いいねボタン付き）
            Expanded(
              child: _memories.isEmpty
                  ? Center(child: Text('まだ投稿がありません', style: TextStyle(color: const Color(0xFF2C3E50).withOpacity(0.3))))
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: _memories.length,
                      itemBuilder: (context, i) {
                        return _ParentCard(
                          memory: _memories[i],
                          onLike: () => ref.read(hlcScoreProvider.notifier).onLike(),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScoreItem extends StatelessWidget {
  final String label;
  final int value;
  final Color color;
  const _ScoreItem({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('$value', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: color)),
        Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color.withOpacity(0.7))),
      ],
    );
  }
}

class _ParentCard extends StatelessWidget {
  final MemoryEntry memory;
  final VoidCallback onLike;
  const _ParentCard({required this.memory, required this.onLike});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(memory.stamp.emoji, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(memory.text, style: const TextStyle(fontSize: 14, color: Color(0xFF2C3E50))),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                '${memory.date.month}/${memory.date.day}',
                style: TextStyle(fontSize: 11, color: const Color(0xFF2C3E50).withOpacity(0.3)),
              ),
              const Spacer(),
              GestureDetector(
                onTap: onLike,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: MaColors.pastelPink.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.favorite_rounded, size: 16, color: Color(0xFFFF6B6B)),
                      SizedBox(width: 4),
                      Text('いいね', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFFFF6B6B))),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
