import 'package:flutter/material.dart';
import '../../models/memory_entry.dart';
import '../../models/echo_event.dart';
import '../../services/memory_database.dart';
import '../../theme/ma_colors.dart';

/// Daily Reflection Theater — 今日の連載スライドショー
class DailyTheaterScreen extends StatefulWidget {
  const DailyTheaterScreen({super.key});

  @override
  State<DailyTheaterScreen> createState() => _DailyTheaterScreenState();
}

class _DailyTheaterScreenState extends State<DailyTheaterScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  List<MemoryEntry> _todayMemories = [];
  int _currentSlide = 0;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _load();
  }

  Future<void> _load() async {
    final memories = await MemoryDatabase.getToday();
    setState(() { _todayMemories = memories; _loaded = true; });
    if (memories.isNotEmpty) _fadeController.forward();
  }

  void _next() {
    if (_currentSlide >= _todayMemories.length - 1) {
      Navigator.pop(context);
      return;
    }
    _fadeController.reverse().then((_) {
      setState(() => _currentSlide++);
      _fadeController.forward();
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded || _todayMemories.isEmpty) {
      return Scaffold(
        backgroundColor: const Color(0xFF0A0A30),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('🌙', style: const TextStyle(fontSize: 48)),
              const SizedBox(height: 12),
              Text('きょうのおはなしはまだないよ', style: TextStyle(color: Colors.white.withOpacity(0.5))),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Text('もどる', style: TextStyle(color: Colors.white.withOpacity(0.3))),
              ),
            ],
          ),
        ),
      );
    }

    final memory = _todayMemories[_currentSlide];
    final emotion = _guessEmotion(memory);

    return Scaffold(
      body: GestureDetector(
        onTap: _next,
        child: AnimatedBuilder(
          animation: _fadeController,
          builder: (context, _) {
            return Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color.lerp(const Color(0xFF0A0A30), emotion.effectColors[0], 0.3)!,
                    const Color(0xFF050515),
                  ],
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: FadeTransition(
                    opacity: _fadeController,
                    child: Column(
                      children: [
                        // ヘッダー
                        Row(
                          children: [
                            Text(
                              '第${_currentSlide + 1}話',
                              style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.4), letterSpacing: 2),
                            ),
                            const Spacer(),
                            GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: Icon(Icons.close_rounded, color: Colors.white.withOpacity(0.3)),
                            ),
                          ],
                        ),
                        const Spacer(),

                        // 感情エフェクト
                        Text(emotion.emoji, style: const TextStyle(fontSize: 56)),
                        const SizedBox(height: 8),
                        Text(emotion.label, style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.4))),
                        const SizedBox(height: 24),

                        // コマ風カード
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.white.withOpacity(0.1)),
                          ),
                          child: Column(
                            children: [
                              Text(memory.stamp.emoji, style: const TextStyle(fontSize: 36)),
                              const SizedBox(height: 12),
                              Text(
                                memory.text,
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 18, color: Colors.white.withOpacity(0.85), height: 1.6),
                              ),
                              if (memory.isChallenge) ...[
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    gradient: MaColors.goldGradient,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Text('⚔️ CHALLENGE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFF5C3D10))),
                                ),
                              ],
                            ],
                          ),
                        ),

                        // ナレーション
                        const SizedBox(height: 16),
                        Text(
                          _narration(memory),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            fontStyle: FontStyle.italic,
                            color: Colors.white.withOpacity(0.3),
                            height: 1.5,
                          ),
                        ),

                        const Spacer(),

                        // プログレス
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(_todayMemories.length, (i) {
                            return Container(
                              margin: const EdgeInsets.symmetric(horizontal: 3),
                              width: _currentSlide == i ? 20 : 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(_currentSlide == i ? 0.7 : 0.2),
                                borderRadius: BorderRadius.circular(3),
                              ),
                            );
                          }),
                        ),
                        const SizedBox(height: 8),
                        Text('タップしてつぎへ', style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.2))),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  EmotionTag _guessEmotion(MemoryEntry m) {
    if (m.isChallenge) return EmotionTag.brave;
    switch (m.stamp) {
      case MemoryStamp.ate: return EmotionTag.happy;
      case MemoryStamp.went: return EmotionTag.curious;
      case MemoryStamp.played: return EmotionTag.happy;
      case MemoryStamp.pet: return EmotionTag.kind;
      case MemoryStamp.challenge: return EmotionTag.brave;
    }
  }

  String _narration(MemoryEntry m) {
    switch (m.stamp) {
      case MemoryStamp.ate: return 'おいしいものは、しあわせのはじまり。';
      case MemoryStamp.went: return 'あたらしい場所には、あたらしい発見がある。';
      case MemoryStamp.played: return 'あそびは、いちばんの学び。';
      case MemoryStamp.pet: return 'ちいさないのちが、おおきなやさしさを育てる。';
      case MemoryStamp.challenge: return 'ちょうせんしたその瞬間、きみはもう成長している。';
    }
  }
}
