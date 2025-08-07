import 'package:flutter_test/flutter_test.dart';
import 'package:takdo/domain/entities/entities.dart';

void main() {
  group('Task Entity', () {
    test('should create Task with all required fields', () {
      // Arrange
      final now = DateTime.now();
      
      // Act
      final task = Task(
        id: 'test-id',
        title: 'Test Task',
        description: 'Test Description',
        dueDate: now,
        priority: TaskPriority.high,
        status: TaskStatus.incomplete,
        userId: 'user-id',
        createdAt: now,
        updatedAt: now,
      );

      // Assert
      expect(task.id, 'test-id');
      expect(task.title, 'Test Task');
      expect(task.description, 'Test Description');
      expect(task.dueDate, now);
      expect(task.priority, TaskPriority.high);
      expect(task.status, TaskStatus.incomplete);
      expect(task.userId, 'user-id');
      expect(task.createdAt, now);
      expect(task.updatedAt, now);
    });

    test('should support copyWith functionality', () {
      // Arrange
      final now = DateTime.now();
      final task = Task(
        id: 'test-id',
        title: 'Test Task',
        description: 'Test Description',
        dueDate: now,
        priority: TaskPriority.low,
        status: TaskStatus.incomplete,
        userId: 'user-id',
        createdAt: now,
        updatedAt: now,
      );

      // Act
      final updatedTask = task.copyWith(
        title: 'Updated Task',
        priority: TaskPriority.high,
        status: TaskStatus.complete,
      );

      // Assert
      expect(updatedTask.title, 'Updated Task');
      expect(updatedTask.priority, TaskPriority.high);
      expect(updatedTask.status, TaskStatus.complete);
      expect(updatedTask.id, task.id); // unchanged
      expect(updatedTask.description, task.description); // unchanged
    });

    test('should support JSON serialization', () {
      // Arrange
      final now = DateTime.parse('2024-01-01T12:00:00.000Z');
      final task = Task(
        id: 'test-id',
        title: 'Test Task',
        description: 'Test Description',
        dueDate: now,
        priority: TaskPriority.medium,
        status: TaskStatus.incomplete,
        userId: 'user-id',
        createdAt: now,
        updatedAt: now,
      );

      // Act
      final json = task.toJson();
      final taskFromJson = Task.fromJson(json);

      // Assert
      expect(taskFromJson, task);
      expect(json['title'], 'Test Task');
      expect(json['priority'], 'medium');
      expect(json['status'], 'incomplete');
    });
  });

  group('User Entity', () {
    test('should create User with all required fields', () {
      // Arrange
      final now = DateTime.now();
      
      // Act
      final user = User(
        id: 'user-id',
        email: 'test@example.com',
        displayName: 'Test User',
        createdAt: now,
      );

      // Assert
      expect(user.id, 'user-id');
      expect(user.email, 'test@example.com');
      expect(user.displayName, 'Test User');
      expect(user.createdAt, now);
    });

    test('should support JSON serialization', () {
      // Arrange
      final now = DateTime.parse('2024-01-01T12:00:00.000Z');
      final user = User(
        id: 'user-id',
        email: 'test@example.com',
        displayName: 'Test User',
        createdAt: now,
      );

      // Act
      final json = user.toJson();
      final userFromJson = User.fromJson(json);

      // Assert
      expect(userFromJson, user);
      expect(json['email'], 'test@example.com');
      expect(json['displayName'], 'Test User');
    });
  });

  group('TaskPriority Enum', () {
    test('should have correct display names', () {
      expect(TaskPriority.low.displayName, 'Low');
      expect(TaskPriority.medium.displayName, 'Medium');
      expect(TaskPriority.high.displayName, 'High');
    });
  });

  group('TaskStatus Enum', () {
    test('should have correct display names', () {
      expect(TaskStatus.incomplete.displayName, 'Incomplete');
      expect(TaskStatus.complete.displayName, 'Complete');
    });

    test('should have correct isComplete property', () {
      expect(TaskStatus.incomplete.isComplete, false);
      expect(TaskStatus.complete.isComplete, true);
    });
  });
}