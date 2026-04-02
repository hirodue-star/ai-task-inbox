import 'package:flutter/material.dart';
import '../theme/ma_colors.dart';
import 'camera_screen.dart';

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
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))..forward();
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const CameraScreen()),
        );
      }
    });
  }

  @override
  void dispose() { _controller.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: ScaleTransition(
          scale: CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80, height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: MaColors.goldGradient,
                  boxShadow: [BoxShadow(color: MaColors.gold.withOpacity(0.4), blurRadius: 24)],
                ),
                child: const Center(
                  child: Text('MA', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Color(0xFF5C3D10))),
                ),
              ),
              const SizedBox(height: 12),
              Text('パシャ！', style: TextStyle(fontSize: 16, color: Colors.white.withOpacity(0.5), letterSpacing: 3)),
            ],
          ),
        ),
      ),
    );
  }
}
