import 'package:freezed_annotation/freezed_annotation.dart';
import 'task_priority.dart';
import 'task_status.dart';

part 'task.freezed.dart';
part 'task.g.dart';

@freezed
class Task with _$Task {
  const factory Task({
    required String id,
    required String title,
    required String description,
    required DateTime dueDate,
    required TaskPriority priority,
    required TaskStatus status,
    required String userId,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _Task;

  factory Task.fromJson(Map<String, dynamic> json) => _$TaskFromJson(json);
}