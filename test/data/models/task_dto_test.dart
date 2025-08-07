import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:takdo/data/models/task_dto.dart';
import 'package:takdo/domain/entities/task.dart';
import 'package:takdo/domain/entities/task_priority.dart';
import 'package:takdo/domain/entities/task_status.dart';

void main() {
  group('TaskDto', () {
    final testDateTime = DateTime(2024, 12, 31, 12, 0, 0);
    final testTimestamp = Timestamp.fromDate(testDateTime);

    final testTaskDto = TaskDto(
      id: 'test-id',
      title: 'Test Task',
      description: 'Test Description',
      dueDate: testDateTime,
      priority: 'medium',
      status: 'incomplete',
      userId: 'user-id',
      createdAt: testDateTime,
      updatedAt: testDateTime,
    );

    final testTask = Task(
      id: 'test-id',
      title: 'Test Task',
      description: 'Test Description',
      dueDate: testDateTime,
      priority: TaskPriority.medium,
      status: TaskStatus.incomplete,
      userId: 'user-id',
      createdAt: testDateTime,
      updatedAt: testDateTime,
    );

    group('JSON serialization', () {
      test('should serialize to JSON correctly', () {
        // Act
        final json = testTaskDto.toJson();

        // Assert
        expect(json['id'], 'test-id');
        expect(json['title'], 'Test Task');
        expect(json['description'], 'Test Description');
        expect(json['dueDate'], isA<Timestamp>());
        expect(json['priority'], 'medium');
        expect(json['status'], 'incomplete');
        expect(json['userId'], 'user-id');
        expect(json['createdAt'], isA<Timestamp>());
        expect(json['updatedAt'], isA<Timestamp>());
      });

      test('should deserialize from JSON correctly', () {
        // Arrange
        final json = {
          'id': 'test-id',
          'title': 'Test Task',
          'description': 'Test Description',
          'dueDate': testTimestamp,
          'priority': 'medium',
          'status': 'incomplete',
          'userId': 'user-id',
          'createdAt': testTimestamp,
          'updatedAt': testTimestamp,
        };

        // Act
        final taskDto = TaskDto.fromJson(json);

        // Assert
        expect(taskDto, testTaskDto);
      });
    });

    group('Domain conversion', () {
      test('should convert from domain entity correctly', () {
        // Act
        final taskDto = TaskDto.fromDomain(testTask);

        // Assert
        expect(taskDto.id, testTask.id);
        expect(taskDto.title, testTask.title);
        expect(taskDto.description, testTask.description);
        expect(taskDto.dueDate, testTask.dueDate);
        expect(taskDto.priority, testTask.priority.name);
        expect(taskDto.status, testTask.status.name);
        expect(taskDto.userId, testTask.userId);
        expect(taskDto.createdAt, testTask.createdAt);
        expect(taskDto.updatedAt, testTask.updatedAt);
      });

      test('should convert to domain entity correctly', () {
        // Act
        final task = testTaskDto.toDomain();

        // Assert
        expect(task.id, testTaskDto.id);
        expect(task.title, testTaskDto.title);
        expect(task.description, testTaskDto.description);
        expect(task.dueDate, testTaskDto.dueDate);
        expect(task.priority, TaskPriority.medium);
        expect(task.status, TaskStatus.incomplete);
        expect(task.userId, testTaskDto.userId);
        expect(task.createdAt, testTaskDto.createdAt);
        expect(task.updatedAt, testTaskDto.updatedAt);
      });

      test('should handle all priority values correctly', () {
        // Test low priority
        final lowPriorityDto = testTaskDto.copyWith(priority: 'low');
        expect(lowPriorityDto.toDomain().priority, TaskPriority.low);

        // Test medium priority
        final mediumPriorityDto = testTaskDto.copyWith(priority: 'medium');
        expect(mediumPriorityDto.toDomain().priority, TaskPriority.medium);

        // Test high priority
        final highPriorityDto = testTaskDto.copyWith(priority: 'high');
        expect(highPriorityDto.toDomain().priority, TaskPriority.high);
      });

      test('should handle all status values correctly', () {
        // Test incomplete status
        final incompleteDto = testTaskDto.copyWith(status: 'incomplete');
        expect(incompleteDto.toDomain().status, TaskStatus.incomplete);

        // Test complete status
        final completeDto = testTaskDto.copyWith(status: 'complete');
        expect(completeDto.toDomain().status, TaskStatus.complete);
      });
    });

    group('copyWith functionality', () {
      test('should create copy with updated fields', () {
        // Act
        final updatedDto = testTaskDto.copyWith(
          title: 'Updated Task',
          priority: 'high',
          status: 'complete',
        );

        // Assert
        expect(updatedDto.title, 'Updated Task');
        expect(updatedDto.priority, 'high');
        expect(updatedDto.status, 'complete');
        expect(updatedDto.id, testTaskDto.id); // unchanged
        expect(updatedDto.description, testTaskDto.description); // unchanged
      });
    });

    group('equality', () {
      test('should be equal when all fields match', () {
        // Arrange
        final dto1 = testTaskDto;
        final dto2 = testTaskDto.copyWith();

        // Assert
        expect(dto1, dto2);
        expect(dto1.hashCode, dto2.hashCode);
      });

      test('should not be equal when fields differ', () {
        // Arrange
        final dto1 = testTaskDto;
        final dto2 = testTaskDto.copyWith(title: 'Different Title');

        // Assert
        expect(dto1, isNot(dto2));
        expect(dto1.hashCode, isNot(dto2.hashCode));
      });
    });
  });
}