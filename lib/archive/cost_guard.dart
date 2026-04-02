import 'package:shared_preferences/shared_preferences.dart';

/// コスト管理ガードレール — API課金を最小化
class CostGuard {
  static const _keyFirstLaunch = 'first_launch_date';
  static const _keyPostCount = 'total_post_count';
  static const _keySubscribed = 'is_subscribed';
  static const _keyLastBatchRun = 'last_batch_run';

  static const int freePostLimit = 10;
  static const int freeTrialDays = 7;

  /// 無料枠チェック
  static Future<FreeTierStatus> checkFreeTier() async {
    final prefs = await SharedPreferences.getInstance();

    // 初回起動日を記録
    final firstLaunchStr = prefs.getString(_keyFirstLaunch);
    final DateTime firstLaunch;
    if (firstLaunchStr == null) {
      firstLaunch = DateTime.now();
      await prefs.setString(_keyFirstLaunch, firstLaunch.toIso8601String());
    } else {
      firstLaunch = DateTime.parse(firstLaunchStr);
    }

    final isSubscribed = prefs.getBool(_keySubscribed) ?? false;
    if (isSubscribed) return FreeTierStatus.subscribed;

    final postCount = prefs.getInt(_keyPostCount) ?? 0;
    final daysSinceInstall = DateTime.now().difference(firstLaunch).inDays;

    if (daysSinceInstall <= freeTrialDays && postCount < freePostLimit) {
      return FreeTierStatus.freeTrial;
    }
    if (postCount < freePostLimit) {
      return FreeTierStatus.freePostsRemaining;
    }
    return FreeTierStatus.paywallRequired;
  }

  /// 投稿カウント加算
  static Future<int> incrementPostCount() async {
    final prefs = await SharedPreferences.getInstance();
    final count = (prefs.getInt(_keyPostCount) ?? 0) + 1;
    await prefs.setInt(_keyPostCount, count);
    return count;
  }

  /// 残り無料投稿数
  static Future<int> remainingFreePosts() async {
    final prefs = await SharedPreferences.getInstance();
    final count = prefs.getInt(_keyPostCount) ?? 0;
    return (freePostLimit - count).clamp(0, freePostLimit);
  }

  /// 無料トライアル残日数
  static Future<int> remainingTrialDays() async {
    final prefs = await SharedPreferences.getInstance();
    final firstLaunchStr = prefs.getString(_keyFirstLaunch);
    if (firstLaunchStr == null) return freeTrialDays;
    final firstLaunch = DateTime.parse(firstLaunchStr);
    final elapsed = DateTime.now().difference(firstLaunch).inDays;
    return (freeTrialDays - elapsed).clamp(0, freeTrialDays);
  }

  /// クラウドAPI呼び出し可否（記念日変換のみ許可）
  static Future<bool> canUseCloudApi() async {
    final status = await checkFreeTier();
    return status == FreeTierStatus.subscribed;
  }

  /// バッチ処理の実行可否（6時間に1回まで）
  static Future<bool> shouldRunBatch() async {
    final prefs = await SharedPreferences.getInstance();
    final lastRunStr = prefs.getString(_keyLastBatchRun);
    if (lastRunStr == null) return true;
    final lastRun = DateTime.parse(lastRunStr);
    return DateTime.now().difference(lastRun).inHours >= 6;
  }

  /// バッチ処理実行済みマーク
  static Future<void> markBatchRun() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyLastBatchRun, DateTime.now().toIso8601String());
  }

  /// サブスク購入（テスト用スタブ）
  static Future<void> subscribe() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keySubscribed, true);
  }
}

enum FreeTierStatus {
  freeTrial,           // 7日以内 & 10件以内
  freePostsRemaining,  // 7日超だが10件以内
  paywallRequired,     // 無料枠超過
  subscribed,          // 課金済み
}
