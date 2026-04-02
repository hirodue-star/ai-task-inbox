import 'package:flutter/material.dart';
import '../theme/ma_colors.dart';

/// 段取りミッション — 手順入力UI
/// 「まず何をした？」「次に何をする？」で論理的思考を強化
class StepByStepInput extends StatefulWidget {
  final void Function(List<String> steps) onComplete;

  const StepByStepInput({super.key, required this.onComplete});

  @override
  State<StepByStepInput> createState() => _StepByStepInputState();
}

class _StepByStepInputState extends State<StepByStepInput> {
  final _steps = <String>[];
  final _controller = TextEditingController();
  static const _maxSteps = 5;

  static const _prompts = [
    'まず、なにをした？',
    'つぎに、なにをした？',
    'そのつぎは？',
    'それから？',
    'さいごに、なにをした？',
  ];

  void _addStep() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    setState(() => _steps.add(text));
    _controller.clear();
    if (_steps.length >= _maxSteps) {
      widget.onComplete(_steps);
    }
  }

  void _finish() {
    if (_steps.isEmpty) return;
    widget.onComplete(_steps);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentPrompt = _steps.length < _prompts.length
        ? _prompts[_steps.length]
        : 'まだある？';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: MaColors.penguinIce.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // ヘッダー
          Row(
            children: [
              Icon(Icons.format_list_numbered_rounded, size: 20, color: MaColors.penguinDeep),
              const SizedBox(width: 8),
              const Text(
                'だんどりをかんがえよう',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF2C3E50),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // 入力済みステップ
          ...List.generate(_steps.length, (i) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
                  Container(
                    width: 24, height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: MaColors.penguinDeep.withOpacity(0.15),
                    ),
                    child: Center(
                      child: Text(
                        '${i + 1}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: MaColors.penguinDeep,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _steps[i],
                      style: const TextStyle(fontSize: 14, color: Color(0xFF2C3E50)),
                    ),
                  ),
                  Icon(Icons.check_rounded, size: 16, color: MaColors.penguinDeep.withOpacity(0.5)),
                ],
              ),
            );
          }),

          // 次のステップ入力
          if (_steps.length < _maxSteps) ...[
            const SizedBox(height: 4),
            Text(
              currentPrompt,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: MaColors.penguinDeep.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Container(
                  width: 24, height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: MaColors.penguinDeep.withOpacity(0.3)),
                  ),
                  child: Center(
                    child: Text(
                      '${_steps.length + 1}',
                      style: TextStyle(fontSize: 12, color: MaColors.penguinDeep.withOpacity(0.4)),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _controller,
                    style: const TextStyle(fontSize: 14, color: Color(0xFF2C3E50)),
                    decoration: InputDecoration(
                      hintText: 'ここにかいてね',
                      hintStyle: TextStyle(color: const Color(0xFF2C3E50).withOpacity(0.3), fontSize: 13),
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(vertical: 8),
                      border: InputBorder.none,
                    ),
                    onSubmitted: (_) => _addStep(),
                  ),
                ),
                GestureDetector(
                  onTap: _addStep,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: MaColors.penguinDeep.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.add_rounded, size: 18, color: MaColors.penguinDeep),
                  ),
                ),
              ],
            ),
          ],

          // 完了ボタン
          if (_steps.isNotEmpty) ...[
            const SizedBox(height: 12),
            GestureDetector(
              onTap: _finish,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: MaColors.penguinDeep.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    'だんどりかんりょう！(${_steps.length}ステップ)',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: MaColors.penguinDeep,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
