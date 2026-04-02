import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/guardian_models.dart';

/// ガーディアン・ルート — 位置情報＆安全サービス
/// 注: 実際のGPS使用にはgeolocatorパッケージが必要
/// 現在はスタブ実装（Firebase連携後に完全稼働）
class GuardianService {
  static final _sanctuaries = <Sanctuary>[];
  static final _checkpoints = <Checkpoint>[];
  static final _todayRoute = <AdventurePoint>[];

  // === ジオフェンス（聖域） ===

  static Future<void> addSanctuary(Sanctuary s) async {
    _sanctuaries.add(s);
    debugPrint('Guardian: sanctuary added "${s.name}" at ${s.latitude},${s.longitude}');
  }

  static List<Sanctuary> get sanctuaries => List.unmodifiable(_sanctuaries);

  /// 現在地がいずれかの聖域内か判定
  static Sanctuary? checkInSanctuary(double lat, double lon) {
    for (final s in _sanctuaries) {
      final dist = _distanceMeters(lat, lon, s.latitude, s.longitude);
      if (dist <= s.radiusMeters) return s;
    }
    return null;
  }

  // === 冒険地図 ===

  static void recordPoint(double lat, double lon, {String? landmark}) {
    _todayRoute.add(AdventurePoint(
      timestamp: DateTime.now(),
      latitude: lat, longitude: lon,
      landmarkName: landmark,
    ));
  }

  static List<AdventurePoint> get todayRoute => List.unmodifiable(_todayRoute);

  /// RPG風ランドマーク変換（プライバシー配慮）
  static String anonymizeLandmark(String? raw) {
    if (raw == null) return 'ふしぎなばしょ';
    if (raw.contains('公園') || raw.contains('パーク')) return '🌳 みどりのひろば';
    if (raw.contains('駅')) return '🚃 てつのまち';
    if (raw.contains('学校') || raw.contains('園')) return '🏫 まなびのしろ';
    if (raw.contains('店') || raw.contains('モール')) return '🏪 にぎわいのまち';
    if (raw.contains('川') || raw.contains('橋')) return '🌊 みずのせかい';
    return '📍 あたらしいとち';
  }

  // === チェックポイントミッション ===

  static void addCheckpoint(Checkpoint cp) {
    _checkpoints.add(cp);
  }

  static List<Checkpoint> get checkpoints => List.unmodifiable(_checkpoints);

  /// チェックポイント到達判定
  static Checkpoint? checkArrival(double lat, double lon) {
    for (var i = 0; i < _checkpoints.length; i++) {
      final cp = _checkpoints[i];
      if (cp.discovered) continue;
      final dist = _distanceMeters(lat, lon, cp.latitude, cp.longitude);
      if (dist <= cp.radiusMeters) {
        _checkpoints[i] = cp.discover();
        return _checkpoints[i];
      }
    }
    return null;
  }

  // === SOS ===

  static Future<SosEvent> triggerSos(double lat, double lon) async {
    // TODO: 10秒音声録音 + Firebase経由で親へ即時送信
    final event = SosEvent(
      timestamp: DateTime.now(),
      latitude: lat, longitude: lon,
    );
    debugPrint('SOS TRIGGERED at $lat,$lon');
    return event;
  }

  // === ユーティリティ ===

  static double _distanceMeters(double lat1, double lon1, double lat2, double lon2) {
    const r = 6371000.0; // 地球半径(m)
    final dLat = _toRad(lat2 - lat1);
    final dLon = _toRad(lon2 - lon1);
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_toRad(lat1)) * math.cos(_toRad(lat2)) *
        math.sin(dLon / 2) * math.sin(dLon / 2);
    return r * 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
  }

  static double _toRad(double deg) => deg * math.pi / 180;
}
