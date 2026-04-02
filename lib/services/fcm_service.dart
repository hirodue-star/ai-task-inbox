import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

/// Firebase Cloud Messaging — 親端末からの承認を受信
class FcmService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static String? _token;

  /// 初期化：通知権限の要求とトークン取得
  static Future<void> initialize() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    debugPrint('FCM permission: ${settings.authorizationStatus}');

    _token = await _messaging.getToken();
    debugPrint('FCM token: $_token');

    // フォアグラウンドメッセージ
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // バックグラウンドから復帰時
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);
  }

  static String? get token => _token;

  /// フォアグラウンドでメッセージ受信
  static void _handleForegroundMessage(RemoteMessage message) {
    final data = message.data;
    final type = data['type'];

    switch (type) {
      case 'parent_approval':
        // 親からの承認 → ひょっこりフレーム + メダル獲得を発動
        _onParentApproval(
          helpId: data['help_id'] ?? '',
          parentName: data['parent_name'] ?? 'ママ',
          note: data['note'] ?? '',
        );
        break;
      case 'encouragement':
        // 応援メッセージ
        _onEncouragement(message: data['message'] ?? 'がんばってるね！');
        break;
    }
  }

  static void _handleMessageOpenedApp(RemoteMessage message) {
    _handleForegroundMessage(message);
  }

  // === コールバック ===
  // GlobalKeyを使ってNavigator経由でUI発火させる

  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  static VoidCallback? onParentApproval;
  static VoidCallback? onEncouragement;

  static void _onParentApproval({
    required String helpId,
    required String parentName,
    required String note,
  }) {
    debugPrint('Parent approval received: $helpId from $parentName');
    onParentApproval?.call();
  }

  static void _onEncouragement({required String message}) {
    debugPrint('Encouragement: $message');
    onEncouragement?.call();
  }

  /// 親端末へ承認リクエストを送信（Firestore経由）
  static Future<void> sendApprovalRequest({
    required String childId,
    required String helpId,
    required String helpCategory,
  }) async {
    // Firestoreに承認リクエストを書き込み
    // Cloud Functionsで親端末へFCM送信
    debugPrint('Approval request sent: $helpId for $childId');
  }
}
