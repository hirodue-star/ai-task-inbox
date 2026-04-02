import 'package:flutter/material.dart';

/// MA-LOGIC カラーパレット — 全級共通
class MaColors {
  MaColors._();

  // ひよこ級 (Squishy & Pastel)
  static const hiyokoPink = Color(0xFFFFB5C5);
  static const hiyokoBlue = Color(0xFFB5D8FF);
  static const hiyokoGreen = Color(0xFFB5FFCA);
  static const hiyokoYellow = Color(0xFFFFECB5);
  static const hiyokoBg = Color(0xFFFFF8F0);
  static const hiyokoSkin = Color(0xFFFFE4B5);
  static const hiyokoCheek = Color(0xFFFFB0B0);

  // ペンギン級 (Ice & Crystalline)
  static const penguinIce = Color(0xFFD0EAFF);
  static const penguinDeep = Color(0xFF6BB5E8);
  static const penguinBg = Color(0xFFEAF4FC);

  // ライオン級 (Gold & Particles)
  static const lionGold = Color(0xFFFFD700);
  static const lionDeepGold = Color(0xFFC8960C);
  static const lionBronze = Color(0xFFCD7F32);
  static const lionBg = Color(0xFF0B0B2B);
  static const lionNavy = Color(0xFF101040);

  // 共通
  static const warmWhite = Color(0xFFFFFDF5);
  static const softShadow = Color(0x33000000);

  // ひよこ級ボタンカラーリスト
  static const hiyokoButtons = [hiyokoPink, hiyokoBlue, hiyokoGreen, hiyokoYellow];
  static const hiyokoButtonLabels = ['いろ', 'かたち', 'おてつだい', 'ぼうけん'];

  // ゴールドグラデーション
  static const goldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFF8DC), Color(0xFFFFD700), Color(0xFFC8960C), Color(0xFFFFD700)],
    stops: [0.0, 0.3, 0.7, 1.0],
  );

  static const goldShine = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xCCFFFFFF), Color(0x00FFFFFF), Color(0x33000000)],
    stops: [0.0, 0.5, 1.0],
  );
}
