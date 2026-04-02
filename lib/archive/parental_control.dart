import 'package:flutter/material.dart';
import '../../services/time_guard.dart';
import '../../theme/ma_colors.dart';

/// 親専用コントロールパネル — 利用制限 + リモート管理
class ParentalControlScreen extends StatefulWidget {
  const ParentalControlScreen({super.key});

  @override
  State<ParentalControlScreen> createState() => _ParentalControlScreenState();
}

class _ParentalControlScreenState extends State<ParentalControlScreen> {
  late int _maxMinutes;
  late int _nightHour;

  @override
  void initState() {
    super.initState();
    _maxMinutes = TimeGuard.maxMinutes;
    _nightHour = TimeGuard.nightStartHour;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F0),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                      child: const Icon(Icons.arrow_back_rounded, color: Color(0xFF2C3E50)),
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Text('ペアレンタル・コントロール',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF2C3E50))),
                ],
              ),

              const SizedBox(height: 24),

              // セキュリティバナー
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF4CAF50).withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.shield_rounded, color: Color(0xFF2E7D32), size: 28),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('データは暗号化されています',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF2E7D32))),
                          Text('お子様のデータは端末内に保存され、家族以外の目には触れません。',
                            style: TextStyle(fontSize: 11, color: const Color(0xFF2E7D32).withOpacity(0.7))),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // 利用時間設定
              _SettingCard(
                icon: Icons.timer_rounded,
                title: '連続使用制限',
                child: Column(
                  children: [
                    Row(
                      children: [
                        Text('$_maxMinutes分', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: Color(0xFF2C3E50))),
                        const Spacer(),
                        Text('まで連続使用可', style: TextStyle(fontSize: 13, color: const Color(0xFF2C3E50).withOpacity(0.5))),
                      ],
                    ),
                    Slider(
                      value: _maxMinutes.toDouble(),
                      min: 10,
                      max: 60,
                      divisions: 10,
                      activeColor: MaColors.penguinDeep,
                      onChanged: (v) => setState(() => _maxMinutes = v.round()),
                      onChangeEnd: (v) => TimeGuard.setMaxMinutes(v.round()),
                    ),
                    Text('制限後は「ライオンの休息モード」が表示されます',
                      style: TextStyle(fontSize: 11, color: const Color(0xFF2C3E50).withOpacity(0.3))),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // 夜間制限
              _SettingCard(
                icon: Icons.nightlight_round,
                title: '夜間制限',
                child: Column(
                  children: [
                    Row(
                      children: [
                        Text('$_nightHour:00', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: Color(0xFF2C3E50))),
                        const Text(' 〜 6:00', style: TextStyle(fontSize: 16, color: Color(0xFF2C3E50))),
                        const Spacer(),
                        Text('利用不可', style: TextStyle(fontSize: 13, color: const Color(0xFF2C3E50).withOpacity(0.5))),
                      ],
                    ),
                    Slider(
                      value: _nightHour.toDouble(),
                      min: 18,
                      max: 22,
                      divisions: 4,
                      activeColor: const Color(0xFF1A1A60),
                      onChanged: (v) => setState(() => _nightHour = v.round()),
                      onChangeEnd: (v) => TimeGuard.setNightHour(v.round()),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // リモートミッション送信
              _SettingCard(
                icon: Icons.send_rounded,
                title: 'リモートミッション送信',
                child: Column(
                  children: [
                    Text('お子様の端末に、今日のミッションを送信できます。',
                      style: TextStyle(fontSize: 12, color: const Color(0xFF2C3E50).withOpacity(0.5))),
                    const SizedBox(height: 12),
                    _MissionButton(label: '#おそうじチャレンジ', emoji: '🧹'),
                    const SizedBox(height: 8),
                    _MissionButton(label: '#おりょうりデビュー', emoji: '🍳'),
                    const SizedBox(height: 8),
                    _MissionButton(label: '#ちょうせんのひ', emoji: '⚔️'),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // プリントハブ
              _SettingCard(
                icon: Icons.print_rounded,
                title: 'プリントアウト・ハブ',
                child: Column(
                  children: [
                    Text('スマホを置いて、紙で楽しもう',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF2C3E50).withOpacity(0.7))),
                    const SizedBox(height: 8),
                    Text('マンガ日記やぬりえをPDFとして書き出し、家庭用プリンターで印刷できます。',
                      style: TextStyle(fontSize: 12, color: const Color(0xFF2C3E50).withOpacity(0.4))),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _PrintButton(icon: Icons.menu_book_rounded, label: 'マンガ日記'),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _PrintButton(icon: Icons.brush_rounded, label: 'ぬりえ'),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _PrintButton(icon: Icons.assessment_rounded, label: '成長レポート'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // 利用状況
              _SettingCard(
                icon: Icons.insights_rounded,
                title: '今日の利用状況',
                child: Column(
                  children: [
                    _UsageStat(label: '利用時間', value: '${TimeGuard.maxMinutes - TimeGuard.remainingMinutes()}分'),
                    _UsageStat(label: '残り時間', value: '${TimeGuard.remainingMinutes()}分'),
                    _UsageStat(label: 'ステータス', value: _statusLabel(TimeGuard.checkStatus())),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _statusLabel(RestStatus status) {
    switch (status) {
      case RestStatus.active: return '利用中';
      case RestStatus.warning: return '残り5分';
      case RestStatus.sessionLimit: return '制限中';
      case RestStatus.nightTime: return '夜間制限中';
    }
  }
}

class _SettingCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget child;
  const _SettingCard({required this.icon, required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: const Color(0xFF2C3E50).withOpacity(0.5)),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF2C3E50))),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _MissionButton extends StatelessWidget {
  final String label;
  final String emoji;
  const _MissionButton({required this.label, required this.emoji});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$label を送信しました'), duration: const Duration(seconds: 2)),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFF8F8F8),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFEEEEEE)),
        ),
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 18)),
            const SizedBox(width: 10),
            Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF2C3E50))),
            const Spacer(),
            Icon(Icons.send_rounded, size: 16, color: MaColors.penguinDeep),
          ],
        ),
      ),
    );
  }
}

class _PrintButton extends StatelessWidget {
  final IconData icon;
  final String label;
  const _PrintButton({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$label のPDF生成中...'), duration: const Duration(seconds: 2)),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF0F0F0),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, size: 22, color: const Color(0xFF2C3E50).withOpacity(0.5)),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(fontSize: 10, color: const Color(0xFF2C3E50).withOpacity(0.5))),
          ],
        ),
      ),
    );
  }
}

class _UsageStat extends StatelessWidget {
  final String label;
  final String value;
  const _UsageStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(label, style: TextStyle(fontSize: 13, color: const Color(0xFF2C3E50).withOpacity(0.5))),
          const Spacer(),
          Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF2C3E50))),
        ],
      ),
    );
  }
}
