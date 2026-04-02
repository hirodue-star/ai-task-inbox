import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../painters/background_painter.dart';
import '../../painters/gaogao_painter.dart';
import '../../providers/hlc_provider.dart';
import '../../theme/ma_colors.dart';
import '../../widgets/hyokkori_frame.dart';

/// 🐣 ひよこ級：お手伝い記録画面
class HiyokoOtetsudai extends ConsumerStatefulWidget {
  const HiyokoOtetsudai({super.key});

  @override
  ConsumerState<HiyokoOtetsudai> createState() => _HiyokoOtetsudaiState();
}

class _HiyokoOtetsudaiState extends ConsumerState<HiyokoOtetsudai>
    with SingleTickerProviderStateMixin {
  late AnimationController _bgController;
  final List<_OtetsudaiItem> _items = [
    _OtetsudaiItem('おそうじ', Icons.cleaning_services_rounded, MaColors.hiyokoPink),
    _OtetsudaiItem('おりょうり', Icons.restaurant_rounded, MaColors.hiyokoGreen),
    _OtetsudaiItem('おせんたく', Icons.local_laundry_service_rounded, MaColors.hiyokoBlue),
    _OtetsudaiItem('おかいもの', Icons.shopping_bag_rounded, MaColors.hiyokoYellow),
    _OtetsudaiItem('ペットのおせわ', Icons.pets_rounded, MaColors.hiyokoPink),
    _OtetsudaiItem('おにわのおしごと', Icons.grass_rounded, MaColors.hiyokoGreen),
  ];
  int? _selectedIndex;

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
                          color: Colors.white.withValues(alpha: 0.7),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.arrow_back_rounded, color: Color(0xFF5C3D10)),
                      ),
                    ),
                    const Spacer(),
                    const Text(
                      'おてつだい',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF5C3D10),
                      ),
                    ),
                    const Spacer(),
                    const SizedBox(width: 40),
                  ],
                ),
              ),

              // ガオガオ（状態に応じて表情変化）
              GaogaoFace(
                mood: _selectedIndex != null ? GaogaoMood.excited : GaogaoMood.happy,
                size: 100,
              ),
              const SizedBox(height: 8),
              Text(
                _selectedIndex != null ? 'すごい！がんばったね！' : 'なにをおてつだいした？',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF5C3D10),
                ),
              ),

              const SizedBox(height: 24),

              // お手伝いカテゴリグリッド
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 1.3,
                  ),
                  itemCount: _items.length,
                  itemBuilder: (context, index) {
                    final item = _items[index];
                    final selected = _selectedIndex == index;
                    return _OtetsudaiCard(
                      item: item,
                      selected: selected,
                      onTap: () => setState(() => _selectedIndex = index),
                    );
                  },
                ),
              ),

              // 記録ボタン
              if (_selectedIndex != null)
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: _RecordButton(
                    onTap: () {
                      _showCompletionDialog();
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCompletionDialog() {
    // HLCスコア加算（奉仕ポイント）
    ref.read(hlcScoreProvider.notifier).completeHelp(points: 10);

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: MaColors.warmWhite,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: MaColors.hiyokoPink.withValues(alpha: 0.3),
                blurRadius: 20,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const GaogaoFace(mood: GaogaoMood.excited, size: 100),
              const SizedBox(height: 16),
              const Text(
                'おてつだいできたね！',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF5C3D10),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'メダルをゲット！',
                style: TextStyle(fontSize: 14, color: Color(0xFF8B7355)),
              ),
              const SizedBox(height: 24),
              GestureDetector(
                onTap: () {
                  Navigator.pop(ctx);
                  setState(() => _selectedIndex = null);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  decoration: BoxDecoration(
                    gradient: MaColors.goldGradient,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'やったー！',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
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
}

class _OtetsudaiItem {
  final String label;
  final IconData icon;
  final Color color;
  const _OtetsudaiItem(this.label, this.icon, this.color);
}

class _OtetsudaiCard extends StatefulWidget {
  final _OtetsudaiItem item;
  final bool selected;
  final VoidCallback onTap;

  const _OtetsudaiCard({required this.item, required this.selected, required this.onTap});

  @override
  State<_OtetsudaiCard> createState() => _OtetsudaiCardState();
}

class _OtetsudaiCardState extends State<_OtetsudaiCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lighter = Color.lerp(widget.item.color, Colors.white, 0.6)!;

    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap();
      },
      onTapCancel: () => _controller.reverse(),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final scale = 1.0 - _controller.value * 0.05;
          return Transform.scale(scale: scale, child: child);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: const Alignment(-0.3, -0.3),
              radius: 1.2,
              colors: [
                Colors.white,
                lighter,
                widget.selected ? widget.item.color : lighter,
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: widget.selected
                ? Border.all(color: widget.item.color, width: 3)
                : null,
            boxShadow: [
              BoxShadow(
                color: widget.item.color.withValues(alpha: widget.selected ? 0.4 : 0.15),
                blurRadius: widget.selected ? 16 : 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(widget.item.icon, size: 36, color: Color.lerp(widget.item.color, Colors.black, 0.3)),
              const SizedBox(height: 8),
              Text(
                widget.item.label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color.lerp(widget.item.color, Colors.black, 0.4),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RecordButton extends StatefulWidget {
  final VoidCallback onTap;
  const _RecordButton({required this.onTap});

  @override
  State<_RecordButton> createState() => _RecordButtonState();
}

class _RecordButtonState extends State<_RecordButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        final glow = 0.2 + _pulseController.value * 0.3;
        return GestureDetector(
          onTap: widget.onTap,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              gradient: MaColors.goldGradient,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: MaColors.lionGold.withValues(alpha: glow),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: const Center(
              child: Text(
                'きろくする！',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF5C3D10),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
