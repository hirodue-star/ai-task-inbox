import 'package:flutter/material.dart';
import '../theme/ma_colors.dart';

/// 🦁 ライオン級：黄金マンダラ 3x3 グリッド
class MandalaGridPainter extends CustomPainter {
  final int? selectedCell;

  MandalaGridPainter({this.selectedCell});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cellW = w / 3;
    final cellH = h / 3;

    // 背景：深いネイビー
    final bgPaint = Paint()
      ..shader = const RadialGradient(
        colors: [Color(0xFF1A1A50), Color(0xFF0B0B2B)],
      ).createShader(Rect.fromLTWH(0, 0, w, h));
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(0, 0, w, h), const Radius.circular(16)),
      bgPaint,
    );

    // 外枠ゴールド
    final outerBorder = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..shader = const LinearGradient(
        colors: [Color(0xFFFFD700), Color(0xFFC8960C), Color(0xFFFFD700)],
      ).createShader(Rect.fromLTWH(0, 0, w, h));
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(2, 2, w - 4, h - 4), const Radius.circular(16)),
      outerBorder,
    );

    // グリッド線（金色）
    final gridPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFFFD700), Color(0xFFC8960C), Color(0xFFFFEA80)],
      ).createShader(Rect.fromLTWH(0, 0, w, h));

    for (var i = 1; i < 3; i++) {
      canvas.drawLine(Offset(cellW * i, 8), Offset(cellW * i, h - 8), gridPaint);
      canvas.drawLine(Offset(8, cellH * i), Offset(w - 8, cellH * i), gridPaint);
    }

    // 各セルのコーナー装飾
    final cornerPaint = Paint()
      ..color = const Color(0xFFFFD700)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    final cornerLen = cellW * 0.12;

    for (var row = 0; row < 3; row++) {
      for (var col = 0; col < 3; col++) {
        final x = cellW * col;
        final y = cellH * row;

        // 選択セルのハイライト
        if (selectedCell != null && selectedCell == row * 3 + col) {
          final glowPaint = Paint()
            ..color = MaColors.lionGold.withValues(alpha: 0.15)
            ..style = PaintingStyle.fill;
          canvas.drawRect(
            Rect.fromLTWH(x + 2, y + 2, cellW - 4, cellH - 4),
            glowPaint,
          );
        }

        // 四隅の装飾
        _drawCorner(canvas, x + 4, y + 4, cornerLen, cornerLen, cornerPaint);
        _drawCorner(canvas, x + cellW - 4, y + 4, -cornerLen, cornerLen, cornerPaint);
        _drawCorner(canvas, x + 4, y + cellH - 4, cornerLen, -cornerLen, cornerPaint);
        _drawCorner(canvas, x + cellW - 4, y + cellH - 4, -cornerLen, -cornerLen, cornerPaint);
      }
    }

    // 中央セルの特別装飾（マンダラの核）
    final centerX = cellW * 1.5;
    final centerY = cellH * 1.5;
    final centerR = cellW * 0.3;
    final mandalaGlow = Paint()
      ..shader = RadialGradient(
        colors: [
          MaColors.lionGold.withValues(alpha: 0.3),
          MaColors.lionGold.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromCircle(center: Offset(centerX, centerY), radius: centerR));
    canvas.drawCircle(Offset(centerX, centerY), centerR, mandalaGlow);

    final mandalaRing = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..color = MaColors.lionGold.withValues(alpha: 0.6);
    canvas.drawCircle(Offset(centerX, centerY), centerR * 0.7, mandalaRing);
    canvas.drawCircle(Offset(centerX, centerY), centerR * 0.4, mandalaRing);
  }

  void _drawCorner(Canvas canvas, double x, double y, double dx, double dy, Paint paint) {
    canvas.drawLine(Offset(x, y), Offset(x + dx, y), paint);
    canvas.drawLine(Offset(x, y), Offset(x, y + dy), paint);
  }

  @override
  bool shouldRepaint(MandalaGridPainter old) => selectedCell != old.selectedCell;
}

/// マンダラグリッドウィジェット
class MandalaGrid extends StatelessWidget {
  final double size;
  final int? selectedCell;
  final void Function(int)? onCellTap;

  const MandalaGrid({super.key, this.size = 300, this.selectedCell, this.onCellTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (details) {
        if (onCellTap == null) return;
        final cellW = size / 3;
        final col = (details.localPosition.dx / cellW).floor().clamp(0, 2);
        final row = (details.localPosition.dy / cellW).floor().clamp(0, 2);
        onCellTap!(row * 3 + col);
      },
      child: SizedBox(
        width: size,
        height: size,
        child: CustomPaint(painter: MandalaGridPainter(selectedCell: selectedCell)),
      ),
    );
  }
}
