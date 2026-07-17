import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/repositories/auth_repository.dart';
import 'auth_state.dart';

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
    _authSubscription?.cancel();
    return super.close();
  }
}
