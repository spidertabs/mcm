// lib/data/models/delivery_model.dart
import '../../domain/entities/delivery_entity.dart';

class DeliveryModel extends DeliveryEntity {
  final String? patientName;

  const DeliveryModel({
    super.id,
    required super.patientId,
    this.patientName,
    required super.deliveryDate,
    required super.deliveryMode,
    required super.birthOutcome,
    super.birthWeightKg,
    super.babySex,
    super.apgarScore,
    super.complications,
    super.bloodLossMl,
    super.placentaComplete,
    super.notes,
    required super.recordedBy,
    required super.createdAt,
  });

  factory DeliveryModel.fromMap(Map<String, dynamic> map) => DeliveryModel(
        id: map['id']?.toString(),
        patientId: map['patient_id']?.toString() ?? '',
        patientName: map['patient_name'] as String?,
        deliveryDate: DateTime.parse(map['delivery_date'] as String),
        deliveryMode:
            DeliveryMode.fromString(map['delivery_type'] as String? ?? 'svd'),
        birthOutcome:
            BirthOutcome.fromString(map['delivery_outcome'] as String? ?? 'live_birth'),
        birthWeightKg: map['birth_weight_kg'] as double?,
        babySex: map['baby_sex'] as String?,
        apgarScore: map['apgar_score'] as int?,
        complications: map['complications'] as String?,
        bloodLossMl: map['blood_loss_ml'] as double?,
        placentaComplete: ((map['placenta_complete'] as int?) ?? 1) == 1,
        notes: map['notes'] as String?,
        recordedBy: map['recorded_by']?.toString() ?? '',
        createdAt: DateTime.parse(map['created_at'] as String),
      );

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'patient_id': patientId,
        'delivery_date': deliveryDate.toIso8601String(),
        'delivery_type': deliveryMode.value,
        'delivery_outcome': birthOutcome.value,
        'birth_weight_kg': birthWeightKg,
        'baby_sex': babySex,
        'apgar_score': apgarScore,
        'complications': complications,
        'blood_loss_ml': bloodLossMl,
        'placenta_complete': placentaComplete ? 1 : 0,
        'notes': notes,
        'recorded_by': recordedBy,
        'created_at': createdAt.toIso8601String(),
      };
}