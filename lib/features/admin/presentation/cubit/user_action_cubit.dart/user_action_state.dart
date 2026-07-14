import 'package:equatable/equatable.dart';
import '../../../../auth/domain/entities/user_entity.dart';

abstract class UserActionState extends Equatable {
  const UserActionState();
  @override
  List<Object?> get props => [];
}

class UserActionInitial extends UserActionState {
  const UserActionInitial();
}

class UserActionLoading extends UserActionState {
  const UserActionLoading();
}

class UserActionSuccess extends UserActionState {
  final UserEntity? user;
  const UserActionSuccess([this.user]);
  @override
  List<Object?> get props => [user];
}

class UserActionError extends UserActionState {
  final String message;
  const UserActionError(this.message);
  @override
  List<Object?> get props => [message];
}
