import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/bond_post.dart';
import '../services/bond_database.dart';
import 'world_provider.dart';
import 'hlc_provider.dart';

/// タイムラインフィード
final bondFeedProvider = StateNotifierProvider<BondFeedNotifier, List<BondPost>>((ref) {
  return BondFeedNotifier(ref);
});

class BondFeedNotifier extends StateNotifier<List<BondPost>> {
  final Ref _ref;

  BondFeedNotifier(this._ref) : super([]) {
    refresh();
  }

  Future<void> refresh() async {
    state = await BondDatabase.getFeed();
  }

  /// 日記 → 投稿として公開
  Future<void> publish(BondPost post) async {
    await BondDatabase.insert(post);
    _ref.read(worldStateProvider.notifier).performAction(restorePoints: 1.5);
    state = [post, ...state];
  }

  /// 親が承認 → ガチャ解放 + パーティクル演出トリガー
  Future<void> approve(String postId) async {
    await BondDatabase.approve(postId);
    _ref.read(worldStateProvider.notifier).parentApproval();
    _ref.read(hlcScoreProvider.notifier).parentApproval();
    state = state.map((p) {
      if (p.id == postId) {
        return p.copyWith(parentApproved: true, approvedAt: DateTime.now());
      }
      return p;
    }).toList();
  }

  /// いいね → パーティクル演出
  Future<void> like(String postId, String userId) async {
    await BondDatabase.like(postId, userId);
    state = state.map((p) {
      if (p.id == postId && !p.likedBy.contains(userId)) {
        return p.copyWith(
          likeCount: p.likeCount + 1,
          likedBy: [...p.likedBy, userId],
        );
      }
      return p;
    }).toList();
  }
}

/// デイリーミッション
final dailyMissionProvider = Provider<DailyMission>((ref) {
  return todaysMission();
});
