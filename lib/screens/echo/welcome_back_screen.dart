import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/echo_event.dart';
import '../../providers/world_provider.dart';
import '../../theme/ma_colors.dart';

/// 今日の冒険報告モード — おかえりインタラクション
class WelcomeBackScreen extends ConsumerStatefulWidget {
  final VoidCallback onComplete;
  const WelcomeBackScreen({super.key, required this.onComplete});

  @override
  ConsumerState<WelcomeBackScreen> createState() => _WelcomeBackScreenState();
}

class _WelcomeBackScreenState extends ConsumerState<WelcomeBackScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  EmotionTag? _selectedEmotion;
  final _textController = TextEditingController();
  int _step = 0; // 0: 感情選択, 1: テキスト入力, 2: 完了

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 8))..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: _selectedEmotion != null
                    ? _selectedEmotion!.effectColors
                    : [const Color(0xFFFFF8F0), const Color(0xFFFFE8D0)],
              ),
            ),
            child: child,
          );
        },
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              children: [
                // スキップ
                Align(
                  alignment: Alignment.topRight,
                  child: GestureDetector(
                    onTap: widget.onComplete,
                    child: Text('スキップ', style: TextStyle(fontSize: 12, color: const Color(0xFF5C3D10).withOpacity(0.3))),
                  ),
                ),
                const Spacer(),

                if (_step == 0) ...[
                  const Text('おかえり！', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Color(0xFF5C3D10))),
                  const SizedBox(height: 8),
                  Text('きょうはどんなきもち？', style: TextStyle(fontSize: 16, color: const Color(0xFF5C3D10).withOpacity(0.6))),
                  const SizedBox(height: 32),
                  Wrap(
                    spacing: 12, runSpacing: 12,
                    alignment: WrapAlignment.center,
                    children: EmotionTag.values.map((e) {
                      final selected = _selectedEmotion == e;
                      return GestureDetector(
                        onTap: () {
                          setState(() { _selectedEmotion = e; _step = 1; });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: selected ? Colors.white.withOpacity(0.8) : Colors.white.withOpacity(0.4),
                            borderRadius: BorderRadius.circular(20),
                            border: selected ? Border.all(color: const Color(0xFF5C3D10), width: 2) : null,
                          ),
                          child: Column(
                            children: [
                              Text(e.emoji, style: const TextStyle(fontSize: 32)),
                              Text(e.label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFF5C3D10).withOpacity(0.7))),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ] else if (_step == 1) ...[
                  Text(_selectedEmotion!.emoji, style: const TextStyle(fontSize: 56)),
                  const SizedBox(height: 16),
                  const Text('きょうのぼうけんをおしえて', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Color(0xFF5C3D10))),
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: TextField(
                      controller: _textController,
                      maxLines: 4,
                      style: const TextStyle(color: Color(0xFF5C3D10)),
                      decoration: InputDecoration(
                        hintText: 'えんであったこと、あそんだこと...',
                        hintStyle: TextStyle(color: const Color(0xFF5C3D10).withOpacity(0.3)),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.all(16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: () {
                      ref.read(worldStateProvider.notifier).performAction(restorePoints: 2.0);
                      setState(() => _step = 2);
                      Future.delayed(const Duration(seconds: 2), widget.onComplete);
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        gradient: MaColors.goldGradient,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Center(
                        child: Text('ほうこくする！', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF5C3D10))),
                      ),
                    ),
                  ),
                ] else ...[
                  const Text('🎉', style: TextStyle(fontSize: 64)),
                  const SizedBox(height: 16),
                  const Text('すごいね！\nきょうもがんばったね！',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Color(0xFF5C3D10), height: 1.4)),
                ],

                const Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
