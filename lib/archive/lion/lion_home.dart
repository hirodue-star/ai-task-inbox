import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/world_state.dart';
import '../../models/incubation.dart';
import '../../painters/world_bg_painter.dart';
import '../../painters/mandala_grid_painter.dart';
import '../../painters/particle_painter.dart';
import '../../providers/world_provider.dart';
import '../../widgets/gacha_capsule.dart';
import '../../theme/ma_colors.dart';
import 'lion_gacha.dart';

/// 🦁 ライオン級ホーム — 遺跡としてのマンダラ + ガチャ入口
class LionHome extends ConsumerStatefulWidget {
  const LionHome({super.key});

  @override
  ConsumerState<LionHome> createState() => _LionHomeState();
}

class _LionHomeState extends ConsumerState<LionHome>
    with SingleTickerProviderStateMixin {
  late AnimationController _bgController;
  int? _selectedCell;
  bool _bigBang = false;
  final Map<int, Incubation> _incubations = {};

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

  void _onCellTap(int cell) {
    final world = ref.read(worldStateProvider);
    if (cell >= world.mandalaSlotsUnlocked) {
      // 未解放スロット
      _showLockedMessage(cell);
      return;
    }
    if (world.mandalaCompleted[cell]) {
      setState(() => _selectedCell = cell);
      return;
    }
    // 孵化中のセル → 進行状況を表示
    if (_incubations.containsKey(cell)) {
      final inc = _incubations[cell]!;
      if (inc.isReady) {
        // 孵化完了 → セル解放
        setState(() => _incubations.remove(cell));
        ref.read(worldStateProvider.notifier).completeMandalaCell(cell);
        final world = ref.read(worldStateProvider);
        if (world.isMandalaComplete) _triggerBigBang();
        return;
      }
      setState(() => _selectedCell = cell);
      _showIncubationStatus(inc);
      return;
    }
    // 未完了セル → 思考の種を植えて孵化開始
    setState(() => _selectedCell = cell);
    _showThoughtInput(cell);
  }

  void _showLockedMessage(int cell) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF0A0A30).withOpacity(0.95),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: MaColors.lionGold.withOpacity(0.3)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.lock_rounded, size: 40, color: MaColors.lionGold.withOpacity(0.5)),
              const SizedBox(height: 12),
              Text(
                '遺跡の封印',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: MaColors.lionGold),
              ),
              const SizedBox(height: 8),
              Text(
                '親からの承認（雫）を得ることで\nこのスロットが解放される。',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: MaColors.lionGold.withOpacity(0.6), height: 1.5),
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () => Navigator.pop(ctx),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  decoration: BoxDecoration(
                    border: Border.all(color: MaColors.lionGold.withOpacity(0.3)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text('閉じる', style: TextStyle(color: MaColors.lionGold.withOpacity(0.7))),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showThoughtInput(int cell) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF0A0A30).withOpacity(0.95),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: MaColors.lionGold.withOpacity(0.4)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _cellLabels[cell],
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: MaColors.lionGold),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                maxLines: 3,
                style: TextStyle(color: MaColors.lionGold.withOpacity(0.9)),
                decoration: InputDecoration(
                  hintText: _cellQuestions[cell],
                  hintStyle: TextStyle(color: MaColors.lionGold.withOpacity(0.3)),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: MaColors.lionGold.withOpacity(0.2)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: MaColors.lionGold.withOpacity(0.5)),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () {
                  if (controller.text.trim().isEmpty) return;
                  Navigator.pop(ctx);
                  // 孵化開始（即座に完了しない → ツァイガルニク効果）
                  setState(() {
                    _incubations[cell] = Incubation(
                      cellIndex: cell,
                      startedAt: DateTime.now(),
                      requiredTime: incubationTimeForCell(cell),
                      seedThought: controller.text.trim(),
                    );
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 10),
                  decoration: BoxDecoration(
                    gradient: MaColors.goldGradient,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Text(
                    '刻む',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF5C3D10)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showIncubationStatus(Incubation inc) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF0A0A30).withOpacity(0.95),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: MaColors.lionGold.withOpacity(0.3)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 孵化プログレス
              SizedBox(
                width: 80,
                height: 80,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircularProgressIndicator(
                      value: inc.progress,
                      strokeWidth: 4,
                      color: MaColors.lionGold,
                      backgroundColor: MaColors.lionGold.withOpacity(0.1),
                    ),
                    Text(
                      '${(inc.progress * 100).toInt()}%',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: MaColors.lionGold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              if (inc.seedThought != null)
                Text(
                  '「${inc.seedThought}」',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: MaColors.lionGold.withOpacity(0.7),
                    fontStyle: FontStyle.italic,
                  ),
                ),
              const SizedBox(height: 8),
              Text(
                inc.statusMessage,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: MaColors.lionGold.withOpacity(0.5),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () => Navigator.pop(ctx),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  decoration: BoxDecoration(
                    border: Border.all(color: MaColors.lionGold.withOpacity(0.3)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    inc.isReady ? '開く' : 'まつ',
                    style: TextStyle(color: MaColors.lionGold.withOpacity(0.7)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _triggerBigBang() {
    setState(() => _bigBang = true);
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) setState(() => _bigBang = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final world = ref.watch(worldStateProvider);
    final screenW = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Stack(
        children: [
          // 世界背景
          AnimatedBuilder(
            animation: _bgController,
            builder: (context, child) {
              return CustomPaint(
                painter: WorldBgPainter(
                  phase: world.phase,
                  evolution: world.evolutionStage,
                  animValue: _bgController.value,
                  abyssIntensity: world.abyssIntensity,
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
                              color: MaColors.lionGold.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(Icons.arrow_back_rounded, color: MaColors.lionGold.withOpacity(0.9)),
                          ),
                        ),
                        const Spacer(),
                        Column(
                          children: [
                            ShaderMask(
                              shaderCallback: (bounds) => MaColors.goldGradient.createShader(bounds),
                              child: const Text(
                                'ライオン級',
                                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: 3),
                              ),
                            ),
                            Text(
                              '${world.mandalaSlotsUnlocked}/9 スロット解放',
                              style: TextStyle(fontSize: 11, color: MaColors.lionGold.withOpacity(0.5)),
                            ),
                          ],
                        ),
                        const Spacer(),
                        const SizedBox(width: 40),
                      ],
                    ),
                  ),

                  const SizedBox(height: 8),

                  // マンダラグリッド（遺跡）
                  Container(
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: MaColors.lionGold.withOpacity(
                            world.phase == TimeOfDayPhase.night ? 0.35 : 0.15,
                          ),
                          blurRadius: world.phase == TimeOfDayPhase.night ? 40 : 20,
                          spreadRadius: world.phase == TimeOfDayPhase.night ? 8 : 3,
                        ),
                      ],
                    ),
                    child: MandalaGrid(
                      size: screenW - 64,
                      selectedCell: _selectedCell,
                      onCellTap: _onCellTap,
                    ),
                  ),

                  const SizedBox(height: 12),

                  if (_selectedCell != null)
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 32),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      decoration: BoxDecoration(
                        color: MaColors.lionGold.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: MaColors.lionGold.withOpacity(0.3)),
                      ),
                      child: Text(
                        _cellLabels[_selectedCell!],
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: MaColors.lionGold.withOpacity(0.9)),
                      ),
                    ),

                  const Spacer(),

                  // ガチャ
                  const Text(
                    'びっくらポン',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFFFFD700), letterSpacing: 2),
                  ),
                  const SizedBox(height: 8),
                  GachaCapsule(
                    size: 80,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LionGacha())),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),

          // Big Bang（マンダラ完成時）
          if (_bigBang)
            const Positioned.fill(
              child: GoldParticleBurst(trigger: true, particleCount: 100),
            ),
        ],
      ),
    );
  }

  static const _cellLabels = [
    '自慢 — じぶんのとくい',
    '分析 — よく考える',
    '創造 — あたらしいアイデア',
    '発見 — みつけたこと',
    '核心 — いちばんたいせつ',
    '方向 — めざすところ',
    '知恵 — しっていること',
    '表現 — つたえるちから',
    'マスター — かんぺき！',
  ];

  static const _cellQuestions = [
    'じぶんのとくいなことを書いてね',
    'なぜそうなると思う？',
    'あたらしいアイデアを書いてね',
    'さいきんみつけたことは？',
    'いちばんたいせつなことは？',
    'これからどうしたい？',
    'しっていることを教えて',
    'どうやってつたえる？',
    'かんぺきにするには？',
  ];
}
