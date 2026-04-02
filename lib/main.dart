import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'screens/splash_screen.dart';
import 'theme/ma_colors.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  // Firebase初期化（firebase_options.dart が生成されたら有効化）
  // await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // await FcmService.initialize();

  runApp(const ProviderScope(child: MaLogicApp()));
}

class MaLogicApp extends StatelessWidget {
  const MaLogicApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
