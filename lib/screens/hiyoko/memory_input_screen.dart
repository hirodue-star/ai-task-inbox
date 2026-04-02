import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../models/memory_entry.dart';
import '../../painters/background_painter.dart';
import '../../providers/world_provider.dart';
import '../../providers/hlc_provider.dart';
import '../../services/memory_database.dart';
import '../../services/ai_illust_service.dart';
import '../../models/bond_post.dart';
import '../../providers/bond_provider.dart';
import '../../theme/ma_colors.dart';
import '../../widgets/ai_interview_dialog.dart';

/// 🐣 メモリー・インプット画面
/// 食べた/行った/遊んだ/ペット/挑戦 のスタンプ + テキスト + カメラ
class MemoryInputScreen extends ConsumerStatefulWidget {
  const MemoryInputScreen({super.key});

  @override
  ConsumerState<MemoryInputScreen> createState() => _MemoryInputScreenState();
}

class _MemoryInputScreenState extends ConsumerState<MemoryInputScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _bgController;
  final _textController = TextEditingController();
  MemoryStamp? _selectedStamp;
  bool _saving = false;
  String? _savedPhotoPath; // カメラ撮影後のパス

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
    _textController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_selectedStamp == null || _textController.text.trim().isEmpty) return;
    setState(() => _saving = true);

    final stamp = _selectedStamp!;
    final text = _textController.text.trim();
    final isChallenge = stamp == MemoryStamp.challenge;

    // AIイラスト生成（プレースホルダー）
    final aiUrl = await AiIllustService.generateIllust(
      photoPath: _savedPhotoPath,
      description: text,
      stamp: stamp.name,
    );

    final entry = MemoryEntry(
      id: const Uuid().v4(),
      date: DateTime.now(),
      stamp: stamp,
      text: text,
      photoPath: _savedPhotoPath,
      aiIllustUrl: aiUrl,
      isChallenge: isChallenge,
    );

    await MemoryDatabase.insert(entry);

    // BOND-LOGに投稿（日記 = シェア）
    final mission = ref.read(dailyMissionProvider);
    final bondPost = BondPost.fromMemory(
      entry,
      authorId: 'child_1',
      authorName: 'ガオガオ',
      missionTag: stamp == mission.relatedStamp ? mission.tag : null,
    );
    ref.read(bondFeedProvider.notifier).publish(bondPost);

    // 世界復元率UP
    ref.read(worldStateProvider.notifier).performAction(
      restorePoints: stamp.restorePoints,
    );

    // HLCスコア
    if (isChallenge) {
      ref.read(hlcScoreProvider.notifier).createSomething(points: 10);
    } else {
      ref.read(hlcScoreProvider.notifier).completeHelp(points: 5);
    }

    setState(() => _saving = false);

    if (!mounted) return;

    // AIインタビュー（言語化トレーニング）
    final interviewAnswers = await showDialog<List<String>>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AiInterviewDialog(
        stamp: stamp,
        originalText: text,
        onComplete: (answers) => Navigator.pop(context, answers),
      ),
    );

    // インタビュー回答でLスコア加算
    if (interviewAnswers != null) {
      final answered = interviewAnswers.where((a) => a.isNotEmpty).length;
      if (answered > 0) {
        ref.read(hlcScoreProvider.notifier).recordThought(points: answered * 3);
      }
    }

    if (!mounted) return;
    _showSavedDialog(entry, aiUrl);
  }

  void _showSavedDialog(MemoryEntry entry, String aiUrl) {
    final theme = AiIllustService.themeFromUrl(aiUrl);

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: MaColors.warmWhite,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: entry.isChallenge
                    ? MaColors.lionGold.withOpacity(0.4)
                    : MaColors.hiyokoPink.withOpacity(0.3),
                blurRadius: 20,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // AIイラストテーマ表示（将来は実画像）
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: _themeGradient(theme),
                ),
                child: Center(
                  child: Text(entry.stamp.emoji, style: const TextStyle(fontSize: 36)),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                entry.isChallenge ? 'ちょうせんの記憶が刻まれた！' : 'おもいでが生まれた！',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF5C3D10),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '「${entry.text}」',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: const Color(0xFF5C3D10).withOpacity(0.6),
                  fontStyle: FontStyle.italic,
                ),
              ),
              if (entry.isChallenge) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    gradient: MaColors.goldGradient,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    '⚔️ 黄金の粒子が世界に追加された',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF5C3D10)),
                  ),
                ),
              ],
              const SizedBox(height: 8),
              Text(
                '+${entry.stamp.restorePoints.toStringAsFixed(1)}% World Restore',
                style: TextStyle(fontSize: 12, color: const Color(0xFF5C3D10).withOpacity(0.4)),
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () {
                  Navigator.pop(ctx);
                  Navigator.pop(context);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF5C3D10).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Text(
                    'もどる',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF5C3D10),
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

  LinearGradient _themeGradient(FantasyTheme theme) {
    switch (theme) {
      case FantasyTheme.enchantedForest:
        return const LinearGradient(colors: [Color(0xFF228B22), Color(0xFF90EE90)]);
      case FantasyTheme.crystalCave:
        return const LinearGradient(colors: [Color(0xFF6BB5E8), Color(0xFFD0EAFF)]);
      case FantasyTheme.skyKingdom:
        return const LinearGradient(colors: [Color(0xFF87CEEB), Color(0xFFFFF8DC)]);
      case FantasyTheme.oceanDepths:
        return const LinearGradient(colors: [Color(0xFF001030), Color(0xFF4A9DD8)]);
      case FantasyTheme.starryDesert:
        return const LinearGradient(colors: [Color(0xFF2C1810), Color(0xFFFFD700)]);
    }
  }

  Future<void> _takePhoto() async {
    // TODO: image_picker パッケージ連携
    // final picker = ImagePicker();
    // final photo = await picker.pickImage(source: ImageSource.camera);
    // if (photo != null) setState(() => _savedPhotoPath = photo.path);

    // プレースホルダー: スナックバーで通知
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('カメラ機能はimage_pickerパッケージ追加後に有効化されます'),
        backgroundColor: MaColors.hiyokoPink.withOpacity(0.8),
        duration: const Duration(seconds: 2),
      ),
    );
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
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.arrow_back_rounded, color: Color(0xFF5C3D10)),
                      ),
                    ),
                    const Spacer(),
                    const Text(
                      'きおくのきろく',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF5C3D10),
                      ),
                    ),
                    const Spacer(),
                    // カメラボタン
                    GestureDetector(
                      onTap: _takePhoto,
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              MaColors.hiyokoPink.withOpacity(0.3),
                              MaColors.hiyokoBlue.withOpacity(0.3),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Colors.white.withOpacity(0.5)),
                        ),
                        child: const Icon(Icons.camera_alt_rounded, color: Color(0xFF5C3D10), size: 24),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                // スタンプ選択
                const Text(
                  'なにをした？',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF5C3D10),
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: MemoryStamp.values.map((stamp) {
                    final selected = _selectedStamp == stamp;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedStamp = stamp),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: selected
                              ? (stamp == MemoryStamp.challenge
                                  ? MaColors.lionGold.withOpacity(0.3)
                                  : MaColors.hiyokoPink.withOpacity(0.3))
                              : Colors.white.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: selected
                                ? (stamp == MemoryStamp.challenge
                                    ? MaColors.lionGold
                                    : MaColors.hiyokoPink)
                                : Colors.white.withOpacity(0.3),
                            width: selected ? 2 : 1,
                          ),
                          boxShadow: selected
                              ? [BoxShadow(
                                  color: (stamp == MemoryStamp.challenge
                                      ? MaColors.lionGold
                                      : MaColors.hiyokoPink).withOpacity(0.2),
                                  blurRadius: 8,
                                )]
                              : null,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(stamp.emoji, style: const TextStyle(fontSize: 20)),
                            const SizedBox(width: 6),
                            Text(
                              stamp.label,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                                color: const Color(0xFF5C3D10),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 24),

                // テキスト入力
                const Text(
                  'おもいでをかこう',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF5C3D10),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withOpacity(0.5)),
                  ),
                  child: TextField(
                    controller: _textController,
                    maxLines: 4,
                    style: const TextStyle(color: Color(0xFF5C3D10), fontSize: 15),
                    decoration: InputDecoration(
                      hintText: _selectedStamp != null
                          ? _hintForStamp(_selectedStamp!)
                          : 'まずスタンプをえらんでね',
                      hintStyle: TextStyle(color: const Color(0xFF5C3D10).withOpacity(0.3)),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.all(16),
                    ),
                  ),
                ),

                // 写真プレビュー
                if (_savedPhotoPath != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.photo_rounded, color: Color(0xFF5C3D10), size: 20),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text('しゃしんがついた！', style: TextStyle(color: Color(0xFF5C3D10), fontSize: 13)),
                        ),
                        GestureDetector(
                          onTap: () => setState(() => _savedPhotoPath = null),
                          child: const Icon(Icons.close_rounded, color: Color(0xFF5C3D10), size: 18),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 32),

                // 保存ボタン
                GestureDetector(
                  onTap: _saving ? null : _save,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      gradient: _selectedStamp == MemoryStamp.challenge
                          ? MaColors.goldGradient
                          : LinearGradient(
                              colors: [MaColors.hiyokoPink, MaColors.hiyokoBlue],
                            ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: (_selectedStamp == MemoryStamp.challenge
                              ? MaColors.lionGold
                              : MaColors.hiyokoPink).withOpacity(0.3),
                          blurRadius: 12,
                        ),
                      ],
                    ),
                    child: Center(
                      child: _saving
                          ? const SizedBox(
                              width: 20, height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : Text(
                              _selectedStamp == MemoryStamp.challenge
                                  ? '⚔️ ちょうせんをきろくする'
                                  : 'おもいでをのこす',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _hintForStamp(MemoryStamp stamp) {
    switch (stamp) {
      case MemoryStamp.ate: return 'なにをたべた？おいしかった？';
      case MemoryStamp.went: return 'どこにいった？なにをみた？';
      case MemoryStamp.played: return 'なにであそんだ？だれと？';
      case MemoryStamp.pet: return 'どうぶつとなにをした？';
      case MemoryStamp.challenge: return 'あたらしいちょうせん！なにに挑んだ？';
    }
  }
}
