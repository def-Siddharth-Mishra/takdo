import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';

// Data layer imports
import 'data/datasources/firebase_auth_datasource.dart';
import 'data/datasources/firestore_task_datasource.dart';
import 'data/repositories/auth_repository_impl.dart';
import 'data/repositories/task_repository_impl.dart';

// Presentation layer imports
import 'presentation/presentation.dart';
import 'presentation/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp();
  
  runApp(const TaskDoApp());
}

class TaskDoApp extends StatelessWidget {
  const TaskDoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        // Auth Repository
        RepositoryProvider<AuthRepositoryImpl>(
          create: (context) => AuthRepositoryImpl(
            dataSource: FirebaseAuthDataSource(),
          ),
        ),
        // Task Repository
        RepositoryProvider<TaskRepositoryImpl>(
          create: (context) => TaskRepositoryImpl(
            dataSource: FirestoreTaskDataSource(),
          ),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          // Auth BLoC
          BlocProvider<AuthBloc>(
            create: (context) => AuthBloc(
              authRepository: context.read<AuthRepositoryImpl>(),
            ),
          ),
          // Task BLoC
          BlocProvider<TaskBloc>(
            create: (context) => TaskBloc(
              taskRepository: context.read<TaskRepositoryImpl>(),
            ),
          ),
        ],
        child: MaterialApp(
          title: 'TaskDo',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          home: const AuthWrapper(
            authenticatedChild: MainNavigationScreen(),
            unauthenticatedChild: LoginScreen(),
            loadingChild: SplashScreen(),
          ),
          routes: {
            LoginScreen.routeName: (context) => const LoginScreen(),
            RegisterScreen.routeName: (context) => const RegisterScreen(),
          },
        ),
      ),
    );
  }
}

