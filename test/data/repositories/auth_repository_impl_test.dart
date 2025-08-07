import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:takdo/data/datasources/firebase_auth_datasource.dart';
import 'package:takdo/data/repositories/auth_repository_impl.dart';
import 'package:takdo/domain/entities/user.dart';
import 'package:takdo/domain/exceptions/auth_exception.dart';

import 'auth_repository_impl_test.mocks.dart';

@GenerateMocks([FirebaseAuthDataSource])
void main() {
  group('AuthRepositoryImpl', () {
    late MockFirebaseAuthDataSource mockDataSource;
    late AuthRepositoryImpl repository;

    final testUser = User(
      id: 'test-id',
      email: 'test@example.com',
      displayName: 'Test User',
      createdAt: DateTime.now(),
    );

    setUp(() {
      mockDataSource = MockFirebaseAuthDataSource();
      repository = AuthRepositoryImpl(dataSource: mockDataSource);
    });

    group('signInWithEmailAndPassword', () {
      test('should return User when sign in succeeds', () async {
        // Arrange
        when(mockDataSource.signInWithEmailAndPassword(
          'test@example.com',
          'password123',
        )).thenAnswer((_) async => testUser);

        // Act
        final result = await repository.signInWithEmailAndPassword(
          'test@example.com',
          'password123',
        );

        // Assert
        expect(result, testUser);
        verify(mockDataSource.signInWithEmailAndPassword(
          'test@example.com',
          'password123',
        )).called(1);
      });

      test('should throw AuthException when sign in fails', () async {
        // Arrange
        when(mockDataSource.signInWithEmailAndPassword(
          'test@example.com',
          'wrongpassword',
        )).thenThrow(const WrongPasswordException());

        // Act & Assert
        expect(
          () => repository.signInWithEmailAndPassword(
            'test@example.com',
            'wrongpassword',
          ),
          throwsA(isA<WrongPasswordException>()),
        );
      });
    });

    group('createUserWithEmailAndPassword', () {
      test('should return User when registration succeeds', () async {
        // Arrange
        when(mockDataSource.createUserWithEmailAndPassword(
          'test@example.com',
          'password123',
        )).thenAnswer((_) async => testUser);

        // Act
        final result = await repository.createUserWithEmailAndPassword(
          'test@example.com',
          'password123',
        );

        // Assert
        expect(result, testUser);
        verify(mockDataSource.createUserWithEmailAndPassword(
          'test@example.com',
          'password123',
        )).called(1);
      });

      test('should throw AuthException when registration fails', () async {
        // Arrange
        when(mockDataSource.createUserWithEmailAndPassword(
          'test@example.com',
          'password123',
        )).thenThrow(const EmailAlreadyInUseException());

        // Act & Assert
        expect(
          () => repository.createUserWithEmailAndPassword(
            'test@example.com',
            'password123',
          ),
          throwsA(isA<EmailAlreadyInUseException>()),
        );
      });
    });

    group('signOut', () {
      test('should complete successfully when sign out succeeds', () async {
        // Arrange
        when(mockDataSource.signOut()).thenAnswer((_) async {});

        // Act
        await repository.signOut();

        // Assert
        verify(mockDataSource.signOut()).called(1);
      });

      test('should throw AuthException when sign out fails', () async {
        // Arrange
        when(mockDataSource.signOut())
            .thenThrow(const NetworkException());

        // Act & Assert
        expect(
          () => repository.signOut(),
          throwsA(isA<NetworkException>()),
        );
      });
    });

    group('authStateChanges', () {
      test('should return stream from data source', () {
        // Arrange
        final stream = Stream.value(testUser);
        when(mockDataSource.authStateChanges).thenAnswer((_) => stream);

        // Act
        final result = repository.authStateChanges;

        // Assert
        expect(result, stream);
        verify(mockDataSource.authStateChanges).called(1);
      });
    });

    group('currentUser', () {
      test('should return current user from data source', () {
        // Arrange
        when(mockDataSource.currentUser).thenReturn(testUser);

        // Act
        final result = repository.currentUser;

        // Assert
        expect(result, testUser);
        verify(mockDataSource.currentUser).called(1);
      });

      test('should return null when no user is signed in', () {
        // Arrange
        when(mockDataSource.currentUser).thenReturn(null);

        // Act
        final result = repository.currentUser;

        // Assert
        expect(result, null);
        verify(mockDataSource.currentUser).called(1);
      });
    });
  });
}