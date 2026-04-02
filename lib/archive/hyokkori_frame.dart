import 'package:flutter/material.dart';
import '../theme/ma_colors.dart';
import '../painters/particle_painter.dart';

/// 親からの承認時に発動する「ひょっこりフレーム」演出
class HyokkoriFrame extends StatefulWidget {
  final String parentName;
  final String message;
  final VoidCallback? onDismiss;

  const HyokkoriFrame({
    super.key,
    required this.parentName,
    this.message = 'すごいね！がんばったね！',
    this.onDismiss,
  });

  @override
  State<HyokkoriFrame> createState() => _HyokkoriFrameState();
}

class _HyokkoriFrameState extends State<HyokkoriFrame>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _bounceController;
  late Animation<Offset> _slideAnim;
  late Animation<double> _bounceAnim;
  late Animation<double> _opacityAnim;
  bool _showParticles = false;

  @override
  void initState() {
    super.initState();

    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    // 下からスライドイン
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 1.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.elasticOut,
    ));

    // バウンス（ひょっこり感）
    _bounceAnim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.15), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 1.15, end: 0.95), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 0.95, end: 1.05), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 1.05, end: 1.0), weight: 1),
    ]).animate(CurvedAnimation(
      parent: _bounceController,
      curve: Curves.easeInOut,
    ));

    _opacityAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _slideController, curve: const Interval(0, 0.4)),
    );

    _slideController.forward().then((_) {
      _bounceController.forward();
      setState(() => _showParticles = true);
    });
  }

  @override
  void dispose() {
    _slideController.dispose();
    _bounceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black54,
      child: Stack(
        children: [
          // パーティクル（背景）
          if (_showParticles)
            Positioned.fill(
              child: GoldParticleBurst(trigger: true, particleCount: 30),
            ),

          // フレーム本体
          Center(
            child: AnimatedBuilder(
              animation: Listenable.merge([_slideController, _bounceController]),
              builder: (context, child) {
                return Opacity(
                  opacity: _opacityAnim.value,
                  child: SlideTransition(
                    position: _slideAnim,
                    child: Transform.scale(
                      scale: _bounceAnim.value,
                      child: child,
                    ),
                  ),
                );
              },
              child: GestureDetector(
                onTap: widget.onDismiss,
                child: Container(
                  margin: const EdgeInsets.all(40),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: MaColors.goldGradient,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: MaColors.lionDeepGold,
                      width: 4,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: MaColors.lionGold.withValues(alpha: 0.5),
                        blurRadius: 30,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // 承認アイコン
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.3),
                        ),
                        child: const Icon(
                          Icons.favorite_rounded,
                          size: 48,
                          color: Color(0xFFFF6B6B),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '${widget.parentName}からの\nおすみつき！',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF5C3D10),
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        widget.message,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: const Color(0xFF5C3D10).withValues(alpha: 0.7),
                        ),
                      ),
                      const SizedBox(height: 20),
                      // メダル獲得表示
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.military_tech_rounded, color: Color(0xFFDAA520), size: 28),
                            SizedBox(width: 8),
                            Text(
                              'メダル獲得！',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF5C3D10),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'タップしてとじる',
                        style: TextStyle(
                          fontSize: 12,
                          color: const Color(0xFF5C3D10).withValues(alpha: 0.5),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// ひょっこりフレームをオーバーレイ表示するヘルパー
void showHyokkoriFrame(
  BuildContext context, {
  required String parentName,
  String message = 'すごいね！がんばったね！',
}) {
  final overlay = Overlay.of(context);
  late OverlayEntry entry;
  entry = OverlayEntry(
    builder: (_) => HyokkoriFrame(
      parentName: parentName,
      message: message,
      onDismiss: () => entry.remove(),
    ),
  );
  overlay.insert(entry);
}
