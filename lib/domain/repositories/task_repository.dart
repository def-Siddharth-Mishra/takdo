import '../entities/task.dart';
import '../entities/task_priority.dart';
import '../entities/task_status.dart';

/// Enum for task sorting options
enum TaskSortBy {
  dueDate,
  createdAt,
  priority,
  title,
}

/// Repository interface for task operations
abstract class TaskRepository {
  /// Get all tasks for a specific user
  /// Throws [TaskException] on failure
  Future<List<Task>> getTasks(String userId);

  /// Create a new task
  /// Throws [TaskException] on failure
  Future<Task> createTask(Task task);

  /// Update an existing task
  /// Throws [TaskException] on failure
  Future<Task> updateTask(Task task);

  /// Delete a task by ID
  /// Throws [TaskException] on failure
  Future<void> deleteTask(String taskId);

  /// Watch tasks for real-time updates
  /// Returns a stream of task lists for the specified user
  Stream<List<Task>> watchTasks(String userId);

  /// Get filtered and sorted tasks
  /// Throws [TaskException] on failure
  Future<List<Task>> getFilteredTasks({
    required String userId,
    TaskPriority? priority,
    TaskStatus? status,
    TaskSortBy sortBy = TaskSortBy.dueDate,
  });
}