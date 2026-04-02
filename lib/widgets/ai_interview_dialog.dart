import 'package:flutter/material.dart';
import '../models/memory_entry.dart';
import '../theme/ma_colors.dart';

/// AIインタビューダイアログ — 面接言語化トレーニング
/// 日記投稿後に問いかけ、子供の思考を深掘りする
class AiInterviewDialog extends StatefulWidget {
  final MemoryStamp stamp;
  final String originalText;
  final void Function(List<String> answers) onComplete;

  const AiInterviewDialog({
    super.key,
    required this.stamp,
    required this.originalText,
    required this.onComplete,
  });

  @override
  State<AiInterviewDialog> createState() => _AiInterviewDialogState();
}

class _AiInterviewDialogState extends State<AiInterviewDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  int _currentQ = 0;
  final _answers = <String>[];
  final _textController = TextEditingController();
  late List<String> _questions;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..forward();
    _questions = _generateQuestions(widget.stamp, widget.originalText);
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _textController.dispose();
    super.dispose();
  }

  List<String> _generateQuestions(MemoryStamp stamp, String text) {
    // スタンプ固有の深掘り質問 + 汎用質問
    final specific = <String>[];
    switch (stamp) {
      case MemoryStamp.ate:
        specific.addAll([
          'なぜこれをたべようとおもったの？',
          'いちばんおいしかったところはどこ？',
        ]);
        break;
      case MemoryStamp.went:
        specific.addAll([
          'そこでいちばんこころにのこったことは？',
          'もういちどいくなら、なにをしたい？',
        ]);
        break;
      case MemoryStamp.played:
        specific.addAll([
          'いちばんくふうしたところはどこ？',
          'つぎはどんなあそびかたをしてみたい？',
        ]);
        break;
      case MemoryStamp.pet:
        specific.addAll([
          'どうぶつはどんなきもちだったとおもう？',
          'もっとなかよくなるには、なにができる？',
        ]);
        break;
      case MemoryStamp.challenge:
        specific.addAll([
          'なぜこのちょうせんをえらんだの？',
          'むずかしかったところはどこ？どうやってのりこえた？',
          'このちょうせんからまなんだことは？',
        ]);
        break;
    }
    return specific;
  }

  void _next() {
    final answer = _textController.text.trim();
    if (answer.isEmpty) return;
    _answers.add(answer);
    _textController.clear();

    if (_currentQ >= _questions.length - 1) {
      widget.onComplete(_answers);
      return;
    }

    _fadeController.reverse().then((_) {
      setState(() => _currentQ++);
      _fadeController.forward();
    });
  }

  void _skip() {
    _answers.add('');
    if (_currentQ >= _questions.length - 1) {
      widget.onComplete(_answers);
      return;
    }
    setState(() => _currentQ++);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: FadeTransition(
        opacity: _fadeController,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: MaColors.warmWhite,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: MaColors.hiyokoPink.withOpacity(0.2),
                blurRadius: 20,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // AIアバター
              Container(
                width: 56, height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [MaColors.hiyokoBlue.withOpacity(0.3), MaColors.hiyokoPink.withOpacity(0.3)],
                  ),
                ),
                child: const Center(child: Text('🤔', style: TextStyle(fontSize: 28))),
              ),
              const SizedBox(height: 12),

              // 質問番号
              Text(
                'しつもん ${_currentQ + 1} / ${_questions.length}',
                style: TextStyle(
                  fontSize: 11,
                  color: const Color(0xFF5C3D10).withOpacity(0.4),
                ),
              ),
              const SizedBox(height: 8),

              // 質問文
              Text(
                _questions[_currentQ],
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF5C3D10),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 16),

              // 回答入力
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: MaColors.hiyokoPink.withOpacity(0.3)),
                ),
                child: TextField(
                  controller: _textController,
                  maxLines: 3,
                  style: const TextStyle(color: Color(0xFF5C3D10), fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'じぶんのことばでこたえてね',
                    hintStyle: TextStyle(color: const Color(0xFF5C3D10).withOpacity(0.3), fontSize: 13),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.all(14),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // ボタン
              Row(
                children: [
                  // スキップ
                  GestureDetector(
                    onTap: _skip,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF5C3D10).withOpacity(0.05),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text(
                        'スキップ',
                        style: TextStyle(
                          fontSize: 13,
                          color: const Color(0xFF5C3D10).withOpacity(0.4),
                        ),
                      ),
                    ),
                  ),
                  const Spacer(),
                  // 回答
                  GestureDetector(
                    onTap: _next,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [MaColors.hiyokoPink, MaColors.hiyokoBlue],
                        ),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text(
                        _currentQ >= _questions.length - 1 ? 'かんりょう！' : 'つぎへ',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
