import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// スマート・タイムリミット — 連続使用制限 + 夜間制限
class TimeGuard {
  static const _keySessionStart = 'session_start';
  static const _keyNightLimitHour = 'night_limit_hour';
  static const _keyMaxMinutes = 'max_session_minutes';

  static DateTime? _sessionStart;
  static int _maxMinutes = 20;
  static int _nightStartHour = 20; // 20時
  static int _nightEndHour = 6;    // 6時

  /// 初期化（アプリ起動時）
  static Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _maxMinutes = prefs.getInt(_keyMaxMinutes) ?? 20;
    _nightStartHour = prefs.getInt(_keyNightLimitHour) ?? 20;
    _sessionStart = DateTime.now();
    await prefs.setString(_keySessionStart, _sessionStart!.toIso8601String());
  }

  /// 利用可否チェック
  static RestStatus checkStatus() {
    final now = DateTime.now();

    // 夜間チェック
    if (_isNightTime(now)) {
      return RestStatus.nightTime;
    }

    // 連続使用チェック
    if (_sessionStart != null) {
      final elapsed = now.difference(_sessionStart!).inMinutes;
      if (elapsed >= _maxMinutes) {
        return RestStatus.sessionLimit;
      }
      if (elapsed >= _maxMinutes - 5) {
        return RestStatus.warning; // 残り5分
      }
    }

    return RestStatus.active;
  }

  /// 残り時間（分）
  static int remainingMinutes() {
    if (_sessionStart == null) return _maxMinutes;
    final elapsed = DateTime.now().difference(_sessionStart!).inMinutes;
    return (_maxMinutes - elapsed).clamp(0, _maxMinutes);
  }

  /// セッションリセット（親の承認で延長）
  static void resetSession() {
    _sessionStart = DateTime.now();
  }

  /// 親の設定変更
  static Future<void> setMaxMinutes(int minutes) async {
    _maxMinutes = minutes;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyMaxMinutes, minutes);
  }

  static Future<void> setNightHour(int hour) async {
    _nightStartHour = hour;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyNightLimitHour, hour);
  }

  static bool _isNightTime(DateTime now) {
    final hour = now.hour;
    if (_nightStartHour > _nightEndHour) {
      return hour >= _nightStartHour || hour < _nightEndHour;
    }
    return hour >= _nightStartHour && hour < _nightEndHour;
  }

  static int get maxMinutes => _maxMinutes;
  static int get nightStartHour => _nightStartHour;
}

enum RestStatus {
  active,       // 通常利用可
  warning,      // 残り5分
  sessionLimit, // 連続使用制限
  nightTime,    // 夜間制限
}
