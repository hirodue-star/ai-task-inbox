import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_level.dart';

/// ユーザーレベルプロバイダー
final userLevelProvider = StateNotifierProvider<UserLevelNotifier, UserLevel>((ref) {
  return UserLevelNotifier();
});

class UserLevelNotifier extends StateNotifier<UserLevel> {
  UserLevelNotifier() : super(const UserLevel(level: 1, totalXp: 0)) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = UserLevel(
      level: prefs.getInt('user_level') ?? 1,
      totalXp: prefs.getInt('user_xp') ?? 0,
    );
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('user_level', state.level);
    await prefs.setInt('user_xp', state.totalXp);
  }

  /// XP加算（レベルアップ判定含む）
  /// 戻り値: レベルアップしたかどうか
  Future<bool> addXp(int xp) async {
    final oldLevel = state.level;
    state = state.addXp(xp);
    await _save();
    return state.level > oldLevel;
  }

  /// 日記投稿 → +10xp
  Future<bool> onDiaryPost() => addXp(10);

  /// お手伝い完了 → +15xp
  Future<bool> onHelpComplete() => addXp(15);

  /// パズル正解 → +8xp
  Future<bool> onPuzzleCorrect() => addXp(8);

  /// マンダラセル完了 → +20xp
  Future<bool> onMandalaComplete() => addXp(20);

  /// 挑戦 → +25xp
  Future<bool> onChallenge() => addXp(25);
}
