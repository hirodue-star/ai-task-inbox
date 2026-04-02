import 'dart:math' as math;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 親のアンビエント状態 → 風速・星の数に変換
class AmbientState {
  final double windSpeed;   // 0.5 ~ 2.0（親の活動量）
  final int starCount;      // 20 ~ 60（親の思考密度）
  final double warmth;      // 0.0 ~ 1.0（親の承認の暖かさ）

  const AmbientState({
    this.windSpeed = 1.0,
    this.starCount = 30,
    this.warmth = 0.5,
  });

  AmbientState copyWith({double? windSpeed, int? starCount, double? warmth}) {
    return AmbientState(
      windSpeed: windSpeed ?? this.windSpeed,
      starCount: starCount ?? this.starCount,
      warmth: warmth ?? this.warmth,
    );
  }
}

final ambientProvider = StateNotifierProvider<AmbientNotifier, AmbientState>((ref) {
  return AmbientNotifier();
});

class AmbientNotifier extends StateNotifier<AmbientState> {
  AmbientNotifier() : super(const AmbientState()) {
    _startAmbientLoop();
  }

  /// アンビエント値を定期的にゆるやかに変動させる
  /// （Firebase接続時は親の実データに置換）
  void _startAmbientLoop() {
    _updateAmbient();
    Future.delayed(const Duration(seconds: 30), () {
      if (mounted) _startAmbientLoop();
    });
  }

  void _updateAmbient() {
    final now = DateTime.now();
    final rng = math.Random(now.minute * 60 + now.second);

    // 時間帯による基本風速
    final hour = now.hour;
    double baseWind;
    if (hour >= 6 && hour < 10) {
      baseWind = 0.8; // 朝：穏やか
    } else if (hour >= 10 && hour < 16) {
      baseWind = 1.2; // 昼：活発
    } else if (hour >= 16 && hour < 20) {
      baseWind = 1.0; // 夕：落ち着き
    } else {
      baseWind = 0.6; // 夜：静か
    }

    state = state.copyWith(
      windSpeed: baseWind + rng.nextDouble() * 0.4 - 0.2,
      starCount: 25 + rng.nextInt(20),
    );
  }

  /// 親の承認を受信 → 暖かさが一時的に上昇
  void receiveParentWarmth() {
    state = state.copyWith(warmth: 1.0);
    // 3分かけてゆっくり冷める
    _coolDown();
  }

  void _coolDown() {
    Future.delayed(const Duration(seconds: 10), () {
      if (!mounted) return;
      if (state.warmth > 0.5) {
        state = state.copyWith(warmth: state.warmth - 0.05);
        _coolDown();
      }
    });
  }
}
