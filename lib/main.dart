import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/splash_screen.dart';
import 'theme/ma_colors.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const MaLogicApp());
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
