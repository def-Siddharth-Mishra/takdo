import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/task.dart';
import '../../domain/entities/task_priority.dart';
import '../../domain/entities/task_status.dart';
import '../bloc/task/task.dart';
import '../providers/task_provider.dart';

/// Example widget demonstrating how to use TaskBloc
class TaskUsageExample extends StatelessWidget {
  final String userId;

  const TaskUsageExample({
    super.key,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    return TaskProvider(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Task Management Example'),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                context.taskBloc.add(TaskRefreshRequested(userId: userId));
              },
            ),
          ],
        ),
        body: BlocBuilder<TaskBloc, TaskState>(
          builder: (context, state) {
            return Column(
              children: [
                // Filter controls
                _buildFilterControls(context),
                const Divider(),
                // Task list
                Expanded(
                  child: _buildTaskList(context, state),
                ),
              ],
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _createSampleTask(context),
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  Widget _buildFilterControls(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          // Priority filter
          DropdownButton<TaskPriority?>(
            hint: const Text('Priority'),
            value: null, // You would track this in a stateful widget
            items: [
              const DropdownMenuItem(value: null, child: Text('All')),
              ...TaskPriority.values.map(
                (priority) => DropdownMenuItem(
                  value: priority,
                  child: Text(priority.name.toUpperCase()),
                ),
              ),
            ],
            onChanged: (priority) {
              context.taskBloc.add(TaskFilterChanged(priority: priority));
            },
          ),
          const SizedBox(width: 16),
          // Status filter
          DropdownButton<TaskStatus?>(
            hint: const Text('Status'),
            value: null, // You would track this in a stateful widget
            items: [
              const DropdownMenuItem(value: null, child: Text('All')),
              ...TaskStatus.values.map(
                (status) => DropdownMenuItem(
                  value: status,
                  child: Text(status.name.toUpperCase()),
                ),
              ),
            ],
            onChanged: (status) {
              context.taskBloc.add(TaskFilterChanged(status: status));
            },
          ),
          const Spacer(),
          // Clear filters
          TextButton(
            onPressed: () {
              context.taskBloc.add(const TaskFilterCleared());
            },
            child: const Text('Clear Filters'),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskList(BuildContext context, TaskState state) {
    if (state is TaskInitial) {
      // Load tasks when first initialized
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.taskBloc.add(TasksLoadRequested(userId: userId));
      });
      return const Center(child: Text('Initializing...'));
    }

    if (state is TaskLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is TaskError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error, size: 64, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(
              state.message,
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                context.taskBloc.add(TaskRefreshRequested(userId: userId));
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (state is TaskLoaded || state is TaskOperationInProgress || state is TaskOperationSuccess) {
      final tasks = state is TaskLoaded 
          ? state.filteredTasks
          : state is TaskOperationInProgress
              ? state.filteredTasks
              : (state as TaskOperationSuccess).filteredTasks;

      if (tasks.isEmpty) {
        return const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.task_alt, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                'No tasks found',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
              SizedBox(height: 8),
              Text(
                'Create your first task using the + button',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        );
      }

      return ListView.builder(
        itemCount: tasks.length,
        itemBuilder: (context, index) {
          final task = tasks[index];
          return _buildTaskCard(context, task);
        },
      );
    }

    return const Center(child: Text('Unknown state'));
  }

  Widget _buildTaskCard(BuildContext context, Task task) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: Checkbox(
          value: task.status == TaskStatus.complete,
          onChanged: (_) {
            context.taskBloc.add(TaskToggleStatusRequested(taskId: task.id));
          },
        ),
        title: Text(
          task.title,
          style: TextStyle(
            decoration: task.status == TaskStatus.complete
                ? TextDecoration.lineThrough
                : null,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (task.description.isNotEmpty) ...[
              Text(task.description),
              const SizedBox(height: 4),
            ],
            Row(
              children: [
                _buildPriorityChip(task.priority),
                const SizedBox(width: 8),
                Text(
                  'Due: ${task.dueDate.day}/${task.dueDate.month}/${task.dueDate.year}',
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton(
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit),
                  SizedBox(width: 8),
                  Text('Edit'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Delete', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
          onSelected: (value) {
            if (value == 'delete') {
              _showDeleteConfirmation(context, task);
            }
            // Edit functionality would be implemented here
          },
        ),
      ),
    );
  }

  Widget _buildPriorityChip(TaskPriority priority) {
    Color color;
    switch (priority) {
      case TaskPriority.high:
        color = Colors.red;
        break;
      case TaskPriority.medium:
        color = Colors.orange;
        break;
      case TaskPriority.low:
        color = Colors.green;
        break;
    }

    return Chip(
      label: Text(
        priority.name.toUpperCase(),
        style: const TextStyle(fontSize: 10, color: Colors.white),
      ),
      backgroundColor: color,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  void _showDeleteConfirmation(BuildContext context, Task task) {
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
              context.taskBloc.add(TaskDeleteRequested(taskId: task.id));
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _createSampleTask(BuildContext context) {
    final now = DateTime.now();
    final sampleTask = Task(
      id: '', // Will be generated by the repository
      title: 'Sample Task ${now.millisecondsSinceEpoch}',
      description: 'This is a sample task created at ${now.toString()}',
      dueDate: now.add(const Duration(days: 1)),
      priority: TaskPriority.medium,
      status: TaskStatus.incomplete,
      userId: userId,
      createdAt: now,
      updatedAt: now,
    );

    context.taskBloc.add(TaskCreateRequested(task: sampleTask));
  }
}