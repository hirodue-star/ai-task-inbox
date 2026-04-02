import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/ma_colors.dart';

/// 🦁 ライオン級：黄金マンダラ 3x3 グリッド + 残光エフェクト
class MandalaGridPainter extends CustomPainter {
  final int? selectedCell;
  final List<_TouchTrail> trails;

  MandalaGridPainter({this.selectedCell, this.trails = const []});

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

    // 残光トレイル（黄金の粉）
    final rng = math.Random(42);
    for (final trail in trails) {
      final alpha = trail.life.clamp(0.0, 1.0);
      // メインの光
      final glowPaint = Paint()
        ..shader = RadialGradient(
          colors: [
            MaColors.lionGold.withValues(alpha: 0.6 * alpha),
            MaColors.lionGold.withValues(alpha: 0.1 * alpha),
            MaColors.lionGold.withValues(alpha: 0),
          ],
          stops: const [0.0, 0.4, 1.0],
        ).createShader(Rect.fromCircle(center: trail.position, radius: 30 * alpha));
      canvas.drawCircle(trail.position, 30 * alpha, glowPaint);

      // 散らばる金粉パーティクル
      for (var i = 0; i < 8; i++) {
        final angle = rng.nextDouble() * math.pi * 2;
        final dist = rng.nextDouble() * 20 * (1.0 - alpha);
        final px = trail.position.dx + dist * math.cos(angle);
        final py = trail.position.dy + dist * math.sin(angle);
        final pSize = 1.0 + rng.nextDouble() * 2.5 * alpha;
        final pAlpha = (alpha * (0.5 + rng.nextDouble() * 0.5)).clamp(0.0, 1.0);
        final colors = [MaColors.lionGold, const Color(0xFFFFF8DC), const Color(0xFFFFEA80)];
        final particlePaint = Paint()
          ..color = colors[i % colors.length].withValues(alpha: pAlpha);
        canvas.drawCircle(Offset(px, py), pSize, particlePaint);
      }
    }

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

        _drawCorner(canvas, x + 4, y + 4, cornerLen, cornerLen, cornerPaint);
        _drawCorner(canvas, x + cellW - 4, y + 4, -cornerLen, cornerLen, cornerPaint);
        _drawCorner(canvas, x + 4, y + cellH - 4, cornerLen, -cornerLen, cornerPaint);
        _drawCorner(canvas, x + cellW - 4, y + cellH - 4, -cornerLen, -cornerLen, cornerPaint);
      }
    }

    // 中央セルの特別装飾
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
  bool shouldRepaint(MandalaGridPainter old) =>
      selectedCell != old.selectedCell || trails.length != old.trails.length;
}

/// タッチ残光データ
class _TouchTrail {
  final Offset position;
  final double life; // 1.0 → 0.0

  const _TouchTrail({required this.position, required this.life});
}

/// マンダラグリッドウィジェット（残光エフェクト付き）
class MandalaGrid extends StatefulWidget {
  final double size;
  final int? selectedCell;
  final void Function(int)? onCellTap;

  const MandalaGrid({super.key, this.size = 300, this.selectedCell, this.onCellTap});

  @override
  State<MandalaGrid> createState() => _MandalaGridState();
}

class _MandalaGridState extends State<MandalaGrid>
    with SingleTickerProviderStateMixin {
  late AnimationController _trailController;
  final List<_TrailEntry> _trails = [];

  @override
  void initState() {
    super.initState();
    _trailController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..addListener(_updateTrails);
  }

  @override
  void dispose() {
    _trailController.dispose();
    super.dispose();
  }

  void _updateTrails() {
    setState(() {
      for (final t in _trails) {
        t.life -= 0.016; // ~60fps
      }
      _trails.removeWhere((t) => t.life <= 0);
      if (_trails.isEmpty) _trailController.stop();
    });
  }

  void _onTapDown(TapDownDetails details) {
    final cellW = widget.size / 3;
    final col = (details.localPosition.dx / cellW).floor().clamp(0, 2);
    final row = (details.localPosition.dy / cellW).floor().clamp(0, 2);
    widget.onCellTap?.call(row * 3 + col);

    // 残光を追加（タップ位置に黄金の粉）
    _trails.add(_TrailEntry(position: details.localPosition, life: 1.0));
    if (!_trailController.isAnimating) {
      _trailController.repeat();
    }
  }

  @override
  Widget build(BuildContext context) {
    final trailData = _trails
        .map((t) => _TouchTrail(position: t.position, life: t.life))
        .toList();

    return GestureDetector(
      onTapDown: _onTapDown,
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: CustomPaint(
          painter: MandalaGridPainter(
            selectedCell: widget.selectedCell,
            trails: trailData,
          ),
        ),
      ),
    );
  }
}

class _TrailEntry {
  final Offset position;
  double life;
  _TrailEntry({required this.position, required this.life});
}
