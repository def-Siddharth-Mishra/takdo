import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/task.dart';
import '../../domain/entities/task_priority.dart';
import '../../domain/entities/task_status.dart';
import '../../domain/repositories/task_repository.dart';
import '../../domain/exceptions/task_exception.dart';
import '../models/task_dto.dart';

/// Data source for Firestore task operations
class FirestoreTaskDataSource {
  final FirebaseFirestore _firestore;
  static const String _collection = 'tasks';

  FirestoreTaskDataSource({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Get all tasks for a specific user
  Future<List<Task>> getTasks(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .orderBy('dueDate')
          .get();

      return querySnapshot.docs
          .map((doc) => TaskDto.fromJson({
                'id': doc.id,
                ...doc.data(),
              }).toDomain())
          .toList();
    } catch (e) {
      throw GenericTaskException('Failed to get tasks: ${e.toString()}');
    }
  }

  /// Create a new task
  Future<Task> createTask(Task task) async {
    try {
      final taskDto = TaskDto.fromDomain(task);
      final docRef = await _firestore
          .collection(_collection)
          .add(taskDto.toJson());

      // Update the task with the generated ID
      final updatedTask = task.copyWith(id: docRef.id);
      
      await docRef.update({'id': docRef.id});

      return updatedTask;
    } catch (e) {
      throw GenericTaskException('Failed to create task: ${e.toString()}');
    }
  }

  /// Update an existing task
  Future<Task> updateTask(Task task) async {
    try {
      final taskDto = TaskDto.fromDomain(task.copyWith(
        updatedAt: DateTime.now(),
      ));

      await _firestore
          .collection(_collection)
          .doc(task.id)
          .update(taskDto.toJson());

      return task.copyWith(updatedAt: DateTime.now());
    } catch (e) {
      throw GenericTaskException('Failed to update task: ${e.toString()}');
    }
  }

  /// Delete a task by ID
  Future<void> deleteTask(String taskId) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(taskId)
          .delete();
    } catch (e) {
      throw GenericTaskException('Failed to delete task: ${e.toString()}');
    }
  }

  /// Watch tasks for real-time updates
  Stream<List<Task>> watchTasks(String userId) {
    try {
      return _firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .orderBy('dueDate')
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => TaskDto.fromJson({
                    'id': doc.id,
                    ...doc.data(),
                  }).toDomain())
              .toList());
    } catch (e) {
      throw GenericTaskException('Failed to watch tasks: ${e.toString()}');
    }
  }

  /// Get filtered and sorted tasks
  Future<List<Task>> getFilteredTasks({
    required String userId,
    TaskPriority? priority,
    TaskStatus? status,
    TaskSortBy sortBy = TaskSortBy.dueDate,
  }) async {
    try {
      Query query = _firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId);

      // Apply filters
      if (priority != null) {
        query = query.where('priority', isEqualTo: priority.name);
      }

      if (status != null) {
        query = query.where('status', isEqualTo: status.name);
      }

      // Apply sorting
      String orderByField;
      switch (sortBy) {
        case TaskSortBy.dueDate:
          orderByField = 'dueDate';
          break;
        case TaskSortBy.createdAt:
          orderByField = 'createdAt';
          break;
        case TaskSortBy.priority:
          orderByField = 'priority';
          break;
        case TaskSortBy.title:
          orderByField = 'title';
          break;
      }

      query = query.orderBy(orderByField);

      final querySnapshot = await query.get();

      List<Task> tasks = querySnapshot.docs
          .map((doc) => TaskDto.fromJson({
                'id': doc.id,
                ...doc.data() as Map<String, dynamic>,
              }).toDomain())
          .toList();

      // Additional sorting for priority (since Firestore doesn't sort enums properly)
      if (sortBy == TaskSortBy.priority) {
        tasks.sort((a, b) {
          const priorityOrder = {
            TaskPriority.high: 0,
            TaskPriority.medium: 1,
            TaskPriority.low: 2,
          };
          return priorityOrder[a.priority]!.compareTo(priorityOrder[b.priority]!);
        });
      }

      return tasks;
    } catch (e) {
      throw GenericTaskException('Failed to get filtered tasks: ${e.toString()}');
    }
  }
}