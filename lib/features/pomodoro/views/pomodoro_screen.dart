import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';
import 'package:video_player/video_player.dart';
import 'package:vibration/vibration.dart';

import '../models/pomodoro_state.dart';
import '../viewmodels/pomodoro_viewmodel.dart';

class PomodoroScreen extends ConsumerStatefulWidget {
  const PomodoroScreen({super.key});

  @override
  ConsumerState<PomodoroScreen> createState() => _PomodoroScreenState();
}

class _PomodoroScreenState extends ConsumerState<PomodoroScreen> with SingleTickerProviderStateMixin {
  VideoPlayerController? _videoController;
  bool _videoReady = false;
  bool _showGreatJob = false;

  @override
  void initState() {
    super.initState();
    _initVideo();
    _loadUserTarget();
  }

  Future<void> _initVideo() async {
    try {
      final ctrl = VideoPlayerController.asset('assets/videos/final_video.mp4');
      await ctrl.initialize();
      // default: no looping until timer starts
      await ctrl.setLooping(false);
      _videoController = ctrl;
      setState(() => _videoReady = true);
    } catch (e) {
      setState(() => _videoReady = false);
    }
  }

  Future<void> _loadUserTarget() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (!doc.exists) return;
      final data = doc.data()!;
      final target = data['target_study_time']; // assume minutes
      if (target != null) {
        final minutes = (target as num).toInt();
        final hours = minutes ~/ 60;
        final mins = minutes % 60;
        ref.read(pomodoroViewModelProvider.notifier).setDuration(hours: hours, minutes: mins);
      }
    } catch (_) {}
  }

  Future<void> _stopAndResetVideo() async {
    try {
      // ensure looping is disabled when stopping/resetting
      await _videoController?.setLooping(false);
      await _videoController?.pause();
      await _videoController?.seekTo(Duration.zero);
    } catch (_) {}
  }

  String _formatDuration(int seconds) {
    final h = seconds ~/ 3600;
    final m = (seconds % 3600) ~/ 60;
    final s = seconds % 60;
    return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  void _showTimePicker(BuildContext context, PomodoroState state) {
    int tempHours = state.totalSeconds ~/ 3600;
    int tempMinutes = (state.totalSeconds % 3600) ~/ 60;

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
                        ref.read(pomodoroViewModelProvider.notifier).setDuration(hours: tempHours, minutes: tempMinutes);
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
                        children: List.generate(24, (i) => Center(child: Text('$i giờ'))),
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
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  // @override
  // Widget build(BuildContext context) {
  //   final state = ref.watch(pomodoroViewModelProvider);
  //   final vm = ref.read(pomodoroViewModelProvider.notifier);

  //   // react to state changes to control video and overlay
  //   ref.listen<PomodoroState>(pomodoroViewModelProvider, (previous, next) async {
  //     if (previous?.status != next.status) {
  //       if (next.status == PomodoroStatus.running) {
  //         if (_videoReady && _videoController != null) {
  //           try {
  //             if (!_videoController!.value.isInitialized) await _videoController!.initialize();
  //             await _videoController?.play();
  //           } catch (_) {}
  //         }
  //       }

  //       if (next.status == PomodoroStatus.paused) {
  //         try {
  //           await _videoController?.pause();
  //         } catch (_) {}
  //       }

  //       if (next.status == PomodoroStatus.finished) {
  //         // stop and reset video, show animation
  //         await _stopAndResetVideo();
  //         if (mounted) setState(() => _showGreatJob = true);
  //         await Future.delayed(const Duration(seconds: 3));
  //         if (mounted) setState(() => _showGreatJob = false);
  //       }
  //     }
  //   });

  //   return Scaffold(
  //     appBar: AppBar(
  //       title: const Text('Quản lý thời gian học'),
  //     ),
  //     body: SafeArea(
  //       child: Center(
  //         child: SingleChildScrollView(
  //           padding: const EdgeInsets.all(16),
  //           child: Container(
  //             width: double.infinity,
  //             constraints: const BoxConstraints(maxWidth: 600),
  //             padding: const EdgeInsets.all(20),
  //             decoration: BoxDecoration(
  //               color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1C1F2E) : Colors.white,
  //               borderRadius: BorderRadius.circular(20),
  //               boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 14, offset: const Offset(0, 6))],
  //             ),
  //             child: Stack(
  //               alignment: Alignment.center,
  //               children: [
  //                 Column(
  //                   mainAxisSize: MainAxisSize.min,
  //                   children: [
  //                     // video (4:3)
  //                     ClipRRect(
  //                       borderRadius: BorderRadius.circular(16),
  //                       child: AspectRatio(
  //                         aspectRatio: 4 / 3,
  //                         child: _videoReady && _videoController != null && _videoController!.value.isInitialized
  //                             ? VideoPlayer(_videoController!)
  //                             : Container(color: Colors.grey.shade200, child: const Center(child: Icon(Icons.videocam_off, size: 56))),
  //                       ),
  //                     ),
  //                     const SizedBox(height: 12),
  //                     GestureDetector(
  //                       onTap: () => _showTimePicker(context, state),
  //                       child: Text(
  //                         _formatDuration(state.remainingSeconds),
  //                         style: Theme.of(context).textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.w800, color: Colors.black),
  //                       ),
  //                     ),
  //                     const SizedBox(height: 18),
  //                     Row(mainAxisAlignment: MainAxisAlignment.center, children: [
  //                       SizedBox(
  //                         height: 44,
  //                         child: FilledButton(
  //                           onPressed: state.status == PomodoroStatus.running
  //                               ? () {
  //                                   vm.pause();
  //                                   try {
  //                                     _videoController?.pause();
  //                                   } catch (_) {}
  //                                 }
  //                               : () {
  //                                   vm.start();
  //                                 },
  //                           style: FilledButton.styleFrom(
  //                             backgroundColor: const Color(0xFFE53935),
  //                             foregroundColor: Colors.white,
  //                             shape: RoundedRectangleBorder(
  //                               borderRadius: BorderRadius.circular(10),
  //                               side: const BorderSide(color: Color(0xFFE53935)),
  //                             ),
  //                           ),
  //                           child: Text(state.status == PomodoroStatus.running ? 'Tạm dừng' : 'Bắt đầu'),
  //                         ),
  //                       ),
  //                       const SizedBox(width: 12),
  //                       SizedBox(
  //                         height: 44,
  //                         child: FilledButton(
  //                           onPressed: () {
  //                             vm.reset();
  //                             _stopAndResetVideo();
  //                           },
  //                           style: FilledButton.styleFrom(
  //                             backgroundColor: const Color(0xFF1E88E5),
  //                             foregroundColor: Colors.white,
  //                             shape: RoundedRectangleBorder(
  //                               borderRadius: BorderRadius.circular(10),
  //                               side: const BorderSide(color: Color(0xFF1E88E5)),
  //                             ),
  //                           ),
  //                           child: const Text('Đặt lại'),
  //                         ),
  //                       ),
  //                     ]),
  //                   ],
  //                 ),

  //               ],
  //             ),
  //           ),
  //         ),
  //       ),
  //     ),
  //   );
    
  //   // NOTE: old inner overlay removed — overlay moved to scaffold-level Stack below
  // }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(pomodoroViewModelProvider);
    final vm = ref.read(pomodoroViewModelProvider.notifier);

    // react to state changes to control video and overlay
    ref.listen<PomodoroState>(pomodoroViewModelProvider, (previous, next) async {
      if (previous?.status != next.status) {
        if (next.status == PomodoroStatus.running) {
          if (_videoReady && _videoController != null) {
            try {
              if (!_videoController!.value.isInitialized) await _videoController!.initialize();
              // enable looping while countdown is running
              await _videoController?.setLooping(true);
              await _videoController?.play();
            } catch (_) {}
          }
        }

        if (next.status == PomodoroStatus.paused) {
          try {
            // disable looping when paused
            await _videoController?.setLooping(false);
            await _videoController?.pause();
          } catch (_) {}
        }

        if (next.status == PomodoroStatus.finished) {
          // stop and reset video, show animation
          await _stopAndResetVideo();
          // vibrate and play short alert sound
          try {
            if (await Vibration.hasVibrator() ?? false) {
              Vibration.vibrate(duration: 500);
            }
          } catch (_) {}
          try {
            SystemSound.play(SystemSoundType.alert);
          } catch (_) {}
          if (mounted) setState(() => _showGreatJob = true);
          await Future.delayed(const Duration(seconds: 3));
          if (mounted) setState(() => _showGreatJob = false);
        }
      }
    });

    // Build scaffold wrapped in a Stack so overlay can cover entire screen
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý thời gian học'),
      ),
      body: Stack(
        children: [
          SafeArea(
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
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 14, offset: const Offset(0, 6))],
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // video
                          ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: AspectRatio(
                              aspectRatio: 4 / 3,
                              child: _videoReady && _videoController != null && _videoController!.value.isInitialized
                                  ? VideoPlayer(_videoController!)
                                  : Container(color: Colors.grey.shade200, child: const Center(child: Icon(Icons.videocam_off, size: 56))),
                            ),
                          ),
                          const SizedBox(height: 12),
                          GestureDetector(
                            onTap: () => _showTimePicker(context, state),
                            child: Text(
                              _formatDuration(state.remainingSeconds),
                              style: Theme.of(context).textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.w800, color: Colors.black),
                            ),
                          ),
                          const SizedBox(height: 18),
                          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                            SizedBox(
                              height: 44,
                              child: FilledButton(
                                onPressed: state.status == PomodoroStatus.running
                                    ? () {
                                        vm.pause();
                                        try {
                                          _videoController?.pause();
                                        } catch (_) {}
                                      }
                                    : () {
                                        vm.start();
                                      },
                                style: FilledButton.styleFrom(
                                  backgroundColor: const Color(0xFFE53935),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    side: const BorderSide(color: Color(0xFFE53935)),
                                  ),
                                ),
                                child: Text(state.status == PomodoroStatus.running ? 'Tạm dừng' : 'Bắt đầu'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            SizedBox(
                              height: 44,
                              child: FilledButton(
                                onPressed: () {
                                  vm.reset();
                                  _stopAndResetVideo();
                                },
                                style: FilledButton.styleFrom(
                                  backgroundColor: const Color(0xFF1E88E5),
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
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (_showGreatJob)
            Positioned.fill(
              child: Container(
                color: Colors.black.withValues(alpha: 0.6),
                alignment: Alignment.center,
                child: Lottie.asset('assets/lottie/great_job.json', width: 280, height: 280, fit: BoxFit.contain),
              ),
            ),
        ],
      ),
    );
  }
}
              

