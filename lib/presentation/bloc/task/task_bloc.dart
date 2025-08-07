import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/task.dart';
import '../../../domain/entities/task_priority.dart';
import '../../../domain/entities/task_status.dart';
import '../../../domain/repositories/task_repository.dart';
import '../../../domain/exceptions/task_exception.dart';
import 'task_event.dart';
import 'task_state.dart';

/// BLoC for managing task-related state and operations
class TaskBloc extends Bloc<TaskEvent, TaskState> {
  final TaskRepository _taskRepository;
  StreamSubscription<List<Task>>? _tasksSubscription;

  TaskBloc({
    required TaskRepository taskRepository,
  })  : _taskRepository = taskRepository,
        super(const TaskInitial()) {
    // Register event handlers
    on<TasksLoadRequested>(_onTasksLoadRequested);
    on<TaskCreateRequested>(_onTaskCreateRequested);
    on<TaskUpdateRequested>(_onTaskUpdateRequested);
    on<TaskDeleteRequested>(_onTaskDeleteRequested);
    on<TaskToggleStatusRequested>(_onTaskToggleStatusRequested);
    on<TaskFilterChanged>(_onTaskFilterChanged);
    on<TaskFilterCleared>(_onTaskFilterCleared);
    on<TaskRefreshRequested>(_onTaskRefreshRequested);
    on<_TaskStreamUpdate>(_onTaskStreamUpdate);
    on<_TaskStreamError>(_onTaskStreamError);
  }

  @override
  Future<void> close() {
    _tasksSubscription?.cancel();
    return super.close();
  }

  /// Handles loading tasks for a user
  Future<void> _onTasksLoadRequested(
    TasksLoadRequested event,
    Emitter<TaskState> emit,
  ) async {
    try {
      emit(const TaskLoading());

      // Cancel any existing subscription
      await _tasksSubscription?.cancel();

      // Start listening to real-time task updates
      _tasksSubscription = _taskRepository.watchTasks(event.userId).listen(
        (tasks) {
          if (!isClosed) {
            final currentState = state;
            final filter = currentState is TaskLoaded 
                ? currentState.currentFilter 
                : const TaskFilter();
            
            final filteredTasks = _applyFilters(tasks, filter);
            
            add(_TaskStreamUpdate(
              tasks: tasks,
              filter: filter,
              filteredTasks: filteredTasks,
            ));
          }
        },
        onError: (error) {
          if (!isClosed) {
            add(_TaskStreamError(error: error));
          }
        },
      );
    } catch (error) {
      emit(TaskError(message: _getErrorMessage(error)));
    }
  }

  /// Handles creating a new task
  Future<void> _onTaskCreateRequested(
    TaskCreateRequested event,
    Emitter<TaskState> emit,
  ) async {
    final currentState = state;
    if (currentState is TaskLoaded) {
      emit(TaskOperationInProgress(
        tasks: currentState.tasks,
        currentFilter: currentState.currentFilter,
        filteredTasks: currentState.filteredTasks,
        operationType: 'creating',
      ));

      try {
        await _taskRepository.createTask(event.task);
        
        // Success state will be handled by the stream listener
        emit(TaskOperationSuccess(
          tasks: currentState.tasks,
          currentFilter: currentState.currentFilter,
          filteredTasks: currentState.filteredTasks,
          message: 'Task created successfully',
        ));
      } catch (error) {
        emit(TaskError(
          message: _getErrorMessage(error),
          tasks: currentState.tasks,
          currentFilter: currentState.currentFilter,
          filteredTasks: currentState.filteredTasks,
        ));
      }
    }
  }

  /// Handles updating an existing task
  Future<void> _onTaskUpdateRequested(
    TaskUpdateRequested event,
    Emitter<TaskState> emit,
  ) async {
    final currentState = state;
    if (currentState is TaskLoaded) {
      emit(TaskOperationInProgress(
        tasks: currentState.tasks,
        currentFilter: currentState.currentFilter,
        filteredTasks: currentState.filteredTasks,
        operationType: 'updating',
      ));

      try {
        await _taskRepository.updateTask(event.task);
        
        emit(TaskOperationSuccess(
          tasks: currentState.tasks,
          currentFilter: currentState.currentFilter,
          filteredTasks: currentState.filteredTasks,
          message: 'Task updated successfully',
        ));
      } catch (error) {
        emit(TaskError(
          message: _getErrorMessage(error),
          tasks: currentState.tasks,
          currentFilter: currentState.currentFilter,
          filteredTasks: currentState.filteredTasks,
        ));
      }
    }
  }

  /// Handles deleting a task
  Future<void> _onTaskDeleteRequested(
    TaskDeleteRequested event,
    Emitter<TaskState> emit,
  ) async {
    final currentState = state;
    if (currentState is TaskLoaded) {
      emit(TaskOperationInProgress(
        tasks: currentState.tasks,
        currentFilter: currentState.currentFilter,
        filteredTasks: currentState.filteredTasks,
        operationType: 'deleting',
      ));

      try {
        await _taskRepository.deleteTask(event.taskId);
        
        emit(TaskOperationSuccess(
          tasks: currentState.tasks,
          currentFilter: currentState.currentFilter,
          filteredTasks: currentState.filteredTasks,
          message: 'Task deleted successfully',
        ));
      } catch (error) {
        emit(TaskError(
          message: _getErrorMessage(error),
          tasks: currentState.tasks,
          currentFilter: currentState.currentFilter,
          filteredTasks: currentState.filteredTasks,
        ));
      }
    }
  }

  /// Handles toggling task completion status
  Future<void> _onTaskToggleStatusRequested(
    TaskToggleStatusRequested event,
    Emitter<TaskState> emit,
  ) async {
    final currentState = state;
    if (currentState is TaskLoaded) {
      try {
        // Find the task to toggle
        final task = currentState.tasks.firstWhere(
          (task) => task.id == event.taskId,
        );

        // Toggle the status
        final updatedTask = task.copyWith(
          status: task.status == TaskStatus.complete 
              ? TaskStatus.incomplete 
              : TaskStatus.complete,
          updatedAt: DateTime.now(),
        );

        // Update the task
        add(TaskUpdateRequested(task: updatedTask));
      } catch (error) {
        emit(TaskError(
          message: 'Task not found',
          tasks: currentState.tasks,
          currentFilter: currentState.currentFilter,
          filteredTasks: currentState.filteredTasks,
        ));
      }
    }
  }

  /// Handles applying filters to tasks
  Future<void> _onTaskFilterChanged(
    TaskFilterChanged event,
    Emitter<TaskState> emit,
  ) async {
    final currentState = state;
    if (currentState is TaskLoaded) {
      final newFilter = TaskFilter(
        priority: event.priority,
        status: event.status,
        sortBy: event.sortBy,
      );

      final filteredTasks = _applyFilters(currentState.tasks, newFilter);

      emit(TaskLoaded(
        tasks: currentState.tasks,
        currentFilter: newFilter,
        filteredTasks: filteredTasks,
      ));
    }
  }

  /// Handles clearing all filters
  Future<void> _onTaskFilterCleared(
    TaskFilterCleared event,
    Emitter<TaskState> emit,
  ) async {
    final currentState = state;
    if (currentState is TaskLoaded) {
      const clearedFilter = TaskFilter();
      final filteredTasks = _applyFilters(currentState.tasks, clearedFilter);

      emit(TaskLoaded(
        tasks: currentState.tasks,
        currentFilter: clearedFilter,
        filteredTasks: filteredTasks,
      ));
    }
  }

  /// Handles refreshing tasks
  Future<void> _onTaskRefreshRequested(
    TaskRefreshRequested event,
    Emitter<TaskState> emit,
  ) async {
    // Simply reload tasks
    add(TasksLoadRequested(userId: event.userId));
  }

  /// Handles stream updates from the repository
  Future<void> _onTaskStreamUpdate(
    _TaskStreamUpdate event,
    Emitter<TaskState> emit,
  ) async {
    emit(TaskLoaded(
      tasks: event.tasks,
      currentFilter: event.filter,
      filteredTasks: event.filteredTasks,
    ));
  }

  /// Handles stream errors from the repository
  Future<void> _onTaskStreamError(
    _TaskStreamError event,
    Emitter<TaskState> emit,
  ) async {
    emit(TaskError(
      message: _getErrorMessage(event.error),
      tasks: state is TaskLoaded ? (state as TaskLoaded).tasks : null,
      currentFilter: state is TaskLoaded ? (state as TaskLoaded).currentFilter : null,
      filteredTasks: state is TaskLoaded ? (state as TaskLoaded).filteredTasks : null,
    ));
  }

  /// Applies filters and sorting to a list of tasks
  List<Task> _applyFilters(List<Task> tasks, TaskFilter filter) {
    var filteredTasks = List<Task>.from(tasks);

    // Apply priority filter
    if (filter.priority != null) {
      filteredTasks = filteredTasks
          .where((task) => task.priority == filter.priority)
          .toList();
    }

    // Apply status filter
    if (filter.status != null) {
      filteredTasks = filteredTasks
          .where((task) => task.status == filter.status)
          .toList();
    }

    // Apply sorting
    switch (filter.sortBy) {
      case TaskSortBy.dueDate:
        filteredTasks.sort((a, b) => a.dueDate.compareTo(b.dueDate));
        break;
      case TaskSortBy.createdAt:
        filteredTasks.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case TaskSortBy.priority:
        filteredTasks.sort((a, b) => _comparePriority(a.priority, b.priority));
        break;
      case TaskSortBy.title:
        filteredTasks.sort((a, b) => a.title.compareTo(b.title));
        break;
    }

    return filteredTasks;
  }

  /// Compares task priorities for sorting (high > medium > low)
  int _comparePriority(TaskPriority a, TaskPriority b) {
    const priorityOrder = {
      TaskPriority.high: 3,
      TaskPriority.medium: 2,
      TaskPriority.low: 1,
    };
    
    return priorityOrder[b]!.compareTo(priorityOrder[a]!);
  }

  /// Converts various error types to user-friendly messages
  String _getErrorMessage(dynamic error) {
    if (error is TaskException) {
      return error.message;
    }
    
    // Handle common error types
    final errorString = error.toString().toLowerCase();
    
    if (errorString.contains('network') || errorString.contains('connection')) {
      return 'Network error. Please check your connection and try again.';
    }
    
    if (errorString.contains('permission')) {
      return 'You don\'t have permission to perform this action.';
    }
    
    if (errorString.contains('not found')) {
      return 'Task not found.';
    }
    
    return 'An unexpected error occurred. Please try again.';
  }
}

/// Internal event for updating state from stream
class _TaskStreamUpdate extends TaskEvent {
  final List<Task> tasks;
  final TaskFilter filter;
  final List<Task> filteredTasks;

  const _TaskStreamUpdate({
    required this.tasks,
    required this.filter,
    required this.filteredTasks,
  });

  @override
  List<Object?> get props => [tasks, filter, filteredTasks];
}

/// Internal event for handling stream errors
class _TaskStreamError extends TaskEvent {
  final dynamic error;

  const _TaskStreamError({required this.error});

  @override
  List<Object?> get props => [error];
}

