import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/constants/index.dart';
import '../../../../core/domain/entities/index.dart';
import '../../../../core/data/repositories/index.dart';
import 'task_detail_screen.dart';
import 'create_task_screen.dart';

class TasksListScreen extends StatefulWidget {
  const TasksListScreen({Key? key}) : super(key: key);

  @override
  State<TasksListScreen> createState() => _TasksListScreenState();
}

class _TasksListScreenState extends State<TasksListScreen> {
  final taskRepo = TaskRepository();
  late String currentUserId;
  String _filterStatus = 'all';

  @override
  void initState() {
    super.initState();
    currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Tasks'), centerTitle: true),
      body: StreamBuilder<List<TaskEntity>>(
        stream: taskRepo.getUserAssignedTasks(currentUserId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.task,
                    size: AppSize.iconXLarge,
                    color: Colors.white.withOpacity(0.3),
                  ),
                  AppLayout.gapMedium,
                  Text(
                    'No tasks assigned',
                    style: TextStyle(color: Colors.white.withOpacity(0.5)),
                  ),
                ],
              ),
            );
          }

          var tasks = snapshot.data!;

          // Apply filter
          if (_filterStatus == 'pending') {
            tasks = tasks.where((t) => !t.completed).toList();
          } else if (_filterStatus == 'completed') {
            tasks = tasks.where((t) => t.completed).toList();
          }

          return Column(
            children: [
              // Filter chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: AppLayout.paddingMedium,
                child: Row(
                  children: ['all', 'pending', 'completed']
                      .map(
                        (status) => Padding(
                          padding: EdgeInsets.only(right: AppPadding.small),
                          child: FilterChip(
                            label: Text(status),
                            selected: _filterStatus == status,
                            onSelected: (selected) {
                              setState(() => _filterStatus = status);
                            },
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: AppLayout.paddingMedium,
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    final task = tasks[index];
                    return _TaskTile(
                      task: task,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => TaskDetailScreen(taskId: task.id),
                          ),
                        );
                      },
                      onCompletionToggle: () {
                        taskRepo.toggleTaskCompletion(
                          task.id,
                          task.projectId,
                          !task.completed,
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text('New Task'),
        onPressed: () {
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => const CreateTaskScreen()));
        },
      ),
    );
  }
}

class _TaskTile extends StatelessWidget {
  final TaskEntity task;
  final VoidCallback onTap;
  final VoidCallback onCompletionToggle;

  const _TaskTile({
    required this.task,
    required this.onTap,
    required this.onCompletionToggle,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final priorityColor = _getPriorityColor(task.priority);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: AppPadding.small),
        padding: AppLayout.paddingMedium,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: AppBorderRadius.medium,
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Row(
          children: [
            Checkbox(
              value: task.completed,
              onChanged: (_) => onCompletionToggle(),
            ),
            AppLayout.horizontalGapSmall,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      decoration: task.completed
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  AppLayout.gapSmall,
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: priorityColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          task.priority,
                          style: TextStyle(
                            color: priorityColor,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      AppLayout.horizontalGapSmall,
                      Icon(
                        Icons.calendar_today,
                        size: AppSize.iconSmall,
                        color: Colors.white.withOpacity(0.4),
                      ),
                      AppLayout.horizontalGapSmall,
                      Text(
                        _formatDate(task.dueDate),
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.5),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}';
  }
}
