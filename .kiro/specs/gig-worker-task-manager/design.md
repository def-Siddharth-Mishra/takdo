# Design Document

## Overview

The Gig Worker Task Manager is a minimal, focused mobile application that follows Clean Architecture principles with modern Dart features. The app uses BLoC or Riverpod for state management, Firebase for authentication and data storage, freezed for immutable data classes, json_serializable for JSON handling, and Material Design 3 for a clean UI experience.

The architecture prioritizes simplicity while maintaining good practices: clear separation of concerns, testability, and modern Dart code generation tools for reduced boilerplate.

## Architecture

### Clean Architecture Layers

```
┌─────────────────────────────────────────────────────────────┐
│                    Presentation Layer                       │
│  ┌─────────────────┐  ┌─────────────────┐  ┌──────────────┐ │
│  │     Pages       │  │     Widgets     │  │    BLoCs     │ │
│  │   (Screens)     │  │  (Components)   │  │ (State Mgmt) │ │
│  └─────────────────┘  └─────────────────┘  └──────────────┘ │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                     Domain Layer                            │
│  ┌─────────────────┐  ┌─────────────────┐  ┌──────────────┐ │
│  │    Entities     │  │   Use Cases     │  │ Repositories │ │
│  │   (Models)      │  │  (Business      │  │ (Interfaces) │ │
│  │                 │  │    Logic)       │  │              │ │
│  └─────────────────┘  └─────────────────┘  └──────────────┘ │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                      Data Layer                             │
│  ┌─────────────────┐  ┌─────────────────┐  ┌──────────────┐ │
│  │  Data Sources   │  │   Repositories  │  │    Models    │ │
│  │ (Firebase API)  │  │ (Implementation)│  │    (DTOs)    │ │
│  └─────────────────┘  └─────────────────┘  └──────────────┘ │
└─────────────────────────────────────────────────────────────┘
```

### State Management Architecture

The app uses BLoC or Riverpod pattern with the following structure:
- **Events/Actions**: User actions and system events
- **States**: UI states representing different app conditions  
- **BLoCs/Providers**: Business logic processors that manage state
- **Repositories**: Data access abstraction layer

### Code Generation Tools

The app leverages modern Dart code generation:
- **freezed**: Generates immutable data classes with copyWith, equality, and toString
- **json_serializable**: Generates JSON serialization/deserialization code
- **build_runner**: Executes code generation during development

## Components and Interfaces

### Core Entities

#### Task Entity (using freezed)
```dart
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

enum TaskPriority { low, medium, high }
enum TaskStatus { incomplete, complete }
```

#### User Entity (using freezed)
```dart
@freezed
class User with _$User {
  const factory User({
    required String id,
    required String email,
    required String displayName,
    required DateTime createdAt,
  }) = _User;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}
```

### Repository Interfaces

#### Authentication Repository
```dart
abstract class AuthRepository {
  Future<User> signInWithEmailAndPassword(String email, String password);
  Future<User> createUserWithEmailAndPassword(String email, String password);
  Future<void> signOut();
  Stream<User?> get authStateChanges;
  User? get currentUser;
}
```

#### Task Repository
```dart
abstract class TaskRepository {
  Future<List<Task>> getTasks(String userId);
  Future<Task> createTask(Task task);
  Future<Task> updateTask(Task task);
  Future<void> deleteTask(String taskId);
  Stream<List<Task>> watchTasks(String userId);
  Future<List<Task>> getFilteredTasks({
    required String userId,
    TaskPriority? priority,
    TaskStatus? status,
    TaskSortBy sortBy = TaskSortBy.dueDate,
  });
}
```

### Use Cases

#### Authentication Use Cases
- `SignInUseCase`: Handle user login with validation
- `SignUpUseCase`: Handle user registration with validation
- `SignOutUseCase`: Handle user logout
- `GetCurrentUserUseCase`: Retrieve current authenticated user

#### Task Management Use Cases
- `GetTasksUseCase`: Retrieve user tasks with optional filtering
- `CreateTaskUseCase`: Create new task with validation
- `UpdateTaskUseCase`: Update existing task
- `DeleteTaskUseCase`: Delete task with confirmation
- `ToggleTaskStatusUseCase`: Mark task as complete/incomplete
- `FilterTasksUseCase`: Apply filters and sorting to tasks

### BLoC Components

#### Authentication BLoC
```dart
// Events
abstract class AuthEvent {}
class AuthSignInRequested extends AuthEvent {
  final String email;
  final String password;
}
class AuthSignUpRequested extends AuthEvent {
  final String email;
  final String password;
}
class AuthSignOutRequested extends AuthEvent {}

// States
abstract class AuthState {}
class AuthInitial extends AuthState {}
class AuthLoading extends AuthState {}
class AuthAuthenticated extends AuthState {
  final User user;
}
class AuthUnauthenticated extends AuthState {}
class AuthError extends AuthState {
  final String message;
}
```

#### Task BLoC
```dart
// Events
abstract class TaskEvent {}
class TasksLoadRequested extends TaskEvent {}
class TaskCreateRequested extends TaskEvent {
  final Task task;
}
class TaskUpdateRequested extends TaskEvent {
  final Task task;
}
class TaskDeleteRequested extends TaskEvent {
  final String taskId;
}
class TaskFilterChanged extends TaskEvent {
  final TaskFilter filter;
}

// States
abstract class TaskState {}
class TaskInitial extends TaskState {}
class TaskLoading extends TaskState {}
class TaskLoaded extends TaskState {
  final List<Task> tasks;
  final TaskFilter currentFilter;
}
class TaskError extends TaskState {
  final String message;
}
```

## Data Models

### Firebase Data Models

#### Task Document Structure (Firestore)
```json
{
  "id": "string",
  "title": "string",
  "description": "string",
  "dueDate": "timestamp",
  "priority": "string", // "low", "medium", "high"
  "status": "string",   // "incomplete", "complete"
  "userId": "string",
  "createdAt": "timestamp",
  "updatedAt": "timestamp"
}
```

#### User Document Structure (Firestore)
```json
{
  "id": "string",
  "email": "string",
  "displayName": "string",
  "createdAt": "timestamp"
}
```

### Data Transfer Objects (DTOs)

#### TaskDto (using freezed and json_serializable)
```dart
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
}

// Custom converter for Firestore Timestamps
class TimestampConverter implements JsonConverter<DateTime, Timestamp> {
  const TimestampConverter();

  @override
  DateTime fromJson(Timestamp timestamp) => timestamp.toDate();

  @override
  Timestamp toJson(DateTime dateTime) => Timestamp.fromDate(dateTime);
}
```

## Error Handling

### Error Types

#### Authentication Errors
- `InvalidEmailError`: Malformed email address
- `WrongPasswordError`: Incorrect password
- `UserNotFoundError`: Email not registered
- `EmailAlreadyInUseError`: Email already registered
- `WeakPasswordError`: Password doesn't meet requirements
- `NetworkError`: Connection issues

#### Task Management Errors
- `TaskNotFoundError`: Task doesn't exist
- `ValidationError`: Invalid task data
- `PermissionError`: User doesn't own the task
- `StorageError`: Firestore operation failed

### Error Handling Strategy

1. **Repository Level**: Catch and transform Firebase exceptions into domain-specific errors
2. **Use Case Level**: Handle business logic errors and validation
3. **BLoC Level**: Transform errors into appropriate UI states
4. **UI Level**: Display user-friendly error messages with retry options

### Error Recovery

- **Offline Support**: Cache tasks locally using Hive/SharedPreferences
- **Retry Mechanism**: Automatic retry for network-related failures
- **Graceful Degradation**: Show cached data when offline
- **User Feedback**: Clear error messages with actionable solutions

## Testing Strategy

### Core Testing Focus
- **Unit Tests**: Test entities, repositories, and business logic
- **Widget Tests**: Test key UI components and screens  
- **Integration Tests**: Test Firebase integration and user flows

### Testing Tools
- **flutter_test**: Core testing framework
- **mockito**: Mocking dependencies
- **bloc_test**: Testing BLoC state management
- **fake_cloud_firestore**: Firebase testing

### Minimal Test Coverage
- Focus on critical business logic and user flows
- Test authentication and task CRUD operations
- Ensure UI components render correctly

## UI/UX Design Specifications

### Design System

#### Color Palette
Based on Reference images:
- **Primary**: Purple/Blue gradient (#6366F1 to #8B5CF6)
- **Secondary**: Orange (#F59E0B)
- **Success**: Green (#10B981)
- **Warning**: Yellow (#F59E0B)
- **Error**: Red (#EF4444)
- **Background**: Light gray (#F9FAFB)
- **Surface**: White (#FFFFFF)

#### Typography
- **Headings**: Inter/Roboto Bold
- **Body**: Inter/Roboto Regular
- **Captions**: Inter/Roboto Light

#### Component Specifications

##### Task Card
- **Layout**: Card with rounded corners (12px radius)
- **Content**: Title, description, due date, priority badges
- **Actions**: Checkbox, edit, delete icons
- **Priority Badges**: Color-coded pills (low=green, medium=orange, high=red)
- **Status**: Visual checkbox with completion state

##### Bottom Navigation
- **Items**: Tasks, Calendar, Profile
- **Style**: Material Design 3 navigation bar
- **Icons**: Outlined when inactive, filled when active

##### Floating Action Button
- **Position**: Bottom right
- **Style**: Extended FAB with "+" icon
- **Color**: Primary gradient
- **Action**: Navigate to create task screen

### Screen Layouts

#### Authentication Screens
- **Splash Screen**: App logo with gradient background
- **Login Screen**: Email/password fields, social login options
- **Register Screen**: Email/password/confirm fields, terms checkbox

#### Main Application Screens
- **Task List**: Grouped by time periods (Today, Tomorrow, This week)
- **Task Detail**: Full task information with edit capabilities
- **Create/Edit Task**: Form with all task fields
- **Filter Screen**: Priority and status filter options

### Responsive Design

#### Breakpoints
- **Mobile**: < 600px width
- **Tablet**: 600px - 1024px width
- **Desktop**: > 1024px width (future consideration)

#### Adaptive Layouts
- **Mobile**: Single column, bottom navigation
- **Tablet**: Adaptive grid, side navigation option
- **Orientation**: Support both portrait and landscape modes