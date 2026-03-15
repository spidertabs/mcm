// lib/data/models/postnatal_model.dart
import '../../domain/entities/postnatal_entity.dart';

class PostnatalModel extends PostnatalEntity {
  final String? patientName;

  const PostnatalModel({
    super.id,
    required super.patientId,
    this.patientName,
    required super.visitDate,
    required super.visitNumber,
    super.motherBpSystolic,
    super.motherBpDiastolic,
    super.motherTemp,
    super.lochia,
    super.breastfeeding,
    super.babyWeight,
    super.babyTemp,
    super.notes,
    required super.recordedBy,
    required super.createdAt,
  });

  factory PostnatalModel.fromMap(Map<String, dynamic> map) => PostnatalModel(
        id: map['id']?.toString(),
        patientId: map['patient_id']?.toString() ?? '',
        patientName: map['patient_name'] as String?,
        visitDate: DateTime.parse(map['visit_date'] as String),
        visitNumber: (map['visit_number'] as int?) ?? 1,
        motherBpSystolic: map['mother_bp_s'] as int?,
        motherBpDiastolic: map['mother_bp_d'] as int?,
        motherTemp: map['mother_temp'] as double?,
        lochia: map['lochia'] as String?,
        breastfeeding: ((map['breastfeeding'] as int?) ?? 1) == 1,
        babyWeight: map['baby_weight'] as double?,
        babyTemp: map['baby_temp'] as double?,
        notes: map['notes'] as String?,
        recordedBy: map['recorded_by']?.toString() ?? '',
        createdAt: DateTime.parse(map['created_at'] as String),
      );

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'patient_id': patientId,
        'visit_date': visitDate.toIso8601String(),
        'visit_number': visitNumber,
        'mother_bp_s': motherBpSystolic,
        'mother_bp_d': motherBpDiastolic,
        'mother_temp': motherTemp,
        'lochia': lochia,
        'breastfeeding': breastfeeding ? 1 : 0,
        'baby_weight': babyWeight,
        'baby_temp': babyTemp,
        'notes': notes,
        'recorded_by': recordedBy,
        'created_at': createdAt.toIso8601String(),
      };
}