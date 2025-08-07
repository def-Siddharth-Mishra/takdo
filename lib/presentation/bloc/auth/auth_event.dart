import 'package:equatable/equatable.dart';

/// Base class for authentication events
abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// Event triggered when user requests sign in
class AuthSignInRequested extends AuthEvent {
  const AuthSignInRequested({
    required this.email,
    required this.password,
  });

  final String email;
  final String password;

  @override
  List<Object?> get props => [email, password];
}

/// Event triggered when user requests sign up
class AuthSignUpRequested extends AuthEvent {
  const AuthSignUpRequested({
    required this.email,
    required this.password,
  });

  final String email;
  final String password;

  @override
  List<Object?> get props => [email, password];
}

/// Event triggered when user requests sign out
class AuthSignOutRequested extends AuthEvent {
  const AuthSignOutRequested();
}

/// Event triggered when authentication state changes
class AuthStateChanged extends AuthEvent {
  const AuthStateChanged({required this.user});

  final dynamic user; // Can be User? or null

  @override
  List<Object?> get props => [user];
}

/// Event triggered to check current authentication status
class AuthStatusRequested extends AuthEvent {
  const AuthStatusRequested();
}