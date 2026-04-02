import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../models/memory_entry.dart';
import '../../services/memory_database.dart';
import '../../painters/manga_painter.dart';

/// コミックアルバム — 日記を4コマ漫画/見開きレイアウトで閲覧
class ComicAlbumScreen extends StatefulWidget {
  const ComicAlbumScreen({super.key});

  @override
  State<ComicAlbumScreen> createState() => _ComicAlbumScreenState();
}

class _ComicAlbumScreenState extends State<ComicAlbumScreen> {
  List<MemoryEntry> _memories = [];
  bool _loading = true;
  _ViewMode _viewMode = _ViewMode.fourPanel;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final db = await MemoryDatabase.database;
    final maps = await db.query('memories', orderBy: 'date ASC');
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
                      child: const Icon(Icons.arrow_back_rounded, color: Color(0xFF1A1A1A)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'マンガ・アルバム',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Color(0xFF1A1A1A)),
                    ),
                  ),
                  // ビューモード切替
                  GestureDetector(
                    onTap: () => setState(() {
                      _viewMode = _viewMode == _ViewMode.fourPanel
                          ? _ViewMode.spread : _ViewMode.fourPanel;
                    }),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        _viewMode == _ViewMode.fourPanel
                            ? Icons.view_module_rounded
                            : Icons.menu_book_rounded,
                        size: 20,
                        color: const Color(0xFF1A1A1A),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // コンテンツ
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _memories.isEmpty
                      ? const Center(
                          child: Text(
                            'まだ思い出がありません\nきおくを記録しよう',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Color(0xFF999999)),
                          ),
                        )
                      : _viewMode == _ViewMode.fourPanel
                          ? _buildFourPanelView()
                          : _buildSpreadView(),
            ),
          ],
        ),
      ),
    );
  }

  /// 4コマ漫画ビュー
  Widget _buildFourPanelView() {
    // 4つずつグループ化
    final pages = <List<MemoryEntry>>[];
    for (var i = 0; i < _memories.length; i += 4) {
      pages.add(_memories.sublist(i, math.min(i + 4, _memories.length)));
    }

    return PageView.builder(
      itemCount: pages.length,
      itemBuilder: (context, pageIndex) {
        final group = pages[pageIndex];
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFF1A1A1A), width: 2),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8, offset: const Offset(2, 2))],
            ),
            child: Column(
              children: [
                // タイトル
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: const BoxDecoration(
                    border: Border(bottom: BorderSide(color: Color(0xFF1A1A1A), width: 2)),
                  ),
                  child: Center(
                    child: Text(
                      '第${pageIndex + 1}話',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                  ),
                ),
                // コマ
                ...List.generate(group.length, (i) {
                  return Expanded(
                    child: _ComicPanel(
                      memory: group[i],
                      panelNumber: i + 1,
                      isLast: i == group.length - 1,
                    ),
                  );
                }),
                // ページ番号
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Text(
                    '— ${pageIndex + 1} / ${pages.length} —',
                    style: TextStyle(fontSize: 10, color: const Color(0xFF1A1A1A).withOpacity(0.3)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// 見開きビュー
  Widget _buildSpreadView() {
    final pages = <List<MemoryEntry>>[];
    for (var i = 0; i < _memories.length; i += 2) {
      pages.add(_memories.sublist(i, math.min(i + 2, _memories.length)));
    }

    return PageView.builder(
      itemCount: pages.length,
      itemBuilder: (context, pageIndex) {
        final group = pages[pageIndex];
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: List.generate(group.length, (i) {
              return Expanded(
                child: Container(
                  margin: EdgeInsets.only(left: i > 0 ? 4 : 0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: const Color(0xFF1A1A1A), width: 2),
                  ),
                  child: Column(
                    children: [
                      // ナレーション枠
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          border: Border(bottom: BorderSide(color: Color(0xFFEEEEEE))),
                        ),
                        child: Text(
                          _generateNarration(group[i]),
                          style: TextStyle(
                            fontSize: 11,
                            fontStyle: FontStyle.italic,
                            color: const Color(0xFF1A1A1A).withOpacity(0.5),
                            height: 1.4,
                          ),
                        ),
                      ),
                      // メインコンテンツ
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(group[i].stamp.emoji, style: const TextStyle(fontSize: 40)),
                              const SizedBox(height: 8),
                              // 吹き出し
                              CustomPaint(
                                size: const Size(double.infinity, 60),
                                painter: BalloonPainter(
                                  isSpeech: !group[i].isChallenge,
                                ),
                                child: Center(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                    child: Text(
                                      group[i].text,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(fontSize: 13, color: Color(0xFF1A1A1A)),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // 日付
                      Container(
                        padding: const EdgeInsets.all(6),
                        child: Text(
                          '${group[i].date.month}/${group[i].date.day}',
                          style: TextStyle(fontSize: 10, color: const Color(0xFF1A1A1A).withOpacity(0.3)),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        );
      },
    );
  }

  /// AIナレーション生成（オンデバイス、ルールベース）
  String _generateNarration(MemoryEntry memory) {
    final date = '${memory.date.month}月${memory.date.day}日';
    switch (memory.stamp) {
      case MemoryStamp.ate:
        return '$date — その日、主人公はとっておきのごちそうに出会った。';
      case MemoryStamp.went:
        return '$date — 新しい土地への冒険が始まった。';
      case MemoryStamp.played:
        return '$date — 無邪気な笑い声が世界に響いた。';
      case MemoryStamp.pet:
        return '$date — 小さな命との対話が始まった。';
      case MemoryStamp.challenge:
        return '$date — 勇者は新たな試練に立ち向かった。';
    }
  }
}

enum _ViewMode { fourPanel, spread }

/// 漫画のコマ
class _ComicPanel extends StatelessWidget {
  final MemoryEntry memory;
  final int panelNumber;
  final bool isLast;

  const _ComicPanel({
    required this.memory,
    required this.panelNumber,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: isLast ? null : const Border(bottom: BorderSide(color: Color(0xFF1A1A1A), width: 2)),
      ),
      child: Row(
        children: [
          // スタンプエリア
          SizedBox(
            width: 60,
            child: Center(
              child: Text(memory.stamp.emoji, style: const TextStyle(fontSize: 28)),
            ),
          ),
          Container(width: 2, color: const Color(0xFF1A1A1A)),
          // テキスト + 吹き出し
          Expanded(
            child: Stack(
              children: [
                CustomPaint(
                  size: Size.infinite,
                  painter: MangaPanelPainter(text: memory.text, isNarration: panelNumber == 1),
                ),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (panelNumber == 1)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Text(
                            _narration(),
                            style: TextStyle(
                              fontSize: 10,
                              fontStyle: FontStyle.italic,
                              color: const Color(0xFF1A1A1A).withOpacity(0.4),
                            ),
                          ),
                        ),
                      Text(
                        memory.text,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${memory.date.month}/${memory.date.day}',
                        style: TextStyle(fontSize: 10, color: const Color(0xFF1A1A1A).withOpacity(0.3)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _narration() {
    switch (memory.stamp) {
      case MemoryStamp.ate: return 'その日のごちそう—';
      case MemoryStamp.went: return 'あたらしい冒険—';
      case MemoryStamp.played: return 'たのしい時間—';
      case MemoryStamp.pet: return 'いのちとの出会い—';
      case MemoryStamp.challenge: return '勇者の挑戦—';
    }
  }
}
