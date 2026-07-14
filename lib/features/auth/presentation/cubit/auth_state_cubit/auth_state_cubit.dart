import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/repositories/auth_repository.dart';
import 'auth_state.dart';

/// Listens to Firebase's auth state stream for the app's ENTIRE lifetime.
/// This is the single source of truth for "is someone logged in" —
/// the router will watch this to redirect between login/dashboard.
class AuthStateCubit extends Cubit<AuthState> {
  final AuthRepository repository;
  StreamSubscription? _authSubscription;

  AuthStateCubit(this.repository) : super(const AuthInitial()) {
    _authSubscription = repository.authStateChanges.listen((user) {
      if (user != null) {
        emit(AuthAuthenticated(user));
      } else {
        emit(const AuthUnauthenticated());
      }
    });
  }

  @override
  Future<void> close() {
    // Always cancel stream subscriptions to avoid memory leaks.
    _authSubscription?.cancel();
    return super.close();
  }
}
