import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'screens/splash_screen.dart';
import 'services/fcm_service.dart';
import 'services/batch_processor.dart';
import 'services/time_guard.dart';
import 'theme/ma_colors.dart';
import 'widgets/hyokkori_frame.dart';

/// グローバルNavigatorKey — ひょっこりフレームの最優先オーバーレイ用
final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  // Firebase初期化（firebase_options.dart が生成されたら有効化）
  // await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await FcmService.initialize();
  await TimeGuard.initialize();
  BatchProcessor.runStartupBatch();

  // 親からの承認 → 全画面を貫通してひょっこりフレーム表示
  FcmService.onParentApproval = () {
    final context = rootNavigatorKey.currentContext;
    if (context != null) {
      showHyokkoriFrame(context, parentName: 'ママ');
    }
  };

  runApp(const ProviderScope(child: MaLogicApp()));
}

class MaLogicApp extends StatelessWidget {
  const MaLogicApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: rootNavigatorKey,
      title: 'MA-LOGIC',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: MaColors.hiyokoYellow,
          brightness: Brightness.light,
        ),
        fontFamily: 'Hiragino Sans',
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: MaColors.lionGold,
          brightness: Brightness.dark,
        ),
        fontFamily: 'Hiragino Sans',
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}
