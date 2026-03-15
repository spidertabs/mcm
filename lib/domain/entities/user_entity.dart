// lib/domain/entities/user_entity.dart
import 'package:equatable/equatable.dart';

enum UserRole {
  healthWorker('health_worker', 'Health Worker'),
  supervisor('supervisor', 'Supervisor'),
  administrator('administrator', 'Administrator'),
  policymaker('policymaker', 'Policymaker');

  const UserRole(this.value, this.label);
  final String value;
  final String label;

  static UserRole fromString(String value) => UserRole.values.firstWhere(
        (r) => r.value == value,
        orElse: () => UserRole.healthWorker,
      );
}

class UserEntity extends Equatable {
  final String? id;
  final String username;
  final String fullName;
  final String? email;
  final String password;
  final UserRole role;
  final bool isActive;
  final String? avatarPath; // local file path to profile picture
  final DateTime createdAt;

  const UserEntity({
    this.id,
    required this.username,
    required this.fullName,
    this.email,
    required this.password,
    required this.role,
    this.isActive = true,
    this.avatarPath,
    required this.createdAt,
  });

  bool get isAdmin        => role == UserRole.administrator;
  bool get isSupervisor   => role == UserRole.supervisor;
  bool get isHealthWorker => role == UserRole.healthWorker;
  bool get isPolicymaker  => role == UserRole.policymaker;
  bool get canWrite       => role != UserRole.policymaker;
  bool get canManageUsers => role == UserRole.administrator;

  UserEntity copyWith({
    String? id,
    String? username,
    String? fullName,
    String? email,
    String? password,
    UserRole? role,
    bool? isActive,
    String? avatarPath,
    bool clearAvatar = false,
    DateTime? createdAt,
  }) =>
      UserEntity(
        id: id ?? this.id,
        username: username ?? this.username,
        fullName: fullName ?? this.fullName,
        email: email ?? this.email,
        password: password ?? this.password,
        role: role ?? this.role,
        isActive: isActive ?? this.isActive,
        avatarPath: clearAvatar ? null : avatarPath ?? this.avatarPath,
        createdAt: createdAt ?? this.createdAt,
      );

  @override
  List<Object?> get props => [id, username, role];
}