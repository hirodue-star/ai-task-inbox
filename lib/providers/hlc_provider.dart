import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/hlc_score.dart';

/// MVP: 投稿数+いいね数のシンプルなスコア管理
final hlcScoreProvider = StateNotifierProvider<HlcScoreNotifier, HlcScore>((ref) {
  return HlcScoreNotifier();
});

class HlcScoreNotifier extends StateNotifier<HlcScore> {
  HlcScoreNotifier() : super(const HlcScore());

  void onPost() => state = state.addPost();
  void onLike() => state = state.addLike();
}
