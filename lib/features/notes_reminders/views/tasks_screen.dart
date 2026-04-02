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
                ),
                _NotesTab(
                  notes: state.notes,
                  onDelete: vm.deleteNote,
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
    final subjectCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    DateTime selectedTime = DateTime.now().add(const Duration(minutes: 30));
    StudyTaskType type = StudyTaskType.deadline;

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
                      if (value != null) {
                        setInnerState(() => type = value);
                      }
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
                  if (titleCtrl.text.trim().isEmpty ||
                      subjectCtrl.text.trim().isEmpty) {
                    return;
                  }
                  await vm.createTask(
                    title: titleCtrl.text,
                    subject: subjectCtrl.text,
                    description: descCtrl.text,
                    deadline: selectedTime,
                    type: type,
                  );
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
    final subjectCtrl = TextEditingController();
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
                await vm.createNote(
                  subject: subjectCtrl.text,
                  content: contentCtrl.text,
                );
                if (mounted) Navigator.pop(ctx);
              },
              child: const Text('Lưu'),
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

  const _TaskTab({
    required this.tasks,
    required this.onToggle,
    required this.onDelete,
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
              '${task.subject} • ${DateFormat('dd/MM/yyyy HH:mm').format(task.deadline)}\n${task.type == StudyTaskType.deadline ? 'Deadline' : 'Lịch học'}',
            ),
            secondary: IconButton(
              icon: const Icon(Icons.delete_outline_rounded),
              onPressed: () => onDelete(task),
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

  const _NotesTab({
    required this.notes,
    required this.onDelete,
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
            title: Text(note.subject),
            subtitle: Text(note.content),
            trailing: IconButton(
              icon: const Icon(Icons.delete_outline_rounded),
              onPressed: () => onDelete(note.id),
            ),
          ),
        );
      },
    );
  }
}
