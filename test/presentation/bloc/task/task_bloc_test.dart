import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:takdo/domain/entities/task.dart';
import 'package:takdo/domain/entities/task_priority.dart';
import 'package:takdo/domain/entities/task_status.dart';
import 'package:takdo/domain/repositories/task_repository.dart';
import 'package:takdo/domain/exceptions/task_exception.dart';
import 'package:takdo/presentation/bloc/task/task.dart';

import 'task_bloc_test.mocks.dart';

@GenerateMocks([TaskRepository])
void main() {
  group('TaskBloc', () {
    late MockTaskRepository mockTaskRepository;
    late TaskBloc taskBloc;

    final testUserId = 'test-user-id';
    final testTask = Task(
      id: 'test-task-id',
      title: 'Test Task',
      description: 'Test Description',
      dueDate: DateTime(2024, 12, 31),
      priority: TaskPriority.medium,
      status: TaskStatus.incomplete,
      userId: testUserId,
      createdAt: DateTime(2024, 1, 1),
      updatedAt: DateTime(2024, 1, 1),
    );

    setUp(() {
      mockTaskRepository = MockTaskRepository();
      taskBloc = TaskBloc(taskRepository: mockTaskRepository);
    });

    tearDown(() {
      taskBloc.close();
    });

    test('initial state is TaskInitial', () {
      expect(taskBloc.state, equals(const TaskInitial()));
    });

    group('TasksLoadRequested', () {
      blocTest<TaskBloc, TaskState>(
        'emits [TaskLoading, TaskLoaded] when tasks are loaded successfully',
        build: () {
          when(mockTaskRepository.watchTasks(testUserId))
              .thenAnswer((_) => Stream.value([testTask]));
          return taskBloc;
        },
        act: (bloc) => bloc.add(TasksLoadRequested(userId: testUserId)),
        expect: () => [
          const TaskLoading(),
          isA<TaskLoaded>()
              .having((state) => state.tasks, 'tasks', [testTask])
              .having((state) => state.filteredTasks, 'filteredTasks', [testTask])
              .having((state) => state.currentFilter, 'currentFilter', const TaskFilter()),
        ],
        verify: (_) {
          verify(mockTaskRepository.watchTasks(testUserId)).called(1);
        },
      );

      blocTest<TaskBloc, TaskState>(
        'emits [TaskLoading, TaskError] when loading tasks fails',
        build: () {
          when(mockTaskRepository.watchTasks(testUserId))
              .thenAnswer((_) => Stream.error(const TaskNotFoundException()));
          return taskBloc;
        },
        act: (bloc) => bloc.add(TasksLoadRequested(userId: testUserId)),
        expect: () => [
          const TaskLoading(),
          isA<TaskError>()
              .having((state) => state.message, 'message', 'Task not found'),
        ],
      );
    });

    group('TaskCreateRequested', () {
      blocTest<TaskBloc, TaskState>(
        'emits [TaskOperationInProgress, TaskOperationSuccess] when task is created successfully',
        build: () {
          when(mockTaskRepository.createTask(testTask))
              .thenAnswer((_) async => testTask);
          return taskBloc;
        },
        seed: () => TaskLoaded(
          tasks: const [],
          currentFilter: const TaskFilter(),
          filteredTasks: const [],
        ),
        act: (bloc) => bloc.add(TaskCreateRequested(task: testTask)),
        expect: () => [
          isA<TaskOperationInProgress>()
              .having((state) => state.operationType, 'operationType', 'creating'),
          isA<TaskOperationSuccess>()
              .having((state) => state.message, 'message', 'Task created successfully'),
        ],
        verify: (_) {
          verify(mockTaskRepository.createTask(testTask)).called(1);
        },
      );

      blocTest<TaskBloc, TaskState>(
        'emits [TaskOperationInProgress, TaskError] when task creation fails',
        build: () {
          when(mockTaskRepository.createTask(testTask))
              .thenThrow(const TaskValidationException('Invalid task data'));
          return taskBloc;
        },
        seed: () => TaskLoaded(
          tasks: const [],
          currentFilter: const TaskFilter(),
          filteredTasks: const [],
        ),
        act: (bloc) => bloc.add(TaskCreateRequested(task: testTask)),
        expect: () => [
          isA<TaskOperationInProgress>()
              .having((state) => state.operationType, 'operationType', 'creating'),
          isA<TaskError>()
              .having((state) => state.message, 'message', 'Invalid task data'),
        ],
      );
    });

    group('TaskFilterChanged', () {
      final highPriorityTask = testTask.copyWith(
        id: 'high-priority-task',
        priority: TaskPriority.high,
      );
      final completedTask = testTask.copyWith(
        id: 'completed-task',
        status: TaskStatus.complete,
      );

      blocTest<TaskBloc, TaskState>(
        'filters tasks by priority correctly',
        build: () => taskBloc,
        seed: () => TaskLoaded(
          tasks: [testTask, highPriorityTask, completedTask],
          currentFilter: const TaskFilter(),
          filteredTasks: [testTask, highPriorityTask, completedTask],
        ),
        act: (bloc) => bloc.add(const TaskFilterChanged(priority: TaskPriority.high)),
        expect: () => [
          isA<TaskLoaded>()
              .having((state) => state.filteredTasks, 'filteredTasks', [highPriorityTask])
              .having((state) => state.currentFilter.priority, 'filter.priority', TaskPriority.high),
        ],
      );

      blocTest<TaskBloc, TaskState>(
        'filters tasks by status correctly',
        build: () => taskBloc,
        seed: () => TaskLoaded(
          tasks: [testTask, highPriorityTask, completedTask],
          currentFilter: const TaskFilter(),
          filteredTasks: [testTask, highPriorityTask, completedTask],
        ),
        act: (bloc) => bloc.add(const TaskFilterChanged(status: TaskStatus.complete)),
        expect: () => [
          isA<TaskLoaded>()
              .having((state) => state.filteredTasks, 'filteredTasks', [completedTask])
              .having((state) => state.currentFilter.status, 'filter.status', TaskStatus.complete),
        ],
      );
    });

    group('TaskFilterCleared', () {
      blocTest<TaskBloc, TaskState>(
        'clears all filters and shows all tasks',
        build: () => taskBloc,
        seed: () => TaskLoaded(
          tasks: [testTask],
          currentFilter: const TaskFilter(priority: TaskPriority.high),
          filteredTasks: const [],
        ),
        act: (bloc) => bloc.add(const TaskFilterCleared()),
        expect: () => [
          isA<TaskLoaded>()
              .having((state) => state.filteredTasks, 'filteredTasks', [testTask])
              .having((state) => state.currentFilter, 'filter', const TaskFilter()),
        ],
      );
    });

    group('TaskToggleStatusRequested', () {
      blocTest<TaskBloc, TaskState>(
        'toggles task status from incomplete to complete',
        build: () {
          when(mockTaskRepository.updateTask(any))
              .thenAnswer((_) async => testTask.copyWith(status: TaskStatus.complete));
          return taskBloc;
        },
        seed: () => TaskLoaded(
          tasks: [testTask],
          currentFilter: const TaskFilter(),
          filteredTasks: [testTask],
        ),
        act: (bloc) => bloc.add(TaskToggleStatusRequested(taskId: testTask.id)),
        expect: () => [
          isA<TaskOperationInProgress>()
              .having((state) => state.operationType, 'operationType', 'updating'),
          isA<TaskOperationSuccess>()
              .having((state) => state.message, 'message', 'Task updated successfully'),
        ],
        verify: (_) {
          verify(mockTaskRepository.updateTask(argThat(
            predicate<Task>((task) => 
              task.id == testTask.id && 
              task.status == TaskStatus.complete
            ),
          ))).called(1);
        },
      );
    });
  });
}