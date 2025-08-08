# Takdo - Task Management Flutter App

A modern, feature-rich task management application built with Flutter and Firebase. Takdo helps you organize your tasks efficiently with a clean and intuitive interface.

## 🚀 Features

- **User Authentication**: Secure login and registration with Firebase Auth
- **Task Management**: Create, edit, delete, and organize tasks
- **Real-time Sync**: All tasks sync in real-time across devices via Firebase Firestore
- **Priority Levels**: Set task priorities (High, Medium, Low)
- **Task Status**: Track task progress (Todo, In Progress, Done)
- **Responsive Design**: Works seamlessly on mobile and desktop
- **Offline Support**: Continue working even without internet connection

## 🛠️ Tech Stack

- **Frontend**: Flutter (Dart)
- **State Management**: BLoC Pattern
- **Backend**: Firebase
  - Firebase Auth for authentication
  - Cloud Firestore for database
- **Architecture**: Clean Architecture with Domain-Driven Design
- **Code Generation**: Freezed for immutable models

## 📱 Screenshots

*Screenshots will be added here*

## 🚦 Getting Started

### Prerequisites

- Flutter SDK (3.8.1 or higher)
- Dart SDK (2.17.0 or higher)
- Firebase account and project setup

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/def-Siddharth-Mishra/takdo.git
   cd takdo
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Set up Firebase**
   - Create a new Firebase project at [Firebase Console](https://console.firebase.google.com/)
   - Enable Authentication (Email/Password)
   - Enable Cloud Firestore
   - Download `google-services.json` for Android and place it in `android/app/`
   - Download `GoogleService-Info.plist` for iOS and place it in `ios/Runner/`

4. **Run the app**
   ```bash
   flutter run
   ```

### Development Setup

1. **Generate code**
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

2. **Run tests**
   ```bash
   flutter test
   ```

## 🏗️ Project Structure

```
lib/
├── data/           # Data layer (models, repositories, datasources)
├── domain/         # Business logic (entities, use cases)
├── presentation/   # UI layer (screens, widgets, bloc)
└── main.dart       # Entry point
```

## 📝 GitHub Best Practices

### Files to Ignore

The project already includes a comprehensive `.gitignore` file that excludes:

- **Build artifacts**: `/build/`, `.dart_tool/`, `.flutter-plugins`
- **Platform-specific files**: 
  - Android: `android/app/debug`, `android/app/profile`, `android/app/release`
  - iOS: `ios/Flutter/.last_build_id`
- **Firebase configuration**: `google-services.json`, `GoogleService-Info.plist`
- **Environment variables**: `.env`, `.env.*`
- **IDE files**: `.idea/`, `.vscode/` (optional)
- **System files**: `.DS_Store`, `*.log`

### Before Pushing to GitHub

1. **Check your .gitignore**
   ```bash
   git status
   ```
   Ensure no sensitive files are being tracked.

2. **Add Firebase config files to .gitignore** (if not already present)
   ```bash
   echo "**/google-services.json" >> .gitignore
   echo "**/GoogleService-Info.plist" >> .gitignore
   ```

3. **Create a .env.example** file for environment variables
   ```bash
   cp .env .env.example
   ```
   Then remove actual values from `.env.example`.

4. **Clean build artifacts**
   ```bash
   flutter clean
   flutter pub get
   ```

### Branch Naming Convention

- `feature/task-name` - New features
- `bugfix/issue-description` - Bug fixes
- `hotfix/critical-fix` - Critical fixes
- `docs/documentation-update` - Documentation updates

### Commit Message Format

```
<type>(<scope>): <subject>

<body>

<footer>
```

Types: `feat`, `fix`, `docs`, `style`, `refactor`, `test`, `chore`

## 🚀 Deployment

### Android Release

```bash
flutter build apk --release
```

### iOS Release

```bash
flutter build ios --release
```

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Firebase team for the backend services
- All contributors and testers

## 📞 Support

For support, email support@takdo.com or join our Slack channel.
