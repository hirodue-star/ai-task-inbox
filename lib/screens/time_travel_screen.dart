import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/memory_entry.dart';
import '../services/memory_database.dart';
import '../services/ai_illust_service.dart';
import '../theme/ma_colors.dart';

/// 思い出の回想（Time Travel Transition）
/// 前日のリアル写真とAI生成イラストがフェードで交互に現れる
class TimeTravelScreen extends StatefulWidget {
  final VoidCallback onComplete;

  const TimeTravelScreen({super.key, required this.onComplete});

  @override
  State<TimeTravelScreen> createState() => _TimeTravelScreenState();
}

class _TimeTravelScreenState extends State<TimeTravelScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _bgController;
  List<MemoryEntry> _memories = [];
  int _currentIndex = 0;
  bool _showingAi = false;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    )..repeat();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _loadMemories();
  }

  Future<void> _loadMemories() async {
    final memories = await MemoryDatabase.getYesterday();
    if (memories.isEmpty) {
      // 昨日の記憶がない → スキップ
      widget.onComplete();
      return;
    }
    setState(() {
      _memories = memories;
      _loaded = true;
    });
    _startSlideshow();
  }

  void _startSlideshow() {
    _fadeController.forward().then((_) {
      Future.delayed(const Duration(seconds: 3), () {
        if (!mounted) return;
        _fadeController.reverse().then((_) {
          if (!mounted) return;
          setState(() {
            if (_showingAi) {
              _showingAi = false;
              _currentIndex++;
              if (_currentIndex >= _memories.length) {
                widget.onComplete();
                return;
              }
            } else {
              _showingAi = true;
            }
          });
          _startSlideshow();
        });
      });
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _bgController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded || _memories.isEmpty) {
      return const SizedBox.shrink();
    }

    final memory = _memories[_currentIndex.clamp(0, _memories.length - 1)];
    final theme = memory.aiIllustUrl != null
        ? AiIllustService.themeFromUrl(memory.aiIllustUrl!)
        : FantasyTheme.enchantedForest;

    return Scaffold(
      body: AnimatedBuilder(
        animation: Listenable.merge([_fadeController, _bgController]),
        builder: (context, _) {
          return Stack(
            fit: StackFit.expand,
            children: [
              // 背景（ファンタジーテーマ）
              CustomPaint(
                painter: _TimeTravelBgPainter(
                  theme: theme,
                  animValue: _bgController.value,
                  isChallenge: memory.isChallenge,
                ),
              ),

              // コンテンツ
              SafeArea(
                child: Center(
                  child: FadeTransition(
                    opacity: _fadeController,
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // ヘッダー
                          Text(
                            _showingAi ? 'AIが描いた世界' : 'きのうのおもいで',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withOpacity(0.6),
                              letterSpacing: 2,
                            ),
                          ),
                          const SizedBox(height: 24),

                          // メモリーカード
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(_showingAi ? 0.1 : 0.15),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: memory.isChallenge
                                    ? MaColors.lionGold.withOpacity(0.4)
                                    : Colors.white.withOpacity(0.2),
                                width: memory.isChallenge ? 2 : 1,
                              ),
                            ),
                            child: Column(
                              children: [
                                // スタンプ
                                Text(
                                  memory.stamp.emoji,
                                  style: const TextStyle(fontSize: 48),
                                ),
                                const SizedBox(height: 12),

                                // テキスト
                                Text(
                                  '「${memory.text}」',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white.withOpacity(0.9),
                                    height: 1.5,
                                  ),
                                ),
                                const SizedBox(height: 8),

                                if (memory.isChallenge)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                    decoration: BoxDecoration(
                                      gradient: MaColors.goldGradient,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Text(
                                      '⚔️ CHALLENGE',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w800,
                                        color: Color(0xFF5C3D10),
                                        letterSpacing: 1,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 24),

                          // プログレスドット
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(_memories.length, (i) {
                              return Container(
                                margin: const EdgeInsets.symmetric(horizontal: 3),
                                width: i == _currentIndex ? 20 : 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: i == _currentIndex
                                      ? Colors.white.withOpacity(0.8)
                                      : Colors.white.withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(3),
                                ),
                              );
                            }),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // スキップボタン
              Positioned(
                top: MediaQuery.of(context).padding.top + 16,
                right: 16,
                child: GestureDetector(
                  onTap: widget.onComplete,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'スキップ',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.5),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// タイムトラベル背景
class _TimeTravelBgPainter extends CustomPainter {
  final FantasyTheme theme;
  final double animValue;
  final bool isChallenge;

  _TimeTravelBgPainter({
    required this.theme,
    required this.animValue,
    this.isChallenge = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    late List<Color> gradColors;
    switch (theme) {
      case FantasyTheme.enchantedForest:
        gradColors = [const Color(0xFF0A2A0A), const Color(0xFF1A4A1A), const Color(0xFF0A2A0A)];
        break;
      case FantasyTheme.crystalCave:
        gradColors = [const Color(0xFF0A1A3A), const Color(0xFF1A3A5A), const Color(0xFF0A1A3A)];
        break;
      case FantasyTheme.skyKingdom:
        gradColors = [const Color(0xFF1A1A40), const Color(0xFF3A3A60), const Color(0xFF1A1A40)];
        break;
      case FantasyTheme.oceanDepths:
        gradColors = [const Color(0xFF001020), const Color(0xFF002040), const Color(0xFF001020)];
        break;
      case FantasyTheme.starryDesert:
        gradColors = [const Color(0xFF1A0A00), const Color(0xFF3A1A0A), const Color(0xFF1A0A00)];
        break;
    }

    final bgPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: gradColors,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    // 浮遊パーティクル
    final rng = math.Random(42);
    for (var i = 0; i < 30; i++) {
      final x = rng.nextDouble() * size.width;
      final baseY = rng.nextDouble() * size.height;
      final y = (baseY - animValue * size.height * 0.2) % size.height;
      final r = 1 + rng.nextDouble() * 2;
      final twinkle = (math.sin(animValue * math.pi * 2 + i) + 1) / 2;
      final color = isChallenge ? MaColors.lionGold : Colors.white;
      final paint = Paint()..color = color.withOpacity(0.1 + twinkle * 0.3);
      canvas.drawCircle(Offset(x, y), r, paint);
    }

    // 挑戦の記憶は黄金粒子を永続追加
    if (isChallenge) {
      for (var i = 0; i < 10; i++) {
        final x = rng.nextDouble() * size.width;
        final y = rng.nextDouble() * size.height;
        final r = 2 + rng.nextDouble() * 3;
        final pulse = (math.sin(animValue * math.pi * 2 * 2 + i * 0.7) + 1) / 2;
        final paint = Paint()..color = MaColors.lionGold.withOpacity(0.2 + pulse * 0.4);
        canvas.drawCircle(Offset(x, y), r, paint);
        final glow = Paint()
          ..shader = RadialGradient(
            colors: [
              MaColors.lionGold.withOpacity(0.06 * pulse),
              MaColors.lionGold.withOpacity(0),
            ],
          ).createShader(Rect.fromCircle(center: Offset(x, y), radius: r * 5));
        canvas.drawCircle(Offset(x, y), r * 5, glow);
      }
    }
  }

  @override
  bool shouldRepaint(_TimeTravelBgPainter old) =>
      animValue != old.animValue || theme != old.theme;
}
