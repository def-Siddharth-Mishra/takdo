import 'package:equatable/equatable.dart';
import '../../../domain/entities/task.dart';
import '../../../domain/entities/task_priority.dart';
import '../../../domain/entities/task_status.dart';
import '../../../domain/repositories/task_repository.dart';

/// Filter configuration for tasks
class TaskFilter extends Equatable {
  final TaskPriority? priority;
  final TaskStatus? status;
  final TaskSortBy sortBy;

  const TaskFilter({
    this.priority,
    this.status,
    this.sortBy = TaskSortBy.dueDate,
  });

  /// Creates a copy of this filter with updated values
  TaskFilter copyWith({
    TaskPriority? priority,
    TaskStatus? status,
    TaskSortBy? sortBy,
  }) {
    return TaskFilter(
      priority: priority ?? this.priority,
      status: status ?? this.status,
      sortBy: sortBy ?? this.sortBy,
    );
  }

  /// Returns true if any filters are applied
  bool get hasActiveFilters => priority != null || status != null;

  /// Returns a cleared version of this filter (no filters applied)
  TaskFilter get cleared => const TaskFilter();

  @override
  List<Object?> get props => [priority, status, sortBy];
}

/// Base class for all task states
abstract class TaskState extends Equatable {
  const TaskState();

  @override
  List<Object?> get props => [];
}

/// Initial state when the BLoC is first created
class TaskInitial extends TaskState {
  const TaskInitial();
}

/// State when tasks are being loaded
class TaskLoading extends TaskState {
  const TaskLoading();
}

/// State when tasks are successfully loaded
class TaskLoaded extends TaskState {
  final List<Task> tasks;
  final TaskFilter currentFilter;
  final List<Task> filteredTasks;

  const TaskLoaded({
    required this.tasks,
    required this.currentFilter,
    required this.filteredTasks,
  });

  /// Creates a copy of this state with updated values
  TaskLoaded copyWith({
    List<Task>? tasks,
    TaskFilter? currentFilter,
    List<Task>? filteredTasks,
  }) {
    return TaskLoaded(
      tasks: tasks ?? this.tasks,
      currentFilter: currentFilter ?? this.currentFilter,
      filteredTasks: filteredTasks ?? this.filteredTasks,
    );
  }

  @override
  List<Object?> get props => [tasks, currentFilter, filteredTasks];
}

/// State when a task operation is in progress (create, update, delete)
class TaskOperationInProgress extends TaskState {
  final List<Task> tasks;
  final TaskFilter currentFilter;
  final List<Task> filteredTasks;
  final String operationType; // 'creating', 'updating', 'deleting'

  const TaskOperationInProgress({
    required this.tasks,
    required this.currentFilter,
    required this.filteredTasks,
    required this.operationType,
  });

  @override
  List<Object?> get props => [tasks, currentFilter, filteredTasks, operationType];
}

/// State when an error occurs
class TaskError extends TaskState {
  final String message;
  final List<Task>? tasks;
  final TaskFilter? currentFilter;
  final List<Task>? filteredTasks;

  const TaskError({
    required this.message,
    this.tasks,
    this.currentFilter,
    this.filteredTasks,
  });

  @override
  List<Object?> get props => [message, tasks, currentFilter, filteredTasks];
}

/// State when a task operation is successful
class TaskOperationSuccess extends TaskState {
  final List<Task> tasks;
  final TaskFilter currentFilter;
  final List<Task> filteredTasks;
  final String message;

  const TaskOperationSuccess({
    required this.tasks,
    required this.currentFilter,
    required this.filteredTasks,
    required this.message,
  });

  @override
  List<Object?> get props => [tasks, currentFilter, filteredTasks, message];
}