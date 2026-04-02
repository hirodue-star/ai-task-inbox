import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/memory_entry.dart';
import '../providers/hlc_provider.dart';
import '../services/memory_database.dart';
import '../theme/ma_colors.dart';
import 'hiyoko/memory_input_screen.dart';
import 'parent/parent_dashboard.dart';

/// ホーム画面（MVP）: 日記タイムライン + 投稿ボタン
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  List<MemoryEntry> _memories = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final memories = await MemoryDatabase.getAll();
    setState(() => _memories = memories);
  }

  @override
  Widget build(BuildContext context) {
    final score = ref.watch(hlcScoreProvider);

    return Scaffold(
      backgroundColor: MaColors.warmWhite,
      body: SafeArea(
        child: Column(
          children: [
            // ヘッダー
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                children: [
                  const Text('MA-LOGIC',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Color(0xFF5C3D10), letterSpacing: 3)),
                  const Spacer(),
                  // 親ダッシュボード
                  GestureDetector(
                    onTap: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const ParentDashboard())),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        gradient: MaColors.goldGradient,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.bar_chart_rounded, size: 16, color: Color(0xFF5C3D10)),
                          const SizedBox(width: 4),
                          Text('${score.postCount}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF5C3D10))),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // タイムライン
            Expanded(
              child: _memories.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 40),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 80, height: 80,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: MaColors.gold.withOpacity(0.1),
                              ),
                              child: const Center(child: Text('🐣', style: TextStyle(fontSize: 36))),
                            ),
                            const SizedBox(height: 16),
                            const Text('はじめての思い出を\nきろくしよう！',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF5C3D10))),
                            const SizedBox(height: 8),
                            Text('下の「きろく」ボタンをタップして\nきょうあったことを書いてね',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 13, color: const Color(0xFF5C3D10).withOpacity(0.4), height: 1.5)),
                            const SizedBox(height: 24),
                            // 矢印で誘導
                            Icon(Icons.arrow_downward_rounded, size: 28, color: MaColors.gold.withOpacity(0.5)),
                          ],
                        ),
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _load,
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: _memories.length,
                        itemBuilder: (context, i) => _DiaryCard(memory: _memories[i]),
                      ),
                    ),
            ),
          ],
        ),
      ),

      // 投稿ボタン（FAB）
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(context,
            MaterialPageRoute(builder: (_) => const MemoryInputScreen()));
          _load();
        },
        backgroundColor: MaColors.gold,
        foregroundColor: const Color(0xFF5C3D10),
        icon: const Icon(Icons.edit_rounded),
        label: const Text('きろく', style: TextStyle(fontWeight: FontWeight.w700)),
      ),
    );
  }
}

/// 日記カード
class _DiaryCard extends StatelessWidget {
  final MemoryEntry memory;
  const _DiaryCard({required this.memory});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: memory.isChallenge
            ? Border.all(color: MaColors.gold.withOpacity(0.4), width: 1.5)
            : null,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 写真（漫画変換済みの場合は線画）
          if (memory.photoPath != null && File(memory.photoPath!).existsSync())
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(
                File(memory.photoPath!),
                width: double.infinity, height: 160, fit: BoxFit.cover,
              ),
            ),
          if (memory.photoPath != null) const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(memory.stamp.emoji, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(memory.text, style: const TextStyle(fontSize: 15, color: Color(0xFF2C3E50), height: 1.4)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          '${memory.date.month}/${memory.date.day} ${memory.date.hour}:${memory.date.minute.toString().padLeft(2, '0')}',
                          style: TextStyle(fontSize: 11, color: const Color(0xFF2C3E50).withOpacity(0.3)),
                        ),
                        if (memory.isChallenge) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                            decoration: BoxDecoration(gradient: MaColors.goldGradient, borderRadius: BorderRadius.circular(6)),
                            child: const Text('⚔️', style: TextStyle(fontSize: 10)),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
