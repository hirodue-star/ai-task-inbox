import 'package:flutter/material.dart';
import '../models/memory_entry.dart';
import '../services/memory_database.dart';
import '../services/ai_illust_service.dart';
import '../theme/ma_colors.dart';

/// 感性のアーカイブ — コレクションブック
/// AI生成イラストのテーマで思い出を振り返る
class CollectionBookScreen extends StatefulWidget {
  const CollectionBookScreen({super.key});

  @override
  State<CollectionBookScreen> createState() => _CollectionBookScreenState();
}

class _CollectionBookScreenState extends State<CollectionBookScreen> {
  List<MemoryEntry> _memories = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final all = await MemoryDatabase.getToday(); // TODO: 全期間に拡張
    // 全期間取得のため直接クエリ
    final db = await MemoryDatabase.database;
    final maps = await db.query('memories', orderBy: 'date DESC');
    setState(() {
      _memories = maps.map((m) => MemoryEntry.fromJson(m)).toList();
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F5F0),
      body: SafeArea(
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
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.arrow_back_rounded, color: Color(0xFF5C3D10)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'かんせいのアーカイブ',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF5C3D10),
                      ),
                    ),
                  ),
                  Text(
                    '${_memories.length}の思い出',
                    style: TextStyle(
                      fontSize: 12,
                      color: const Color(0xFF5C3D10).withOpacity(0.4),
                    ),
                  ),
                ],
              ),
            ),

            // コレクション
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _memories.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.auto_stories_rounded, size: 48,
                                  color: const Color(0xFF5C3D10).withOpacity(0.2)),
                              const SizedBox(height: 8),
                              Text(
                                'まだ思い出がありません\nきおくを記録しよう',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: const Color(0xFF5C3D10).withOpacity(0.3),
                                ),
                              ),
                            ],
                          ),
                        )
                      : GridView.builder(
                          padding: const EdgeInsets.all(16),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 12,
                            crossAxisSpacing: 12,
                            childAspectRatio: 0.8,
                          ),
                          itemCount: _memories.length,
                          itemBuilder: (context, index) {
                            return _MemoryCard(memory: _memories[index]);
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MemoryCard extends StatelessWidget {
  final MemoryEntry memory;
  const _MemoryCard({required this.memory});

  @override
  Widget build(BuildContext context) {
    final theme = memory.aiIllustUrl != null
        ? AiIllustService.themeFromUrl(memory.aiIllustUrl!)
        : FantasyTheme.enchantedForest;

    return GestureDetector(
      onTap: () => _showDetail(context),
      child: Container(
        decoration: BoxDecoration(
          gradient: _themeGradient(theme),
          borderRadius: BorderRadius.circular(20),
          border: memory.isChallenge
              ? Border.all(color: MaColors.lionGold, width: 2)
              : null,
          boxShadow: [
            BoxShadow(
              color: _themeColor(theme).withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            // テーマアイコン
            Positioned(
              top: 12, right: 12,
              child: Text(_themeEmoji(theme), style: const TextStyle(fontSize: 20)),
            ),
            // コンテンツ
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(memory.stamp.emoji, style: const TextStyle(fontSize: 32)),
                  const SizedBox(height: 8),
                  Expanded(
                    child: Text(
                      memory.text,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white.withOpacity(0.9),
                        height: 1.4,
                      ),
                    ),
                  ),
                  // 日付
                  Text(
                    '${memory.date.month}/${memory.date.day}',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.white.withOpacity(0.5),
                    ),
                  ),
                  if (memory.isChallenge)
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: MaColors.lionGold.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        '⚔️',
                        style: TextStyle(fontSize: 10),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDetail(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFFF8F5F0),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(memory.stamp.emoji, style: const TextStyle(fontSize: 48)),
              const SizedBox(height: 12),
              Text(
                '「${memory.text}」',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF5C3D10),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${memory.date.year}/${memory.date.month}/${memory.date.day}',
                style: TextStyle(fontSize: 12, color: const Color(0xFF5C3D10).withOpacity(0.4)),
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () => Navigator.pop(ctx),
                child: const Text('とじる', style: TextStyle(color: Color(0xFF5C3D10))),
              ),
            ],
          ),
        ),
      ),
    );
  }

  LinearGradient _themeGradient(FantasyTheme theme) {
    switch (theme) {
      case FantasyTheme.enchantedForest:
        return const LinearGradient(
          begin: Alignment.topLeft, end: Alignment.bottomRight,
          colors: [Color(0xFF1A4A1A), Color(0xFF2E7D32)]);
      case FantasyTheme.crystalCave:
        return const LinearGradient(
          begin: Alignment.topLeft, end: Alignment.bottomRight,
          colors: [Color(0xFF1A3A5A), Color(0xFF4A9DD8)]);
      case FantasyTheme.skyKingdom:
        return const LinearGradient(
          begin: Alignment.topLeft, end: Alignment.bottomRight,
          colors: [Color(0xFF3A3A60), Color(0xFF87CEEB)]);
      case FantasyTheme.oceanDepths:
        return const LinearGradient(
          begin: Alignment.topLeft, end: Alignment.bottomRight,
          colors: [Color(0xFF001030), Color(0xFF1A5A8A)]);
      case FantasyTheme.starryDesert:
        return const LinearGradient(
          begin: Alignment.topLeft, end: Alignment.bottomRight,
          colors: [Color(0xFF3A1A0A), Color(0xFFDAA520)]);
    }
  }

  Color _themeColor(FantasyTheme theme) {
    switch (theme) {
      case FantasyTheme.enchantedForest: return const Color(0xFF228B22);
      case FantasyTheme.crystalCave: return const Color(0xFF4A9DD8);
      case FantasyTheme.skyKingdom: return const Color(0xFF87CEEB);
      case FantasyTheme.oceanDepths: return const Color(0xFF1A5A8A);
      case FantasyTheme.starryDesert: return const Color(0xFFDAA520);
    }
  }

  String _themeEmoji(FantasyTheme theme) {
    switch (theme) {
      case FantasyTheme.enchantedForest: return '🌿';
      case FantasyTheme.crystalCave: return '💎';
      case FantasyTheme.skyKingdom: return '☁️';
      case FantasyTheme.oceanDepths: return '🌊';
      case FantasyTheme.starryDesert: return '🌟';
    }
  }
}
