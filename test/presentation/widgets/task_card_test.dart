import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:takdo/domain/entities/task.dart';
import 'package:takdo/domain/entities/task_priority.dart';
import 'package:takdo/domain/entities/task_status.dart';
import 'package:takdo/presentation/widgets/task_card.dart';

void main() {
  group('TaskCard Widget Tests', () {
    final testTask = Task(
      id: 'test-task-id',
      title: 'Test Task',
      description: 'This is a test task description',
      dueDate: DateTime.now().add(const Duration(days: 1)),
      priority: TaskPriority.high,
      status: TaskStatus.incomplete,
      userId: 'test-user-id',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final completedTask = testTask.copyWith(
      status: TaskStatus.complete,
    );

    Widget createWidgetUnderTest({
      required Task task,
      VoidCallback? onToggleStatus,
      VoidCallback? onEdit,
      VoidCallback? onDelete,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: TaskCard(
            task: task,
            onToggleStatus: onToggleStatus ?? () {},
            onEdit: onEdit ?? () {},
            onDelete: onDelete ?? () {},
          ),
        ),
      );
    }

    testWidgets('should display task information correctly', (tester) async {
      // Act
      await tester.pumpWidget(createWidgetUnderTest(task: testTask));

      // Assert
      expect(find.text('Test Task'), findsOneWidget);
      expect(find.text('This is a test task description'), findsOneWidget);
      expect(find.byType(Card), findsOneWidget);
    });

    testWidgets('should display priority badge', (tester) async {
      // Act
      await tester.pumpWidget(createWidgetUnderTest(task: testTask));

      // Assert
      expect(find.text('HIGH'), findsOneWidget);
    });

    testWidgets('should display different priority labels', (tester) async {
      // Test low priority
      final lowPriorityTask = testTask.copyWith(priority: TaskPriority.low);
      await tester.pumpWidget(createWidgetUnderTest(task: lowPriorityTask));
      
      expect(find.text('LOW'), findsOneWidget);

      // Test medium priority
      final mediumPriorityTask = testTask.copyWith(priority: TaskPriority.medium);
      await tester.pumpWidget(createWidgetUnderTest(task: mediumPriorityTask));
      await tester.pump();
      
      expect(find.text('MED'), findsOneWidget);
    });

    testWidgets('should display completion indicator', (tester) async {
      // Act
      await tester.pumpWidget(createWidgetUnderTest(task: testTask));

      // Assert - Check for completion circle
      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('should show completed state styling', (tester) async {
      // Act
      await tester.pumpWidget(createWidgetUnderTest(task: completedTask));

      // Assert - Check for completed badge
      expect(find.text('COMPLETED'), findsOneWidget);
    });

    testWidgets('should display menu options', (tester) async {
      // Act
      await tester.pumpWidget(createWidgetUnderTest(task: testTask));

      // Assert - Menu icon should be present
      expect(find.byIcon(Icons.more_vert), findsOneWidget);
    });

    testWidgets('should display overdue indicator for past due tasks', (tester) async {
      // Arrange
      final overdueTask = testTask.copyWith(
        dueDate: DateTime.now().subtract(const Duration(days: 1)),
      );

      // Act
      await tester.pumpWidget(createWidgetUnderTest(task: overdueTask));

      // Assert - overdue styling should be present
      expect(find.text('OVERDUE'), findsOneWidget);
    });

    testWidgets('should not display overdue indicator for future tasks', (tester) async {
      // Act
      await tester.pumpWidget(createWidgetUnderTest(task: testTask));

      // Assert - no overdue indicator for future tasks
      expect(find.text('OVERDUE'), findsNothing);
    });

    testWidgets('should display card with proper styling', (tester) async {
      // Act
      await tester.pumpWidget(createWidgetUnderTest(task: testTask));

      // Assert
      expect(find.byType(Card), findsOneWidget);
      expect(find.byType(InkWell), findsWidgets);
    });
  });
}