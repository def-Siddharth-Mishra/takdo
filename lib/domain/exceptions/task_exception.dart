/// Base class for task-related exceptions
abstract class TaskException implements Exception {
  const TaskException(this.message);

  final String message;

  @override
  String toString() => 'TaskException: $message';
}

/// Exception thrown when a task is not found
class TaskNotFoundException extends TaskException {
  const TaskNotFoundException() : super('Task not found');
}

/// Exception thrown when task validation fails
class TaskValidationException extends TaskException {
  const TaskValidationException(super.message);
}

/// Exception thrown when user doesn't have permission to access/modify a task
class TaskPermissionException extends TaskException {
  const TaskPermissionException() : super('Permission denied for this task');
}

/// Exception thrown when storage operations fail
class TaskStorageException extends TaskException {
  const TaskStorageException(super.message);
}

/// Exception thrown for generic task-related errors
class GenericTaskException extends TaskException {
  const GenericTaskException(super.message);
}