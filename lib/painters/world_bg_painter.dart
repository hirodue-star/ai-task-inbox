import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/world_state.dart';
import '../theme/ma_colors.dart';

/// 動的世界背景 — 時刻連動 + 進化段階で完全変化
class WorldBgPainter extends CustomPainter {
  final TimeOfDayPhase phase;
  final EvolutionStage evolution;
  final double animValue;
  final double abyssIntensity;

  WorldBgPainter({
    required this.phase,
    required this.evolution,
    required this.animValue,
    this.abyssIntensity = 0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    _drawSky(canvas, size);
    _drawCelestialBody(canvas, size);
    _drawEvolution(canvas, size);
    _drawAbyss(canvas, size);
  }

  /// 空のグラデーション（時間帯）
  void _drawSky(Canvas canvas, Size size) {
    late List<Color> colors;
    switch (phase) {
      case TimeOfDayPhase.morning:
        colors = [
          const Color(0xFFFFF0E8), // 淡いオレンジ
          const Color(0xFFFFE4D0),
          const Color(0xFFFFD5B8),
          const Color(0xFFA8D8FF), // 澄んだ水色
        ];
        break;
      case TimeOfDayPhase.daytime:
        colors = [
          const Color(0xFF87CEEB), // 明るい空色
          const Color(0xFFB0E0FF),
          const Color(0xFFE0F0FF),
          const Color(0xFFF5F5FF),
        ];
        break;
      case TimeOfDayPhase.evening:
        colors = [
          const Color(0xFF2C1810), // 深い夕焼け
          const Color(0xFF8B3A1A),
          const Color(0xFFFF6B35),
          const Color(0xFFFFAA50),
        ];
        break;
      case TimeOfDayPhase.night:
        colors = [
          const Color(0xFF050515), // 深宇宙
          const Color(0xFF0A0A30),
          const Color(0xFF101050),
          const Color(0xFF1A1A60),
        ];
        break;
    }

    final skyPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: colors,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), skyPaint);

    // 夜の星
    if (phase == TimeOfDayPhase.night) {
      _drawStars(canvas, size);
    }
  }

  void _drawStars(Canvas canvas, Size size) {
    final rng = math.Random(99);
    for (var i = 0; i < 80; i++) {
      final x = rng.nextDouble() * size.width;
      final y = rng.nextDouble() * size.height * 0.6;
      final r = 0.5 + rng.nextDouble() * 2;
      final twinkle = (math.sin(animValue * math.pi * 2 + i * 0.7) + 1) / 2;
      final paint = Paint()..color = Colors.white.withOpacity(0.3 + twinkle * 0.7);
      canvas.drawCircle(Offset(x, y), r, paint);
    }
    // 夜のライオン級黄金発光
    for (var i = 0; i < 20; i++) {
      final x = rng.nextDouble() * size.width;
      final y = rng.nextDouble() * size.height * 0.4;
      final r = 1 + rng.nextDouble() * 3;
      final pulse = (math.sin(animValue * math.pi * 2 + i * 1.3) + 1) / 2;
      final paint = Paint()
        ..color = MaColors.lionGold.withOpacity(0.15 + pulse * 0.4);
      canvas.drawCircle(Offset(x, y), r, paint);
      // ゴールドグロー
      final glow = Paint()
        ..shader = RadialGradient(
          colors: [
            MaColors.lionGold.withOpacity(0.08 * pulse),
            MaColors.lionGold.withOpacity(0),
          ],
        ).createShader(Rect.fromCircle(center: Offset(x, y), radius: r * 5));
      canvas.drawCircle(Offset(x, y), r * 5, glow);
    }
  }

  /// 天体（太陽/月）
  void _drawCelestialBody(Canvas canvas, Size size) {
    final cx = size.width * (0.3 + animValue * 0.4);
    late double cy;
    late Color bodyColor;
    late double bodyR;

    switch (phase) {
      case TimeOfDayPhase.morning:
        cy = size.height * 0.25;
        bodyColor = const Color(0xFFFFE066);
        bodyR = 30;
        break;
      case TimeOfDayPhase.daytime:
        cy = size.height * 0.12;
        bodyColor = const Color(0xFFFFDD44);
        bodyR = 35;
        break;
      case TimeOfDayPhase.evening:
        cy = size.height * 0.3;
        bodyColor = const Color(0xFFFF6633);
        bodyR = 40;
        break;
      case TimeOfDayPhase.night:
        cy = size.height * 0.15;
        bodyColor = const Color(0xFFE8E8F0);
        bodyR = 25;
        break;
    }

    // グロー
    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          bodyColor.withOpacity(0.3),
          bodyColor.withOpacity(0),
        ],
      ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: bodyR * 3));
    canvas.drawCircle(Offset(cx, cy), bodyR * 3, glowPaint);

    // 本体
    final bodyPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.3, -0.3),
        colors: [Colors.white, bodyColor],
      ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: bodyR));
    canvas.drawCircle(Offset(cx, cy), bodyR, bodyPaint);
  }

  /// 進化段階の描画（地面 + 生命）
  void _drawEvolution(Canvas canvas, Size size) {
    final groundY = size.height * 0.75;

    switch (evolution) {
      case EvolutionStage.barren:
        _drawBarren(canvas, size, groundY);
        break;
      case EvolutionStage.sprout:
        _drawBarren(canvas, size, groundY);
        _drawSprouts(canvas, size, groundY);
        break;
      case EvolutionStage.forest:
        _drawForest(canvas, size, groundY);
        break;
      case EvolutionStage.civilization:
        _drawForest(canvas, size, groundY);
        _drawBuildings(canvas, size, groundY);
        break;
      case EvolutionStage.golden:
        _drawGoldenAge(canvas, size, groundY);
        break;
    }
  }

  void _drawBarren(Canvas canvas, Size size, double groundY) {
    final groundPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFF8B7355).withOpacity(0.6),
          const Color(0xFF5C4033).withOpacity(0.8),
        ],
      ).createShader(Rect.fromLTWH(0, groundY, size.width, size.height - groundY));
    canvas.drawRect(Rect.fromLTWH(0, groundY, size.width, size.height - groundY), groundPaint);

    // ひび割れ
    final crackPaint = Paint()
      ..color = const Color(0xFF3D2C1E).withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    final rng = math.Random(33);
    for (var i = 0; i < 8; i++) {
      final x = rng.nextDouble() * size.width;
      final y = groundY + rng.nextDouble() * (size.height - groundY) * 0.5;
      final path = Path()..moveTo(x, y);
      for (var j = 0; j < 3; j++) {
        path.relativeLineTo(rng.nextDouble() * 20 - 10, rng.nextDouble() * 15);
      }
      canvas.drawPath(path, crackPaint);
    }
  }

  void _drawSprouts(Canvas canvas, Size size, double groundY) {
    final rng = math.Random(55);
    for (var i = 0; i < 6; i++) {
      final x = 30 + rng.nextDouble() * (size.width - 60);
      final y = groundY - 5;
      final h = 8 + rng.nextDouble() * 15;
      final sway = math.sin(animValue * math.pi * 2 + i) * 3;

      // 茎
      final stemPaint = Paint()
        ..color = const Color(0xFF6B8E23)
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(Offset(x, y), Offset(x + sway, y - h), stemPaint);

      // 葉
      final leafPaint = Paint()..color = const Color(0xFF90EE90);
      canvas.drawOval(
        Rect.fromCenter(center: Offset(x + sway + 4, y - h + 2), width: 8, height: 5),
        leafPaint,
      );
    }
  }

  void _drawForest(Canvas canvas, Size size, double groundY) {
    // 緑の丘
    final hillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [const Color(0xFF4CAF50), const Color(0xFF2E7D32)],
      ).createShader(Rect.fromLTWH(0, groundY - 30, size.width, size.height - groundY + 30));

    final hillPath = Path()..moveTo(0, size.height);
    hillPath.lineTo(0, groundY);
    for (var x = 0.0; x <= size.width; x += 1) {
      final y = groundY - 20 * math.sin(x * 0.02 + animValue * 0.5) - 10;
      hillPath.lineTo(x, y);
    }
    hillPath.lineTo(size.width, size.height);
    hillPath.close();
    canvas.drawPath(hillPath, hillPaint);

    // 木
    final rng = math.Random(44);
    for (var i = 0; i < 5; i++) {
      final x = 40 + rng.nextDouble() * (size.width - 80);
      final baseY = groundY - 15 - rng.nextDouble() * 10;
      final treeH = 30 + rng.nextDouble() * 25;
      final sway = math.sin(animValue * math.pi * 2 * 0.3 + i) * 2;

      // 幹
      final trunkPaint = Paint()..color = const Color(0xFF8B5A2B);
      canvas.drawRect(Rect.fromCenter(center: Offset(x, baseY - treeH / 3), width: 6, height: treeH * 0.5), trunkPaint);

      // 冠
      final crownPaint = Paint()..color = Color.lerp(const Color(0xFF228B22), const Color(0xFF32CD32), rng.nextDouble())!;
      canvas.drawCircle(Offset(x + sway, baseY - treeH * 0.7), treeH * 0.35, crownPaint);
    }
  }

  void _drawBuildings(Canvas canvas, Size size, double groundY) {
    final rng = math.Random(77);
    for (var i = 0; i < 3; i++) {
      final x = size.width * (0.2 + i * 0.3);
      final bw = 25 + rng.nextDouble() * 15;
      final bh = 40 + rng.nextDouble() * 30;
      final baseY = groundY - 20;

      // 建物
      final buildPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFFDEB887).withOpacity(0.9),
            const Color(0xFFA0825A).withOpacity(0.9),
          ],
        ).createShader(Rect.fromLTWH(x - bw / 2, baseY - bh, bw, bh));
      canvas.drawRect(Rect.fromLTWH(x - bw / 2, baseY - bh, bw, bh), buildPaint);

      // 屋根
      final roofPaint = Paint()..color = const Color(0xFFCD853F);
      final roof = Path()
        ..moveTo(x - bw / 2 - 5, baseY - bh)
        ..lineTo(x, baseY - bh - 15)
        ..lineTo(x + bw / 2 + 5, baseY - bh)
        ..close();
      canvas.drawPath(roof, roofPaint);

      // 窓（夜は光る）
      final windowColor = phase == TimeOfDayPhase.night
          ? const Color(0xFFFFE066)
          : const Color(0xFF87CEEB);
      final windowPaint = Paint()..color = windowColor.withOpacity(0.7);
      canvas.drawRect(Rect.fromCenter(center: Offset(x - 5, baseY - bh * 0.6), width: 6, height: 6), windowPaint);
      canvas.drawRect(Rect.fromCenter(center: Offset(x + 5, baseY - bh * 0.6), width: 6, height: 6), windowPaint);
    }
  }

  void _drawGoldenAge(Canvas canvas, Size size, double groundY) {
    _drawForest(canvas, size, groundY);
    _drawBuildings(canvas, size, groundY);

    // 黄金のオーラ
    final auraPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(0, 0.5),
        radius: 1.0,
        colors: [
          MaColors.lionGold.withOpacity(0.08 + (math.sin(animValue * math.pi * 2) + 1) / 2 * 0.06),
          MaColors.lionGold.withOpacity(0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), auraPaint);

    // 金の粒子
    final rng = math.Random(88);
    for (var i = 0; i < 15; i++) {
      final x = rng.nextDouble() * size.width;
      final baseY = rng.nextDouble() * groundY;
      final y = baseY - animValue * 40 * (0.5 + rng.nextDouble());
      final r = 1.5 + rng.nextDouble() * 2;
      final pulse = (math.sin(animValue * math.pi * 2 + i * 0.8) + 1) / 2;
      final paint = Paint()..color = MaColors.lionGold.withOpacity(0.3 + pulse * 0.5);
      canvas.drawCircle(Offset(x, y % groundY), r, paint);
    }
  }

  /// 深海の渦（ペンギン級への伏線）
  void _drawAbyss(Canvas canvas, Size size) {
    if (abyssIntensity <= 0.01) return;

    final cx = size.width / 2;
    final cy = size.height * 0.92;
    final maxR = size.width * 0.4 * abyssIntensity;

    // 渦の影
    for (var i = 5; i >= 0; i--) {
      final r = maxR * (1 - i * 0.15);
      final alpha = (0.03 + i * 0.02) * abyssIntensity;
      final paint = Paint()
        ..shader = RadialGradient(
          colors: [
            const Color(0xFF001030).withOpacity(alpha),
            const Color(0xFF001030).withOpacity(0),
          ],
        ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: r));
      canvas.drawCircle(Offset(cx, cy), r, paint);
    }

    // 渦巻き線
    final spiralPaint = Paint()
      ..color = MaColors.penguinDeep.withOpacity(0.15 * abyssIntensity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final spiralPath = Path();
    for (var angle = 0.0; angle < math.pi * 6; angle += 0.1) {
      final r = (angle / (math.pi * 6)) * maxR * 0.8;
      final a = angle + animValue * math.pi * 2;
      final x = cx + r * math.cos(a);
      final y = cy + r * math.sin(a) * 0.4; // 楕円形に
      if (angle == 0) {
        spiralPath.moveTo(x, y);
      } else {
        spiralPath.lineTo(x, y);
      }
    }
    canvas.drawPath(spiralPath, spiralPaint);

    // 泡（深海の気配）
    final rng = math.Random(66);
    for (var i = 0; i < (5 * abyssIntensity).round(); i++) {
      final bx = cx + (rng.nextDouble() - 0.5) * maxR;
      final baseBy = cy - rng.nextDouble() * 30;
      final by = baseBy - animValue * 20;
      final br = 2 + rng.nextDouble() * 3;
      final bPaint = Paint()
        ..color = MaColors.penguinIce.withOpacity(0.1 * abyssIntensity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8;
      canvas.drawCircle(Offset(bx, by), br, bPaint);
    }
  }

  @override
  bool shouldRepaint(WorldBgPainter old) =>
      phase != old.phase ||
      evolution != old.evolution ||
      animValue != old.animValue ||
      abyssIntensity != old.abyssIntensity;
}
