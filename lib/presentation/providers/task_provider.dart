import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/task_repository_impl.dart';
import '../../data/datasources/firestore_task_datasource.dart';
import '../bloc/task/task.dart';

/// Provider widget that creates and provides TaskBloc to its children
class TaskProvider extends StatelessWidget {
  final Widget child;

  const TaskProvider({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider<TaskBloc>(
      create: (context) => TaskBloc(
        taskRepository: TaskRepositoryImpl(
          dataSource: FirestoreTaskDataSource(),
        ),
      ),
      child: child,
    );
  }
}

/// Extension to easily access TaskBloc from BuildContext
extension TaskBlocExtension on BuildContext {
  /// Gets the TaskBloc instance from the widget tree
  TaskBloc get taskBloc => read<TaskBloc>();
  
  /// Watches the TaskBloc for state changes
  TaskState get taskState => watch<TaskBloc>().state;
}