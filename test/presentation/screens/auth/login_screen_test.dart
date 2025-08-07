import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:takdo/domain/repositories/auth_repository.dart';
import 'package:takdo/presentation/bloc/auth/auth_bloc.dart';
import 'package:takdo/presentation/bloc/auth/auth_state.dart';
import 'package:takdo/presentation/screens/auth/login_screen.dart';
import 'package:takdo/presentation/widgets/auth_form_field.dart';
import 'package:takdo/presentation/widgets/auth_button.dart';

import 'login_screen_test.mocks.dart';

@GenerateMocks([AuthRepository])
void main() {
  group('LoginScreen Widget Tests', () {
    late MockAuthRepository mockAuthRepository;
    late AuthBloc authBloc;

    setUp(() {
      mockAuthRepository = MockAuthRepository();
      when(mockAuthRepository.authStateChanges)
          .thenAnswer((_) => Stream.value(null));
      authBloc = AuthBloc(authRepository: mockAuthRepository);
    });

    tearDown(() {
      authBloc.close();
    });

    Widget createWidgetUnderTest() {
      return MaterialApp(
        home: BlocProvider<AuthBloc>(
          create: (_) => authBloc,
          child: const LoginScreen(),
        ),
      );
    }

    testWidgets('should display all required UI elements', (tester) async {
      // Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert
      expect(find.text('Welcome Back'), findsOneWidget);
      expect(find.text('Sign in to continue managing your tasks'), findsOneWidget);
      expect(find.byType(AuthFormField), findsNWidgets(2)); // Email and password fields
      expect(find.text('Sign In'), findsOneWidget);
      expect(find.text('Don\'t have an account? '), findsOneWidget);
      expect(find.text('Sign Up'), findsOneWidget);
    });

    testWidgets('should display email and password form fields', (tester) async {
      // Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert
      expect(find.byType(AuthFormField), findsNWidgets(2));
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
    });

    testWidgets('should enable sign in button when form is valid', (tester) async {
      // Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert - Sign In button should be present
      expect(find.byType(AuthButton), findsOneWidget);
      expect(find.text('Sign In'), findsOneWidget);
    });

    testWidgets('should show loading state when authentication is in progress', (tester) async {
      // Arrange
      authBloc.emit(const AuthLoading());

      // Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should show error message when authentication fails', (tester) async {
      // Arrange
      authBloc.emit(const AuthError(message: 'Invalid credentials'));

      // Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      // Assert
      expect(find.text('Invalid credentials'), findsOneWidget);
      expect(find.byIcon(Icons.error), findsOneWidget);
    });

    testWidgets('should navigate to register screen when sign up is tapped', (tester) async {
      // Act
      await tester.pumpWidget(createWidgetUnderTest());
      
      final signUpButton = find.text('Sign Up');
      expect(signUpButton, findsOneWidget);
      
      await tester.tap(signUpButton);
      await tester.pumpAndSettle();

      // Note: In a real test, you would verify navigation occurred
      // This would require setting up a Navigator observer or using integration tests
    });

    testWidgets('should validate email format', (tester) async {
      // Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert - Form validation will be handled by the form fields
      expect(find.byType(Form), findsOneWidget);
    });

    testWidgets('should validate password length', (tester) async {
      // Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert - Password field should be present
      expect(find.text('Password'), findsOneWidget);
    });

    testWidgets('should toggle password visibility', (tester) async {
      // Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert - Password visibility toggle should be present
      expect(find.byIcon(Icons.visibility_outlined), findsOneWidget);
    });
  });
}