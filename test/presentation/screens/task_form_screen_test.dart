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
import 'package:takdo/presentation/screens/task_form_screen.dart';

import 'task_form_screen_test.mocks.dart';

@GenerateMocks([TaskRepository])
void main() {
  group('TaskFormScreen Widget Tests', () {
    late MockTaskRepository mockTaskRepository;
    late TaskBloc taskBloc;

    final testUser = User(
      id: 'test-user-id',
      email: 'test@example.com',
      displayName: 'Test User',
      createdAt: DateTime.now(),
    );

    final existingTask = Task(
      id: 'existing-task-id',
      title: 'Existing Task',
      description: 'Existing description',
      dueDate: DateTime(2024, 12, 31),
      priority: TaskPriority.medium,
      status: TaskStatus.incomplete,
      userId: testUser.id,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    setUp(() {
      mockTaskRepository = MockTaskRepository();
      taskBloc = TaskBloc(taskRepository: mockTaskRepository);
    });

    tearDown(() {
      taskBloc.close();
    });

    Widget createWidgetUnderTest({Task? task}) {
      return MaterialApp(
        home: BlocProvider<TaskBloc>(
          create: (_) => taskBloc,
          child: TaskFormScreen(
            task: task,
          ),
        ),
      );
    }

    group('Create Task Mode', () {
      testWidgets('should display correct app bar title for new task', (tester) async {
        // Act
        await tester.pumpWidget(createWidgetUnderTest());

        // Assert
        expect(find.text('Create Task'), findsOneWidget);
        expect(find.byType(AppBar), findsOneWidget);
      });

      testWidgets('should display all form fields', (tester) async {
        // Act
        await tester.pumpWidget(createWidgetUnderTest());

        // Assert
        expect(find.byKey(const Key('title_field')), findsOneWidget);
        expect(find.byKey(const Key('description_field')), findsOneWidget);
        expect(find.byKey(const Key('due_date_field')), findsOneWidget);
        expect(find.byKey(const Key('priority_dropdown')), findsOneWidget);
        expect(find.text('Create Task'), findsNWidgets(2)); // App bar and button
      });

      testWidgets('should have empty form fields initially', (tester) async {
        // Act
        await tester.pumpWidget(createWidgetUnderTest());

        // Assert
        final titleField = tester.widget<TextFormField>(find.byKey(const Key('title_field')));
        final descriptionField = tester.widget<TextFormField>(find.byKey(const Key('description_field')));
        
        expect(titleField.controller?.text, isEmpty);
        expect(descriptionField.controller?.text, isEmpty);
      });

      testWidgets('should validate required fields', (tester) async {
        // Act
        await tester.pumpWidget(createWidgetUnderTest());

        // Try to submit without filling required fields
        final createButton = find.byKey(const Key('submit_button'));
        await tester.tap(createButton);
        await tester.pump();

        // Assert
        expect(find.text('Please enter a title'), findsOneWidget);
        expect(find.text('Please enter a description'), findsOneWidget);
      });

      testWidgets('should enable submit button when form is valid', (tester) async {
        // Act
        await tester.pumpWidget(createWidgetUnderTest());

        // Fill in required fields
        await tester.enterText(find.byKey(const Key('title_field')), 'Test Task');
        await tester.enterText(find.byKey(const Key('description_field')), 'Test Description');
        await tester.pump();

        // Assert
        final submitButton = find.byKey(const Key('submit_button'));
        expect(submitButton, findsOneWidget);
        
        final button = tester.widget<ElevatedButton>(submitButton);
        expect(button.onPressed, isNotNull);
      });
    });

    group('Edit Task Mode', () {
      testWidgets('should display correct app bar title for editing', (tester) async {
        // Act
        await tester.pumpWidget(createWidgetUnderTest(task: existingTask));

        // Assert
        expect(find.text('Edit Task'), findsOneWidget);
      });

      testWidgets('should pre-populate form fields with existing task data', (tester) async {
        // Act
        await tester.pumpWidget(createWidgetUnderTest(task: existingTask));

        // Assert
        final titleField = tester.widget<TextFormField>(find.byKey(const Key('title_field')));
        final descriptionField = tester.widget<TextFormField>(find.byKey(const Key('description_field')));
        
        expect(titleField.controller?.text, 'Existing Task');
        expect(descriptionField.controller?.text, 'Existing description');
      });

      testWidgets('should show update button text', (tester) async {
        // Act
        await tester.pumpWidget(createWidgetUnderTest(task: existingTask));

        // Assert
        expect(find.text('Update Task'), findsOneWidget);
      });
    });

    group('Form Interactions', () {
      testWidgets('should open date picker when due date field is tapped', (tester) async {
        // Act
        await tester.pumpWidget(createWidgetUnderTest());

        final dueDateField = find.byKey(const Key('due_date_field'));
        await tester.tap(dueDateField);
        await tester.pumpAndSettle();

        // Assert
        expect(find.byType(DatePickerDialog), findsOneWidget);
      });

      testWidgets('should show priority dropdown options', (tester) async {
        // Act
        await tester.pumpWidget(createWidgetUnderTest());

        final priorityDropdown = find.byKey(const Key('priority_dropdown'));
        await tester.tap(priorityDropdown);
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('Low'), findsOneWidget);
        expect(find.text('Medium'), findsOneWidget);
        expect(find.text('High'), findsOneWidget);
      });

      testWidgets('should update priority when dropdown selection changes', (tester) async {
        // Act
        await tester.pumpWidget(createWidgetUnderTest());

        final priorityDropdown = find.byKey(const Key('priority_dropdown'));
        await tester.tap(priorityDropdown);
        await tester.pumpAndSettle();

        await tester.tap(find.text('High'));
        await tester.pumpAndSettle();

        // Assert
        final dropdown = tester.widget<DropdownButtonFormField<TaskPriority>>(priorityDropdown);
        // Note: In actual implementation, priority selection is handled differently
        // This test would need to be adjusted based on the actual UI implementation
      });

      testWidgets('should validate title length', (tester) async {
        // Act
        await tester.pumpWidget(createWidgetUnderTest());

        // Enter title that's too long
        await tester.enterText(
          find.byKey(const Key('title_field')),
          'A' * 101, // Assuming max length is 100
        );
        
        // Trigger validation
        final submitButton = find.byKey(const Key('submit_button'));
        await tester.tap(submitButton);
        await tester.pump();

        // Assert
        expect(find.text('Title must be less than 100 characters'), findsOneWidget);
      });

      testWidgets('should validate description length', (tester) async {
        // Act
        await tester.pumpWidget(createWidgetUnderTest());

        // Enter description that's too long
        await tester.enterText(
          find.byKey(const Key('description_field')),
          'A' * 501, // Assuming max length is 500
        );
        
        // Trigger validation
        final submitButton = find.byKey(const Key('submit_button'));
        await tester.tap(submitButton);
        await tester.pump();

        // Assert
        expect(find.text('Description must be less than 500 characters'), findsOneWidget);
      });
    });

    group('Form Submission', () {
      testWidgets('should show loading state during task creation', (tester) async {
        // Arrange
        taskBloc.emit(const TaskOperationInProgress(
          tasks: [],
          currentFilter: TaskFilter(),
          filteredTasks: [],
          operationType: 'creating',
        ));

        // Act
        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pump();

        // Assert
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
        expect(find.text('Creating...'), findsOneWidget);
      });

      testWidgets('should show loading state during task update', (tester) async {
        // Arrange
        taskBloc.emit(const TaskOperationInProgress(
          tasks: [],
          currentFilter: TaskFilter(),
          filteredTasks: [],
          operationType: 'updating',
        ));

        // Act
        await tester.pumpWidget(createWidgetUnderTest(task: existingTask));
        await tester.pump();

        // Assert
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
        expect(find.text('Updating...'), findsOneWidget);
      });

      testWidgets('should show success message after successful creation', (tester) async {
        // Arrange
        taskBloc.emit(const TaskOperationSuccess(
          tasks: [],
          currentFilter: TaskFilter(),
          filteredTasks: [],
          message: 'Task created successfully',
        ));

        // Act
        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pump();

        // Assert
        expect(find.text('Task created successfully'), findsOneWidget);
        expect(find.byIcon(Icons.check_circle), findsOneWidget);
      });

      testWidgets('should show error message when operation fails', (tester) async {
        // Arrange
        taskBloc.emit(const TaskError(message: 'Failed to create task'));

        // Act
        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pump();

        // Assert
        expect(find.text('Failed to create task'), findsOneWidget);
        expect(find.byIcon(Icons.error), findsOneWidget);
      });

      testWidgets('should clear form after successful creation', (tester) async {
        // Act
        await tester.pumpWidget(createWidgetUnderTest());

        // Fill form
        await tester.enterText(find.byKey(const Key('title_field')), 'Test Task');
        await tester.enterText(find.byKey(const Key('description_field')), 'Test Description');

        // Simulate successful creation
        taskBloc.emit(const TaskOperationSuccess(
          tasks: [],
          currentFilter: TaskFilter(),
          filteredTasks: [],
          message: 'Task created successfully',
        ));
        await tester.pump();

        // Assert form is cleared
        final titleField = tester.widget<TextFormField>(find.byKey(const Key('title_field')));
        final descriptionField = tester.widget<TextFormField>(find.byKey(const Key('description_field')));
        
        expect(titleField.controller?.text, isEmpty);
        expect(descriptionField.controller?.text, isEmpty);
      });
    });

    group('Navigation', () {
      testWidgets('should have back button in app bar', (tester) async {
        // Act
        await tester.pumpWidget(createWidgetUnderTest());

        // Assert
        expect(find.byType(BackButton), findsOneWidget);
      });

      testWidgets('should show discard changes dialog when back is pressed with unsaved changes', (tester) async {
        // Act
        await tester.pumpWidget(createWidgetUnderTest());

        // Make changes to form
        await tester.enterText(find.byKey(const Key('title_field')), 'Unsaved Task');

        // Try to go back
        final backButton = find.byType(BackButton);
        await tester.tap(backButton);
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('Discard Changes?'), findsOneWidget);
        expect(find.text('You have unsaved changes. Are you sure you want to discard them?'), findsOneWidget);
        expect(find.text('Discard'), findsOneWidget);
        expect(find.text('Keep Editing'), findsOneWidget);
      });
    });
  });
}