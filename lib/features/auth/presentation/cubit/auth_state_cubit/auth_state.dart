import 'package:equatable/equatable.dart';
import '../../../domain/entities/user_entity.dart';

/// Global auth state — reflects whether ANYONE is logged in right now.
/// Used by the router to decide splash -> login vs splash -> dashboard.
abstract class AuthState extends Equatable {
  const AuthState();
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthAuthenticated extends AuthState {
  final UserEntity user;
  const AuthAuthenticated(this.user);

  @override
  List<Object?> get props => [user];
}

class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}
