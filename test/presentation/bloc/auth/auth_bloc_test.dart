import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:takdo/domain/entities/user.dart';
import 'package:takdo/domain/exceptions/auth_exception.dart';
import 'package:takdo/domain/repositories/auth_repository.dart';
import 'package:takdo/presentation/bloc/auth/auth_bloc.dart';
import 'package:takdo/presentation/bloc/auth/auth_event.dart';
import 'package:takdo/presentation/bloc/auth/auth_state.dart';

import 'auth_bloc_test.mocks.dart';

@GenerateMocks([AuthRepository])
void main() {
  group('AuthBloc', () {
    late MockAuthRepository mockAuthRepository;
    late AuthBloc authBloc;

    final testUser = User(
      id: 'test-id',
      email: 'test@example.com',
      displayName: 'Test User',
      createdAt: DateTime.now(),
    );

    setUp(() {
      mockAuthRepository = MockAuthRepository();
      when(mockAuthRepository.authStateChanges)
          .thenAnswer((_) => Stream.value(null));
      authBloc = AuthBloc(authRepository: mockAuthRepository);
    });

    tearDown(() {
      authBloc.close();
    });

    test('initial state is AuthInitial', () {
      expect(authBloc.state, const AuthInitial());
    });

    group('AuthSignInRequested', () {
      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, AuthAuthenticated] when sign in succeeds',
        build: () {
          when(mockAuthRepository.signInWithEmailAndPassword(
            'test@example.com',
            'password123',
          )).thenAnswer((_) async => testUser);
          return authBloc;
        },
        act: (bloc) => bloc.add(const AuthSignInRequested(
          email: 'test@example.com',
          password: 'password123',
        )),
        expect: () => [
          const AuthLoading(),
          AuthAuthenticated(user: testUser),
        ],
      );

      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, AuthError] when sign in fails',
        build: () {
          when(mockAuthRepository.signInWithEmailAndPassword(
            'test@example.com',
            'wrongpassword',
          )).thenThrow(const WrongPasswordException());
          return authBloc;
        },
        act: (bloc) => bloc.add(const AuthSignInRequested(
          email: 'test@example.com',
          password: 'wrongpassword',
        )),
        expect: () => [
          const AuthLoading(),
          const AuthError(message: 'Incorrect password'),
        ],
      );
    });

    group('AuthSignUpRequested', () {
      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, AuthAuthenticated] when sign up succeeds',
        build: () {
          when(mockAuthRepository.createUserWithEmailAndPassword(
            'test@example.com',
            'password123',
          )).thenAnswer((_) async => testUser);
          return authBloc;
        },
        act: (bloc) => bloc.add(const AuthSignUpRequested(
          email: 'test@example.com',
          password: 'password123',
        )),
        expect: () => [
          const AuthLoading(),
          AuthAuthenticated(user: testUser),
        ],
      );

      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, AuthError] when sign up fails',
        build: () {
          when(mockAuthRepository.createUserWithEmailAndPassword(
            'test@example.com',
            'password123',
          )).thenThrow(const EmailAlreadyInUseException());
          return authBloc;
        },
        act: (bloc) => bloc.add(const AuthSignUpRequested(
          email: 'test@example.com',
          password: 'password123',
        )),
        expect: () => [
          const AuthLoading(),
          const AuthError(message: 'Email is already in use'),
        ],
      );
    });

    group('AuthSignOutRequested', () {
      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, AuthUnauthenticated] when sign out succeeds',
        build: () {
          when(mockAuthRepository.signOut()).thenAnswer((_) async {});
          return authBloc;
        },
        act: (bloc) => bloc.add(const AuthSignOutRequested()),
        expect: () => [
          const AuthLoading(),
          const AuthUnauthenticated(),
        ],
      );

      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, AuthError] when sign out fails',
        build: () {
          when(mockAuthRepository.signOut())
              .thenThrow(const NetworkException());
          return authBloc;
        },
        act: (bloc) => bloc.add(const AuthSignOutRequested()),
        expect: () => [
          const AuthLoading(),
          const AuthError(message: 'Network connection error'),
        ],
      );
    });

    group('AuthStatusRequested', () {
      blocTest<AuthBloc, AuthState>(
        'emits AuthAuthenticated when user is logged in',
        build: () {
          when(mockAuthRepository.currentUser).thenReturn(testUser);
          return authBloc;
        },
        act: (bloc) => bloc.add(const AuthStatusRequested()),
        expect: () => [
          AuthAuthenticated(user: testUser),
        ],
      );

      blocTest<AuthBloc, AuthState>(
        'emits AuthUnauthenticated when no user is logged in',
        build: () {
          when(mockAuthRepository.currentUser).thenReturn(null);
          return authBloc;
        },
        seed: () => AuthAuthenticated(user: testUser), // Start from authenticated state
        act: (bloc) => bloc.add(const AuthStatusRequested()),
        expect: () => [
          const AuthUnauthenticated(),
        ],
        verify: (_) {
          verify(mockAuthRepository.currentUser).called(1);
        },
      );
    });
  });
}