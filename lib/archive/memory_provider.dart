import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/memory_database.dart';

/// 挑戦数プロバイダー（黄金粒子の永続源）
final challengeCountProvider = FutureProvider<int>((ref) async {
  return MemoryDatabase.getChallengeCount();
});

/// 今日の記憶数
final todayMemoryCountProvider = FutureProvider<int>((ref) async {
  final memories = await MemoryDatabase.getToday();
  return memories.length;
});
