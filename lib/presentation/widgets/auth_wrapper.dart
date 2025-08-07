import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/auth/auth_bloc.dart';
import '../bloc/auth/auth_event.dart';
import '../bloc/auth/auth_state.dart';

/// Widget that wraps the app and handles authentication state
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({
    super.key,
    required this.authenticatedChild,
    required this.unauthenticatedChild,
    this.loadingChild,
  });

  /// Widget to show when user is authenticated
  final Widget authenticatedChild;

  /// Widget to show when user is not authenticated
  final Widget unauthenticatedChild;

  /// Widget to show when authentication is loading (optional)
  final Widget? loadingChild;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        // Handle side effects like showing error messages
        if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      builder: (context, state) {
        // Check authentication status on initial load
        if (state is AuthInitial) {
          context.read<AuthBloc>().add(const AuthStatusRequested());
          return loadingChild ?? const _DefaultLoadingWidget();
        }

        // Show loading widget during authentication operations
        if (state is AuthLoading) {
          return loadingChild ?? const _DefaultLoadingWidget();
        }

        // Show authenticated content when user is logged in
        if (state is AuthAuthenticated) {
          return authenticatedChild;
        }

        // Show unauthenticated content when user is not logged in
        return unauthenticatedChild;
      },
    );
  }
}

/// Default loading widget
class _DefaultLoadingWidget extends StatelessWidget {
  const _DefaultLoadingWidget();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}