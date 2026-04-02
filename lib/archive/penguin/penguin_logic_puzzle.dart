import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../painters/ice_painter.dart';
import '../../providers/hlc_provider.dart';
import '../../theme/ma_colors.dart';

/// 🐧 ペンギン級：ろんりパズル画面
/// パターン認識・順序・分類の論理タスク
class PenguinLogicPuzzle extends ConsumerStatefulWidget {
  const PenguinLogicPuzzle({super.key});

  @override
  ConsumerState<PenguinLogicPuzzle> createState() => _PenguinLogicPuzzleState();
}

class _PenguinLogicPuzzleState extends ConsumerState<PenguinLogicPuzzle>
    with SingleTickerProviderStateMixin {
  late AnimationController _bgController;
  int _currentPuzzle = 0;
  int _score = 0;
  bool _showResult = false;
  bool _isCorrect = false;

  final _puzzles = const [
    _PatternPuzzle(
      question: 'つぎにくるのはどれ？',
      sequence: ['🔴', '🔵', '🔴', '🔵', '🔴', '?'],
      choices: ['🔵', '🔴', '🟢', '🟡'],
      answer: 0,
    ),
    _PatternPuzzle(
      question: 'なかまはずれはどれ？',
      sequence: ['🍎', '🍊', '🍋', '🚗'],
      choices: ['🍎', '🍊', '🍋', '🚗'],
      answer: 3,
    ),
    _PatternPuzzle(
      question: 'おおきいじゅんにならべると？',
      sequence: ['いぬ', 'ぞう', 'ねこ'],
      choices: ['ぞう→いぬ→ねこ', 'ねこ→いぬ→ぞう', 'いぬ→ねこ→ぞう', 'ぞう→ねこ→いぬ'],
      answer: 0,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();
  }

  @override
  void dispose() {
    _bgController.dispose();
    super.dispose();
  }

  void _selectAnswer(int index) {
    if (_showResult) return;
    final puzzle = _puzzles[_currentPuzzle];
    final correct = index == puzzle.answer;

    setState(() {
      _showResult = true;
      _isCorrect = correct;
      if (correct) _score++;
    });

    if (correct) {
      ref.read(hlcScoreProvider.notifier).recordThought(points: 5);
    }

    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      if (_currentPuzzle < _puzzles.length - 1) {
        setState(() {
          _currentPuzzle++;
          _showResult = false;
        });
      } else {
        _showFinalResult();
      }
    });
  }

  void _showFinalResult() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withValues(alpha: 0.95),
                MaColors.penguinIce.withValues(alpha: 0.8),
              ],
            ),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: MaColors.penguinIce, width: 2),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _score == _puzzles.length ? Icons.stars_rounded : Icons.star_half_rounded,
                size: 64,
                color: MaColors.penguinDeep,
              ),
              const SizedBox(height: 16),
              Text(
                '$_score / ${_puzzles.length} せいかい！',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: MaColors.penguinDeep,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _score == _puzzles.length ? 'かんぺき！すごい！' : 'がんばったね！',
                style: TextStyle(fontSize: 16, color: MaColors.penguinDeep.withValues(alpha: 0.7)),
              ),
              const SizedBox(height: 24),
              GestureDetector(
                onTap: () {
                  Navigator.pop(ctx);
                  Navigator.pop(context);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  decoration: BoxDecoration(
                    color: MaColors.penguinDeep,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'もどる',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
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

  @override
  Widget build(BuildContext context) {
    final puzzle = _puzzles[_currentPuzzle];

    return Scaffold(
      body: AnimatedBuilder(
        animation: _bgController,
        builder: (context, child) {
          return CustomPaint(
            painter: PenguinBgPainter(animValue: _bgController.value),
            child: child,
          );
        },
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // ヘッダー
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(Icons.arrow_back_rounded, color: MaColors.penguinDeep),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'もんだい ${_currentPuzzle + 1} / ${_puzzles.length}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: MaColors.penguinDeep,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'スコア: $_score',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: MaColors.penguinDeep,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                // 問題文
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: MaColors.penguinIce),
                  ),
                  child: Column(
                    children: [
                      Text(
                        puzzle.question,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: MaColors.penguinDeep,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 12,
                        children: puzzle.sequence.map((s) {
                          return Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: s == '?'
                                  ? MaColors.penguinIce.withValues(alpha: 0.3)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: s == '?' ? MaColors.penguinDeep : MaColors.penguinIce,
                                width: s == '?' ? 2 : 1,
                              ),
                            ),
                            child: Text(
                              s,
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: s == '?' ? FontWeight.w800 : FontWeight.normal,
                                color: MaColors.penguinDeep,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // 選択肢
                Expanded(
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 2.5,
                    ),
                    itemCount: puzzle.choices.length,
                    itemBuilder: (context, index) {
                      Color bgColor;
                      if (_showResult) {
                        if (index == puzzle.answer) {
                          bgColor = const Color(0xFF4CAF50).withValues(alpha: 0.3);
                        } else if (_isCorrect) {
                          bgColor = Colors.white.withValues(alpha: 0.5);
                        } else {
                          bgColor = Colors.white.withValues(alpha: 0.5);
                        }
                      } else {
                        bgColor = Colors.white.withValues(alpha: 0.7);
                      }

                      return GestureDetector(
                        onTap: () => _selectAnswer(index),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          decoration: BoxDecoration(
                            color: bgColor,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: _showResult && index == puzzle.answer
                                  ? const Color(0xFF4CAF50)
                                  : MaColors.penguinIce,
                              width: _showResult && index == puzzle.answer ? 3 : 1,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              puzzle.choices[index],
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: MaColors.penguinDeep,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // 結果表示
                if (_showResult)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: _isCorrect
                          ? const Color(0xFF4CAF50).withValues(alpha: 0.2)
                          : const Color(0xFFFF5252).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      _isCorrect ? 'せいかい！ +5 ろんりポイント' : 'ざんねん…つぎはがんばろう！',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: _isCorrect ? const Color(0xFF2E7D32) : const Color(0xFFC62828),
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
}

class _PatternPuzzle {
  final String question;
  final List<String> sequence;
  final List<String> choices;
  final int answer;

  const _PatternPuzzle({
    required this.question,
    required this.sequence,
    required this.choices,
    required this.answer,
  });
}
