import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';
import '../../models/memory_entry.dart';
import '../../providers/hlc_provider.dart';
import '../../services/memory_database.dart';
import '../../services/manga_converter.dart';
import '../../theme/ma_colors.dart';
import '../../widgets/gaogao_reaction.dart';

/// 日記投稿画面（MVP: スタンプ + テキスト + 写真→漫画変換 + 保存）
class MemoryInputScreen extends ConsumerStatefulWidget {
  const MemoryInputScreen({super.key});

  @override
  ConsumerState<MemoryInputScreen> createState() => _MemoryInputScreenState();
}

class _MemoryInputScreenState extends ConsumerState<MemoryInputScreen> {
  final _textController = TextEditingController();
  final _picker = ImagePicker();
  MemoryStamp? _selectedStamp;
  String? _photoPath;
  String? _mangaPath;
  bool _saving = false;
  bool _converting = false;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _takePhoto() async {
    final photo = await _picker.pickImage(source: ImageSource.camera, maxWidth: 1200);
    if (photo == null) return;
    setState(() {
      _photoPath = photo.path;
      _mangaPath = null;
    });
    _convertToManga(photo.path);
  }

  Future<void> _pickPhoto() async {
    final photo = await _picker.pickImage(source: ImageSource.gallery, maxWidth: 1200);
    if (photo == null) return;
    setState(() {
      _photoPath = photo.path;
      _mangaPath = null;
    });
    _convertToManga(photo.path);
  }

  Future<void> _convertToManga(String path) async {
    setState(() => _converting = true);
    final outputDir = p.dirname(path);
    final result = await MangaConverter.convert(path, outputDir);
    if (mounted) {
      setState(() {
        _mangaPath = result;
        _converting = false;
      });
    }
  }

  Future<void> _save() async {
    if (_selectedStamp == null || _textController.text.trim().isEmpty) return;
    setState(() => _saving = true);

    final entry = MemoryEntry(
      id: const Uuid().v4(),
      date: DateTime.now(),
      stamp: _selectedStamp!,
      text: _textController.text.trim(),
      photoPath: _mangaPath ?? _photoPath,
    );

    await MemoryDatabase.insert(entry);
    ref.read(hlcScoreProvider.notifier).onPost();
    setState(() => _saving = false);

    // ガオガオリアクション → 戻る
    if (!mounted) return;
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => GaogaoReaction(onComplete: () => Navigator.pop(context)),
    );
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

              const SizedBox(height: 24),

              // 写真エリア
              GestureDetector(
                onTap: _photoPath == null ? _showPhotoOptions : null,
                child: Container(
                  width: double.infinity,
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFEEEEEE)),
                  ),
                  child: _buildPhotoArea(),
                ),
              ),

              const SizedBox(height: 20),

              // スタンプ選択
              const Text('なにをした？', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF5C3D10))),
              const SizedBox(height: 10),
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

              const SizedBox(height: 20),

              // テキスト入力
              const Text('おもいでをかこう', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF5C3D10))),
              const SizedBox(height: 8),
              TextField(
                controller: _textController,
                maxLines: 4,
                style: const TextStyle(color: Color(0xFF2C3E50), fontSize: 15),
                decoration: InputDecoration(
                  hintText: _selectedStamp != null ? _hintFor(_selectedStamp!) : 'スタンプをえらんでね',
                  hintStyle: TextStyle(color: const Color(0xFF5C3D10).withOpacity(0.25)),
                  filled: true, fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFEEEEEE))),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFEEEEEE))),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: MaColors.gold)),
                ),
              ),

              const SizedBox(height: 24),

              // 保存ボタン
              SizedBox(
                width: double.infinity, height: 52,
                child: ElevatedButton(
                  onPressed: (_selectedStamp != null && !_saving && !_converting) ? _save : null,
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

  Widget _buildPhotoArea() {
    if (_converting) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2)),
          const SizedBox(height: 8),
          Text('漫画に変換中...', style: TextStyle(fontSize: 13, color: const Color(0xFF5C3D10).withOpacity(0.5))),
        ],
      );
    }

    if (_mangaPath != null) {
      // 漫画変換済み — 線画とオリジナルを切り替え表示
      return Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Image.file(File(_mangaPath!), width: double.infinity, height: 200, fit: BoxFit.cover),
          ),
          // 写真切り替えボタン
          Positioned(
            top: 8, right: 8,
            child: Row(
              children: [
                _PhotoToggle(icon: Icons.brush_rounded, label: '線画', active: true, onTap: () {}),
                const SizedBox(width: 4),
                _PhotoToggle(icon: Icons.photo_rounded, label: '写真', active: false,
                  onTap: () => setState(() => _mangaPath = null)),
              ],
            ),
          ),
          // 再撮影
          Positioned(
            bottom: 8, right: 8,
            child: GestureDetector(
              onTap: _showPhotoOptions,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.refresh_rounded, color: Colors.white, size: 20),
              ),
            ),
          ),
        ],
      );
    }

    if (_photoPath != null) {
      return Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Image.file(File(_photoPath!), width: double.infinity, height: 200, fit: BoxFit.cover),
          ),
          Positioned(
            top: 8, right: 8,
            child: GestureDetector(
              onTap: () => _convertToManga(_photoPath!),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: MaColors.gold,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.brush_rounded, size: 14, color: Color(0xFF5C3D10)),
                    SizedBox(width: 4),
                    Text('漫画に変換', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF5C3D10))),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 8, right: 8,
            child: GestureDetector(
              onTap: _showPhotoOptions,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.refresh_rounded, color: Colors.white, size: 20),
              ),
            ),
          ),
        ],
      );
    }

    // 未撮影
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.camera_alt_rounded, size: 36, color: const Color(0xFF5C3D10).withOpacity(0.2)),
        const SizedBox(height: 8),
        Text('写真をとろう（なくてもOK）',
          style: TextStyle(fontSize: 13, color: const Color(0xFF5C3D10).withOpacity(0.3))),
      ],
    );
  }

  void _showPhotoOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt_rounded),
                title: const Text('カメラで撮影'),
                onTap: () { Navigator.pop(ctx); _takePhoto(); },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_rounded),
                title: const Text('ライブラリから選択'),
                onTap: () { Navigator.pop(ctx); _pickPhoto(); },
              ),
              if (_photoPath != null)
                ListTile(
                  leading: const Icon(Icons.delete_outline_rounded, color: Colors.red),
                  title: const Text('写真を削除', style: TextStyle(color: Colors.red)),
                  onTap: () {
                    Navigator.pop(ctx);
                    setState(() { _photoPath = null; _mangaPath = null; });
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _hintFor(MemoryStamp stamp) {
    switch (stamp) {
      case MemoryStamp.kindness: return 'だれにやさしくした？';
      case MemoryStamp.logic: return 'じゅんばんをかんがえてやったことは？';
      case MemoryStamp.creation: return 'なにをつくった？かいた？';
      case MemoryStamp.discovery: return 'なにをみつけた？きづいた？';
      case MemoryStamp.challenge: return 'なにに挑んだ？';
      case MemoryStamp.expression: return 'だれになにをつたえた？';
      case MemoryStamp.helping: return 'だれのおてつだいをした？';
      case MemoryStamp.nature: return 'そとでなにをみた？かんじた？';
    }
  }
}

class _PhotoToggle extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;
  const _PhotoToggle({required this.icon, required this.label, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: active ? MaColors.gold : Colors.black.withOpacity(0.4),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12, color: active ? const Color(0xFF5C3D10) : Colors.white),
            const SizedBox(width: 3),
            Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600,
              color: active ? const Color(0xFF5C3D10) : Colors.white)),
          ],
        ),
      ),
    );
  }
}
