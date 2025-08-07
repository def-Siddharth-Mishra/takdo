import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/datasources/firebase_auth_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../bloc/auth/auth_bloc.dart';

/// Provider widget that creates and provides AuthBloc to the widget tree
class AuthProvider extends StatelessWidget {
  const AuthProvider({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AuthBloc>(
      create: (context) => AuthBloc(
        authRepository: AuthRepositoryImpl(
          dataSource: FirebaseAuthDataSource(),
        ),
      ),
      child: child,
    );
  }
}

/// Extension to easily access AuthBloc from BuildContext
extension AuthBlocExtension on BuildContext {
  /// Get AuthBloc instance
  AuthBloc get authBloc => read<AuthBloc>();

  /// Watch AuthBloc state changes
  AuthBloc get watchAuthBloc => watch<AuthBloc>();
}