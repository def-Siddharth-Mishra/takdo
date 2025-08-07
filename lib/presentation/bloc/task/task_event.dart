import 'package:equatable/equatable.dart';
import '../../../domain/entities/task.dart';
import '../../../domain/entities/task_priority.dart';
import '../../../domain/entities/task_status.dart';
import '../../../domain/repositories/task_repository.dart';

/// Base class for all task events
abstract class TaskEvent extends Equatable {
  const TaskEvent();

  @override
  List<Object?> get props => [];
}

/// Event to load tasks for a user
class TasksLoadRequested extends TaskEvent {
  final String userId;

  const TasksLoadRequested({required this.userId});

  @override
  List<Object?> get props => [userId];
}

/// Event to create a new task
class TaskCreateRequested extends TaskEvent {
  final Task task;

  const TaskCreateRequested({required this.task});

  @override
  List<Object?> get props => [task];
}

/// Event to update an existing task
class TaskUpdateRequested extends TaskEvent {
  final Task task;

  const TaskUpdateRequested({required this.task});

  @override
  List<Object?> get props => [task];
}

/// Event to delete a task
class TaskDeleteRequested extends TaskEvent {
  final String taskId;

  const TaskDeleteRequested({required this.taskId});

  @override
  List<Object?> get props => [taskId];
}

/// Event to toggle task completion status
class TaskToggleStatusRequested extends TaskEvent {
  final String taskId;

  const TaskToggleStatusRequested({required this.taskId});

  @override
  List<Object?> get props => [taskId];
}

/// Event to apply filters to tasks
class TaskFilterChanged extends TaskEvent {
  final TaskPriority? priority;
  final TaskStatus? status;
  final TaskSortBy sortBy;

  const TaskFilterChanged({
    this.priority,
    this.status,
    this.sortBy = TaskSortBy.dueDate,
  });

  @override
  List<Object?> get props => [priority, status, sortBy];
}

/// Event to clear all filters
class TaskFilterCleared extends TaskEvent {
  const TaskFilterCleared();
}

/// Event to refresh tasks (reload from repository)
class TaskRefreshRequested extends TaskEvent {
  final String userId;

  const TaskRefreshRequested({required this.userId});

  @override
  List<Object?> get props => [userId];
}