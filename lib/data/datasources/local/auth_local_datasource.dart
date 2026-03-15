// lib/data/datasources/local/auth_local_datasource.dart
import 'package:bcrypt/bcrypt.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';
import '../../../core/storage/database_helper.dart';
import '../../../core/errors/exceptions.dart';
import '../../models/user_model.dart';
import '../../../domain/entities/user_entity.dart';

class AuthLocalDataSource {
  final DatabaseHelper _db;
  const AuthLocalDataSource(this._db);

  Future<UserModel> register({
    required String username,
    required String fullName,
    required String password,
    required UserRole role,
  }) async {
    final db = await _db.database;
    final existing = await db.query(
      'users',
      where: 'username = ?',
      whereArgs: [username],
    );
    if (existing.isNotEmpty) {
      throw const AuthException('Username already exists');
    }
    final hashed = BCrypt.hashpw(password, BCrypt.gensalt());
    final now = DateTime.now();
    final user = UserModel(
      id: const Uuid().v4(),
      username: username,
      fullName: fullName,
      password: hashed,
      role: role,
      isActive: true,
      createdAt: now,
    );
    await db.insert('users', user.toMap());
    return user;
  }

  Future<UserModel> login({
    required String username,
    required String password,
  }) async {
    final db = await _db.database;
    final rows = await db.query(
      'users',
      where: 'username = ? AND is_active = 1',
      whereArgs: [username],
    );
    if (rows.isEmpty) {
      throw const AuthException('Invalid username or password');
    }
    final user = UserModel.fromMap(rows.first);
    if (!BCrypt.checkpw(password, user.password)) {
      throw const AuthException('Invalid username or password');
    }
    return user;
  }

  Future<UserModel?> getUserById(String id) async {
    final db = await _db.database;
    final rows = await db.query('users', where: 'id = ?', whereArgs: [id]);
    if (rows.isEmpty) return null;
    return UserModel.fromMap(rows.first);
  }

  Future<bool> isFirstUser() async {
    final db = await _db.database;
    final count = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM users'),
    );
    return (count ?? 0) == 0;
  }

  Future<List<UserModel>> getAllUsers() async {
    final db = await _db.database;
    final rows = await db.query('users', orderBy: 'full_name ASC');
    return rows.map(UserModel.fromMap).toList();
  }

  Future<void> updatePassword({
    required String userId,
    required String newHashedPassword,
  }) async {
    final db = await _db.database;
    await db.update(
      'users',
      {
        'password': newHashedPassword,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [userId],
    );
  }

  /// Updates the avatar_path for a user.
  /// Pass null to remove the avatar.
  Future<UserModel> updateAvatar({
    required String userId,
    required String? avatarPath,
  }) async {
    final db = await _db.database;
    await db.update(
      'users',
      {
        'avatar_path': avatarPath,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [userId],
    );
    final rows = await db.query('users', where: 'id = ?', whereArgs: [userId]);
    if (rows.isEmpty) throw const AuthException('User not found');
    return UserModel.fromMap(rows.first);
  }
}