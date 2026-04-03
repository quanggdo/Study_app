import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:vibration/vibration.dart';
import 'package:video_player/video_player.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../models/pomodoro_state.dart';
import '../viewmodels/pomodoro_viewmodel.dart';

class PomodoroScreen extends ConsumerStatefulWidget {
  const PomodoroScreen({super.key});

  @override
  ConsumerState<PomodoroScreen> createState() => _PomodoroScreenState();
}

class _PomodoroScreenState extends ConsumerState<PomodoroScreen> with SingleTickerProviderStateMixin {
  StreamSubscription<GyroscopeEvent>? _gyroSub;
  double _tiltX = 0.0;
  double _tiltY = 0.0;

  bool _listenerAttached = false;
  bool _finishedNotified = false;

  // pickers
  int _selectedHours = 0;
  int _selectedMinutes = 25;

  // video
  VideoPlayerController? _videoController;
  bool _videoAvailable = false;
  String _videoStatus = 'Chưa khởi tạo';

  // lottie display when finished
  bool _showGreatJob = false;

  static const double _baseVideoSize = 220.0;

  @override
  void initState() {
    super.initState();

    _gyroSub = gyroscopeEvents.listen((event) {
      setState(() {
        _tiltX = event.x * 0.02;
        _tiltY = event.y * 0.02;
      });
    });

    _initVideo();
  }

  Future<void> _initVideo() async {
    try {
      setState(() {
        _videoStatus = 'Đang khởi tạo video...';
      });
      final ctrl = VideoPlayerController.asset('assets/videos/reach_to_top.mp4');
      await ctrl.initialize();
      debugPrint('[Pomodoro] _initVideo: initialized; duration=${ctrl.value.duration}');
      _videoController = ctrl;
      _videoAvailable = true;
      setState(() {
        _videoStatus = 'Initialized (${ctrl.value.duration.inSeconds}s)';
      });
    } catch (e) {
      _videoAvailable = false;
      // ignore: avoid_print
      debugPrint('[Pomodoro] _initVideo: failed to initialize video - $e');
      setState(() {
        _videoStatus = 'Lỗi khởi tạo video';
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Không thể khởi tạo video: $e')));
      }
    }
  }

  @override
  void dispose() {
    _gyroSub?.cancel();
    _videoController?.dispose();
    super.dispose();
  }

  String _formatDuration(int seconds) {
    final h = seconds ~/ 3600;
    final m = (seconds % 3600) ~/ 60;
    final s = seconds % 60;
    return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  void _showTimePicker(BuildContext context, PomodoroViewModel vm) {
    int tempHours = _selectedHours;
    int tempMinutes = _selectedMinutes;

    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        return SizedBox(
          height: 280,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
                  TextButton(
                      onPressed: () {
                        setState(() {
                          _selectedHours = tempHours;
                          _selectedMinutes = tempMinutes;
                        });
                        vm.setDuration(hours: _selectedHours, minutes: _selectedMinutes);
                        Navigator.pop(ctx);
                      },
                      child: const Text('Xong')),
                ],
              ),
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: CupertinoPicker(
                        scrollController: FixedExtentScrollController(initialItem: tempHours),
                        itemExtent: 32,
                        onSelectedItemChanged: (i) => tempHours = i,
                        children: List.generate(6, (i) => Center(child: Text('$i giờ'))),
                      ),
                    ),
                    Expanded(
                      child: CupertinoPicker(
                        scrollController: FixedExtentScrollController(initialItem: tempMinutes),
                        itemExtent: 32,
                        onSelectedItemChanged: (i) => tempMinutes = i,
                        children: List.generate(60, (i) => Center(child: Text('${i.toString().padLeft(2, '0')} phút'))),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(pomodoroViewModelProvider);
    final vm = ref.read(pomodoroViewModelProvider.notifier);

    // Attach listener once to control video and completion overlay
    if (!_listenerAttached) {
      _listenerAttached = true;
      ref.listen<PomodoroState>(pomodoroViewModelProvider, (previous, next) async {
        final prevRem = previous?.remainingSeconds ?? -1;

        // start video when timer starts - ensure controller is initialized
        if ((previous == null || previous.isRunning == false) && next.isRunning == true) {
          if (_videoController != null) {
            // wait for initialization if not yet ready
            if (!_videoController!.value.isInitialized) {
              try {
                await _videoController!.initialize();
              } catch (_) {}
            }

            final vdMs = _videoController!.value.duration.inMilliseconds;
            final vd = vdMs > 0 ? vdMs / 1000.0 : 0.0;
            final target = next.totalSeconds > 0 ? next.totalSeconds.toDouble() : 1.0;
            final speed = (vd > 0 && target > 0) ? (vd / target) : 1.0;
            final safeSpeed = speed.clamp(0.1, 10.0);

            debugPrint('[Pomodoro] starting video: initialized=${_videoController!.value.isInitialized} duration=${vd}s target=${target}s speed=${safeSpeed}');

            try {
              await _videoController?.setPlaybackSpeed(safeSpeed);
            } catch (e) {
              debugPrint('[Pomodoro] setPlaybackSpeed failed: $e');
            }
            await _videoController?.setVolume(1.0);
            await _videoController?.seekTo(Duration.zero);
            try {
              await _videoController?.play();
              if (mounted) setState(() => _videoStatus = 'Đang phát');
              debugPrint('[Pomodoro] video play called');
            } catch (e) {
              debugPrint('[Pomodoro] video play failed: $e');
              if (mounted) {
                setState(() => _videoStatus = 'Lỗi phát video');
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi phát video: $e')));
              }
            }
          }
        }

        // pause video when timer pauses
        if (previous != null && previous.isRunning == true && next.isRunning == false) {
          if (_videoAvailable) {
            await _videoController?.pause();
            if (mounted) setState(() => _videoStatus = 'Tạm dừng');
          }
        }

        // completion
        final nextRem = next.remainingSeconds;
        if (prevRem != 0 && nextRem == 0 && !_finishedNotified) {
          _finishedNotified = true;
          Vibration.hasVibrator().then((has) {
            if (has == true) Vibration.vibrate(duration: 180);
          });
          HapticFeedback.mediumImpact();

          // pause video
          if (_videoAvailable) await _videoController?.pause();

          // show Great Job overlay
          setState(() => _showGreatJob = true);
          await Future.delayed(const Duration(milliseconds: 2200));
          setState(() => _showGreatJob = false);
        }

        // reset on full reset
        if (next.remainingSeconds == next.totalSeconds) {
          _finishedNotified = false;
          if (_videoAvailable) {
            await _videoController?.pause();
            await _videoController?.seekTo(Duration.zero);
            if (mounted) setState(() => _videoStatus = 'Đã đặt lại');
          }
        }
      });
    }

    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF0F1117) : const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: const Text('Quản lý thời gian học'),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Container(
              width: double.infinity,
              constraints: const BoxConstraints(maxWidth: 600),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1C1F2E) : Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 14, offset: const Offset(0, 6))],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // video or fallback
                      Transform(
                        transform: Matrix4.identity()..rotateX(_tiltX)..rotateY(_tiltY),
                        alignment: Alignment.center,
                        child: SizedBox(
                          width: _baseVideoSize * 1.3,
                          height: _baseVideoSize * 1.3,
                          child: _videoAvailable && _videoController != null && _videoController!.value.isInitialized
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: FittedBox(
                                    fit: BoxFit.cover,
                                    child: SizedBox(
                                      width: _videoController!.value.size.width,
                                      height: _videoController!.value.size.height,
                                      child: VideoPlayer(_videoController!),
                                    ),
                                  ),
                                )
                              : Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    color: Colors.grey.shade200,
                                  ),
                                  child: Center(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.videocam_off, size: 48),
                                        SizedBox(height: 8),
                                        Text('Video chưa có sẵn'),
                                      ],
                                    ),
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(_videoStatus, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.black87)),
                      const SizedBox(height: 10),
                      GestureDetector(
                        onTap: () {
                          if (!state.isRunning) _showTimePicker(context, vm);
                        },
                        child: Text(_formatDuration(state.remainingSeconds), style: Theme.of(context).textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.w800, color: Colors.black)),
                      ),
                      const SizedBox(height: 18),
                      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                        SizedBox(
                          height: 44,
                          child: FilledButton(
                            onPressed: state.isRunning
                                ? vm.pause
                                : () async {
                                    // start timer
                                    vm.start();
                                    debugPrint('[Pomodoro] Start button pressed. controllerInit=${_videoController?.value.isInitialized} available=$_videoAvailable');
                                    if (_videoController != null) {
                                      try {
                                        if (!_videoController!.value.isInitialized) {
                                          await _videoController!.initialize();
                                        }
                                        final vdMs = _videoController!.value.duration.inMilliseconds;
                                        final vd = vdMs > 0 ? vdMs / 1000.0 : 0.0;
                                        final target = state.totalSeconds > 0 ? state.totalSeconds.toDouble() : 1.0;
                                        final speed = (vd > 0 && target > 0) ? (vd / target) : 1.0;
                                        final safeSpeed = speed.clamp(0.1, 10.0);
                                        await _videoController?.setPlaybackSpeed(safeSpeed);
                                        await _videoController?.setVolume(1.0);
                                        await _videoController?.seekTo(Duration.zero);
                                        await _videoController?.play();
                                        if (mounted) setState(() => _videoStatus = 'Đang phát (btn)');
                                        debugPrint('[Pomodoro] Start button triggered play; speed=$safeSpeed');
                                      } catch (e) {
                                        debugPrint('[Pomodoro] Start button play failed: $e');
                                        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi phát video: $e')));
                                      }
                                    } else {
                                      debugPrint('[Pomodoro] Start button: no video controller');
                                      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Video chưa sẵn sàng')));
                                    }
                                  },
                            style: FilledButton.styleFrom(
                              backgroundColor: const Color(0xFFE53935), // solid red
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                                side: const BorderSide(color: Color(0xFFE53935)),
                              ),
                            ),
                            child: Text(state.isRunning ? 'Tạm dừng' : (state.remainingSeconds == state.totalSeconds ? 'Bắt đầu' : 'Tiếp tục')),
                          ),
                        ),
                        const SizedBox(width: 12),
                        SizedBox(
                          height: 44,
                          child: FilledButton(
                            onPressed: vm.reset,
                            style: FilledButton.styleFrom(
                              backgroundColor: const Color(0xFF1E88E5), // blue
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                                side: const BorderSide(color: Color(0xFF1E88E5)),
                              ),
                            ),
                            child: const Text('Đặt lại'),
                          ),
                        ),
                      ]),
                    ],
                  ),
                  // dark overlay + greatjob lottie
                  if (_showGreatJob)
                    AnimatedOpacity(
                      opacity: _showGreatJob ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 300),
                      child: Container(
                        color: Colors.black.withOpacity(0.6),
                        width: double.infinity,
                        height: 600,
                        alignment: Alignment.center,
                        child: Lottie.asset('assets/lottie/greatjob.json', width: 240, height: 240, fit: BoxFit.contain),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
