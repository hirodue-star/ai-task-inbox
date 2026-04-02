import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../models/memory_entry.dart';
import '../../providers/hlc_provider.dart';
import '../../services/memory_database.dart';
import '../../theme/ma_colors.dart';

/// 日記投稿画面（MVP: スタンプ + テキスト + 保存）
class MemoryInputScreen extends ConsumerStatefulWidget {
  const MemoryInputScreen({super.key});

  @override
  ConsumerState<MemoryInputScreen> createState() => _MemoryInputScreenState();
}

class _MemoryInputScreenState extends ConsumerState<MemoryInputScreen> {
  final _textController = TextEditingController();
  MemoryStamp? _selectedStamp;
  bool _saving = false;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_selectedStamp == null || _textController.text.trim().isEmpty) return;
    setState(() => _saving = true);

    final entry = MemoryEntry(
      id: const Uuid().v4(),
      date: DateTime.now(),
      stamp: _selectedStamp!,
      text: _textController.text.trim(),
    );

    await MemoryDatabase.insert(entry);
    ref.read(hlcScoreProvider.notifier).onPost();

    setState(() => _saving = false);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MaColors.warmWhite,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ヘッダー
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.close_rounded, color: Color(0xFF5C3D10), size: 28),
                  ),
                  const Spacer(),
                  const Text('きおくのきろく',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF5C3D10))),
                  const Spacer(),
                  const SizedBox(width: 28),
                ],
              ),

              const SizedBox(height: 32),

              // スタンプ選択
              const Text('なにをした？', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF5C3D10))),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8, runSpacing: 8,
                children: MemoryStamp.values.map((stamp) {
                  final selected = _selectedStamp == stamp;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedStamp = stamp),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: selected ? MaColors.gold.withOpacity(0.15) : Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: selected ? MaColors.gold : const Color(0xFFEEEEEE),
                          width: selected ? 2 : 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(stamp.emoji, style: const TextStyle(fontSize: 18)),
                          const SizedBox(width: 6),
                          Text(stamp.label,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                              color: const Color(0xFF5C3D10),
                            )),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 24),

              // テキスト入力
              const Text('おもいでをかこう', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF5C3D10))),
              const SizedBox(height: 8),
              TextField(
                controller: _textController,
                maxLines: 5,
                style: const TextStyle(color: Color(0xFF2C3E50), fontSize: 15),
                decoration: InputDecoration(
                  hintText: _selectedStamp != null ? _hintFor(_selectedStamp!) : 'スタンプをえらんでね',
                  hintStyle: TextStyle(color: const Color(0xFF5C3D10).withOpacity(0.25)),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: Color(0xFFEEEEEE)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: Color(0xFFEEEEEE)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: MaColors.gold),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // 保存ボタン
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: (_selectedStamp != null && !_saving) ? _save : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: MaColors.gold,
                    foregroundColor: const Color(0xFF5C3D10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: _saving
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text('きろくする', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _hintFor(MemoryStamp stamp) {
    switch (stamp) {
      case MemoryStamp.ate: return 'なにをたべた？おいしかった？';
      case MemoryStamp.went: return 'どこにいった？なにをみた？';
      case MemoryStamp.played: return 'なにであそんだ？';
      case MemoryStamp.pet: return 'どうぶつとなにをした？';
      case MemoryStamp.challenge: return 'なにに挑んだ？';
    }
  }
}
