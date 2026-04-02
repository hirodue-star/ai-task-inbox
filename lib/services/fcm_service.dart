import 'package:flutter/material.dart';

/// Firebase Cloud Messaging — 親端末からの承認を受信
/// Firebase設定完了後に実装を有効化
class FcmService {
  static String? _token;

  /// 初期化（Firebase設定後に有効化）
  static Future<void> initialize() async {
    // TODO: Firebase設定後に以下を有効化
    // final settings = await FirebaseMessaging.instance.requestPermission();
    // _token = await FirebaseMessaging.instance.getToken();
    // FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    debugPrint('FCM: stub mode (Firebase未設定)');
  }

  static String? get token => _token;

  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  static VoidCallback? onParentApproval;
  static VoidCallback? onEncouragement;

  /// テスト用：承認をシミュレート
  static void simulateParentApproval({
    String parentName = 'ママ',
    String note = 'がんばったね！',
  }) {
    debugPrint('FCM simulate: parent approval from $parentName');
    onParentApproval?.call();
  }

  /// 親端末へ承認リクエストを送信
  static Future<void> sendApprovalRequest({
    required String childId,
    required String helpId,
    required String helpCategory,
  }) async {
    debugPrint('Approval request sent: $helpId for $childId');
  }
}
