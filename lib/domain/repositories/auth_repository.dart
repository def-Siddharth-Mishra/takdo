import '../entities/user.dart';

/// Repository interface for authentication operations
abstract class AuthRepository {
  /// Sign in with email and password
  /// Throws [AuthException] on failure
  Future<User> signInWithEmailAndPassword(String email, String password);

  /// Create user with email and password
  /// Throws [AuthException] on failure
  Future<User> createUserWithEmailAndPassword(String email, String password);

  /// Sign out current user
  /// Throws [AuthException] on failure
  Future<void> signOut();

  /// Stream of authentication state changes
  /// Returns null when user is not authenticated
  Stream<User?> get authStateChanges;

  /// Get current authenticated user
  /// Returns null if no user is authenticated
  User? get currentUser;
}