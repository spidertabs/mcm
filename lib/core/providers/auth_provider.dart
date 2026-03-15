// lib/core/providers/auth_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/local/auth_local_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/usecases/auth/login_usecase.dart';
import '../../domain/usecases/auth/register_usecase.dart';
import '../../domain/usecases/auth/logout_usecase.dart';
import '../../core/storage/database_helper.dart';
import '../../core/storage/secure_storage_helper.dart';

// ── Infrastructure providers ──────────────────────────────────────────────────

final databaseHelperProvider =
    Provider<DatabaseHelper>((_) => DatabaseHelper.instance);

final secureStorageProvider =
    Provider<SecureStorageHelper>((_) => SecureStorageHelper.instance);

final authDataSourceProvider = Provider<AuthLocalDataSource>(
    (ref) => AuthLocalDataSource(ref.read(databaseHelperProvider)));

final authRepositoryProvider = Provider<AuthRepositoryImpl>((ref) =>
    AuthRepositoryImpl(
      ref.read(authDataSourceProvider),
      ref.read(secureStorageProvider),
    ));

// ── Use case providers ────────────────────────────────────────────────────────

final loginUseCaseProvider =
    Provider((ref) => LoginUseCase(ref.read(authRepositoryProvider)));

final registerUseCaseProvider =
    Provider((ref) => RegisterUseCase(ref.read(authRepositoryProvider)));

final logoutUseCaseProvider =
    Provider((ref) => LogoutUseCase(ref.read(authRepositoryProvider)));

// ── Auth state ────────────────────────────────────────────────────────────────

class AuthState {
  final UserEntity? currentUser;
  final bool isLoading;
  final String? error;

  const AuthState({
    this.currentUser,
    this.isLoading = false,
    this.error,
  });

  bool get isAuthenticated => currentUser != null;

  AuthState copyWith({
    UserEntity? currentUser,
    bool? isLoading,
    String? error,
    bool clearUser = false,
    bool clearError = false,
  }) =>
      AuthState(
        currentUser: clearUser ? null : currentUser ?? this.currentUser,
        isLoading: isLoading ?? this.isLoading,
        error: clearError ? null : error ?? this.error,
      );
}

class AuthNotifier extends StateNotifier<AuthState> {
  final LoginUseCase _login;
  final RegisterUseCase _register;
  final LogoutUseCase _logout;
  final AuthRepositoryImpl _repo;
  final AuthLocalDataSource _ds;

  AuthNotifier(this._login, this._register, this._logout, this._repo, this._ds)
      : super(const AuthState(isLoading: true)) {
    _restoreSession();
  }

  Future<void> _restoreSession() async {
    final result = await _repo.getCurrentUser();
    result.fold(
      (_) => state = const AuthState(),
      (user) => state = AuthState(currentUser: user),
    );
  }

  Future<bool> login(String username, String password) async {
    state = state.copyWith(isLoading: true, clearError: true);
    final result = await _login(LoginParams(
      username: username,
      password: password,
    ));
    return result.fold(
      (failure) {
        state = AuthState(error: failure.message);
        return false;
      },
      (user) {
        state = AuthState(currentUser: user);
        return true;
      },
    );
  }

  Future<bool> register({
    required String username,
    required String fullName,
    required String password,
    required UserRole role,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    final result = await _register(RegisterParams(
      username: username,
      fullName: fullName,
      password: password,
      role: role,
    ));
    return result.fold(
      (failure) {
        state = AuthState(error: failure.message);
        return false;
      },
      (user) {
        state = AuthState(currentUser: user);
        return true;
      },
    );
  }

  Future<void> logout() async {
    await _logout();
    state = const AuthState();
  }

  /// Set or remove the profile picture.
  /// Pass null to remove the avatar.
  Future<bool> updateAvatar(String? avatarPath) async {
    final user = state.currentUser;
    if (user == null || user.id == null) return false;
    try {
      final updated = await _ds.updateAvatar(
        userId: user.id!,
        avatarPath: avatarPath,
      );
      state = state.copyWith(currentUser: updated);
      return true;
    } catch (_) {
      return false;
    }
  }
}

final authStateProvider =
    StateNotifierProvider<AuthNotifier, AuthState>((ref) => AuthNotifier(
          ref.read(loginUseCaseProvider),
          ref.read(registerUseCaseProvider),
          ref.read(logoutUseCaseProvider),
          ref.read(authRepositoryProvider),
          ref.read(authDataSourceProvider),
        ));