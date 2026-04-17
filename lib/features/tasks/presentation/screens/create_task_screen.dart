import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/constants/index.dart';
import '../../../../core/data/repositories/index.dart'; // Still needed for NotificationRepository for now
import '../providers/tasks_provider.dart';

class CreateTaskScreen extends ConsumerStatefulWidget {
  final String? projectId;

  const CreateTaskScreen({this.projectId, super.key});

  @override
  ConsumerState<CreateTaskScreen> createState() => _CreateTaskScreenState();
}

class _CreateTaskScreenState extends ConsumerState<CreateTaskScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  late String currentUserId;
  bool _isLoading = false;
  String _selectedPriority = 'medium';
  DateTime _selectedDueDate = DateTime.now().add(Duration(days: 7));
  String _selectedDueTime = '09:00';

  @override
  void initState() {
    super.initState();
    currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _handleCreate() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final taskRepo = ref.read(taskRepositoryProvider);
      final taskId = await taskRepo.createTask(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        creatorId: currentUserId,
        projectId: widget.projectId ?? 'default',
        dueDate: _selectedDueDate,
        dueTime: _selectedDueTime,
        assigneeIds: [currentUserId],
        priority: _selectedPriority,
        tags: [],
      );

      final currentUser = FirebaseAuth.instance.currentUser;
      final actorName = currentUser?.displayName ?? 'Someone';
      final actorPhotoURL = currentUser?.photoURL;

      // TODO: Refactor NotificationRepository to feature-based architecture later
      await NotificationRepository().createNotification(
        userId: currentUserId,
        type: 'task_assigned',
        title: 'New Task Assigned',
        body:
            '$actorName assigned you a new task: "${_titleController.text.trim()}"',
        actorId: currentUserId,
        actorName: actorName,
        actorPhotoURL: actorPhotoURL,
        relatedEntityId: taskId,
        relatedEntityType: 'task',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Task created successfully')),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _selectTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: int.parse(_selectedDueTime.split(':')[0]),
        minute: int.parse(_selectedDueTime.split(':')[1]),
      ),
    );
    if (picked != null) {
      setState(() {
        _selectedDueTime =
            '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Task'), centerTitle: true),
      body: SingleChildScrollView(
        padding: AppLayout.paddingMedium,
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppLayout.gapMedium,

              // Title field
              TextFormField(
                controller: _titleController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Task Title',
                  hintText: 'Enter task name',
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
                  labelStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                  prefixIcon: const Icon(Icons.task_outlined),
                  border: OutlineInputBorder(
                    borderRadius: AppBorderRadius.medium,
                    borderSide: BorderSide(
                      color: Colors.white.withOpacity(0.2),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: AppBorderRadius.medium,
                    borderSide: BorderSide(
                      color: Colors.white.withOpacity(0.2),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: AppBorderRadius.medium,
                    borderSide: BorderSide(color: Colors.blue.shade300),
                  ),
                ),
                validator: (value) {
                  if (value?.isEmpty ?? true) return 'Title is required';
                  return null;
                },
              ),
              AppLayout.gapMedium,

              // Description field
              TextFormField(
                controller: _descriptionController,
                style: const TextStyle(color: Colors.white),
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: 'Description',
                  hintText: 'Enter task description',
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
                  labelStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                  border: OutlineInputBorder(
                    borderRadius: AppBorderRadius.medium,
                    borderSide: BorderSide(
                      color: Colors.white.withOpacity(0.2),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: AppBorderRadius.medium,
                    borderSide: BorderSide(
                      color: Colors.white.withOpacity(0.2),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: AppBorderRadius.medium,
                    borderSide: BorderSide(color: Colors.blue.shade300),
                  ),
                ),
                validator: (value) {
                  if (value?.isEmpty ?? true) return 'Description is required';
                  return null;
                },
              ),
              AppLayout.gapMedium,

              // Priority dropdown
              DropdownButtonFormField<String>(
                value: _selectedPriority,
                style: const TextStyle(color: Colors.white),
                dropdownColor: Colors.grey.shade800,
                decoration: InputDecoration(
                  labelText: 'Priority',
                  labelStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                  prefixIcon: const Icon(Icons.flag_outlined),
                  border: OutlineInputBorder(
                    borderRadius: AppBorderRadius.medium,
                    borderSide: BorderSide(
                      color: Colors.white.withOpacity(0.2),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: AppBorderRadius.medium,
                    borderSide: BorderSide(
                      color: Colors.white.withOpacity(0.2),
                    ),
                  ),
                ),
                items: ['low', 'medium', 'high']
                    .map(
                      (priority) => DropdownMenuItem(
                        value: priority,
                        child: Text(priority),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) setState(() => _selectedPriority = value);
                },
              ),
              AppLayout.gapMedium,

              // Due date
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.calendar_today),
                title: Text(
                  'Due Date: ${_selectedDueDate.day}/${_selectedDueDate.month}/${_selectedDueDate.year}',
                ),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _selectedDueDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(Duration(days: 365)),
                  );
                  if (picked != null) {
                    setState(() => _selectedDueDate = picked);
                  }
                },
              ),
              AppLayout.gapSmall,

              // Due time
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.schedule),
                title: Text('Due Time: $_selectedDueTime'),
                onTap: _selectTime,
              ),
              AppLayout.gapXLarge,

              // Create button
              SizedBox(
                height: AppSize.buttonHeight,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleCreate,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade600,
                    disabledBackgroundColor: Colors.green.shade600.withOpacity(
                      0.5,
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation(Colors.white),
                          ),
                        )
                      : const Text(
                          'Create Task',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
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
