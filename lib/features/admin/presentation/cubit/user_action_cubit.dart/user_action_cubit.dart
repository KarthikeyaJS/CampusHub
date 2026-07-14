import 'package:campus_hub/features/admin/domain/usecases/create_manage_user_usecase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../auth/domain/entities/user_role.dart';
import '../../../domain/usecases/update_user_role_usecase.dart';
import 'user_action_state.dart';

class UserActionCubit extends Cubit<UserActionState> {
  final CreateManagedUserUseCase createManagedUserUseCase;
  final UpdateUserRoleUseCase updateUserRoleUseCase;

  UserActionCubit({
    required this.createManagedUserUseCase,
    required this.updateUserRoleUseCase,
  }) : super(const UserActionInitial());

  Future<void> createUser({
    required String name,
    required String email,
    required String password,
    required UserRole role,
    String? department,
  }) async {
    emit(const UserActionLoading());
    final result = await createManagedUserUseCase(
      name: name,
      email: email,
      password: password,
      role: role,
      department: department,
    );
    result.fold(
      (failure) => emit(UserActionError(failure.message)),
      (user) => emit(UserActionSuccess(user)),
    );
  }

  Future<void> updateRole({
    required String uid,
    required UserRole role,
    String? department,
  }) async {
    emit(const UserActionLoading());
    final result = await updateUserRoleUseCase(
      uid: uid,
      role: role,
      department: department,
    );
    result.fold(
      (failure) => emit(UserActionError(failure.message)),
      (_) => emit(const UserActionSuccess()),
    );
  }
}
