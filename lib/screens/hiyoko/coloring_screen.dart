import 'package:flutter/material.dart';
import '../../widgets/coloring_canvas.dart';

/// ぬりえモード（子供向け: 巧緻性トレーニング）
class ColoringScreen extends StatelessWidget {
  const ColoringScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: const Color(0xFFFFFDF5),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.close_rounded, color: Color(0xFF5C3D10), size: 28),
                  ),
                  const Spacer(),
                  const Text('ぬりえ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF5C3D10))),
                  const Spacer(),
                  const SizedBox(width: 28),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: ColoringCanvas(width: w - 32, height: w - 32),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
