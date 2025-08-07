import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/task.dart';
import '../../domain/entities/task_priority.dart';
import '../../domain/entities/task_status.dart';
import '../converters/timestamp_converter.dart';

part 'task_dto.freezed.dart';
part 'task_dto.g.dart';

/// Data Transfer Object for Task entity with Firestore serialization
@freezed
class TaskDto with _$TaskDto {
  const factory TaskDto({
    required String id,
    required String title,
    required String description,
    @TimestampConverter() required DateTime dueDate,
    required String priority,
    required String status,
    required String userId,
    @TimestampConverter() required DateTime createdAt,
    @TimestampConverter() required DateTime updatedAt,
  }) = _TaskDto;

  factory TaskDto.fromJson(Map<String, dynamic> json) => _$TaskDtoFromJson(json);

  /// Convert from domain Task entity to TaskDto
  factory TaskDto.fromDomain(Task task) {
    return TaskDto(
      id: task.id,
      title: task.title,
      description: task.description,
      dueDate: task.dueDate,
      priority: task.priority.name,
      status: task.status.name,
      userId: task.userId,
      createdAt: task.createdAt,
      updatedAt: task.updatedAt,
    );
  }
}

/// Extension to convert TaskDto to domain Task entity
extension TaskDtoX on TaskDto {
  Task toDomain() {
    return Task(
      id: id,
      title: title,
      description: description,
      dueDate: dueDate,
      priority: TaskPriority.values.firstWhere((e) => e.name == priority),
      status: TaskStatus.values.firstWhere((e) => e.name == status),
      userId: userId,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

