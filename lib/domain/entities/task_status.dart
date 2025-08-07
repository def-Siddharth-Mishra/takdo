enum TaskStatus {
  incomplete,
  complete;

  String get displayName {
    switch (this) {
      case TaskStatus.incomplete:
        return 'Incomplete';
      case TaskStatus.complete:
        return 'Complete';
    }
  }

  bool get isComplete => this == TaskStatus.complete;
}