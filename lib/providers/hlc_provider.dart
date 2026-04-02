import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/hlc_score.dart';
import '../services/thought_database.dart';

/// HLCスコアの状態管理 — 全画面で共有・更新
final hlcScoreProvider = StateNotifierProvider<HlcScoreNotifier, HlcScore>((ref) {
  return HlcScoreNotifier();
});

class HlcScoreNotifier extends StateNotifier<HlcScore> {
  HlcScoreNotifier() : super(const HlcScore()) {
    _loadFromDb();
  }

  Future<void> _loadFromDb() async {
    state = await ThoughtDatabase.getLatestScore();
  }

  /// お手伝い完了時：奉仕(H)スコア加算
  Future<void> completeHelp({int points = 10}) async {
    state = state.add(h: points);
    await ThoughtDatabase.saveScore(state);
  }

  /// 思考記録時：論理(L)スコア加算
  Future<void> recordThought({int points = 5}) async {
    state = state.add(l: points);
    await ThoughtDatabase.saveScore(state);
  }

  /// 創造的活動時：創造(C)スコア加算
  Future<void> createSomething({int points = 8}) async {
    state = state.add(c: points);
    await ThoughtDatabase.saveScore(state);
  }

  /// 親からの承認時：全スコアにボーナス
  Future<void> parentApproval({int bonus = 5}) async {
    state = state.add(h: bonus, l: bonus, c: bonus);
    await ThoughtDatabase.saveScore(state);
  }

  /// ガチャ報酬
  Future<void> gachaReward({required int h, required int l, required int c}) async {
    state = state.add(h: h, l: l, c: c);
    await ThoughtDatabase.saveScore(state);
  }
}

/// 現在のプレイヤーレベル（derived）
final playerLevelProvider = Provider<PlayerLevel>((ref) {
  return ref.watch(hlcScoreProvider).level;
});

/// レベルアップ検知
final levelUpEventProvider = Provider<bool>((ref) {
  final prev = ref.watch(hlcScoreProvider.notifier);
  // レベルアップはUI側でスコア変更前後を比較して検知
  return false;
});
