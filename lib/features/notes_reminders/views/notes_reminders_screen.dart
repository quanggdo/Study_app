// Placeholder for notes_reminders/views/notes_reminders_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/responsive_center.dart';

import '../models/note_model.dart';
import '../models/task_model.dart';
import '../viewmodels/notes_reminders_viewmodel.dart';

class NotesRemindersScreen extends ConsumerStatefulWidget {
  const NotesRemindersScreen({super.key});

  @override
  ConsumerState<NotesRemindersScreen> createState() => _NotesRemindersScreenState();
}

class _NotesRemindersScreenState extends ConsumerState<NotesRemindersScreen>
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
    final state = ref.watch(notesRemindersViewModelProvider);
    final vm = ref.read(notesRemindersViewModelProvider.notifier);

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
          'Nhắc lịch và ghi chú môn học',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white.withOpacity(0.6),
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'Nhắc lịch  deadline'),
            Tab(text: 'Ghi chú môn học'),
          ],
        ),
      ),
      body: ResponsiveCenter(
        maxWidth: 600,
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
            Text(_tabController.index == 0 ? 'Thêm nhắc lịch mới' : 'Thêm ghi chú mới'),
      ),
    );
  }

  Future<void> _showCreateTaskDialog(
    BuildContext context,
    NotesRemindersViewModel vm,
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
            title: const Text('Tao nhac lich / deadline'),
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
                        child: Text('Khẩn cấp'),
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
                child: const Text('Huy'),
              ),
              FilledButton(
                onPressed: () async {
                  if (titleCtrl.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Vui lòng nhập tên công việc / Môn học.'),
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
    NotesRemindersViewModel vm,
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
    NotesRemindersViewModel vm,
    TaskModel task,
  ) async {
    final titleCtrl = TextEditingController(text: task.title);
    DateTime selectedTime = task.deadline;
    TaskPriority priority = task.priority;

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
                      decoration: const InputDecoration(labelText: 'Tên công việc / ôn học'),
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
                        if (value != null) setInnerState(() => priority = value);
                      },
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
                    if (titleCtrl.text.trim().isEmpty) {
                      return;
                    }
                    await vm.updateTask(
                      oldTask: task,
                      newTask: task.copyWith(
                        title: titleCtrl.text.trim(),
                        deadline: selectedTime,
                        priority: priority,
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
    NotesRemindersViewModel vm,
    NoteModel note,
  ) async {
    final subjectIdCtrl = TextEditingController(text: note.subjectId);
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
                  controller: subjectIdCtrl,
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
                if (subjectIdCtrl.text.trim().isEmpty ||
                    contentCtrl.text.trim().isEmpty) {
                  return;
                }
                await vm.updateNote(
                  note.copyWith(
                    subjectId: subjectIdCtrl.text.trim(),
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
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.event_note_rounded,
              size: 64,
              color: Colors.grey.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'Chưa có nhắc lịch / deadline',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Hãy bấm nút thêm để tạo mới.',
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 14,
              ),
            ),
          ],
        ).animate().fadeIn(duration: 400.ms),
      );
    }

    final pendingTasks = tasks.where((task) => !task.isCompleted).toList();
    final completedTasks = tasks.where((task) => task.isCompleted).toList();

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      children: [
        _buildSectionHeader(
          context,
          title: 'Đang làm',
          count: pendingTasks.length,
          icon: Icons.pending_actions_rounded,
        ),
        if (pendingTasks.isEmpty)
          _buildSectionEmpty(context, 'Không có task đang làm.')
        else
          ...List.generate(
            pendingTasks.length,
            (index) => Padding(
              padding: EdgeInsets.only(bottom: index == pendingTasks.length - 1 ? 0 : 12),
              child: _buildTaskCard(
                context: context,
                task: pendingTasks[index],
                delay: 80 + (index * 40),
              ),
            ),
          ),
        const SizedBox(height: 18),
        _buildSectionHeader(
          context,
          title: 'Đã hoàn thành',
          count: completedTasks.length,
          icon: Icons.check_circle_outline_rounded,
        ),
        if (completedTasks.isEmpty)
          _buildSectionEmpty(context, 'Chưa có task đã hoàn thành.')
        else
          ...List.generate(
            completedTasks.length,
            (index) => Padding(
              padding:
                  EdgeInsets.only(bottom: index == completedTasks.length - 1 ? 0 : 12),
              child: _buildTaskCard(
                context: context,
                task: completedTasks[index],
                delay: 80 + ((pendingTasks.length + index) * 40),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildSectionHeader(
    BuildContext context, {
    required String title,
    required int count,
    required IconData icon,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 8),
          Text(
            '$title ($count)',
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionEmpty(BuildContext context, String text) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.35),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildTaskCard({
    required BuildContext context,
    required TaskModel task,
    required int delay,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C1F2E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.25)
                : Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(4, 8, 8, 8),
          child: Row(
            children: [
              IconButton(
                tooltip: task.isCompleted
                    ? 'Đánh dấu chưa hoàn thành'
                    : 'Đánh dấu hoàn thành',
                onPressed: () => onToggle(task),
                icon: Icon(
                  task.isCompleted
                      ? Icons.check_circle_rounded
                      : Icons.radio_button_unchecked_rounded,
                  size: 22,
                  color: task.isCompleted
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.outline,
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        decoration:
                            task.isCompleted ? TextDecoration.lineThrough : null,
                        color: task.isCompleted ? Colors.grey.shade500 : null,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.schedule_rounded,
                          size: 14,
                          color: task.isCompleted
                              ? Colors.grey.shade500
                              : Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          DateFormat('dd/MM/yyyy HH:mm').format(task.deadline),
                          style: TextStyle(
                            fontSize: 12.5,
                            color: task.isCompleted
                                ? Colors.grey.shade500
                                : Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color:
                                _getPriorityColor(task.priority).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            task.priority.name.toUpperCase(),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: _getPriorityColor(task.priority),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.more_vert_rounded),
                color: Colors.grey.shade500,
                onPressed: () => _showTaskOptions(context, task),
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(delay: Duration(milliseconds: delay)).slideX(begin: 0.04);
  }

  Color _getPriorityColor(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.high: return Colors.red;
      case TaskPriority.medium: return Colors.orange;
      case TaskPriority.low: return Colors.blue;
    }
  }

  void _showTaskOptions(BuildContext context, TaskModel task) {
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
                    color: Colors.grey.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 10),
                ListTile(
                  leading: const Icon(Icons.edit_rounded, color: Colors.blue),
                  title: const Text('Chỉnh sửa'),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    onEdit(task);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.delete_outline_rounded, color: Colors.red),
                  title: const Text('Xóa', style: TextStyle(color: Colors.red)),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    onDelete(task);
                  },
                ),
              ],
            ),
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
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.format_quote_rounded,
              size: 64,
              color: Colors.grey.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'Bạn chưa có ghi chú nào',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Ghi chú và lưu trữ kiến thức để dễ dàng hơn.',
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 14,
              ),
            ),
          ],
        ).animate().fadeIn(duration: 400.ms),
      );
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      itemCount: notes.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final note = notes[index];
        final delay = 100 + (index * 50);

        return Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1C1F2E) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? Colors.black.withOpacity(0.25)
                    : Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            title: Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text(
                note.subjectId,
                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15.5),
              ),
            ),
            subtitle: Text(
              note.content,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                height: 1.4,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.more_vert_rounded),
              color: Colors.grey.shade500,
              onPressed: () {
                _showNoteOptions(context, note);
              },
            ),
          ),
        ).animate().fadeIn(delay: Duration(milliseconds: delay)).slideX(begin: 0.04);
      },
    );
  }

  void _showNoteOptions(BuildContext context, NoteModel note) {
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
                    color: Colors.grey.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 10),
                ListTile(
                  leading: const Icon(Icons.edit_rounded, color: Colors.blue),
                  title: const Text('Chỉnh sửa'),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    onEdit(note);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.delete_outline_rounded, color: Colors.red),
                  title: const Text('Xóa', style: TextStyle(color: Colors.red)),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    onDelete(note.id);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}


