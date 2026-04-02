import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../models/echo_event.dart';
import '../../theme/ma_colors.dart';

/// 保育士専用簡易UI — クイックスタンプパレット
/// 文章入力なしで非認知能力をワンタップ評価
class TeacherInterface extends StatefulWidget {
  const TeacherInterface({super.key});

  @override
  State<TeacherInterface> createState() => _TeacherInterfaceState();
}

class _TeacherInterfaceState extends State<TeacherInterface> {
  final _sentStamps = <TeacherStamp>[];

  void _sendStamp(NonCogSkill skill) {
    final stamp = TeacherStamp(
      id: const Uuid().v4(),
      childId: 'child_1', // TODO: 園児選択
      teacherName: 'せんせい',
      timestamp: DateTime.now(),
      skill: skill,
    );

    setState(() => _sentStamps.insert(0, stamp));

    // TODO: Firebase経由で家庭に送信
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${skill.emoji} ${skill.label}スタンプを送信しました'),
        backgroundColor: const Color(0xFF4CAF50),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F0),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
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
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                      child: const Icon(Icons.arrow_back_rounded, color: Color(0xFF2C3E50)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Teacher Palette', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF2C3E50))),
                        Text('ワンタップで非認知能力を評価', style: TextStyle(fontSize: 11, color: Color(0xFF8B8B8B))),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text('LITE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFF2E7D32))),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // セキュリティバナー
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F8FF),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF42A5F5).withOpacity(0.2)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.verified_user_rounded, size: 16, color: const Color(0xFF42A5F5).withOpacity(0.7)),
                    const SizedBox(width: 8),
                    Text('匿名化通信 ・ 園ポリシー準拠',
                      style: TextStyle(fontSize: 11, color: const Color(0xFF42A5F5).withOpacity(0.7))),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // スタンプパレット
              const Text('スタンプを選んでタップ',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF2C3E50))),
              const SizedBox(height: 12),

              GridView.count(
                crossAxisCount: 3,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                children: NonCogSkill.values.map((skill) {
                  return GestureDetector(
                    onTap: () => _sendStamp(skill),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(skill.emoji, style: const TextStyle(fontSize: 32)),
                          const SizedBox(height: 4),
                          Text(skill.label,
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF2C3E50))),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 20),

              // 送信履歴
              const Text('送信済み',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF2C3E50))),
              const SizedBox(height: 8),

              Expanded(
                child: _sentStamps.isEmpty
                    ? Center(
                        child: Text('スタンプをタップして送信',
                          style: TextStyle(fontSize: 13, color: const Color(0xFF2C3E50).withOpacity(0.3))),
                      )
                    : ListView.builder(
                        itemCount: _sentStamps.length,
                        itemBuilder: (context, i) {
                          final s = _sentStamps[i];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 6),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Text(s.skill.emoji, style: const TextStyle(fontSize: 20)),
                                const SizedBox(width: 10),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(s.skill.label,
                                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF2C3E50))),
                                    Text('「${s.skill.comicMessage}」',
                                      style: TextStyle(fontSize: 10, color: const Color(0xFF2C3E50).withOpacity(0.4))),
                                  ],
                                ),
                                const Spacer(),
                                Icon(Icons.check_circle_rounded, size: 16, color: const Color(0xFF4CAF50).withOpacity(0.5)),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
