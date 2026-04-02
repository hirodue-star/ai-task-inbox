import 'package:flutter/material.dart';
import '../../painters/background_painter.dart';
import '../../painters/mandala_grid_painter.dart';
import '../../widgets/gacha_capsule.dart';
import '../../theme/ma_colors.dart';
import 'lion_gacha.dart';

/// 🦁 ライオン級ホーム — 黄金マンダラ + ガチャ入口
class LionHome extends StatefulWidget {
  const LionHome({super.key});

  @override
  State<LionHome> createState() => _LionHomeState();
}

class _LionHomeState extends State<LionHome>
    with SingleTickerProviderStateMixin {
  late AnimationController _bgController;
  int? _selectedCell;

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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenW = MediaQuery.of(context).size.width;

    return Scaffold(
      body: AnimatedBuilder(
        animation: _bgController,
        builder: (context, child) {
          return CustomPaint(
            painter: LionBgPainter(animValue: _bgController.value),
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
                          color: MaColors.lionGold.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.arrow_back_rounded,
                          color: MaColors.lionGold.withValues(alpha: 0.9),
                        ),
                      ),
                    ),
                    const Spacer(),
                    ShaderMask(
                      shaderCallback: (bounds) => MaColors.goldGradient.createShader(bounds),
                      child: const Text(
                        'ライオン級',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: 3,
                        ),
                      ),
                    ),
                    const Spacer(),
                    const SizedBox(width: 40),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // マンダラグリッド
              Container(
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: MaColors.lionGold.withValues(alpha: 0.2),
                      blurRadius: 30,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: MandalaGrid(
                  size: screenW - 64,
                  selectedCell: _selectedCell,
                  onCellTap: (cell) {
                    setState(() => _selectedCell = cell);
                  },
                ),
              ),

              const SizedBox(height: 12),

              // セル情報
              if (_selectedCell != null)
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 32),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: MaColors.lionGold.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: MaColors.lionGold.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    _cellLabels[_selectedCell!],
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: MaColors.lionGold.withValues(alpha: 0.9),
                    ),
                  ),
                ),

              const Spacer(),

              // ガチャセクション
              const Text(
                'びっくらポン',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFFFD700),
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 8),
              GachaCapsule(
                size: 90,
                onTap: () {
                  Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const LionGacha()));
                },
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
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
}
