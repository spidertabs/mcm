// lib/domain/entities/family_planning_entity.dart
import 'package:equatable/equatable.dart';

class FamilyPlanningEntity extends Equatable {
  final String? id;
  final String patientId;
  final DateTime serviceDate;
  final String method;
  final bool isNewClient;
  final DateTime? followUp;
  final String? notes;
  final String recordedBy;
  final DateTime createdAt;

  const FamilyPlanningEntity({
    this.id,
    required this.patientId,
    required this.serviceDate,
    required this.method,
    this.isNewClient = true,
    this.followUp,
    this.notes,
    required this.recordedBy,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, patientId, serviceDate];
}