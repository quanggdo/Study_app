// Placeholder for notes_reminders/views/tasks_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../models/note_model.dart';
import '../models/task_model.dart';
import '../viewmodels/notes_viewmodel.dart';

class TasksScreen extends ConsumerStatefulWidget {
  const TasksScreen({super.key});

  @override
  ConsumerState<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends ConsumerState<TasksScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(notesViewModelProvider);
    final vm = ref.read(notesViewModelProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nhắc lịch & Ghi chú môn học'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Nhắc lịch & Deadline'),
            Tab(text: 'Ghi chú môn học'),
          ],
        ),
      ),
      body: Column(
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
            child: TabBarView(
              controller: _tabController,
              children: [
                _TaskTab(
                  tasks: state.tasks,
                  onToggle: vm.toggleTask,
                  onDelete: vm.deleteTask,
                  onEdit: (task) => _showEditTaskDialog(context, vm, task),
                ),
                _NotesTab(
                  notes: state.notes,
                  onDelete: vm.deleteNote,
                  onEdit: (note) => _showEditNoteDialog(context, vm, note),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          if (_tabController.index == 0) {
            await _showCreateTaskDialog(context, vm);
            return;
          }
          await _showCreateNoteDialog(context, vm);
        },
        icon: const Icon(Icons.add_rounded),
        label:
            Text(_tabController.index == 0 ? 'Thêm nhắc lịch' : 'Thêm ghi chú'),
      ),
    );
  }

  Future<void> _showCreateTaskDialog(
    BuildContext context,
    NotesViewModel vm,
  ) async {
    final titleCtrl = TextEditingController();
    DateTime selectedTime = DateTime.now().add(const Duration(minutes: 30));
    TaskPriority priority = TaskPriority.medium;

    await showDialog<void>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(builder: (ctx, setInnerState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text('Tạo nhắc lịch / deadline'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleCtrl,
                    decoration: const InputDecoration(labelText: 'Tên công việc / Môn học'),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<TaskPriority>(
                    value: priority,
                    decoration: const InputDecoration(labelText: 'Độ ưu tiên'),
                    items: const [
                      DropdownMenuItem(
                        value: TaskPriority.high,
                        child: Text('Khẩn cấp (Báo thức)'),
                      ),
                      DropdownMenuItem(
                        value: TaskPriority.medium,
                        child: Text('Bình thường'),
                      ),
                      DropdownMenuItem(
                        value: TaskPriority.low,
                        child: Text('Thấp'),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setInnerState(() => priority = value);
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Thời điểm nhắc'),
                    subtitle: Text(
                        DateFormat('dd/MM/yyyy HH:mm').format(selectedTime)),
                    trailing: const Icon(Icons.schedule_rounded),
                    onTap: () async {
                      final date = await showDatePicker(
                        context: ctx,
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2100),
                        initialDate: selectedTime,
                      );
                      if (date == null) return;

                      final time = await showTimePicker(
                        context: ctx,
                        initialTime: TimeOfDay.fromDateTime(selectedTime),
                      );
                      if (time == null) return;

                      setInnerState(() {
                        selectedTime = DateTime(
                          date.year,
                          date.month,
                          date.day,
                          time.hour,
                          time.minute,
                        );
                      });
                    },
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
<<<<<<< Updated upstream
                  if (titleCtrl.text.trim().isEmpty ||
                      subjectCtrl.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Vui lòng nhập tiêu đề và môn học.'),
                      ),
                    );
                    return;
                  }
                  if (selectedTime.isBefore(DateTime.now())) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Thời điểm nhắc phải ở tương lai.'),
                      ),
                    );
=======
                  if (titleCtrl.text.trim().isEmpty) {
>>>>>>> Stashed changes
                    return;
                  }
                  await vm.createTask(
                    title: titleCtrl.text,
                    deadline: selectedTime,
                    priority: priority,
                  );
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Đã thêm nhắc lịch/deadline.'),
                      ),
                    );
                  }
                  if (mounted) Navigator.pop(ctx);
                },
                child: const Text('Lưu'),
              ),
            ],
          );
        });
      },
    );
  }

  Future<void> _showCreateNoteDialog(
    BuildContext context,
    NotesViewModel vm,
  ) async {
    final subjectIdCtrl = TextEditingController();
    final contentCtrl = TextEditingController();

    await showDialog<void>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text('Tạo ghi chú môn học'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: subjectIdCtrl,
                  decoration: const InputDecoration(labelText: 'Mã môn học'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: contentCtrl,
                  maxLines: 5,
                  decoration:
                      const InputDecoration(labelText: 'Nội dung ghi chú'),
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
                if (subjectIdCtrl.text.trim().isEmpty ||
                    contentCtrl.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content:
                          Text('Vui lòng nhập môn học và nội dung ghi chú.'),
                    ),
                  );
                  return;
                }
                await vm.createNote(
                  subjectId: subjectIdCtrl.text,
                  content: contentCtrl.text,
                );
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Đã thêm ghi chú môn học.'),
                    ),
                  );
                }
                if (mounted) Navigator.pop(ctx);
              },
              child: const Text('Lưu'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showEditTaskDialog(
    BuildContext context,
    NotesViewModel vm,
    TaskModel task,
  ) async {
    final titleCtrl = TextEditingController(text: task.title);
    final subjectCtrl = TextEditingController(text: task.subject);
    final descCtrl = TextEditingController(text: task.description ?? '');
    DateTime selectedTime = task.deadline;
    StudyTaskType type = task.type;

    await showDialog<void>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setInnerState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: const Text('Chỉnh sửa nhắc lịch / deadline'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleCtrl,
                      decoration: const InputDecoration(labelText: 'Tiêu đề'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: subjectCtrl,
                      decoration: const InputDecoration(labelText: 'Môn học'),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<StudyTaskType>(
                      value: type,
                      decoration: const InputDecoration(labelText: 'Loại nhắc'),
                      items: const [
                        DropdownMenuItem(
                          value: StudyTaskType.deadline,
                          child: Text('Deadline'),
                        ),
                        DropdownMenuItem(
                          value: StudyTaskType.schedule,
                          child: Text('Lịch học'),
                        ),
                      ],
                      onChanged: (value) {
                        if (value != null) setInnerState(() => type = value);
                      },
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: descCtrl,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText: 'Mô tả (tùy chọn)',
                      ),
                    ),
                    const SizedBox(height: 12),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Thời điểm nhắc'),
                      subtitle: Text(
                        DateFormat('dd/MM/yyyy HH:mm').format(selectedTime),
                      ),
                      trailing: const Icon(Icons.schedule_rounded),
                      onTap: () async {
                        final date = await showDatePicker(
                          context: ctx,
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2100),
                          initialDate: selectedTime,
                        );
                        if (date == null) return;
                        final time = await showTimePicker(
                          context: ctx,
                          initialTime: TimeOfDay.fromDateTime(selectedTime),
                        );
                        if (time == null) return;

                        setInnerState(() {
                          selectedTime = DateTime(
                            date.year,
                            date.month,
                            date.day,
                            time.hour,
                            time.minute,
                          );
                        });
                      },
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
                    if (titleCtrl.text.trim().isEmpty ||
                        subjectCtrl.text.trim().isEmpty) {
                      return;
                    }
                    await vm.updateTask(
                      task.copyWith(
                        title: titleCtrl.text.trim(),
                        subject: subjectCtrl.text.trim(),
                        description: descCtrl.text.trim().isEmpty
                            ? null
                            : descCtrl.text.trim(),
                        deadline: selectedTime,
                        type: type,
                      ),
                    );
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Đã cập nhật nhắc lịch/deadline.'),
                        ),
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
      },
    );
  }

  Future<void> _showEditNoteDialog(
    BuildContext context,
    NotesViewModel vm,
    NoteModel note,
  ) async {
    final subjectCtrl = TextEditingController(text: note.subject);
    final contentCtrl = TextEditingController(text: note.content);

    await showDialog<void>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text('Chỉnh sửa ghi chú môn học'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: subjectCtrl,
                  decoration: const InputDecoration(labelText: 'Môn học'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: contentCtrl,
                  maxLines: 5,
                  decoration:
                      const InputDecoration(labelText: 'Nội dung ghi chú'),
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
                    subject: subjectCtrl.text.trim(),
                    content: contentCtrl.text.trim(),
                  ),
                );
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Đã cập nhật ghi chú.'),
                    ),
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

class _TaskTab extends StatelessWidget {
  final List<TaskModel> tasks;
  final Future<void> Function(TaskModel task) onToggle;
  final Future<void> Function(TaskModel task) onDelete;
  final Future<void> Function(TaskModel task) onEdit;

  const _TaskTab({
    required this.tasks,
    required this.onToggle,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    if (tasks.isEmpty) {
      return const Center(
        child: Text('Chưa có nhắc lịch/deadline. Hãy thêm mới.'),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: tasks.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final task = tasks[index];
        return Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: CheckboxListTile(
            value: task.isCompleted,
            onChanged: (_) => onToggle(task),
            title: Text(task.title),
            subtitle: Text(
              '${DateFormat('dd/MM/yyyy HH:mm').format(task.deadline)}\nƯu tiên: ${task.priority.name}',
            ),
            secondary: IconButton(
              icon: const Icon(Icons.more_horiz_rounded),
              onPressed: () {
                showModalBottomSheet<void>(
                  context: context,
                  builder: (sheetContext) {
                    return SafeArea(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ListTile(
                            leading: const Icon(Icons.edit_rounded),
                            title: const Text('Chỉnh sửa'),
                            onTap: () {
                              Navigator.pop(sheetContext);
                              onEdit(task);
                            },
                          ),
                          ListTile(
                            leading: const Icon(Icons.delete_outline_rounded),
                            title: const Text('Xóa'),
                            onTap: () {
                              Navigator.pop(sheetContext);
                              onDelete(task);
                            },
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
            controlAffinity: ListTileControlAffinity.leading,
          ),
        );
      },
    );
  }
}

class _NotesTab extends StatelessWidget {
  final List<NoteModel> notes;
  final Future<void> Function(String noteId) onDelete;
  final Future<void> Function(NoteModel note) onEdit;

  const _NotesTab({
    required this.notes,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    if (notes.isEmpty) {
      return const Center(
        child: Text('Chưa có ghi chú môn học. Hãy thêm mới.'),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: notes.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final note = notes[index];
        return Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: ListTile(
<<<<<<< Updated upstream
            title: Text(note.subject),
            subtitle: Text(
              note.content,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
=======
            title: Text(note.subjectId),
            subtitle: Text(note.content),
>>>>>>> Stashed changes
            trailing: IconButton(
              icon: const Icon(Icons.more_horiz_rounded),
              onPressed: () {
                showModalBottomSheet<void>(
                  context: context,
                  builder: (sheetContext) {
                    return SafeArea(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ListTile(
                            leading: const Icon(Icons.edit_rounded),
                            title: const Text('Chỉnh sửa'),
                            onTap: () {
                              Navigator.pop(sheetContext);
                              onEdit(note);
                            },
                          ),
                          ListTile(
                            leading: const Icon(Icons.delete_outline_rounded),
                            title: const Text('Xóa'),
                            onTap: () {
                              Navigator.pop(sheetContext);
                              onDelete(note.id);
                            },
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }
}
