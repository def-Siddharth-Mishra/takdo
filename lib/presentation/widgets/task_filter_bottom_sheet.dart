import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/task_priority.dart';
import '../../domain/entities/task_status.dart';
import '../../domain/repositories/task_repository.dart';
import '../bloc/task/task_bloc.dart';
import '../bloc/task/task_event.dart';
import '../bloc/task/task_state.dart';

class TaskFilterBottomSheet extends StatefulWidget {
  const TaskFilterBottomSheet({super.key});

  @override
  State<TaskFilterBottomSheet> createState() => _TaskFilterBottomSheetState();
}

class _TaskFilterBottomSheetState extends State<TaskFilterBottomSheet> {
  TaskPriority? selectedPriority;
  TaskStatus? selectedStatus;
  TaskSortBy selectedSortBy = TaskSortBy.dueDate;

  @override
  void initState() {
    super.initState();
    
    // Initialize with current filter values
    final taskState = context.read<TaskBloc>().state;
    if (taskState is TaskLoaded) {
      selectedPriority = taskState.currentFilter.priority;
      selectedStatus = taskState.currentFilter.status;
      selectedSortBy = taskState.currentFilter.sortBy;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(top: 12),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                const Text(
                  'Filter & Sort Tasks',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    setState(() {
                      selectedPriority = null;
                      selectedStatus = null;
                      selectedSortBy = TaskSortBy.dueDate;
                    });
                  },
                  child: const Text('Clear All'),
                ),
              ],
            ),
          ),

          // Filter options
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Priority filter
                const Text(
                  'Priority',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildPriorityChip(null, 'All'),
                    const SizedBox(width: 8),
                    _buildPriorityChip(TaskPriority.high, 'High'),
                    const SizedBox(width: 8),
                    _buildPriorityChip(TaskPriority.medium, 'Medium'),
                    const SizedBox(width: 8),
                    _buildPriorityChip(TaskPriority.low, 'Low'),
                  ],
                ),

                const SizedBox(height: 24),

                // Status filter
                const Text(
                  'Status',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildStatusChip(null, 'All'),
                    const SizedBox(width: 8),
                    _buildStatusChip(TaskStatus.incomplete, 'Incomplete'),
                    const SizedBox(width: 8),
                    _buildStatusChip(TaskStatus.complete, 'Completed'),
                  ],
                ),

                const SizedBox(height: 24),

                // Sort by
                const Text(
                  'Sort By',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildSortChip(TaskSortBy.dueDate, 'Due Date'),
                    _buildSortChip(TaskSortBy.priority, 'Priority'),
                    _buildSortChip(TaskSortBy.createdAt, 'Created'),
                    _buildSortChip(TaskSortBy.title, 'Title'),
                  ],
                ),

                const SizedBox(height: 32),

                // Apply button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      context.read<TaskBloc>().add(
                        TaskFilterChanged(
                          priority: selectedPriority,
                          status: selectedStatus,
                          sortBy: selectedSortBy,
                        ),
                      );
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Apply Filters',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriorityChip(TaskPriority? priority, String label) {
    final isSelected = selectedPriority == priority;
    Color? chipColor;
    
    if (priority != null) {
      switch (priority) {
        case TaskPriority.high:
          chipColor = Colors.red;
          break;
        case TaskPriority.medium:
          chipColor = Colors.orange;
          break;
        case TaskPriority.low:
          chipColor = Colors.green;
          break;
      }
    }

    return FilterChip(
      label: Text(
        label,
        style: TextStyle(
          color: isSelected
              ? (chipColor ?? Theme.of(context).colorScheme.onPrimary)
              : (chipColor ?? Colors.grey[700]),
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          selectedPriority = selected ? priority : null;
        });
      },
      backgroundColor: chipColor?.withOpacity(0.1),
      selectedColor: chipColor ?? Theme.of(context).colorScheme.primary,
      checkmarkColor: chipColor != null 
          ? Colors.white 
          : Theme.of(context).colorScheme.onPrimary,
      side: chipColor != null
          ? BorderSide(color: chipColor.withOpacity(0.3))
          : null,
    );
  }

  Widget _buildStatusChip(TaskStatus? status, String label) {
    final isSelected = selectedStatus == status;
    Color? chipColor;
    
    if (status != null) {
      switch (status) {
        case TaskStatus.complete:
          chipColor = Colors.green;
          break;
        case TaskStatus.incomplete:
          chipColor = Colors.blue;
          break;
      }
    }

    return FilterChip(
      label: Text(
        label,
        style: TextStyle(
          color: isSelected
              ? (chipColor ?? Theme.of(context).colorScheme.onPrimary)
              : (chipColor ?? Colors.grey[700]),
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          selectedStatus = selected ? status : null;
        });
      },
      backgroundColor: chipColor?.withOpacity(0.1),
      selectedColor: chipColor ?? Theme.of(context).colorScheme.primary,
      checkmarkColor: chipColor != null 
          ? Colors.white 
          : Theme.of(context).colorScheme.onPrimary,
      side: chipColor != null
          ? BorderSide(color: chipColor.withOpacity(0.3))
          : null,
    );
  }

  Widget _buildSortChip(TaskSortBy sortBy, String label) {
    final isSelected = selectedSortBy == sortBy;

    return FilterChip(
      label: Text(
        label,
        style: TextStyle(
          color: isSelected
              ? Theme.of(context).colorScheme.onPrimary
              : Colors.grey[700],
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          setState(() {
            selectedSortBy = sortBy;
          });
        }
      },
      selectedColor: Theme.of(context).colorScheme.primary,
      checkmarkColor: Theme.of(context).colorScheme.onPrimary,
    );
  }
}