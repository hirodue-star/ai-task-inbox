import 'package:flutter/material.dart';
import '../theme/ma_colors.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500))..forward();
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      }
    });
  }

  @override
  void dispose() { _controller.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MaColors.warmWhite,
      body: Center(
        child: ScaleTransition(
          scale: CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 100, height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: MaColors.goldGradient,
                  boxShadow: [BoxShadow(color: MaColors.gold.withOpacity(0.3), blurRadius: 24)],
                ),
                child: const Center(
                  child: Text('MA', style: TextStyle(fontSize: 36, fontWeight: FontWeight.w900, color: Color(0xFF5C3D10))),
                ),
              ),
              const SizedBox(height: 16),
              const Text('MA-LOGIC', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: Color(0xFF5C3D10), letterSpacing: 4)),
            ],
          ),
        ),
      ),
    );
  }
}
