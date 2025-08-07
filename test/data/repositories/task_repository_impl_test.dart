import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:takdo/data/datasources/firestore_task_datasource.dart';
import 'package:takdo/data/repositories/task_repository_impl.dart';
import 'package:takdo/domain/entities/task.dart';
import 'package:takdo/domain/entities/task_priority.dart';
import 'package:takdo/domain/entities/task_status.dart';
import 'package:takdo/domain/repositories/task_repository.dart';
import 'package:takdo/domain/exceptions/task_exception.dart';

import 'task_repository_impl_test.mocks.dart';

@GenerateMocks([FirestoreTaskDataSource])
void main() {
  group('TaskRepositoryImpl', () {
    late MockFirestoreTaskDataSource mockDataSource;
    late TaskRepositoryImpl repository;

    final testTask = Task(
      id: 'test-task-id',
      title: 'Test Task',
      description: 'Test Description',
      dueDate: DateTime(2024, 12, 31),
      priority: TaskPriority.medium,
      status: TaskStatus.incomplete,
      userId: 'test-user-id',
      createdAt: DateTime(2024, 1, 1),
      updatedAt: DateTime(2024, 1, 1),
    );

    setUp(() {
      mockDataSource = MockFirestoreTaskDataSource();
      repository = TaskRepositoryImpl(dataSource: mockDataSource);
    });

    group('getTasks', () {
      test('should return list of tasks when successful', () async {
        // Arrange
        final tasks = [testTask];
        when(mockDataSource.getTasks('test-user-id'))
            .thenAnswer((_) async => tasks);

        // Act
        final result = await repository.getTasks('test-user-id');

        // Assert
        expect(result, tasks);
        verify(mockDataSource.getTasks('test-user-id')).called(1);
      });

      test('should throw TaskException when data source fails', () async {
        // Arrange
        when(mockDataSource.getTasks('test-user-id'))
            .thenThrow(const GenericTaskException('Failed to get tasks'));

        // Act & Assert
        expect(
          () => repository.getTasks('test-user-id'),
          throwsA(isA<GenericTaskException>()),
        );
      });
    });

    group('createTask', () {
      test('should return created task when successful', () async {
        // Arrange
        when(mockDataSource.createTask(testTask))
            .thenAnswer((_) async => testTask);

        // Act
        final result = await repository.createTask(testTask);

        // Assert
        expect(result, testTask);
        verify(mockDataSource.createTask(testTask)).called(1);
      });

      test('should throw TaskException when creation fails', () async {
        // Arrange
        when(mockDataSource.createTask(testTask))
            .thenThrow(const TaskValidationException('Invalid task data'));

        // Act & Assert
        expect(
          () => repository.createTask(testTask),
          throwsA(isA<TaskValidationException>()),
        );
      });
    });

    group('updateTask', () {
      test('should return updated task when successful', () async {
        // Arrange
        final updatedTask = testTask.copyWith(title: 'Updated Task');
        when(mockDataSource.updateTask(updatedTask))
            .thenAnswer((_) async => updatedTask);

        // Act
        final result = await repository.updateTask(updatedTask);

        // Assert
        expect(result, updatedTask);
        verify(mockDataSource.updateTask(updatedTask)).called(1);
      });

      test('should throw TaskException when update fails', () async {
        // Arrange
        when(mockDataSource.updateTask(testTask))
            .thenThrow(const TaskNotFoundException());

        // Act & Assert
        expect(
          () => repository.updateTask(testTask),
          throwsA(isA<TaskNotFoundException>()),
        );
      });
    });

    group('deleteTask', () {
      test('should complete successfully when deletion succeeds', () async {
        // Arrange
        when(mockDataSource.deleteTask('test-task-id'))
            .thenAnswer((_) async {});

        // Act
        await repository.deleteTask('test-task-id');

        // Assert
        verify(mockDataSource.deleteTask('test-task-id')).called(1);
      });

      test('should throw TaskException when deletion fails', () async {
        // Arrange
        when(mockDataSource.deleteTask('test-task-id'))
            .thenThrow(const TaskNotFoundException());

        // Act & Assert
        expect(
          () => repository.deleteTask('test-task-id'),
          throwsA(isA<TaskNotFoundException>()),
        );
      });
    });

    group('watchTasks', () {
      test('should return stream of tasks from data source', () {
        // Arrange
        final stream = Stream.value([testTask]);
        when(mockDataSource.watchTasks('test-user-id'))
            .thenAnswer((_) => stream);

        // Act
        final result = repository.watchTasks('test-user-id');

        // Assert
        expect(result, stream);
        verify(mockDataSource.watchTasks('test-user-id')).called(1);
      });
    });

    group('getFilteredTasks', () {
      test('should return filtered tasks when successful', () async {
        // Arrange
        final filteredTasks = [testTask];
        when(mockDataSource.getFilteredTasks(
          userId: 'test-user-id',
          priority: TaskPriority.high,
          status: TaskStatus.incomplete,
          sortBy: TaskSortBy.dueDate,
        )).thenAnswer((_) async => filteredTasks);

        // Act
        final result = await repository.getFilteredTasks(
          userId: 'test-user-id',
          priority: TaskPriority.high,
          status: TaskStatus.incomplete,
          sortBy: TaskSortBy.dueDate,
        );

        // Assert
        expect(result, filteredTasks);
        verify(mockDataSource.getFilteredTasks(
          userId: 'test-user-id',
          priority: TaskPriority.high,
          status: TaskStatus.incomplete,
          sortBy: TaskSortBy.dueDate,
        )).called(1);
      });

      test('should use default sortBy when not specified', () async {
        // Arrange
        final filteredTasks = [testTask];
        when(mockDataSource.getFilteredTasks(
          userId: 'test-user-id',
          sortBy: TaskSortBy.dueDate,
        )).thenAnswer((_) async => filteredTasks);

        // Act
        final result = await repository.getFilteredTasks(
          userId: 'test-user-id',
        );

        // Assert
        expect(result, filteredTasks);
        verify(mockDataSource.getFilteredTasks(
          userId: 'test-user-id',
          sortBy: TaskSortBy.dueDate,
        )).called(1);
      });

      test('should throw TaskException when filtering fails', () async {
        // Arrange
        when(mockDataSource.getFilteredTasks(
          userId: 'test-user-id',
          sortBy: TaskSortBy.dueDate,
        )).thenThrow(const GenericTaskException('Failed to filter tasks'));

        // Act & Assert
        expect(
          () => repository.getFilteredTasks(userId: 'test-user-id'),
          throwsA(isA<GenericTaskException>()),
        );
      });
    });
  });
}