import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/task.dart';
import '../../domain/entities/task_status.dart';
import '../bloc/auth/auth_bloc.dart';
import '../bloc/auth/auth_event.dart';
import '../bloc/auth/auth_state.dart';
import '../bloc/task/task_bloc.dart';
import '../bloc/task/task_event.dart';
import '../bloc/task/task_state.dart';
import '../widgets/task_card.dart';
import '../widgets/task_filter_bottom_sheet.dart';
import '../widgets/responsive_layout.dart';
import '../theme/app_theme.dart';
import 'task_form_screen.dart';

class TaskListScreen extends StatefulWidget {
  static const String routeName = '/task-list';

  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  void _loadTasks() {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      context.read<TaskBloc>().add(
        TasksLoadRequested(userId: authState.user.id),
      );
    }
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const TaskFilterBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: const Text(
          'My Tasks',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterBottomSheet,
          ),
        ],
      ),
      body: BlocConsumer<TaskBloc, TaskState>(
        listener: (context, state) {
          if (state is TaskError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state is TaskOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is TaskLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is TaskError && state.tasks == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading tasks',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    state.message,
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadTasks,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final tasks = state is TaskLoaded
              ? state.filteredTasks
              : state is TaskError
              ? state.filteredTasks ?? []
              : <Task>[];

          final currentFilter = state is TaskLoaded
              ? state.currentFilter
              : state is TaskError
              ? state.currentFilter ?? const TaskFilter()
              : const TaskFilter();

          if (tasks.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.task_alt, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    currentFilter.hasActiveFilters
                        ? 'No tasks match your filters'
                        : 'No tasks yet',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    currentFilter.hasActiveFilters
                        ? 'Try adjusting your filters'
                        : 'Create your first task to get started',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
                  ),
                  if (currentFilter.hasActiveFilters) ...[
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () {
                        context.read<TaskBloc>().add(const TaskFilterCleared());
                      },
                      child: const Text('Clear Filters'),
                    ),
                  ],
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              final authState = context.read<AuthBloc>().state;
              if (authState is AuthAuthenticated) {
                context.read<TaskBloc>().add(
                  TaskRefreshRequested(userId: authState.user.id),
                );
              }
            },
            child: CustomScrollView(
              slivers: [
                // Active filters indicator
                if (currentFilter.hasActiveFilters)
                  SliverToBoxAdapter(
                    child: Container(
                      margin: const EdgeInsets.all(16),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.filter_list,
                            size: 20,
                            color: Theme.of(
                              context,
                            ).colorScheme.onPrimaryContainer,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _getFilterDescription(currentFilter),
                              style: TextStyle(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onPrimaryContainer,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              context.read<TaskBloc>().add(
                                const TaskFilterCleared(),
                              );
                            },
                            child: Text(
                              'Clear',
                              style: TextStyle(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onPrimaryContainer,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                // Grouped task lists
                ..._buildGroupedTaskLists(tasks),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const TaskFormScreen(),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('New Task'),
      ),
    );
  }

  String _getFilterDescription(TaskFilter filter) {
    final parts = <String>[];

    if (filter.priority != null) {
      parts.add('${filter.priority!.name.toUpperCase()} priority');
    }

    if (filter.status != null) {
      parts.add(
        filter.status == TaskStatus.complete ? 'Completed' : 'Incomplete',
      );
    }

    return 'Filtered by: ${parts.join(', ')}';
  }

  List<Widget> _buildGroupedTaskLists(List<Task> tasks) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final nextWeek = today.add(const Duration(days: 7));

    // Group tasks by time periods
    final todayTasks = <Task>[];
    final tomorrowTasks = <Task>[];
    final thisWeekTasks = <Task>[];
    final laterTasks = <Task>[];
    final overdueTasks = <Task>[];

    for (final task in tasks) {
      final taskDate = DateTime(
        task.dueDate.year,
        task.dueDate.month,
        task.dueDate.day,
      );

      if (taskDate.isBefore(today) && task.status == TaskStatus.incomplete) {
        overdueTasks.add(task);
      } else if (taskDate.isAtSameMomentAs(today)) {
        todayTasks.add(task);
      } else if (taskDate.isAtSameMomentAs(tomorrow)) {
        tomorrowTasks.add(task);
      } else if (taskDate.isBefore(nextWeek)) {
        thisWeekTasks.add(task);
      } else {
        laterTasks.add(task);
      }
    }

    final slivers = <Widget>[];

    // Overdue tasks (if any)
    if (overdueTasks.isNotEmpty) {
      slivers.addAll(
        _buildTaskSection('Overdue', overdueTasks, Colors.red, Icons.warning),
      );
    }

    // Today's tasks
    if (todayTasks.isNotEmpty) {
      slivers.addAll(
        _buildTaskSection(
          'Today',
          todayTasks,
          Theme.of(context).colorScheme.primary,
          Icons.today,
        ),
      );
    }

    // Tomorrow's tasks
    if (tomorrowTasks.isNotEmpty) {
      slivers.addAll(
        _buildTaskSection(
          'Tomorrow',
          tomorrowTasks,
          Colors.orange,
          Icons.event,
        ),
      );
    }

    // This week's tasks
    if (thisWeekTasks.isNotEmpty) {
      slivers.addAll(
        _buildTaskSection(
          'This Week',
          thisWeekTasks,
          Colors.blue,
          Icons.date_range,
        ),
      );
    }

    // Later tasks
    if (laterTasks.isNotEmpty) {
      slivers.addAll(
        _buildTaskSection('Later', laterTasks, Colors.grey, Icons.schedule),
      );
    }

    return slivers;
  }

  List<Widget> _buildTaskSection(
    String title,
    List<Task> tasks,
    Color color,
    IconData icon,
  ) {
    return [
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
          child: Row(
            children: [
              Icon(icon, size: 20, color: color),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${tasks.length}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: TaskCard(
              task: tasks[index],
              onToggleStatus: () {
                context.read<TaskBloc>().add(
                  TaskToggleStatusRequested(taskId: tasks[index].id),
                );
              },
              onEdit: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => TaskFormScreen(task: tasks[index]),
                  ),
                );
              },
              onDelete: () {
                _showDeleteConfirmation(tasks[index]);
              },
            ),
          );
        }, childCount: tasks.length),
      ),
    ];
  }

  void _showDeleteConfirmation(Task task) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Task'),
        content: Text('Are you sure you want to delete "${task.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<TaskBloc>().add(
                TaskDeleteRequested(taskId: task.id),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
