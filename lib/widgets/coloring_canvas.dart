import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// デジタルぬりえキャンバス — 巧緻性トレーニング
/// 線画の上から指で色を塗る
class ColoringCanvas extends StatefulWidget {
  final double width;
  final double height;
  final GlobalKey? captureKey; // 外部からキャプチャ用キーを渡す

  const ColoringCanvas({super.key, required this.width, required this.height, this.captureKey});

  @override
  State<ColoringCanvas> createState() => _ColoringCanvasState();
}

class _ColoringCanvasState extends State<ColoringCanvas> {
  final _strokes = <_ColorStroke>[];
  _ColorStroke? _currentStroke;
  Color _selectedColor = const Color(0xFFFF6B6B);
  double _brushSize = 12;

  static const _palette = [
    Color(0xFFFF6B6B), // 赤
    Color(0xFFFF9F43), // オレンジ
    Color(0xFFFFE066), // 黄
    Color(0xFF4CAF50), // 緑
    Color(0xFF42A5F5), // 青
    Color(0xFFAB47BC), // 紫
    Color(0xFF8D6E63), // 茶
    Color(0xFFFF80AB), // ピンク
    Color(0xFF26C6DA), // シアン
    Color(0xFFFFFFFF), // 消しゴム（白）
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // キャンバス
        RepaintBoundary(
          key: widget.captureKey,
          child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: GestureDetector(
            onPanStart: (d) {
              _currentStroke = _ColorStroke(
                color: _selectedColor,
                width: _brushSize,
                points: [d.localPosition],
              );
            },
            onPanUpdate: (d) {
              if (_currentStroke != null) {
                setState(() {
                  _currentStroke!.points.add(d.localPosition);
                });
              }
            },
            onPanEnd: (_) {
              if (_currentStroke != null) {
                setState(() {
                  _strokes.add(_currentStroke!);
                  _currentStroke = null;
                });
              }
            },
            child: Container(
              width: widget.width,
              height: widget.height,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: const Color(0xFF1A1A1A), width: 2),
              ),
              child: CustomPaint(
                painter: _ColoringPainter(
                  strokes: _strokes,
                  currentStroke: _currentStroke,
                ),
              ),
            ),
          ),
        )),

        const SizedBox(height: 12),

        // カラーパレット
        SizedBox(
          height: 44,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: _palette.map((color) {
              final isSelected = _selectedColor == color;
              return GestureDetector(
                onTap: () => setState(() => _selectedColor = color),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: isSelected ? 36 : 28,
                  height: isSelected ? 36 : 28,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? const Color(0xFF1A1A1A) : const Color(0xFFCCCCCC),
                      width: isSelected ? 3 : 1,
                    ),
                    boxShadow: isSelected
                        ? [BoxShadow(color: color.withOpacity(0.4), blurRadius: 8)]
                        : null,
                  ),
                  child: color == Colors.white
                      ? const Icon(Icons.auto_fix_high_rounded, size: 14, color: Color(0xFF999999))
                      : null,
                ),
              );
            }).toList(),
          ),
        ),

        const SizedBox(height: 8),

        // ブラシサイズ + undo
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('細', style: TextStyle(fontSize: 11, color: Color(0xFF999999))),
            SizedBox(
              width: 150,
              child: Slider(
                value: _brushSize,
                min: 4,
                max: 30,
                activeColor: _selectedColor,
                onChanged: (v) => setState(() => _brushSize = v),
              ),
            ),
            const Text('太', style: TextStyle(fontSize: 11, color: Color(0xFF999999))),
            const SizedBox(width: 16),
            GestureDetector(
              onTap: () {
                if (_strokes.isNotEmpty) {
                  setState(() => _strokes.removeLast());
                }
              },
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F0F0),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.undo_rounded, size: 20, color: Color(0xFF666666)),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ColorStroke {
  final Color color;
  final double width;
  final List<Offset> points;

  _ColorStroke({required this.color, required this.width, required this.points});
}

class _ColoringPainter extends CustomPainter {
  final List<_ColorStroke> strokes;
  final _ColorStroke? currentStroke;

  _ColoringPainter({required this.strokes, this.currentStroke});

  @override
  void paint(Canvas canvas, Size size) {
    for (final stroke in [...strokes, if (currentStroke != null) currentStroke!]) {
      if (stroke.points.length < 2) continue;
      final paint = Paint()
        ..color = stroke.color.withOpacity(0.7)
        ..strokeWidth = stroke.width
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke
        ..blendMode = stroke.color == Colors.white ? BlendMode.src : BlendMode.srcOver;

      final path = Path()..moveTo(stroke.points[0].dx, stroke.points[0].dy);
      for (var i = 1; i < stroke.points.length; i++) {
        final p0 = stroke.points[i - 1];
        final p1 = stroke.points[i];
        final mid = Offset((p0.dx + p1.dx) / 2, (p0.dy + p1.dy) / 2);
        path.quadraticBezierTo(p0.dx, p0.dy, mid.dx, mid.dy);
      }
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(_ColoringPainter old) => true;
}
