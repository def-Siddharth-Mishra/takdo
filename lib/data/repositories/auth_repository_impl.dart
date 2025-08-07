import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/firebase_auth_datasource.dart';

/// Implementation of AuthRepository using Firebase Authentication
class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuthDataSource _dataSource;

  AuthRepositoryImpl({
    required FirebaseAuthDataSource dataSource,
  }) : _dataSource = dataSource;

  @override
  Future<User> signInWithEmailAndPassword(String email, String password) {
    return _dataSource.signInWithEmailAndPassword(email, password);
  }

  @override
  Future<User> createUserWithEmailAndPassword(String email, String password) {
    return _dataSource.createUserWithEmailAndPassword(email, password);
  }

  @override
  Future<void> signOut() {
    return _dataSource.signOut();
  }

  @override
  Stream<User?> get authStateChanges => _dataSource.authStateChanges;

  @override
  User? get currentUser => _dataSource.currentUser;
}