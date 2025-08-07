import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/user.dart' as domain;
import '../../domain/exceptions/auth_exception.dart';
import '../models/user_dto.dart';

/// Data source for Firebase Authentication operations
class FirebaseAuthDataSource {
  final firebase_auth.FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  FirebaseAuthDataSource({
    firebase_auth.FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
  })  : _firebaseAuth = firebaseAuth ?? firebase_auth.FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  /// Sign in with email and password
  Future<domain.User> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user == null) {
        throw const GenericAuthException('Sign in failed: No user returned');
      }

      // Get user data from Firestore
      final userDoc = await _firestore
          .collection('users')
          .doc(credential.user!.uid)
          .get();

      if (!userDoc.exists) {
        throw const GenericAuthException('User data not found');
      }

      final userDto = UserDto.fromJson(userDoc.data()!);
      return userDto.toDomain();
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw GenericAuthException(_mapFirebaseAuthError(e.code));
    } catch (e) {
      throw GenericAuthException('Sign in failed: ${e.toString()}');
    }
  }

  /// Create user with email and password
  Future<domain.User> createUserWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user == null) {
        throw const GenericAuthException('Registration failed: No user returned');
      }

      // Create user document in Firestore
      final user = domain.User(
        id: credential.user!.uid,
        email: email,
        displayName: credential.user!.displayName ?? email.split('@')[0],
        createdAt: DateTime.now(),
      );

      final userDto = UserDto.fromDomain(user);
      await _firestore
          .collection('users')
          .doc(user.id)
          .set(userDto.toJson());

      return user;
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw GenericAuthException(_mapFirebaseAuthError(e.code));
    } catch (e) {
      throw GenericAuthException('Registration failed: ${e.toString()}');
    }
  }

  /// Sign out current user
  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
    } catch (e) {
      throw GenericAuthException('Sign out failed: ${e.toString()}');
    }
  }

  /// Stream of authentication state changes
  Stream<domain.User?> get authStateChanges {
    return _firebaseAuth.authStateChanges().asyncMap((firebaseUser) async {
      if (firebaseUser == null) return null;

      try {
        final userDoc = await _firestore
            .collection('users')
            .doc(firebaseUser.uid)
            .get();

        if (!userDoc.exists) return null;

        final userDto = UserDto.fromJson(userDoc.data()!);
        return userDto.toDomain();
      } catch (e) {
        return null;
      }
    });
  }

  /// Get current authenticated user
  domain.User? get currentUser {
    final firebaseUser = _firebaseAuth.currentUser;
    if (firebaseUser == null) return null;

    // Note: This is a synchronous method, so we can't fetch from Firestore
    // In a real app, you might want to cache the user data locally
    return domain.User(
      id: firebaseUser.uid,
      email: firebaseUser.email ?? '',
      displayName: firebaseUser.displayName ?? '',
      createdAt: firebaseUser.metadata.creationTime ?? DateTime.now(),
    );
  }

  /// Map Firebase Auth error codes to user-friendly messages
  String _mapFirebaseAuthError(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No user found with this email address';
      case 'wrong-password':
        return 'Incorrect password';
      case 'invalid-email':
        return 'Invalid email address';
      case 'user-disabled':
        return 'This account has been disabled';
      case 'too-many-requests':
        return 'Too many failed attempts. Please try again later';
      case 'email-already-in-use':
        return 'An account already exists with this email address';
      case 'weak-password':
        return 'Password is too weak. Please choose a stronger password';
      case 'network-request-failed':
        return 'Network error. Please check your connection';
      default:
        return 'Authentication failed. Please try again';
    }
  }
}