// lib/data/repositories/auth_repository_impl.dart
import 'package:dartz/dartz.dart';
import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../core/storage/secure_storage_helper.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/local/auth_local_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthLocalDataSource _dataSource;
  final SecureStorageHelper _secureStorage;

  const AuthRepositoryImpl(this._dataSource, this._secureStorage);

  @override
  Future<Either<Failure, UserEntity>> register({
    required String username,
    required String fullName,
    required String password,
    required UserRole role,
  }) async {
    try {
      final user = await _dataSource.register(
        username: username,
        fullName: fullName,
        password: password,
        role: role,
      );
      await _secureStorage.saveSession(
        userId: user.id ?? '',
        role: user.role.value,
      );
      return Right(user);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> login({
    required String username,
    required String password,
  }) async {
    try {
      final user = await _dataSource.login(
        username: username,
        password: password,
      );
      await _secureStorage.saveSession(
        userId: user.id ?? '',
        role: user.role.value,
      );
      return Right(user);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    await _secureStorage.clearSession();
    return const Right(null);
  }

  @override
  Future<Either<Failure, UserEntity?>> getCurrentUser() async {
    try {
      final userId = await _secureStorage.getSessionUserId();
      if (userId == null || userId.isEmpty) return const Right(null);
      final user = await _dataSource.getUserById(userId);
      return Right(user);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<bool> isFirstUser() => _dataSource.isFirstUser();
}
