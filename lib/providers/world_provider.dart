import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/world_state.dart';

/// 世界状態のグローバルプロバイダー
final worldStateProvider = StateNotifierProvider<WorldStateNotifier, WorldState>((ref) {
  return WorldStateNotifier();
});

class WorldStateNotifier extends StateNotifier<WorldState> {
  WorldStateNotifier() : super(WorldState(lastActionAt: DateTime.now())) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString('world_state');
    if (json != null) {
      state = WorldState.fromJson(jsonDecode(json) as Map<String, dynamic>);
    }
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('world_state', jsonEncode(state.toJson()));
  }

  /// アクション実行 → 世界復元率UP
  Future<void> performAction({double restorePoints = 1.5}) async {
    state = state.copyWith(
      restorePercent: (state.restorePercent + restorePoints).clamp(0.0, 100.0),
      totalActions: state.totalActions + 1,
      lastActionAt: DateTime.now(),
    );
    await _save();
  }

  /// 親の承認（雫）→ マンダラスロット解放
  Future<void> parentApproval() async {
    final newSlots = (state.mandalaSlotsUnlocked + 1).clamp(0, 9);
    state = state.copyWith(
      mandalaSlotsUnlocked: newSlots,
      restorePercent: (state.restorePercent + 5.0).clamp(0.0, 100.0),
      totalActions: state.totalActions + 1,
      lastActionAt: DateTime.now(),
    );
    await _save();
  }

  /// マンダラセル完了
  Future<void> completeMandalaCell(int cellIndex) async {
    if (cellIndex < 0 || cellIndex >= 9) return;
    if (cellIndex >= state.mandalaSlotsUnlocked) return; // 未解放
    final completed = List<bool>.from(state.mandalaCompleted);
    completed[cellIndex] = true;
    state = state.copyWith(
      mandalaCompleted: completed,
      restorePercent: (state.restorePercent + 3.0).clamp(0.0, 100.0),
      totalActions: state.totalActions + 1,
      lastActionAt: DateTime.now(),
    );
    await _save();
  }

  /// 写真撮影
  Future<void> takePhoto() async {
    await performAction(restorePoints: 2.0);
  }
}
