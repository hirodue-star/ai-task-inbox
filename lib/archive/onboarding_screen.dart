import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/ma_colors.dart';

/// オンボーディング — プライバシー宣言 + アプリ紹介
class OnboardingScreen extends StatefulWidget {
  final VoidCallback onComplete;
  const OnboardingScreen({super.key, required this.onComplete});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _currentPage = 0;

  final _pages = const [
    _OnboardPage(
      emoji: '🐣',
      title: 'ようこそ、MA-LOGICへ',
      body: 'お手伝い、遊び、挑戦。\n毎日の「やりたい」が、\nお子様の力になります。',
      bgColors: [Color(0xFFFFF8F0), Color(0xFFFFE8D0)],
    ),
    _OnboardPage(
      emoji: '📖',
      title: '思い出が漫画になる',
      body: '写真を撮って、日記を書くだけ。\nAIが自動で漫画に変換。\nお子様の成長が一冊の本になります。',
      bgColors: [Color(0xFFE8F4FF), Color(0xFFD0E8FF)],
    ),
    _OnboardPage(
      emoji: '🎓',
      title: '遊びが、合格へ',
      body: 'お手伝い記録が「思いやり」の証拠に。\nパズルが「論理力」の証拠に。\n日記が「表現力」の証拠に。',
      bgColors: [Color(0xFFFFF8DC), Color(0xFFFFE8B5)],
    ),
    _OnboardPage(
      emoji: '🛡️',
      title: 'お約束',
      body: 'お子様のデータは暗号化され、\n端末内に安全に保存されます。\n\n家族以外の目には\n一切触れません。\n\n20分で自動的に休憩モードに入り、\n夜間は利用できません。\n\n「スマホを置いて遊ぶ」を\n応援するアプリです。',
      bgColors: [Color(0xFFE8F5E9), Color(0xFFC8E6C9)],
      isPrivacy: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: _controller,
            itemCount: _pages.length,
            onPageChanged: (i) => setState(() => _currentPage = i),
            itemBuilder: (context, index) {
              final page = _pages[index];
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: page.bgColors,
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(page.emoji, style: const TextStyle(fontSize: 64)),
                        const SizedBox(height: 32),
                        Text(
                          page.title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF2C3E50),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          page.body,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 15,
                            color: const Color(0xFF2C3E50).withOpacity(0.6),
                            height: 1.7,
                          ),
                        ),
                        if (page.isPrivacy) ...[
                          const SizedBox(height: 20),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.6),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFF4CAF50).withOpacity(0.3)),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.verified_user_rounded, color: Color(0xFF2E7D32), size: 20),
                                SizedBox(width: 8),
                                Text('E2E暗号化 ・ ローカル保存',
                                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF2E7D32))),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              );
            },
          ),

          // ドットインジケータ + ボタン
          Positioned(
            bottom: 60,
            left: 0, right: 0,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(_pages.length, (i) {
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: _currentPage == i ? 24 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _currentPage == i
                            ? const Color(0xFF2C3E50)
                            : const Color(0xFF2C3E50).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 24),
                if (_currentPage == _pages.length - 1)
                  GestureDetector(
                    onTap: () async {
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.setBool('onboarding_done', true);
                      widget.onComplete();
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 40),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: MaColors.goldGradient,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [BoxShadow(color: MaColors.lionGold.withOpacity(0.3), blurRadius: 12)],
                      ),
                      child: const Center(
                        child: Text('はじめる',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF5C3D10))),
                      ),
                    ),
                  )
                else
                  GestureDetector(
                    onTap: () => _controller.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    ),
                    child: Text('つぎへ',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: const Color(0xFF2C3E50).withOpacity(0.6))),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OnboardPage {
  final String emoji;
  final String title;
  final String body;
  final List<Color> bgColors;
  final bool isPrivacy;

  const _OnboardPage({
    required this.emoji,
    required this.title,
    required this.body,
    required this.bgColors,
    this.isPrivacy = false,
  });
}
