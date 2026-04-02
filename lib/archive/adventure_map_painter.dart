import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/guardian_models.dart';
import '../theme/ma_colors.dart';

/// 冒険地図（RPG風）— 1日の移動経路をビジュアル化
class AdventureMapPainter extends CustomPainter {
  final List<AdventurePoint> route;
  final List<Sanctuary> sanctuaries;
  final List<Checkpoint> checkpoints;
  final double animValue;

  AdventureMapPainter({
    required this.route,
    required this.sanctuaries,
    required this.checkpoints,
    required this.animValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (route.isEmpty) {
      _drawEmptyMap(canvas, size);
      return;
    }

    _drawTerrain(canvas, size);
    _drawRoute(canvas, size);
    _drawSanctuaries(canvas, size);
    _drawCheckpoints(canvas, size);
  }

  void _drawEmptyMap(Canvas canvas, Size size) {
    // 古地図風の背景
    final bgPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFF5E6C8), Color(0xFFE8D5A8), Color(0xFFF0DEB8)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(0, 0, size.width, size.height), const Radius.circular(16)),
      bgPaint,
    );

    // 「冒険はまだはじまっていない」
    final tp = TextPainter(
      text: TextSpan(
        text: '冒険はまだはじまっていない…',
        style: TextStyle(fontSize: 14, color: const Color(0xFF8B7355).withOpacity(0.5), fontStyle: FontStyle.italic),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(size.width / 2 - tp.width / 2, size.height / 2 - tp.height / 2));
  }

  void _drawTerrain(Canvas canvas, Size size) {
    // 古地図風の背景
    final bgPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFFF5E6C8), Color(0xFFE8D5A8)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(0, 0, size.width, size.height), const Radius.circular(16)),
      bgPaint,
    );

    // 地図の質感（点線のグリッド）
    final gridPaint = Paint()
      ..color = const Color(0xFFD4C4A0).withOpacity(0.3)
      ..strokeWidth = 0.5;
    for (var x = 0.0; x < size.width; x += 30) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (var y = 0.0; y < size.height; y += 30) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // ランダムな地形要素
    final rng = math.Random(42);
    final treePaint = Paint()..color = const Color(0xFF6B8E23).withOpacity(0.2);
    for (var i = 0; i < 8; i++) {
      final x = rng.nextDouble() * size.width;
      final y = rng.nextDouble() * size.height;
      canvas.drawCircle(Offset(x, y), 8 + rng.nextDouble() * 12, treePaint);
    }
  }

  void _drawRoute(Canvas canvas, Size size) {
    if (route.length < 2) return;

    // ルートをキャンバス座標にマッピング
    final points = _mapToCanvas(size);

    // 点線の冒険路
    final routePaint = Paint()
      ..color = const Color(0xFF8B4513)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final path = Path()..moveTo(points[0].dx, points[0].dy);
    for (var i = 1; i < points.length; i++) {
      final p0 = points[i - 1];
      final p1 = points[i];
      final mid = Offset((p0.dx + p1.dx) / 2, (p0.dy + p1.dy) / 2);
      path.quadraticBezierTo(p0.dx, p0.dy, mid.dx, mid.dy);
    }
    canvas.drawPath(path, routePaint);

    // 足跡ドット
    final dotPaint = Paint()..color = const Color(0xFF5C3D10);
    final animatedCount = (points.length * animValue).round();
    for (var i = 0; i < animatedCount && i < points.length; i++) {
      canvas.drawCircle(points[i], 3, dotPaint);
    }

    // 現在地マーカー
    if (animatedCount > 0 && animatedCount <= points.length) {
      final current = points[(animatedCount - 1).clamp(0, points.length - 1)];
      final markerPaint = Paint()
        ..shader = RadialGradient(
          colors: [MaColors.lionGold, MaColors.lionGold.withOpacity(0)],
        ).createShader(Rect.fromCircle(center: current, radius: 15));
      canvas.drawCircle(current, 15, markerPaint);
      canvas.drawCircle(current, 6, Paint()..color = MaColors.lionGold);
      canvas.drawCircle(current, 4, Paint()..color = Colors.white);
    }
  }

  void _drawSanctuaries(Canvas canvas, Size size) {
    for (final s in sanctuaries) {
      final point = _geoToCanvas(s.latitude, s.longitude, size);
      if (point == null) continue;

      // 聖域の光
      final glowPaint = Paint()
        ..shader = RadialGradient(
          colors: [
            const Color(0xFFFFD700).withOpacity(0.15),
            const Color(0xFFFFD700).withOpacity(0),
          ],
        ).createShader(Rect.fromCircle(center: point, radius: 25));
      canvas.drawCircle(point, 25, glowPaint);

      // アイコン背景
      canvas.drawCircle(point, 12, Paint()..color = Colors.white.withOpacity(0.8));
      canvas.drawCircle(point, 12, Paint()
        ..color = const Color(0xFF8B4513).withOpacity(0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5);

      // ラベル
      final tp = TextPainter(
        text: TextSpan(text: s.emoji, style: const TextStyle(fontSize: 14)),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(point.dx - tp.width / 2, point.dy - tp.height / 2));
    }
  }

  void _drawCheckpoints(Canvas canvas, Size size) {
    for (final cp in checkpoints) {
      final point = _geoToCanvas(cp.latitude, cp.longitude, size);
      if (point == null) continue;

      if (cp.discovered) {
        // 開いた宝箱
        canvas.drawCircle(point, 10, Paint()..color = MaColors.lionGold.withOpacity(0.3));
        final tp = TextPainter(
          text: const TextSpan(text: '🎁', style: TextStyle(fontSize: 18)),
          textDirection: TextDirection.ltr,
        )..layout();
        tp.paint(canvas, Offset(point.dx - tp.width / 2, point.dy - tp.height / 2));
      } else {
        // 未発見の宝箱（ぼんやり光る）
        final pulse = (math.sin(animValue * math.pi * 2 + cp.hashCode) + 1) / 2;
        canvas.drawCircle(point, 8 + pulse * 4, Paint()
          ..color = const Color(0xFFFFD700).withOpacity(0.1 + pulse * 0.1));
        final tp = TextPainter(
          text: TextSpan(text: '?', style: TextStyle(
            fontSize: 14, fontWeight: FontWeight.bold,
            color: const Color(0xFF8B4513).withOpacity(0.3 + pulse * 0.2))),
          textDirection: TextDirection.ltr,
        )..layout();
        tp.paint(canvas, Offset(point.dx - tp.width / 2, point.dy - tp.height / 2));
      }
    }
  }

  List<Offset> _mapToCanvas(Size size) {
    if (route.isEmpty) return [];
    final margin = 40.0;
    double minLat = route[0].latitude, maxLat = route[0].latitude;
    double minLon = route[0].longitude, maxLon = route[0].longitude;
    for (final p in route) {
      minLat = math.min(minLat, p.latitude);
      maxLat = math.max(maxLat, p.latitude);
      minLon = math.min(minLon, p.longitude);
      maxLon = math.max(maxLon, p.longitude);
    }
    final latRange = (maxLat - minLat).clamp(0.001, double.infinity);
    final lonRange = (maxLon - minLon).clamp(0.001, double.infinity);

    return route.map((p) {
      final x = margin + ((p.longitude - minLon) / lonRange) * (size.width - margin * 2);
      final y = margin + ((maxLat - p.latitude) / latRange) * (size.height - margin * 2);
      return Offset(x, y);
    }).toList();
  }

  Offset? _geoToCanvas(double lat, double lon, Size size) {
    if (route.isEmpty) return null;
    final margin = 40.0;
    double minLat = route[0].latitude, maxLat = route[0].latitude;
    double minLon = route[0].longitude, maxLon = route[0].longitude;
    for (final p in route) {
      minLat = math.min(minLat, p.latitude);
      maxLat = math.max(maxLat, p.latitude);
      minLon = math.min(minLon, p.longitude);
      maxLon = math.max(maxLon, p.longitude);
    }
    final latRange = (maxLat - minLat).clamp(0.001, double.infinity);
    final lonRange = (maxLon - minLon).clamp(0.001, double.infinity);
    final x = margin + ((lon - minLon) / lonRange) * (size.width - margin * 2);
    final y = margin + ((maxLat - lat) / latRange) * (size.height - margin * 2);
    return Offset(x.clamp(0, size.width), y.clamp(0, size.height));
  }

  @override
  bool shouldRepaint(AdventureMapPainter old) => animValue != old.animValue || route.length != old.route.length;
}
