import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/guardian_models.dart';
import '../../painters/adventure_map_painter.dart';
import '../../services/guardian_service.dart';
import '../../theme/ma_colors.dart';

/// 冒険地図画面 + 聖域管理 + SOS
class AdventureMapScreen extends ConsumerStatefulWidget {
  const AdventureMapScreen({super.key});

  @override
  ConsumerState<AdventureMapScreen> createState() => _AdventureMapScreenState();
}

class _AdventureMapScreenState extends ConsumerState<AdventureMapScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat();

    // デモデータ
    if (GuardianService.todayRoute.isEmpty) {
      _loadDemoData();
    }
  }

  void _loadDemoData() {
    // サンプル聖域
    GuardianService.addSanctuary(const Sanctuary(
      id: 'home', name: 'おうち', emoji: '🏠',
      latitude: 35.6812, longitude: 139.7671, type: SanctuaryType.home,
    ));
    GuardianService.addSanctuary(const Sanctuary(
      id: 'school', name: 'えん', emoji: '🏫',
      latitude: 35.6830, longitude: 139.7700, type: SanctuaryType.school,
    ));
    // サンプルルート
    for (var i = 0; i < 10; i++) {
      GuardianService.recordPoint(
        35.6812 + i * 0.0002,
        139.7671 + i * 0.0003,
        landmark: i == 5 ? '公園' : null,
      );
    }
    // サンプルチェックポイント
    GuardianService.addCheckpoint(const Checkpoint(
      id: 'cp1', name: 'さくらのき',
      latitude: 35.6820, longitude: 139.7685,
      rewardEmoji: '🌸', xpReward: 10,
    ));
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final route = GuardianService.todayRoute;
    final sanctuaries = GuardianService.sanctuaries;
    final checkpoints = GuardianService.checkpoints;

    return Scaffold(
      backgroundColor: const Color(0xFFF5E6C8),
      body: SafeArea(
        child: Column(
          children: [
            // ヘッダー
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.arrow_back_rounded, color: Color(0xFF5C3D10)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('ぼうけんちず', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF5C3D10))),
                        Text('きょうのあしあと', style: TextStyle(fontSize: 11, color: Color(0xFF8B7355))),
                      ],
                    ),
                  ),
                  // SOS
                  GestureDetector(
                    onLongPress: () => _triggerSos(),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF5252).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFFF5252).withOpacity(0.3)),
                      ),
                      child: const Icon(Icons.sos_rounded, color: Color(0xFFFF5252), size: 20),
                    ),
                  ),
                ],
              ),
            ),

            // 地図
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: AnimatedBuilder(
                  animation: _animController,
                  builder: (context, _) {
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: CustomPaint(
                        painter: AdventureMapPainter(
                          route: route,
                          sanctuaries: sanctuaries,
                          checkpoints: checkpoints,
                          animValue: _animController.value,
                        ),
                        size: Size.infinite,
                      ),
                    );
                  },
                ),
              ),
            ),

            // 統計 + 聖域リスト
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.8),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _Stat(label: 'あしあと', value: '${route.length}', emoji: '👣'),
                      _Stat(label: 'せいいき', value: '${sanctuaries.length}', emoji: '🛡️'),
                      _Stat(label: 'たからばこ',
                        value: '${checkpoints.where((c) => c.discovered).length}/${checkpoints.length}',
                        emoji: '🎁'),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // 聖域リスト
                  ...sanctuaries.map((s) => Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Row(
                      children: [
                        Text(s.emoji, style: const TextStyle(fontSize: 16)),
                        const SizedBox(width: 8),
                        Text(s.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF5C3D10))),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFF4CAF50).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(s.type.label,
                            style: TextStyle(fontSize: 10, color: const Color(0xFF4CAF50).withOpacity(0.7))),
                        ),
                      ],
                    ),
                  )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _triggerSos() {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFFFF5252),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.warning_rounded, size: 48, color: Colors.white),
              const SizedBox(height: 12),
              const Text('SOS送信', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white)),
              const SizedBox(height: 8),
              const Text('位置情報と音声を\n保護者に送信します',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.white70)),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.pop(ctx),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Center(child: Text('キャンセル', style: TextStyle(color: Colors.white))),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: GestureDetector(
                      onTap: () async {
                        await GuardianService.triggerSos(35.6812, 139.7671);
                        if (ctx.mounted) Navigator.pop(ctx);
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('SOS送信完了'), backgroundColor: Color(0xFFFF5252)),
                          );
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Center(
                          child: Text('送信する', style: TextStyle(color: Color(0xFFFF5252), fontWeight: FontWeight.w700)),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String label;
  final String value;
  final String emoji;
  const _Stat({required this.label, required this.value, required this.emoji});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 20)),
        Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF5C3D10))),
        Text(label, style: TextStyle(fontSize: 10, color: const Color(0xFF5C3D10).withOpacity(0.5))),
      ],
    );
  }
}
