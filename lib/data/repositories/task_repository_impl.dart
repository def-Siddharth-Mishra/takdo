import '../../domain/entities/task.dart';
import '../../domain/entities/task_priority.dart';
import '../../domain/entities/task_status.dart';
import '../../domain/repositories/task_repository.dart';
import '../datasources/firestore_task_datasource.dart';

/// Implementation of TaskRepository using Firestore
class TaskRepositoryImpl implements TaskRepository {
  final FirestoreTaskDataSource _dataSource;

  TaskRepositoryImpl({
    required FirestoreTaskDataSource dataSource,
  }) : _dataSource = dataSource;

  @override
  Future<List<Task>> getTasks(String userId) {
    return _dataSource.getTasks(userId);
  }

  @override
  Future<Task> createTask(Task task) {
    return _dataSource.createTask(task);
  }

  @override
  Future<Task> updateTask(Task task) {
    return _dataSource.updateTask(task);
  }

  @override
  Future<void> deleteTask(String taskId) {
    return _dataSource.deleteTask(taskId);
  }

  @override
  Stream<List<Task>> watchTasks(String userId) {
    return _dataSource.watchTasks(userId);
  }

  @override
  Future<List<Task>> getFilteredTasks({
    required String userId,
    TaskPriority? priority,
    TaskStatus? status,
    TaskSortBy sortBy = TaskSortBy.dueDate,
  }) {
    return _dataSource.getFilteredTasks(
      userId: userId,
      priority: priority,
      status: status,
      sortBy: sortBy,
    );
  }
}