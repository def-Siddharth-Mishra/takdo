import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../../core/app_constants.dart';
import '../../widgets/home/custom_app_bar.dart';
import '../../widgets/home/task_section.dart';
import '../task/add_task_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  // Sample data - replace with your actual data from bloc
  final List<TaskItem> _todayTasks = [
    TaskItem(
      title: 'Schedule dentist appointment',
      subtitle: '1 May',
      tags: ['Personal'],
      onTap: () {},
      onToggleComplete: () {},
    ),
    TaskItem(
      title: 'Prepare Team Meeting',
      subtitle: '1 May',
      tags: ['Urgent', 'Work'],
      onTap: () {},
      onToggleComplete: () {},
    ),
  ];

  final List<TaskItem> _tomorrowTasks = [
    TaskItem(
      title: 'Call Charlotte',
      subtitle: '2 May',
      tags: ['Personal'],
      onTap: () {},
      onToggleComplete: () {},
    ),
    TaskItem(
      title: 'Submit exercise 3.1',
      subtitle: '2 May',
      tags: ['Uni', 'Study'],
      onTap: () {},
      onToggleComplete: () {},
    ),
    TaskItem(
      title: 'Prepare A/B Test',
      subtitle: '2 May',
      tags: ['Urgent', 'Work'],
      onTap: () {},
      onToggleComplete: () {},
    ),
  ];

  final List<TaskItem> _thisWeekTasks = [
    TaskItem(
      title: 'Submit exercise 3.2',
      subtitle: '5 May',
      tags: ['Uni', 'Study'],
      onTap: () {},
      onToggleComplete: () {},
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: 'My tasks',
        subtitle: 'Today, 1 May',
        onMenuPressed: () {
          // Handle menu press
        },
        onSearchPressed: () {
          // Handle search press
        },
        onMorePressed: () {
          // Handle more press
        },
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: AppConstants.spacing24),
            TaskSection(
              title: 'Today',
              tasks: _todayTasks,
            ),
            TaskSection(
              title: 'Tomorrow',
              tasks: _tomorrowTasks,
            ),
            TaskSection(
              title: 'This week',
              tasks: _thisWeekTasks,
            ),
            // Add some bottom padding for the FAB
            const SizedBox(height: 100),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddTaskDialog(context);
        },
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                onPressed: () {
                  setState(() {
                    _currentIndex = 0;
                  });
                },
                icon: Icon(
                  Icons.format_list_bulleted,
                  color: _currentIndex == 0 ? AppColors.primary : AppColors.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: 40), // Space for FAB
              IconButton(
                onPressed: () {
                  setState(() {
                    _currentIndex = 1;
                  });
                },
                icon: Icon(
                  Icons.calendar_today,
                  color: _currentIndex == 1 ? AppColors.primary : AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddTaskDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Task'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: 'Task Title',
                hintText: 'Enter task title',
              ),
            ),
            SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: 'Description',
                hintText: 'Enter task description',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Implement add task logic
              Navigator.of(context).pop();
            },
            child: const Text('Add Task'),
          ),
        ],
      ),
    );
  }
}