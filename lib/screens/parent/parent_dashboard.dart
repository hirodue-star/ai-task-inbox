import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/memory_entry.dart';
import '../../providers/hlc_provider.dart';
import '../../services/memory_database.dart';
import '../../theme/ma_colors.dart';

/// 親ダッシュボード — マンダラ9マス + エピソードポップアップ
class ParentDashboard extends ConsumerStatefulWidget {
  const ParentDashboard({super.key});

  @override
  ConsumerState<ParentDashboard> createState() => _ParentDashboardState();
}

class _ParentDashboardState extends ConsumerState<ParentDashboard> {
  List<MemoryEntry> _all = [];
  Map<int, List<MemoryEntry>> _byCell = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final all = await MemoryDatabase.getAll();
    final byCell = <int, List<MemoryEntry>>{};
    for (final m in all) {
      byCell.putIfAbsent(m.mandalaCell, () => []).add(m);
    }
    setState(() { _all = all; _byCell = byCell; });
  }

  @override
  Widget build(BuildContext context) {
    final score = ref.watch(hlcScoreProvider);
    final screenW = MediaQuery.of(context).size.width;
    final gridSize = screenW - 48;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F0),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ヘッダー
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.arrow_back_rounded, color: Color(0xFF2C3E50)),
                  ),
                  const SizedBox(width: 12),
                  const Text('成長マンダラ',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF2C3E50))),
                  const Spacer(),
                  Text('${_all.length}件の記録',
                    style: TextStyle(fontSize: 12, color: const Color(0xFF2C3E50).withOpacity(0.4))),
                ],
              ),

              const SizedBox(height: 20),

              // マンダラ 3x3 グリッド
              Container(
                width: gridSize, height: gridSize,
                decoration: BoxDecoration(
                  color: const Color(0xFF0B0B2B),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: MaColors.gold.withOpacity(0.5), width: 2),
                  boxShadow: [BoxShadow(color: MaColors.gold.withOpacity(0.15), blurRadius: 20)],
                ),
                child: GridView.count(
                  crossAxisCount: 3,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(4),
                  mainAxisSpacing: 3, crossAxisSpacing: 3,
                  children: [
                    // 9マス: 1-8が周囲、0(中央)が集約
                    _MandalaCell(cell: 1, stamp: MemoryStamp.kindness, entries: _byCell[1] ?? [], onTap: () => _showEntries(1)),
                    _MandalaCell(cell: 2, stamp: MemoryStamp.logic, entries: _byCell[2] ?? [], onTap: () => _showEntries(2)),
                    _MandalaCell(cell: 3, stamp: MemoryStamp.creation, entries: _byCell[3] ?? [], onTap: () => _showEntries(3)),
                    _MandalaCell(cell: 4, stamp: MemoryStamp.discovery, entries: _byCell[4] ?? [], onTap: () => _showEntries(4)),
                    // 中央: 総合
                    _MandalaCenterCell(total: _all.length, likeCount: score.likeCount),
                    _MandalaCell(cell: 5, stamp: MemoryStamp.challenge, entries: _byCell[5] ?? [], onTap: () => _showEntries(5)),
                    _MandalaCell(cell: 6, stamp: MemoryStamp.expression, entries: _byCell[6] ?? [], onTap: () => _showEntries(6)),
                    _MandalaCell(cell: 7, stamp: MemoryStamp.helping, entries: _byCell[7] ?? [], onTap: () => _showEntries(7)),
                    _MandalaCell(cell: 8, stamp: MemoryStamp.nature, entries: _byCell[8] ?? [], onTap: () => _showEntries(8)),
                  ],
                ),
              ),

              const SizedBox(height: 16),
              Text('マスをタップするとエピソードが見れます',
                style: TextStyle(fontSize: 12, color: const Color(0xFF2C3E50).withOpacity(0.3))),

              const SizedBox(height: 24),

              // HLCバー
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _ScoreItem('H 思いやり', score.hospitality, MaColors.pastelPink),
                    _ScoreItem('L 継続力', score.logic, MaColors.pastelBlue),
                    _ScoreItem('C 創造性', score.creativity, MaColors.gold),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // 最新の投稿（いいねボタン付き）
              const Text('最新のきろく',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF2C3E50))),
              const SizedBox(height: 8),
              ..._all.take(5).map((m) => _PostCard(
                memory: m,
                onLike: () => ref.read(hlcScoreProvider.notifier).onLike(),
              )),
            ],
          ),
        ),
      ),
    );
  }

  void _showEntries(int cell) {
    final entries = _byCell[cell] ?? [];
    final stamp = MemoryStamp.values.firstWhere((s) => s.mandalaCell == cell);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        minChildSize: 0.3,
        expand: false,
        builder: (ctx, scrollController) => Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(width: 40, height: 4, decoration: BoxDecoration(
                  color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Text(stamp.emoji, style: const TextStyle(fontSize: 28)),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(stamp.mandalaLabel,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF2C3E50))),
                      Text('${entries.length}件のエピソード',
                        style: TextStyle(fontSize: 12, color: const Color(0xFF2C3E50).withOpacity(0.4))),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: entries.isEmpty
                    ? Center(child: Text('まだ記録がありません',
                        style: TextStyle(color: const Color(0xFF2C3E50).withOpacity(0.3))))
                    : ListView.builder(
                        controller: scrollController,
                        itemCount: entries.length,
                        itemBuilder: (ctx, i) => Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8F5F0),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(entries[i].text,
                                style: const TextStyle(fontSize: 14, color: Color(0xFF2C3E50), height: 1.4)),
                              const SizedBox(height: 4),
                              Text('${entries[i].date.month}/${entries[i].date.day}',
                                style: TextStyle(fontSize: 11, color: const Color(0xFF2C3E50).withOpacity(0.3))),
                            ],
                          ),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// マンダラの1マス
class _MandalaCell extends StatelessWidget {
  final int cell;
  final MemoryStamp stamp;
  final List<MemoryEntry> entries;
  final VoidCallback onTap;

  const _MandalaCell({required this.cell, required this.stamp, required this.entries, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final hasEntries = entries.isNotEmpty;
    final brightness = (entries.length / 5).clamp(0.1, 1.0);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: hasEntries
              ? MaColors.gold.withOpacity(0.05 + brightness * 0.2)
              : Colors.white.withOpacity(0.03),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: hasEntries ? MaColors.gold.withOpacity(0.3 + brightness * 0.4) : Colors.white.withOpacity(0.08),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(stamp.emoji, style: const TextStyle(fontSize: 22)),
            const SizedBox(height: 2),
            Text(stamp.label,
              style: TextStyle(fontSize: 9, color: Colors.white.withOpacity(hasEntries ? 0.8 : 0.3))),
            if (hasEntries)
              Text('${entries.length}',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: MaColors.gold.withOpacity(0.8))),
          ],
        ),
      ),
    );
  }
}

/// マンダラ中央セル
class _MandalaCenterCell extends StatelessWidget {
  final int total;
  final int likeCount;
  const _MandalaCenterCell({required this.total, required this.likeCount});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [MaColors.gold.withOpacity(0.15), MaColors.gold.withOpacity(0.05)],
        ),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: MaColors.gold.withOpacity(0.5)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('$total', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: MaColors.gold)),
          Text('きろく', style: TextStyle(fontSize: 9, color: MaColors.gold.withOpacity(0.6))),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.favorite_rounded, size: 10, color: MaColors.pastelPink.withOpacity(0.7)),
              const SizedBox(width: 2),
              Text('$likeCount', style: TextStyle(fontSize: 10, color: MaColors.pastelPink.withOpacity(0.7))),
            ],
          ),
        ],
      ),
    );
  }
}

class _ScoreItem extends StatelessWidget {
  final String label;
  final int value;
  final Color color;
  const _ScoreItem(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('$value', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: color)),
        Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color.withOpacity(0.7))),
      ],
    );
  }
}

class _PostCard extends StatelessWidget {
  final MemoryEntry memory;
  final VoidCallback onLike;
  const _PostCard({required this.memory, required this.onLike});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
      child: Row(
        children: [
          Text(memory.stamp.emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 10),
          Expanded(child: Text(memory.text,
            maxLines: 2, overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 14, color: Color(0xFF2C3E50)))),
          GestureDetector(
            onTap: onLike,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: MaColors.pastelPink.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.favorite_rounded, size: 18, color: Color(0xFFFF6B6B)),
            ),
          ),
        ],
      ),
    );
  }
}
