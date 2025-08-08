import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../../core/app_constants.dart';
import 'task_card.dart';

class TaskSection extends StatelessWidget {
  final String title;
  final List<TaskItem> tasks;

  const TaskSection({
    super.key,
    required this.title,
    required this.tasks,
  });

  @override
  Widget build(BuildContext context) {
    if (tasks.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacing20),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.onSurface,
            ),
          ),
        ),
        const SizedBox(height: AppConstants.spacing16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacing20),
          child: Column(
            children: tasks.map((task) => TaskCard(
              title: task.title,
              subtitle: task.subtitle,
              tags: task.tags,
              isCompleted: task.isCompleted,
              onTap: task.onTap,
              onToggleComplete: task.onToggleComplete,
              onDelete: task.onDelete,
            )).toList(),
          ),
        ),
        const SizedBox(height: AppConstants.spacing24),
      ],
    );
  }
}

class TaskItem {
  final String title;
  final String subtitle;
  final List<String> tags;
  final bool isCompleted;
  final VoidCallback? onTap;
  final VoidCallback? onToggleComplete;
  final VoidCallback? onDelete;

  TaskItem({
    required this.title,
    this.subtitle = '',
    this.tags = const [],
    this.isCompleted = false,
    this.onTap,
    this.onToggleComplete,
    this.onDelete,
  });
}