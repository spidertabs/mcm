import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../entities/user_entity.dart';
import '../../repositories/auth_repository.dart';

class RegisterParams {
  final String fullName;
  final String username;
  final String? email;
  final String password;
  final UserRole role;
  const RegisterParams({
    required this.fullName,
    required this.username,
    this.email,
    required this.password,
    required this.role,
  });
}

class RegisterUseCase {
  final AuthRepository _repository;
  const RegisterUseCase(this._repository);

  Future<Either<Failure, UserEntity>> call(RegisterParams params) async {
    // First user ever registered becomes Administrator automatically
    final isFirst = await _repository.isFirstUser();
    final assignedRole =
        isFirst ? UserRole.administrator : params.role;

    return _repository.register(
      username: params.username.trim(),
      fullName: params.fullName.trim(),
      password: params.password,
      role: assignedRole,
    );
  }
}
