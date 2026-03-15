// lib/data/models/user_model.dart
import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    super.id,
    required super.username,
    required super.fullName,
    super.email,
    required super.password,
    required super.role,
    super.isActive,
    super.avatarPath,
    required super.createdAt,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) => UserModel(
    id: map['id']?.toString(),
    username: map['username'] as String? ?? '',
    fullName: map['full_name'] as String? ?? '',
    email: map['email'] as String?,
    password: map['password'] as String? ?? '',
    role: UserRole.fromString(map['role'] as String? ?? 'health_worker'),
    isActive: ((map['is_active'] as int?) ?? 1) == 1,
    avatarPath: map['avatar_path'] as String?,
    createdAt: map['created_at'] != null
        ? DateTime.parse(map['created_at'] as String)
        : DateTime.now(),
  );

  Map<String, dynamic> toMap() => {
    if (id != null) 'id': id,
    'username': username,
    'full_name': fullName,
    if (email != null) 'email': email,
    'password': password,
    'role': role.value,
    'is_active': isActive ? 1 : 0,
    'avatar_path': avatarPath,
    'created_at': createdAt.toIso8601String(),
    'updated_at': createdAt.toIso8601String(),
  };
}