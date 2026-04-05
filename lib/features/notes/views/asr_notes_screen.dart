import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_to_text.dart';

import 'package:student_academic_assistant/core/theme/app_theme.dart';
import 'package:student_academic_assistant/core/widgets/responsive_center.dart';
import 'package:student_academic_assistant/features/notes/models/note_model.dart';
import 'package:student_academic_assistant/features/notes/viewmodels/notes_viewmodel.dart';

class AsrNotesScreen extends ConsumerStatefulWidget {
  const AsrNotesScreen({super.key});

  @override
  ConsumerState<AsrNotesScreen> createState() => _AsrNotesScreenState();
}

class _AsrNotesScreenState extends ConsumerState<AsrNotesScreen> {
  final SpeechToText _speechToText = SpeechToText();
  bool _speechReady = false;
  bool _isListening = false;

  @override
  void initState() {
    super.initState();
  }

  void _onSpeechError(dynamic _) {
    if (!mounted) return;
    setState(() {
      _isListening = false;
      _speechReady = false;
    });
  }

  @override
  void dispose() {
    _speechToText.stop();
    _speechToText.cancel();
    super.dispose();
  }

  Future<bool> _ensureMicrophonePermission(BuildContext context) async {
    PermissionStatus status = await Permission.microphone.status;
    if (!mounted) return false;

    if (status.isDenied) {
      status = await Permission.microphone.request();
    }

    if (status.isGranted || status.isLimited) {
      return true;
    }

    if (status.isPermanentlyDenied || status.isRestricted) {
      await showDialog<void>(
        context: context,
        builder: (ctx) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text('Cần quyền microphone'),
            content: const Text(
              'Ứng dụng cần quyền microphone để nhận diện giọng nói. '
              'Bạn có thể mở cài đặt để cấp quyền ngay.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Hủy'),
              ),
              FilledButton(
                onPressed: () async {
                  await openAppSettings();
                  if (ctx.mounted) {
                    Navigator.pop(ctx);
                  }
                },
                child: const Text('Mở cài đặt'),
              ),
            ],
          );
        },
      );
      return false;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Không có quyền microphone để nhận diện giọng nói.'),
      ),
    );
    return false;
  }

  Future<bool> _ensureSpeechReady(BuildContext context) async {
    if (_speechReady) return true;

    final bool isReady = await _speechToText.initialize(
      onError: _onSpeechError,
    );

    if (!mounted) return false;
    setState(() {
      _speechReady = isReady;
    });

    if (!isReady) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Không thể khởi tạo nhận diện giọng nói trên thiết bị này.'),
        ),
      );
    }

    return isReady;
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(notesViewModelProvider);
    final vm = ref.read(notesViewModelProvider.notifier);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: AppTheme.heroGradient,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Ghi chú bằng giọng nói (ASR)',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
      ),
      body: ResponsiveCenter(
        maxWidth: 680,
        child: Column(
          children: [
            if (state.isLoading) const LinearProgressIndicator(minHeight: 2),
            if (state.errorMessage != null)
              Container(
                width: double.infinity,
                color: Theme.of(context).colorScheme.errorContainer,
                padding: const EdgeInsets.all(12),
                child: Text(
                  state.errorMessage!,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onErrorContainer,
                  ),
                ),
              ),
            Expanded(
              child: state.notes.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.mic_none_rounded,
                            size: 62,
                            color: Colors.grey.withValues(alpha: 0.35),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            'Chưa có ghi chú nào',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Chạm mic để nói hoặc tải file ghi âm lên.',
                            style: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ).animate().fadeIn(duration: 400.ms),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 18, 16, 20),
                      itemCount: state.notes.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final note = state.notes[index];
                        final delay = 80 + (index * 40);

                        return Container(
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF1C1F2E) : Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: isDark
                                    ? Colors.black.withValues(alpha: 0.25)
                                    : Colors.black.withValues(alpha: 0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            title: Text(
                              note.subjectName.isEmpty ? 'Chưa rõ môn học' : note.subjectName,
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 15,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 6),
                                Text(
                                  note.content,
                                  maxLines: 4,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                    height: 1.35,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  DateFormat('dd/MM/yyyy HH:mm').format(note.updatedAt),
                                  style: TextStyle(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant
                                        .withValues(alpha: 0.8),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.more_vert_rounded),
                              onPressed: () => _showNoteOptions(context, vm, note),
                            ),
                          ),
                        ).animate().fadeIn(delay: Duration(milliseconds: delay)).slideX(begin: 0.04);
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateAsrDialog(context, vm),
        icon: const Icon(Icons.mic_rounded),
        label: const Text('Tạo ghi chú mới'),
      ),
    );
  }

  Future<void> _showCreateAsrDialog(
    BuildContext context,
    NotesViewModel vm,
  ) async {
    final subjectCtrl = TextEditingController();
    final transcriptCtrl = TextEditingController();
    PlatformFile? selectedAudioFile;
    bool isSubmitting = false;

    await showDialog<void>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setInnerState) {
            Future<void> onPickAudio() async {
              final result = await FilePicker.platform.pickFiles(
                type: FileType.custom,
                allowMultiple: false,
                withData: true,
                allowedExtensions: const <String>[
                  'mp3',
                  'wav',
                  'm4a',
                  'aac',
                  'ogg',
                  'webm',
                ],
              );

              if (result == null || result.files.isEmpty) return;
              setInnerState(() {
                selectedAudioFile = result.files.single;
              });
            }

            Future<void> onToggleListening() async {
              final bool hasMicPermission = await _ensureMicrophonePermission(context);
              if (!hasMicPermission) return;

              if (_isListening) {
                await _speechToText.stop();
                if (!mounted) return;
                setInnerState(() => _isListening = false);
                setState(() => _isListening = false);
                return;
              }

              final bool ready = await _ensureSpeechReady(context);
              if (!ready || !mounted) return;

              try {
                setInnerState(() => _isListening = true);
                setState(() => _isListening = true);

                await _speechToText.listen(
                  localeId: 'vi_VN',
                  listenMode: ListenMode.dictation,
                  partialResults: true,
                  cancelOnError: true,
                  listenFor: const Duration(seconds: 60),
                  pauseFor: const Duration(seconds: 8),
                  onResult: (result) {
                    if (!mounted) return;
                    setInnerState(() {
                      transcriptCtrl.text = result.recognizedWords;
                      transcriptCtrl.selection = TextSelection.collapsed(
                        offset: transcriptCtrl.text.length,
                      );

                      if (result.finalResult) {
                        _isListening = false;
                      }
                    });

                    if (result.finalResult) {
                      setState(() => _isListening = false);
                    }
                  },
                );
              } catch (e) {
                debugPrint('ASR Start Error: $e');
                if (!mounted) return;
                setInnerState(() => _isListening = false);
                setState(() {
                  _isListening = false;
                  _speechReady = false;
                });
              }
            }

            Future<void> onSubmit() async {
              final subjectHint = subjectCtrl.text.trim();
              final transcript = transcriptCtrl.text.trim();
              if (selectedAudioFile == null && transcript.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Hãy chọn file ghi âm hoặc nói vào microphone trước khi gửi.'),
                  ),
                );
                return;
              }

              setInnerState(() {
                isSubmitting = true;
              });

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Đang gửi lên AI xử lý...'),
                  duration: Duration(seconds: 2),
                ),
              );

              await vm.createNoteFromAsrInput(
                subjectHint: subjectHint,
                transcript: transcript,
                audioFile: selectedAudioFile,
              );

              if (!context.mounted) return;

              final hasError = ref.read(notesViewModelProvider).errorMessage != null;

              setInnerState(() {
                isSubmitting = false;
              });

              if (hasError) return;

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Đã lưu ghi chú môn học.')),
              );
              Navigator.pop(ctx);
            }

            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: const Text('Tạo ghi chú bằng giọng nói + AI'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: subjectCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Tên môn học (gợi ý)',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: transcriptCtrl,
                      maxLines: 5,
                      decoration: const InputDecoration(
                        labelText: 'Transcript giọng nói',
                        hintText: 'Có thể để trống nếu bạn gửi file ghi âm.',
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        OutlinedButton.icon(
                          onPressed: isSubmitting ? null : onPickAudio,
                          icon: const Icon(Icons.audio_file_rounded),
                          label: const Text('Nhập file ghi âm'),
                        ),
                        FilledButton.tonalIcon(
                          onPressed: isSubmitting ? null : onToggleListening,
                          icon: Icon(
                            _isListening
                                ? Icons.stop_circle_rounded
                                : Icons.mic_rounded,
                          ),
                          label:
                              Text(_isListening ? 'Dừng ghi' : 'Nhấn để nói'),
                        ),
                      ],
                    ),
                    if (selectedAudioFile != null) ...[
                      const SizedBox(height: 10),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .surfaceContainerHighest
                              .withValues(alpha: 0.45),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          'File đã chọn: ${selectedAudioFile!.name}',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                            fontSize: 12.5,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isSubmitting
                      ? null
                      : () async {
                          if (_isListening) {
                            await _speechToText.stop();
                            if (mounted) {
                              setInnerState(() {
                                _isListening = false;
                              });
                              setState(() {
                                _isListening = false;
                              });
                            }
                          }
                          if (context.mounted) {
                            Navigator.pop(ctx);
                          }
                        },
                  child: const Text('Hủy'),
                ),
                FilledButton(
                  onPressed: isSubmitting ? null : onSubmit,
                  child: isSubmitting
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Gửi lên'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showNoteOptions(
    BuildContext context,
    NotesViewModel vm,
    NoteModel note,
  ) {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 10),
                ListTile(
                  leading: const Icon(Icons.edit_rounded, color: Colors.blue),
                  title: const Text('Chỉnh sửa'),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    _showEditNoteDialog(context, vm, note);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.delete_outline_rounded, color: Colors.red),
                  title: const Text('Xóa', style: TextStyle(color: Colors.red)),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    vm.deleteNote(note.id);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _showEditNoteDialog(
    BuildContext context,
    NotesViewModel vm,
    NoteModel note,
  ) async {
    final subjectCtrl = TextEditingController(text: note.subjectName);
    final contentCtrl = TextEditingController(text: note.content);

    await showDialog<void>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text('Chỉnh sửa ghi chú'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: subjectCtrl,
                  decoration: const InputDecoration(labelText: 'Tên môn học'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: contentCtrl,
                  maxLines: 6,
                  decoration: const InputDecoration(labelText: 'Nội dung ghi chú'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Hủy'),
            ),
            FilledButton(
              onPressed: () async {
                if (subjectCtrl.text.trim().isEmpty ||
                    contentCtrl.text.trim().isEmpty) {
                  return;
                }
                await vm.updateNote(
                  note.copyWith(
                    subjectName: subjectCtrl.text.trim(),
                    content: contentCtrl.text.trim(),
                  ),
                );
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Đã cập nhật ghi chú.')),
                  );
                }
                if (context.mounted) Navigator.pop(ctx);
              },
              child: const Text('Cập nhật'),
            ),
          ],
        );
      },
    );
  }
}

