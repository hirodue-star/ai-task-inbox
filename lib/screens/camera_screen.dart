import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';
import '../models/memory_entry.dart';
import '../providers/hlc_provider.dart';
import '../services/memory_database.dart';
import '../services/manga_converter.dart';
import '../theme/ma_colors.dart';
import 'parent/parent_dashboard.dart';
import 'hiyoko/coloring_screen.dart';

/// 30秒魔法UI — 起動即カメラ、3ボタン、ガオガオ爆発
class CameraScreen extends ConsumerStatefulWidget {
  const CameraScreen({super.key});

  @override
  ConsumerState<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends ConsumerState<CameraScreen>
    with TickerProviderStateMixin {
  final _picker = ImagePicker();
  String? _photoPath;
  String? _mangaPath;
  bool _processing = false;
  _Phase _phase = _Phase.camera;

  // リップルエフェクト
  AnimationController? _rippleController;
  Color _rippleColor = Colors.transparent;
  Offset _rippleCenter = Offset.zero;

  // ガオガオ演出
  AnimationController? _gaogaoController;
  String _gaogaoMessage = '';
  MemoryStamp? _selectedStamp;

  // テキスト
  bool _showText = false;
  final _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // 起動即カメラ
    Future.microtask(_openCamera);
  }

  @override
  void dispose() {
    _rippleController?.dispose();
    _gaogaoController?.dispose();
    _textController.dispose();
    super.dispose();
  }

  Future<void> _openCamera() async {
    final photo = await _picker.pickImage(source: ImageSource.camera, maxWidth: 1200);
    if (photo != null) {
      setState(() { _photoPath = photo.path; _phase = _Phase.stamp; });
    }
  }

  Future<void> _onStampTap(MemoryStamp stamp, Offset tapPosition, Color color) async {
    setState(() { _selectedStamp = stamp; _rippleCenter = tapPosition; _rippleColor = color; });

    // リップルエフェクト
    _rippleController?.dispose();
    _rippleController = AnimationController(vsync: this, duration: const Duration(milliseconds: 400))
      ..forward();

    // 即保存＆漫画変換を並行
    setState(() { _processing = true; _phase = _Phase.processing; });

    // 漫画変換
    String? mangaPath;
    if (_photoPath != null) {
      mangaPath = await MangaConverter.convert(_photoPath!, p.dirname(_photoPath!));
    }

    // DB保存
    final entry = MemoryEntry(
      id: const Uuid().v4(),
      date: DateTime.now(),
      stamp: stamp,
      text: _textController.text.trim().isEmpty ? stamp.label : _textController.text.trim(),
      photoPath: mangaPath ?? _photoPath,
    );
    await MemoryDatabase.insert(entry);
    ref.read(hlcScoreProvider.notifier).onPost();

    setState(() { _mangaPath = mangaPath; _processing = false; });

    // ガオガオ爆発
    _gaogaoMessage = _randomPraise();
    _gaogaoController?.dispose();
    _gaogaoController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500))
      ..forward();
    setState(() => _phase = _Phase.gaogao);

    // 2秒後にカメラに戻る
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      setState(() {
        _phase = _Phase.camera;
        _photoPath = null;
        _mangaPath = null;
        _selectedStamp = null;
        _showText = false;
        _textController.clear();
      });
      _openCamera();
    }
  }

  String _randomPraise() {
    const praises = ['天才！', '大発見！', 'すっごーい！', 'さすが！', 'やったね！', 'かっこいい！', 'すてき！'];
    return praises[DateTime.now().microsecond % praises.length];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 背景（写真 or 漫画 or 黒）
          if (_mangaPath != null && _phase == _Phase.gaogao)
            Image.file(File(_mangaPath!), fit: BoxFit.cover, color: Colors.white.withOpacity(0.3), colorBlendMode: BlendMode.modulate)
          else if (_photoPath != null)
            Image.file(File(_photoPath!), fit: BoxFit.cover)
          else
            Container(color: const Color(0xFF0A0A20)),

          // フェーズ別UI
          if (_phase == _Phase.camera) _buildCameraPhase(),
          if (_phase == _Phase.stamp) _buildStampPhase(),
          if (_phase == _Phase.processing) _buildProcessing(),
          if (_phase == _Phase.gaogao) _buildGaogao(),

          // リップルエフェクト
          if (_rippleController != null)
            AnimatedBuilder(
              animation: _rippleController!,
              builder: (_, __) => CustomPaint(
                painter: _RipplePainter(
                  center: _rippleCenter,
                  progress: _rippleController!.value,
                  color: _rippleColor,
                ),
                size: Size.infinite,
              ),
            ),

          // 上部バー（常時表示）
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // ぬりえ
                  _TopButton(
                    icon: Icons.brush_rounded,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ColoringScreen())),
                  ),
                  const Spacer(),
                  // 親ダッシュボード
                  _TopButton(
                    icon: Icons.bar_chart_rounded,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ParentDashboard())),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCameraPhase() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: _openCamera,
            child: Container(
              width: 100, height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.2),
                border: Border.all(color: Colors.white.withOpacity(0.5), width: 4),
              ),
              child: const Icon(Icons.camera_alt_rounded, size: 44, color: Colors.white),
            ),
          ),
          const SizedBox(height: 12),
          Text('パシャ！', style: TextStyle(fontSize: 16, color: Colors.white.withOpacity(0.6), fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildStampPhase() {
    return SafeArea(
      child: Column(
        children: [
          const Spacer(),

          // テキスト入力（任意、小さく）
          if (_showText)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: TextField(
                controller: _textController,
                maxLines: 2,
                style: const TextStyle(color: Colors.white, fontSize: 15),
                decoration: InputDecoration(
                  hintText: 'もっとかく？',
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
                  filled: true,
                  fillColor: Colors.black.withOpacity(0.4),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                ),
              ),
            ),

          if (!_showText)
            GestureDetector(
              onTap: () => setState(() => _showText = true),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.edit_rounded, size: 14, color: Colors.white.withOpacity(0.3)),
                    const SizedBox(width: 4),
                    Text('もっとかく', style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.3))),
                  ],
                ),
              ),
            ),

          const SizedBox(height: 12),

          // 3つの巨大ボタン
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _BigStampButton(
                  emoji: '😊', label: 'たのしい', color: const Color(0xFFFF6B9D),
                  stamp: MemoryStamp.kindness,
                  onTapWithPosition: (pos) => _onStampTap(MemoryStamp.kindness, pos, const Color(0xFFFF6B9D)),
                ),
                _BigStampButton(
                  emoji: '⚔️', label: 'がんばった', color: const Color(0xFFFFD700),
                  stamp: MemoryStamp.challenge,
                  onTapWithPosition: (pos) => _onStampTap(MemoryStamp.challenge, pos, const Color(0xFFFFD700)),
                ),
                _BigStampButton(
                  emoji: '🎨', label: 'つくった', color: const Color(0xFF6BB5E8),
                  stamp: MemoryStamp.creation,
                  onTapWithPosition: (pos) => _onStampTap(MemoryStamp.creation, pos, const Color(0xFF6BB5E8)),
                ),
              ],
            ),
          ),

          // 撮り直し
          GestureDetector(
            onTap: () {
              setState(() { _photoPath = null; _phase = _Phase.camera; });
              _openCamera();
            },
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Text('とりなおす', style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.3))),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProcessing() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(width: 32, height: 32, child: CircularProgressIndicator(strokeWidth: 3, color: Colors.white)),
          const SizedBox(height: 12),
          Text('まんがにしてるよ...', style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.6))),
        ],
      ),
    );
  }

  Widget _buildGaogao() {
    return AnimatedBuilder(
      animation: _gaogaoController!,
      builder: (_, __) {
        final t = _gaogaoController!.value;
        return Container(
          color: Colors.black.withOpacity(0.5 * (1 - t * 0.3)),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ガオガオ
                Transform.scale(
                  scale: 0.5 + t * 0.5,
                  child: Container(
                    width: 120, height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFFFFE4B5),
                      boxShadow: [BoxShadow(color: MaColors.gold.withOpacity(0.4), blurRadius: 30)],
                    ),
                    child: const Center(child: Text('😆', style: TextStyle(fontSize: 56))),
                  ),
                ),
                const SizedBox(height: 16),
                // メッセージ
                Opacity(
                  opacity: (t * 2).clamp(0, 1),
                  child: Text(
                    _gaogaoMessage,
                    style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Colors.white,
                      shadows: [Shadow(color: Colors.black38, blurRadius: 8)]),
                  ),
                ),
                const SizedBox(height: 8),
                if (_selectedStamp != null)
                  Opacity(
                    opacity: (t * 2 - 0.5).clamp(0, 1),
                    child: Text(
                      '${_selectedStamp!.emoji} ${_selectedStamp!.label}',
                      style: TextStyle(fontSize: 16, color: Colors.white.withOpacity(0.6)),
                    ),
                  ),
                // パーティクル
                ...List.generate(8, (i) {
                  final angle = i * math.pi * 2 / 8;
                  final dist = 60 + 50 * t;
                  final alpha = (1 - t).clamp(0.0, 1.0);
                  return Transform.translate(
                    offset: Offset(dist * math.cos(angle), dist * math.sin(angle) - 40),
                    child: Opacity(
                      opacity: alpha,
                      child: Text(['⭐','💖','✨','🌟','💕','⭐','✨','💖'][i], style: const TextStyle(fontSize: 20)),
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }
}

enum _Phase { camera, stamp, processing, gaogao }

/// 巨大スタンプボタン
class _BigStampButton extends StatefulWidget {
  final String emoji;
  final String label;
  final Color color;
  final MemoryStamp stamp;
  final void Function(Offset globalPosition) onTapWithPosition;

  const _BigStampButton({
    required this.emoji, required this.label, required this.color,
    required this.stamp, required this.onTapWithPosition,
  });

  @override
  State<_BigStampButton> createState() => _BigStampButtonState();
}

class _BigStampButtonState extends State<_BigStampButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 150));
  }

  @override
  void dispose() { _controller.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (details) {
        _controller.reverse();
        final box = context.findRenderObject() as RenderBox;
        final globalPos = box.localToGlobal(box.size.center(Offset.zero));
        widget.onTapWithPosition(globalPos);
      },
      onTapCancel: () => _controller.reverse(),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (_, child) => Transform.scale(
          scale: 1.0 - _controller.value * 0.1,
          child: child,
        ),
        child: Container(
          width: 96, height: 96,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: widget.color.withOpacity(0.2),
            border: Border.all(color: widget.color, width: 3),
            boxShadow: [BoxShadow(color: widget.color.withOpacity(0.3), blurRadius: 16)],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(widget.emoji, style: const TextStyle(fontSize: 36)),
              Text(widget.label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: widget.color)),
            ],
          ),
        ),
      ),
    );
  }
}

/// リップルエフェクト
class _RipplePainter extends CustomPainter {
  final Offset center;
  final double progress;
  final Color color;

  _RipplePainter({required this.center, required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final maxR = size.longestSide;
    final r = maxR * progress;
    final paint = Paint()
      ..color = color.withOpacity(0.3 * (1 - progress))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4 * (1 - progress);
    canvas.drawCircle(center, r, paint);

    final fillPaint = Paint()
      ..color = color.withOpacity(0.05 * (1 - progress));
    canvas.drawCircle(center, r, fillPaint);
  }

  @override
  bool shouldRepaint(_RipplePainter old) => progress != old.progress;
}

/// 上部の小さなボタン
class _TopButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _TopButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.3),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(icon, color: Colors.white.withOpacity(0.7), size: 22),
      ),
    );
  }
}
