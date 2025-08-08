import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'presentation/core/app_theme.dart';
import 'presentation/screens/onboarding/onboarding_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const TakdoApp());
}

class TakdoApp extends StatelessWidget {
  const TakdoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Takdo - Task Management',
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      home: const OnboardingScreen(),
    );
  }
}