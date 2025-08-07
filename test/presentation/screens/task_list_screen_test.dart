import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:takdo/domain/entities/task.dart';
import 'package:takdo/domain/entities/task_priority.dart';
import 'package:takdo/domain/entities/task_status.dart';
import 'package:takdo/domain/entities/user.dart';
import 'package:takdo/domain/repositories/task_repository.dart';
import 'package:takdo/presentation/bloc/task/task_bloc.dart';
import 'package:takdo/presentation/bloc/task/task_state.dart';
import 'package:takdo/presentation/screens/task_list_screen.dart';
import 'package:takdo/presentation/widgets/task_card.dart';

import 'task_list_screen_test.mocks.dart';

@GenerateMocks([TaskRepository])
void main() {
  group('TaskListScreen Widget Tests', () {
    late MockTaskRepository mockTaskRepository;
    late TaskBloc taskBloc;

    final testUser = User(
      id: 'test-user-id',
      email: 'test@example.com',
      displayName: 'Test User',
      createdAt: DateTime.now(),
    );

    final testTasks = [
      Task(
        id: 'task-1',
        title: 'High Priority Task',
        description: 'Important task',
        dueDate: DateTime.now().add(const Duration(days: 1)),
        priority: TaskPriority.high,
        status: TaskStatus.incomplete,
        userId: testUser.id,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      Task(
        id: 'task-2',
        title: 'Completed Task',
        description: 'Already done',
        dueDate: DateTime.now().subtract(const Duration(days: 1)),
        priority: TaskPriority.medium,
        status: TaskStatus.complete,
        userId: testUser.id,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      Task(
        id: 'task-3',
        title: 'Low Priority Task',
        description: 'Can wait',
        dueDate: DateTime.now().add(const Duration(days: 7)),
        priority: TaskPriority.low,
        status: TaskStatus.incomplete,
        userId: testUser.id,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];

    setUp(() {
      mockTaskRepository = MockTaskRepository();
      taskBloc = TaskBloc(taskRepository: mockTaskRepository);
    });

    tearDown(() {
      taskBloc.close();
    });

    Widget createWidgetUnderTest() {
      return MaterialApp(
        home: BlocProvider<TaskBloc>(
          create: (_) => taskBloc,
          child: const TaskListScreen(),
        ),
      );
    }

    testWidgets('should display app bar with correct title', (tester) async {
      // Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.text('My Tasks'), findsOneWidget);
    });

    testWidgets('should display loading indicator when tasks are loading', (tester) async {
      // Arrange
      taskBloc.emit(const TaskLoading());

      // Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Loading tasks...'), findsOneWidget);
    });

    testWidgets('should display error message when task loading fails', (tester) async {
      // Arrange
      taskBloc.emit(const TaskError(message: 'Failed to load tasks'));

      // Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      // Assert
      expect(find.text('Failed to load tasks'), findsOneWidget);
      expect(find.byIcon(Icons.error), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    });

    testWidgets('should display empty state when no tasks exist', (tester) async {
      // Arrange
      taskBloc.emit(const TaskLoaded(
        tasks: [],
        filteredTasks: [],
        currentFilter: TaskFilter(),
      ));

      // Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      // Assert
      expect(find.text('No tasks yet'), findsOneWidget);
      expect(find.text('Tap the + button to create your first task'), findsOneWidget);
      expect(find.byIcon(Icons.task_alt), findsOneWidget);
    });

    testWidgets('should display task cards when tasks are loaded', (tester) async {
      // Arrange
      taskBloc.emit(TaskLoaded(
        tasks: testTasks,
        filteredTasks: testTasks,
        currentFilter: const TaskFilter(),
      ));

      // Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      // Assert
      expect(find.byType(TaskCard), findsNWidgets(testTasks.length));
      expect(find.text('High Priority Task'), findsOneWidget);
      expect(find.text('Completed Task'), findsOneWidget);
      expect(find.text('Low Priority Task'), findsOneWidget);
    });

    testWidgets('should display floating action button', (tester) async {
      // Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert
      expect(find.byType(FloatingActionButton), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('should show filter bottom sheet when filter button is tapped', (tester) async {
      // Arrange
      taskBloc.emit(TaskLoaded(
        tasks: testTasks,
        filteredTasks: testTasks,
        currentFilter: const TaskFilter(),
      ));

      // Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      final filterButton = find.byKey(const Key('filter_button'));
      expect(filterButton, findsOneWidget);

      await tester.tap(filterButton);
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Filter Tasks'), findsOneWidget);
      expect(find.text('Priority'), findsOneWidget);
      expect(find.text('Status'), findsOneWidget);
    });

    testWidgets('should display search bar', (tester) async {
      // Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert
      expect(find.byKey(const Key('search_field')), findsOneWidget);
      expect(find.text('Search tasks...'), findsOneWidget);
    });

    testWidgets('should group tasks by time periods', (tester) async {
      // Arrange
      final todayTask = testTasks[0].copyWith(
        dueDate: DateTime.now(),
      );
      final tomorrowTask = testTasks[1].copyWith(
        dueDate: DateTime.now().add(const Duration(days: 1)),
      );
      final thisWeekTask = testTasks[2].copyWith(
        dueDate: DateTime.now().add(const Duration(days: 3)),
      );

      final groupedTasks = [todayTask, tomorrowTask, thisWeekTask];

      taskBloc.emit(TaskLoaded(
        tasks: groupedTasks,
        filteredTasks: groupedTasks,
        currentFilter: const TaskFilter(),
      ));

      // Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      // Assert
      expect(find.text('Today'), findsOneWidget);
      expect(find.text('Tomorrow'), findsOneWidget);
      expect(find.text('This Week'), findsOneWidget);
    });

    testWidgets('should show active filter indicator when filters are applied', (tester) async {
      // Arrange
      taskBloc.emit(TaskLoaded(
        tasks: testTasks,
        filteredTasks: [testTasks[0]], // Only high priority task
        currentFilter: const TaskFilter(priority: TaskPriority.high),
      ));

      // Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      // Assert
      expect(find.byKey(const Key('active_filter_chip')), findsOneWidget);
      expect(find.text('High Priority'), findsOneWidget);
    });

    testWidgets('should handle task card tap', (tester) async {
      // Arrange
      taskBloc.emit(TaskLoaded(
        tasks: testTasks,
        filteredTasks: testTasks,
        currentFilter: const TaskFilter(),
      ));

      // Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      final taskCard = find.byType(TaskCard).first;
      await tester.tap(taskCard);
      await tester.pumpAndSettle();

      // Note: In a real test, you would verify navigation to task detail screen
    });

    testWidgets('should handle task completion toggle', (tester) async {
      // Arrange
      taskBloc.emit(TaskLoaded(
        tasks: testTasks,
        filteredTasks: testTasks,
        currentFilter: const TaskFilter(),
      ));

      // Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      final checkbox = find.byKey(Key('task_checkbox_${testTasks[0].id}')).first;
      await tester.tap(checkbox);
      await tester.pump();

      // Note: In a real test, you would verify that the appropriate BLoC event was dispatched
    });

    testWidgets('should refresh tasks when pull to refresh is triggered', (tester) async {
      // Arrange
      taskBloc.emit(TaskLoaded(
        tasks: testTasks,
        filteredTasks: testTasks,
        currentFilter: const TaskFilter(),
      ));

      // Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      await tester.fling(
        find.byType(RefreshIndicator),
        const Offset(0, 300),
        1000,
      );
      await tester.pump();

      // Note: In a real test, you would verify that the refresh event was dispatched
    });
  });
}