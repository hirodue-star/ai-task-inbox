import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_level.dart';
import '../providers/level_provider.dart';
import '../theme/ma_colors.dart';
import '../screens/bond/bond_feed_screen.dart';
import '../screens/manga/comic_album_screen.dart';
import '../screens/manga/coloring_screen.dart';
import '../screens/parent/parent_dashboard.dart';
import '../screens/collection_book_screen.dart';
import '../screens/parent/parental_control.dart';
import '../screens/echo/welcome_back_screen.dart';
import '../screens/echo/daily_theater_screen.dart';
import '../screens/teacher/teacher_interface.dart';
import '../screens/guardian/adventure_map_screen.dart';

/// スワイプで開くサイドメニュー — レベルに応じて項目変化
class AdaptiveDrawer extends ConsumerWidget {
  const AdaptiveDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userLevel = ref.watch(userLevelProvider);

    return Drawer(
      backgroundColor: Colors.white.withOpacity(0.97),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(right: Radius.circular(24)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // レベル表示
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: _tierGradient(userLevel.tier),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          _tierEmoji(userLevel.tier),
                          style: const TextStyle(fontSize: 24),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Lv.${userLevel.level}',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            color: _tierTextColor(userLevel.tier),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // XPバー
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: userLevel.progress,
                        minHeight: 6,
                        backgroundColor: Colors.white.withOpacity(0.3),
                        valueColor: AlwaysStoppedAnimation(
                          _tierTextColor(userLevel.tier).withOpacity(0.7),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${userLevel.totalXp} / ${userLevel.xpForNext} XP',
                      style: TextStyle(
                        fontSize: 10,
                        color: _tierTextColor(userLevel.tier).withOpacity(0.5),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // メニュー項目（レベルに応じて表示制御）
              _NavItem(
                icon: Icons.people_rounded,
                label: 'BOND-LOG',
                subtitle: '家族のタイムライン',
                onTap: () => _navigate(context, const BondFeedScreen()),
              ),
              _NavItem(
                icon: Icons.menu_book_rounded,
                label: 'マンガ・アルバム',
                subtitle: '思い出の連載',
                onTap: () => _navigate(context, const ComicAlbumScreen()),
              ),
              _NavItem(
                icon: Icons.brush_rounded,
                label: 'ぬりえ',
                subtitle: '巧緻性トレーニング',
                onTap: () => _navigate(context, const ColoringScreen()),
              ),

              _NavItem(
                icon: Icons.map_rounded,
                label: 'ぼうけんちず',
                subtitle: '冒険地図 & 見守り',
                onTap: () => _navigate(context, const AdventureMapScreen()),
              ),
              _NavItem(
                icon: Icons.nightlight_round,
                label: 'きょうの連載',
                subtitle: '1日のふりかえりシアター',
                onTap: () => _navigate(context, const DailyTheaterScreen()),
              ),

              if (userLevel.level >= 3) ...[
                const Divider(height: 32),
                _NavItem(
                  icon: Icons.auto_stories_rounded,
                  label: 'コレクション',
                  subtitle: '感性のアーカイブ',
                  onTap: () => _navigate(context, const CollectionBookScreen()),
                ),
              ],

              if (userLevel.level >= 5) ...[
                _NavItem(
                  icon: Icons.bar_chart_rounded,
                  label: '成長ダッシュボード',
                  subtitle: '親用レポート',
                  badge: 'PRO',
                  onTap: () => _navigate(context, const ParentDashboard()),
                ),
              ],

              const Divider(height: 24),

              // 保育士・親ツール
              _NavItem(
                icon: Icons.school_rounded,
                label: 'Teacher Palette',
                subtitle: '保育士用クイックスタンプ',
                badge: 'NEW',
                onTap: () => _navigate(context, const TeacherInterface()),
              ),
              _NavItem(
                icon: Icons.shield_rounded,
                label: 'ペアレンタル・コントロール',
                subtitle: '利用制限・プリント・安全設定',
                onTap: () => _navigate(context, const ParentalControlScreen()),
              ),

              const Spacer(),

              // ティア情報
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F8F8),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline_rounded, size: 16, color: const Color(0xFF2C3E50).withOpacity(0.3)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _tierDesc(userLevel.tier),
                        style: TextStyle(fontSize: 11, color: const Color(0xFF2C3E50).withOpacity(0.4)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigate(BuildContext context, Widget screen) {
    Navigator.pop(context); // ドロワーを閉じる
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  LinearGradient _tierGradient(UiTier tier) {
    switch (tier) {
      case UiTier.intuitive:
        return LinearGradient(colors: [MaColors.hiyokoPink.withOpacity(0.2), MaColors.hiyokoBlue.withOpacity(0.2)]);
      case UiTier.analytical:
        return LinearGradient(colors: [MaColors.penguinIce.withOpacity(0.3), MaColors.penguinDeep.withOpacity(0.15)]);
      case UiTier.abstract:
        return const LinearGradient(colors: [Color(0xFFFFF8DC), Color(0xFFFFE8B5)]);
    }
  }

  Color _tierTextColor(UiTier tier) {
    switch (tier) {
      case UiTier.intuitive: return const Color(0xFF5C3D10);
      case UiTier.analytical: return MaColors.penguinDeep;
      case UiTier.abstract: return const Color(0xFF5C3D10);
    }
  }

  String _tierEmoji(UiTier tier) {
    switch (tier) {
      case UiTier.intuitive: return '🐣';
      case UiTier.analytical: return '🐧';
      case UiTier.abstract: return '🦁';
    }
  }

  String _tierDesc(UiTier tier) {
    switch (tier) {
      case UiTier.intuitive: return 'Lv.4で比較・論理UIが解放されます';
      case UiTier.analytical: return 'Lv.8で抽象思考UIが解放されます';
      case UiTier.abstract: return 'マスターレベルに到達しました';
    }
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final String? badge;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.subtitle,
    this.badge,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
        child: Row(
          children: [
            Icon(icon, size: 22, color: const Color(0xFF2C3E50).withOpacity(0.5)),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF2C3E50))),
                  Text(subtitle, style: TextStyle(fontSize: 11, color: const Color(0xFF2C3E50).withOpacity(0.4))),
                ],
              ),
            ),
            if (badge != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  gradient: MaColors.goldGradient,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(badge!, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: Color(0xFF5C3D10))),
              ),
            Icon(Icons.chevron_right_rounded, size: 18, color: const Color(0xFF2C3E50).withOpacity(0.2)),
          ],
        ),
      ),
    );
  }
}
