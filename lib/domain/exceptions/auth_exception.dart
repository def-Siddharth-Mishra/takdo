/// Base class for authentication-related exceptions
abstract class AuthException implements Exception {
  const AuthException(this.message);

  final String message;

  @override
  String toString() => 'AuthException: $message';
}

/// Exception thrown when email format is invalid
class InvalidEmailException extends AuthException {
  const InvalidEmailException() : super('Invalid email format');
}

/// Exception thrown when password is incorrect
class WrongPasswordException extends AuthException {
  const WrongPasswordException() : super('Incorrect password');
}

/// Exception thrown when user is not found
class UserNotFoundException extends AuthException {
  const UserNotFoundException() : super('User not found');
}

/// Exception thrown when email is already in use
class EmailAlreadyInUseException extends AuthException {
  const EmailAlreadyInUseException() : super('Email is already in use');
}

/// Exception thrown when password is too weak
class WeakPasswordException extends AuthException {
  const WeakPasswordException() : super('Password is too weak');
}

/// Exception thrown when there are network connectivity issues
class NetworkException extends AuthException {
  const NetworkException() : super('Network connection error');
}

/// Exception thrown for generic authentication errors
class GenericAuthException extends AuthException {
  const GenericAuthException(super.message);
}