import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';
import '../../models/memory_entry.dart';
import '../../providers/hlc_provider.dart';
import '../../services/memory_database.dart';
import '../../theme/ma_colors.dart';
import '../../widgets/coloring_canvas.dart';

/// ぬりえモード — 描く→保存→日記に投稿→親のマンダラ「🎨つくった」に蓄積
class ColoringScreen extends ConsumerStatefulWidget {
  const ColoringScreen({super.key});

  @override
  ConsumerState<ColoringScreen> createState() => _ColoringScreenState();
}

class _ColoringScreenState extends ConsumerState<ColoringScreen> {
  final _captureKey = GlobalKey();
  bool _saving = false;

  Future<void> _saveAndPost() async {
    setState(() => _saving = true);

    // キャンバスをPNG画像にキャプチャ
    String? savedPath;
    try {
      final boundary = _captureKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary != null) {
        final image = await boundary.toImage(pixelRatio: 2.0);
        final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
        if (byteData != null) {
          final dir = Directory.systemTemp;
          final file = File(p.join(dir.path, 'coloring_${DateTime.now().millisecondsSinceEpoch}.png'));
          await file.writeAsBytes(byteData.buffer.asUint8List());
          savedPath = file.path;
        }
      }
    } catch (e) {
      debugPrint('Capture error: $e');
    }

    // 日記として投稿（🎨つくった カテゴリ）
    final entry = MemoryEntry(
      id: const Uuid().v4(),
      date: DateTime.now(),
      stamp: MemoryStamp.creation,
      text: 'ぬりえをかいたよ！',
      photoPath: savedPath,
    );
    await MemoryDatabase.insert(entry);
    ref.read(hlcScoreProvider.notifier).onPost();

    setState(() => _saving = false);

    if (!mounted) return;

    // 完了メッセージ
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('😆 すごい！きろくできたよ！'),
        backgroundColor: MaColors.gold,
        duration: const Duration(seconds: 2),
      ),
    );
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFFFFFDF5),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.close_rounded, color: Color(0xFF5C3D10), size: 28),
                  ),
                  const Spacer(),
                  const Text('ぬりえ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF5C3D10))),
                  const Spacer(),
                  const SizedBox(width: 28),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ColoringCanvas(width: w - 32, height: w - 32, captureKey: _captureKey),
              ),
            ),
            // できた！ボタン
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity, height: 52,
                child: ElevatedButton(
                  onPressed: _saving ? null : _saveAndPost,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: MaColors.gold,
                    foregroundColor: const Color(0xFF5C3D10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: _saving
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text('できた！みせる', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
