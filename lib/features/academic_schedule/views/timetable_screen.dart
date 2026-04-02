import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/providers/user_provider.dart';
import '../../../core/widgets/responsive_center.dart';
import '../models/class_session_model.dart';
import '../viewmodels/schedule_viewmodel.dart';

class TimetableScreen extends ConsumerWidget {
  const TimetableScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<ClassSessionModel>> scheduleAsync =
        ref.watch(userScheduleStreamProvider);
    final ScheduleState state = ref.watch(scheduleNotifierProvider);
    final String? uid = ref.watch(currentUserProvider)?.uid;

    ref.listen<ScheduleState>(scheduleNotifierProvider, (prev, next) {
      if (next.errorMessage != null && next.errorMessage!.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.errorMessage!)),
        );
        ref.read(scheduleNotifierProvider.notifier).clearError();
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý thời khóa biểu'),
      ),
      body: ResponsiveCenter(
        maxWidth: 900,
        child: scheduleAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (Object e, StackTrace _) =>
              Center(child: Text('Không thể tải dữ liệu: $e')),
          data: (List<ClassSessionModel> sessions) {
            final Map<int, List<ClassSessionModel>> grouped =
                _groupByDay(sessions);

            if (sessions.isEmpty) {
              return const _EmptyScheduleView();
            }

            return ListView(
              padding: const EdgeInsets.all(16),
              children: <Widget>[
                for (final int day in grouped.keys)
                  _DaySection(
                    dayOfWeek: day,
                    sessions: grouped[day]!,
                    onDelete: (String id) {
                      ref.read(scheduleNotifierProvider.notifier).deleteSession(
                            id,
                          );
                    },
                  ),
                if (state.latestExtractedText != null &&
                    state.latestExtractedText!.trim().isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: ExpansionTile(
                      tilePadding: const EdgeInsets.symmetric(horizontal: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      collapsedShape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      title: const Text('Văn bản trích xuất gần nhất từ ảnh'),
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                          child: SelectableText(state.latestExtractedText!),
                        ),
                      ],
                    ),
                  ),
              ],
            );
          },
        ),
      ),
      floatingActionButton: uid == null
          ? null
          : FloatingActionButton.extended(
              onPressed: state.isImporting || state.isSubmitting
                  ? null
                  : () => _showCreateOptions(context, ref, uid),
              icon: state.isImporting || state.isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.add_rounded),
              label: Text(
                state.isImporting ? 'Đang xử lý ảnh...' : 'Thêm lịch học',
              ),
            ),
    );
  }

  void _showCreateOptions(BuildContext context, WidgetRef ref, String uid) {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                ListTile(
                  leading: const Icon(Icons.edit_calendar_rounded),
                  title: const Text('Nhập tay'),
                  subtitle: const Text('Tạo buổi học thủ công'),
                  onTap: () {
                    Navigator.pop(ctx);
                    _showManualCreateDialog(context, ref, uid);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.photo_library_rounded),
                  title: const Text('Đọc từ thư viện ảnh'),
                  subtitle: const Text('Dùng Gemini 2.5 Flash để trích xuất'),
                  onTap: () async {
                    Navigator.pop(ctx);
                    final int count = await ref
                        .read(scheduleNotifierProvider.notifier)
                        .importFromImage(uid: uid, source: ImageSource.gallery);
                    if (context.mounted && count > 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Đã thêm $count buổi học từ ảnh.'),
                        ),
                      );
                    }
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.photo_camera_rounded),
                  title: const Text('Chụp ảnh từ camera'),
                  subtitle: const Text('Hữu ích khi chạy trên điện thoại'),
                  onTap: () async {
                    Navigator.pop(ctx);
                    final int count = await ref
                        .read(scheduleNotifierProvider.notifier)
                        .importFromImage(uid: uid, source: ImageSource.camera);
                    if (context.mounted && count > 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Đã thêm $count buổi học từ ảnh.'),
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _showManualCreateDialog(
    BuildContext context,
    WidgetRef ref,
    String uid,
  ) async {
    final TextEditingController subjectController = TextEditingController();
    final TextEditingController roomController = TextEditingController();
    final TextEditingController startController = TextEditingController();
    final TextEditingController endController = TextEditingController();
    int dayOfWeek = 2;

    await showDialog<void>(
      context: context,
      builder: (BuildContext ctx) {
        return StatefulBuilder(
          builder:
              (BuildContext context, void Function(void Function()) setSt) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: const Text('Thêm buổi học thủ công'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    TextField(
                      controller: subjectController,
                      decoration: const InputDecoration(
                        labelText: 'Môn học',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<int>(
                      value: dayOfWeek,
                      decoration: const InputDecoration(
                        labelText: 'Thứ',
                        border: OutlineInputBorder(),
                      ),
                      items: _dayOptions.entries
                          .map(
                            (MapEntry<int, String> e) => DropdownMenuItem<int>(
                              value: e.key,
                              child: Text(e.value),
                            ),
                          )
                          .toList(),
                      onChanged: (int? value) {
                        if (value != null) {
                          setSt(() {
                            dayOfWeek = value;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: TextField(
                            controller: startController,
                            readOnly: true,
                            decoration: const InputDecoration(
                              labelText: 'Bắt đầu (HH:mm)',
                              border: OutlineInputBorder(),
                            ),
                            onTap: () async {
                              final TimeOfDay? picked = await showTimePicker(
                                context: ctx,
                                initialTime:
                                    const TimeOfDay(hour: 7, minute: 0),
                              );
                              if (picked != null) {
                                startController.text = _formatTimeOfDay(picked);
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: endController,
                            readOnly: true,
                            decoration: const InputDecoration(
                              labelText: 'Kết thúc (HH:mm)',
                              border: OutlineInputBorder(),
                            ),
                            onTap: () async {
                              final TimeOfDay? picked = await showTimePicker(
                                context: ctx,
                                initialTime:
                                    const TimeOfDay(hour: 9, minute: 0),
                              );
                              if (picked != null) {
                                endController.text = _formatTimeOfDay(picked);
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: roomController,
                      decoration: const InputDecoration(
                        labelText: 'Phòng học (tuỳ chọn)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Huỷ'),
                ),
                FilledButton(
                  onPressed: () async {
                    final bool ok = await ref
                        .read(scheduleNotifierProvider.notifier)
                        .addManualSession(
                          uid: uid,
                          subjectName: subjectController.text,
                          dayOfWeek: dayOfWeek,
                          startTime: startController.text.trim(),
                          endTime: endController.text.trim(),
                          room: roomController.text,
                        );
                    if (ctx.mounted && ok) {
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Đã tạo buổi học.')),
                      );
                    }
                  },
                  child: const Text('Lưu'),
                ),
              ],
            );
          },
        );
      },
    );

    subjectController.dispose();
    roomController.dispose();
    startController.dispose();
    endController.dispose();
  }

  static Map<int, List<ClassSessionModel>> _groupByDay(
    List<ClassSessionModel> sessions,
  ) {
    final Map<int, List<ClassSessionModel>> grouped =
        <int, List<ClassSessionModel>>{};
    for (final ClassSessionModel s in sessions) {
      grouped.putIfAbsent(s.dayOfWeek, () => <ClassSessionModel>[]).add(s);
    }
    for (final List<ClassSessionModel> daySessions in grouped.values) {
      daySessions.sort(
        (ClassSessionModel a, ClassSessionModel b) =>
            a.startTime.compareTo(b.startTime),
      );
    }
    return Map<int, List<ClassSessionModel>>.fromEntries(
      grouped.entries.toList()..sort((a, b) => a.key.compareTo(b.key)),
    );
  }

  static String _formatTimeOfDay(TimeOfDay t) {
    final String hh = t.hour.toString().padLeft(2, '0');
    final String mm = t.minute.toString().padLeft(2, '0');
    return '$hh:$mm';
  }
}

class _DaySection extends StatelessWidget {
  final int dayOfWeek;
  final List<ClassSessionModel> sessions;
  final ValueChanged<String> onDelete;

  const _DaySection({
    required this.dayOfWeek,
    required this.sessions,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                _dayOptions[dayOfWeek] ?? 'Không rõ',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              for (final ClassSessionModel session in sessions)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    tileColor:
                        Theme.of(context).colorScheme.surfaceContainerHighest,
                    title: Text(session.subjectName),
                    subtitle: Text(
                      '${session.startTime} - ${session.endTime}'
                      '${session.room.isNotEmpty ? ' • ${session.room}' : ''}'
                      '${session.isFromOcr ? ' • AI' : ''}',
                    ),
                    trailing: IconButton(
                      tooltip: 'Xoá buổi học',
                      icon: const Icon(Icons.delete_outline_rounded),
                      onPressed: () => onDelete(session.id),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyScheduleView extends StatelessWidget {
  const _EmptyScheduleView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              Icons.calendar_month_outlined,
              size: 56,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 12),
            Text(
              'Bạn chưa có thời khóa biểu',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Nhấn nút "Thêm lịch học" để nhập tay hoặc đọc từ ảnh bằng Gemini.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

const Map<int, String> _dayOptions = <int, String>{
  2: 'Thứ 2',
  3: 'Thứ 3',
  4: 'Thứ 4',
  5: 'Thứ 5',
  6: 'Thứ 6',
  7: 'Thứ 7',
  8: 'Chủ nhật',
};
