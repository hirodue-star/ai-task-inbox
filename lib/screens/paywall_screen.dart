import 'package:flutter/material.dart';
import '../services/cost_guard.dart';
import '../theme/ma_colors.dart';

/// ペイウォール — 資産が溜まり手放せなくなった瞬間に表示
class PaywallScreen extends StatefulWidget {
  final VoidCallback onSubscribed;
  final VoidCallback onDismiss;

  const PaywallScreen({super.key, required this.onSubscribed, required this.onDismiss});

  @override
  State<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends State<PaywallScreen> {
  int _remainingPosts = 0;
  int _remainingDays = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final posts = await CostGuard.remainingFreePosts();
    final days = await CostGuard.remainingTrialDays();
    setState(() {
      _remainingPosts = posts;
      _remainingDays = days;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFDF5),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              const Spacer(),

              // ロゴ
              Container(
                width: 80, height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: MaColors.goldGradient,
                  boxShadow: [BoxShadow(color: MaColors.lionGold.withOpacity(0.3), blurRadius: 20)],
                ),
                child: const Center(
                  child: Text('MA', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Color(0xFF5C3D10))),
                ),
              ),
              const SizedBox(height: 24),

              const Text(
                'お子様の成長記録を\nずっと守り続けるために',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF2C3E50),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                '無料期間が終了しました',
                style: TextStyle(fontSize: 14, color: const Color(0xFF2C3E50).withOpacity(0.5)),
              ),

              const SizedBox(height: 32),

              // プラン
              _PlanCard(
                title: 'ファミリープラン',
                price: '¥480 / 月',
                features: const [
                  '無制限の思い出記録',
                  'AI強み分析レポート',
                  'デジタル漫画本の自動生成',
                  'データバックアップ＆エクスポート',
                  '記念日AI変換（月3回）',
                ],
                isRecommended: true,
                onTap: () async {
                  await CostGuard.subscribe();
                  widget.onSubscribed();
                },
              ),
              const SizedBox(height: 12),
              _PlanCard(
                title: '年間プラン',
                price: '¥3,980 / 年',
                features: const [
                  'ファミリープランの全機能',
                  '年間で2ヶ月分おトク',
                  '成長アニュアルレポート',
                ],
                badge: '30% OFF',
                onTap: () async {
                  await CostGuard.subscribe();
                  widget.onSubscribed();
                },
              ),

              const Spacer(),

              // スキップ（閲覧のみ）
              GestureDetector(
                onTap: widget.onDismiss,
                child: Text(
                  '過去の記録を見るだけ（新規投稿不可）',
                  style: TextStyle(
                    fontSize: 12,
                    color: const Color(0xFF2C3E50).withOpacity(0.3),
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'いつでもキャンセル可能 · データは永久保存',
                style: TextStyle(fontSize: 10, color: const Color(0xFF2C3E50).withOpacity(0.2)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  final String title;
  final String price;
  final List<String> features;
  final bool isRecommended;
  final String? badge;
  final VoidCallback onTap;

  const _PlanCard({
    required this.title,
    required this.price,
    required this.features,
    this.isRecommended = false,
    this.badge,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isRecommended ? null : Colors.white,
          gradient: isRecommended ? MaColors.goldGradient : null,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isRecommended ? MaColors.lionDeepGold : const Color(0xFFEEEEEE),
            width: isRecommended ? 2 : 1,
          ),
          boxShadow: isRecommended
              ? [BoxShadow(color: MaColors.lionGold.withOpacity(0.2), blurRadius: 12)]
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: isRecommended ? const Color(0xFF5C3D10) : const Color(0xFF2C3E50),
                  ),
                ),
                if (isRecommended) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFF5C3D10).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text('おすすめ', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFF5C3D10))),
                  ),
                ],
                if (badge != null) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF6B6B),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(badge!, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white)),
                  ),
                ],
                const Spacer(),
                Text(
                  price,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: isRecommended ? const Color(0xFF5C3D10) : const Color(0xFF2C3E50),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ...features.map((f) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  Icon(Icons.check_rounded, size: 14,
                    color: isRecommended ? const Color(0xFF5C3D10) : const Color(0xFF4CAF50)),
                  const SizedBox(width: 6),
                  Text(f, style: TextStyle(
                    fontSize: 12,
                    color: (isRecommended ? const Color(0xFF5C3D10) : const Color(0xFF2C3E50)).withOpacity(0.7),
                  )),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }
}
