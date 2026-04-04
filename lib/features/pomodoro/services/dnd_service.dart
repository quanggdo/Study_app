import 'package:flutter/services.dart';

class DndService {
  static const MethodChannel _channel = MethodChannel('study_app/dnd');

  static Future<bool> hasPermission() async {
    try {
      final granted = await _channel.invokeMethod<bool>('hasDndPermission');
      return granted ?? false;
    } catch (_) {
      return false;
    }
  }

  static Future<void> requestPermission() async {
    try {
      await _channel.invokeMethod('openDndSettings');
    } catch (_) {}
  }

  static Future<bool> setDnd(bool enabled) async {
    try {
      final res = await _channel.invokeMethod<bool>('setDnd', {'enabled': enabled});
      return res ?? false;
    } catch (_) {
      return false;
    }
  }
}
