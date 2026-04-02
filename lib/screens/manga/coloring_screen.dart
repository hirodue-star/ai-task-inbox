import 'package:flutter/material.dart';
import '../../widgets/coloring_canvas.dart';

/// ぬりえモード — 巧緻性トレーニング
class ColoringScreen extends StatelessWidget {
  const ColoringScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenW = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F5F0),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.arrow_back_rounded, color: Color(0xFF1A1A1A)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'ぬりえモード',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Color(0xFF1A1A1A)),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      '巧緻性UP',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF2E7D32)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ColoringCanvas(
                  width: screenW - 32,
                  height: screenW - 32,
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
