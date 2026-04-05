import 'package:just_audio/just_audio.dart';

/// Service để quản lý phát âm thanh trong Pomodoro
class PomodoroAudioService {
  static final PomodoroAudioService _instance = PomodoroAudioService._internal();
  static AudioPlayer? _audioPlayer;

  factory PomodoroAudioService() {
    return _instance;
  }

  PomodoroAudioService._internal();

  /// Phát âm thanh hoàn thành (crystal_2021_lg.mp3)
  Future<void> playCompletionSound() async {
    try {
      _audioPlayer ??= AudioPlayer();
      
      // Đặt volume (0.0 - 1.0)
      await _audioPlayer!.setVolume(0.8);
      
      // Phát file từ assets
      await _audioPlayer!.setAsset('assets/audios/crystal_2021_lg.mp3');
      await _audioPlayer!.play();
    } catch (e) {
      print('Error playing completion sound: $e');
    }
  }

  /// Dừng âm thanh nếu đang phát
  Future<void> stopSound() async {
    try {
      await _audioPlayer?.stop();
    } catch (e) {
      print('Error stopping sound: $e');
    }
  }

  /// Giải phóng resource
  Future<void> dispose() async {
    try {
      await _audioPlayer?.dispose();
      _audioPlayer = null;
    } catch (e) {
      print('Error disposing audio player: $e');
    }
  }
}
