import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/hlc_provider.dart';
import '../../providers/world_provider.dart';
import '../../models/hlc_score.dart';
import '../../theme/ma_colors.dart';

/// 親用ダッシュボード — HLC成長グラフ + 統計
class ParentDashboard extends ConsumerWidget {
  const ParentDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final score = ref.watch(hlcScoreProvider);
    final world = ref.watch(worldStateProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F0),
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
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
                      ),
                      child: const Icon(Icons.arrow_back_rounded, color: Color(0xFF2C3E50)),
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Text(
                      '成長ダッシュボード',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Color(0xFF2C3E50)),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // HLCレーダーチャート
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 12)],
                ),
                child: Column(
                  children: [
                    const Text(
                      'HLC バランス',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF2C3E50)),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 220,
                      child: CustomPaint(
                        size: const Size(220, 220),
                        painter: _HlcRadarPainter(score: score),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _StatChip('H 奉仕', score.hospitality, MaColors.hiyokoPink),
                        _StatChip('L 論理', score.logic, MaColors.penguinDeep),
                        _StatChip('C 創造', score.creativity, MaColors.lionGold),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // 強み分析
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [_strengthColor(score).withOpacity(0.1), Colors.white],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _strengthColor(score).withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'お子様の強み',
                      style: TextStyle(fontSize: 13, color: const Color(0xFF2C3E50).withOpacity(0.5)),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      score.strength,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: _strengthColor(score),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _strengthAdvice(score),
                      style: TextStyle(fontSize: 13, color: const Color(0xFF2C3E50).withOpacity(0.6), height: 1.5),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // 世界復元率
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 12)],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'World Restore',
                          style: TextStyle(fontSize: 13, color: const Color(0xFF2C3E50).withOpacity(0.5)),
                        ),
                        const Spacer(),
                        Text(
                          '${world.restorePercent.toStringAsFixed(1)}%',
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF2C3E50)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: world.restorePercent / 100,
                        minHeight: 10,
                        backgroundColor: const Color(0xFFF0F0F0),
                        valueColor: AlwaysStoppedAnimation(MaColors.lionGold),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'マンダラ解放: ${world.mandalaSlotsUnlocked}/9 スロット',
                      style: TextStyle(fontSize: 12, color: const Color(0xFF2C3E50).withOpacity(0.4)),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // レベル情報
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: MaColors.goldGradient,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '現在のレベル',
                          style: TextStyle(fontSize: 12, color: const Color(0xFF5C3D10).withOpacity(0.6)),
                        ),
                        Text(
                          score.level.name.toUpperCase(),
                          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Color(0xFF5C3D10)),
                        ),
                      ],
                    ),
                    const Spacer(),
                    if (score.pointsToNextLevel > 0)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '次のレベルまで',
                            style: TextStyle(fontSize: 11, color: const Color(0xFF5C3D10).withOpacity(0.5)),
                          ),
                          Text(
                            '${score.pointsToNextLevel} pt',
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF5C3D10)),
                          ),
                        ],
                      )
                    else
                      const Text('🏆 MAX', style: TextStyle(fontSize: 24)),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // 入試対策指標
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 12)],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '私立入学準備指標',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF2C3E50)),
                    ),
                    const SizedBox(height: 12),
                    _PrepIndicator('言語化力（面接対応）', _interviewReadiness(score), Icons.record_voice_over_rounded),
                    const SizedBox(height: 8),
                    _PrepIndicator('段取り力（手順思考）', _logicalReadiness(score), Icons.format_list_numbered_rounded),
                    const SizedBox(height: 8),
                    _PrepIndicator('感性（創造・表現）', _creativeReadiness(score), Icons.palette_rounded),
                    const SizedBox(height: 8),
                    _PrepIndicator('思いやり（協調性）', _hospitalityReadiness(score), Icons.favorite_rounded),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _strengthColor(HlcScore score) {
    if (score.hospitality >= score.logic && score.hospitality >= score.creativity) return MaColors.hiyokoPink;
    if (score.logic >= score.hospitality && score.logic >= score.creativity) return MaColors.penguinDeep;
    return MaColors.lionGold;
  }

  String _strengthAdvice(HlcScore score) {
    if (score.hospitality >= score.logic && score.hospitality >= score.creativity) {
      return '思いやりの心が大きく育っています。面接では「お友達を助けた経験」を語れるでしょう。';
    }
    if (score.logic >= score.hospitality && score.logic >= score.creativity) {
      return '論理的思考力が伸びています。「なぜ？」を考える習慣が身についています。';
    }
    return '創造力が豊かです。独自の発想力は面接官の心に残るでしょう。';
  }

  double _interviewReadiness(HlcScore score) => ((score.hospitality + score.creativity) / 200).clamp(0.0, 1.0);
  double _logicalReadiness(HlcScore score) => (score.logic / 100).clamp(0.0, 1.0);
  double _creativeReadiness(HlcScore score) => (score.creativity / 100).clamp(0.0, 1.0);
  double _hospitalityReadiness(HlcScore score) => (score.hospitality / 100).clamp(0.0, 1.0);
}

/// HLCレーダーチャート
class _HlcRadarPainter extends CustomPainter {
  final HlcScore score;
  _HlcRadarPainter({required this.score});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width * 0.4;

    // グリッド
    final gridPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5
      ..color = const Color(0xFF2C3E50).withOpacity(0.1);

    for (var level = 1; level <= 3; level++) {
      final lr = r * level / 3;
      final path = Path();
      for (var i = 0; i < 3; i++) {
        final angle = (i * 2 * math.pi / 3) - math.pi / 2;
        final x = cx + lr * math.cos(angle);
        final y = cy + lr * math.sin(angle);
        if (i == 0) path.moveTo(x, y); else path.lineTo(x, y);
      }
      path.close();
      canvas.drawPath(path, gridPaint);
    }

    // 軸線
    for (var i = 0; i < 3; i++) {
      final angle = (i * 2 * math.pi / 3) - math.pi / 2;
      canvas.drawLine(Offset(cx, cy), Offset(cx + r * math.cos(angle), cy + r * math.sin(angle)), gridPaint);
    }

    // データ
    final maxVal = [score.hospitality, score.logic, score.creativity, 100].reduce(math.max).toDouble();
    final values = [score.hospitality / maxVal, score.logic / maxVal, score.creativity / maxVal];
    final colors = [MaColors.hiyokoPink, MaColors.penguinDeep, MaColors.lionGold];

    final dataPath = Path();
    for (var i = 0; i < 3; i++) {
      final angle = (i * 2 * math.pi / 3) - math.pi / 2;
      final dr = r * values[i];
      final x = cx + dr * math.cos(angle);
      final y = cy + dr * math.sin(angle);
      if (i == 0) dataPath.moveTo(x, y); else dataPath.lineTo(x, y);
    }
    dataPath.close();

    // 塗り
    final fillPaint = Paint()
      ..color = MaColors.hiyokoPink.withOpacity(0.15)
      ..style = PaintingStyle.fill;
    canvas.drawPath(dataPath, fillPaint);

    // 線
    final strokePaint = Paint()
      ..color = MaColors.hiyokoPink.withOpacity(0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawPath(dataPath, strokePaint);

    // 頂点のドット
    for (var i = 0; i < 3; i++) {
      final angle = (i * 2 * math.pi / 3) - math.pi / 2;
      final dr = r * values[i];
      final x = cx + dr * math.cos(angle);
      final y = cy + dr * math.sin(angle);
      canvas.drawCircle(Offset(x, y), 5, Paint()..color = colors[i]);
      canvas.drawCircle(Offset(x, y), 3, Paint()..color = Colors.white);
    }

    // ラベル
    final labels = ['H 奉仕', 'L 論理', 'C 創造'];
    for (var i = 0; i < 3; i++) {
      final angle = (i * 2 * math.pi / 3) - math.pi / 2;
      final lx = cx + (r + 20) * math.cos(angle);
      final ly = cy + (r + 20) * math.sin(angle);
      final tp = TextPainter(
        text: TextSpan(
          text: labels[i],
          style: TextStyle(fontSize: 11, color: colors[i], fontWeight: FontWeight.w600),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(lx - tp.width / 2, ly - tp.height / 2));
    }
  }

  @override
  bool shouldRepaint(_HlcRadarPainter old) => score != old.score;
}

class _StatChip extends StatelessWidget {
  final String label;
  final int value;
  final Color color;
  const _StatChip(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600)),
        Text('$value', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: color)),
      ],
    );
  }
}

class _PrepIndicator extends StatelessWidget {
  final String label;
  final double value;
  final IconData icon;
  const _PrepIndicator(this.label, this.value, this.icon);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: const Color(0xFF2C3E50).withOpacity(0.4)),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(fontSize: 12, color: const Color(0xFF2C3E50).withOpacity(0.6))),
              const SizedBox(height: 2),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: value,
                  minHeight: 6,
                  backgroundColor: const Color(0xFFF0F0F0),
                  valueColor: AlwaysStoppedAnimation(
                    Color.lerp(const Color(0xFFFF9999), const Color(0xFF4CAF50), value)!,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '${(value * 100).toInt()}%',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: const Color(0xFF2C3E50).withOpacity(0.5)),
        ),
      ],
    );
  }
}
