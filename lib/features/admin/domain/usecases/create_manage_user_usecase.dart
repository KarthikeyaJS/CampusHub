import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../auth/domain/entities/user_role.dart';
import '../repositories/admin_repository.dart';

/// Creates a Staff/Coordinator/Admin account on the Admin's behalf.
/// See AdminRemoteDataSourceImpl for why this needs a secondary Firebase
/// App instance under the hood — it must NOT change who's currently logged in.
class CreateManagedUserUseCase {
  final AdminRepository repository;
  const CreateManagedUserUseCase(this.repository);

  Future<Either<Failure, UserEntity>> call({
    required String name,
    required String email,
    required String password,
    required UserRole role,
    String? department,
  }) {
    return repository.createUserAccount(
      name: name,
      email: email,
      password: password,
      role: role,
      department: department,
    );
  }
}
