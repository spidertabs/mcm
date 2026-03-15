// lib/data/models/family_planning_model.dart
import '../../domain/entities/family_planning_entity.dart';

class FamilyPlanningModel extends FamilyPlanningEntity {
  final String? patientName;

  const FamilyPlanningModel({
    super.id,
    required super.patientId,
    this.patientName,
    required super.serviceDate,
    required super.method,
    super.isNewClient,
    super.followUp,
    super.notes,
    required super.recordedBy,
    required super.createdAt,
  });

  factory FamilyPlanningModel.fromMap(Map<String, dynamic> map) =>
      FamilyPlanningModel(
        id: map['id']?.toString(),
        patientId: map['patient_id']?.toString() ?? '',
        patientName: map['patient_name'] as String?,
        serviceDate: DateTime.parse(map['service_date'] as String),
        method: map['method'] as String? ?? '',
        isNewClient: ((map['is_new_client'] as int?) ?? 1) == 1,
        followUp: map['follow_up'] != null
            ? DateTime.tryParse(map['follow_up'] as String)
            : null,
        notes: map['notes'] as String?,
        recordedBy: map['recorded_by']?.toString() ?? '',
        createdAt: DateTime.parse(map['created_at'] as String),
      );

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'patient_id': patientId,
        'service_date': serviceDate.toIso8601String(),
        'method': method,
        'is_new_client': isNewClient ? 1 : 0,
        'follow_up': followUp?.toIso8601String(),
        'notes': notes,
        'recorded_by': recordedBy,
        'created_at': createdAt.toIso8601String(),
      };
}