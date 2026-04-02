/// HLCスコア（MVP: 投稿数 + いいね数ベースの簡易計算）
class HlcScore {
  final int postCount;
  final int likeCount;

  const HlcScore({this.postCount = 0, this.likeCount = 0});

  int get hospitality => likeCount * 3;       // 親の「いいね」が思いやりの指標
  int get logic => postCount;                  // 投稿の継続性が論理性の指標
  int get creativity => postCount + likeCount; // 総活動量が創造性の指標

  HlcScore addPost() => HlcScore(postCount: postCount + 1, likeCount: likeCount);
  HlcScore addLike() => HlcScore(postCount: postCount, likeCount: likeCount + 1);
}
