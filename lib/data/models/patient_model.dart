// lib/data/models/patient_model.dart
import '../../domain/entities/patient_entity.dart';

class PatientModel extends PatientEntity {
  const PatientModel({
    super.id,
    required super.fullName,
    required super.dateOfBirth,
    super.phone,
    super.address,
    super.village,
    super.nextOfKin,
    super.nokPhone,
    super.lmp,
    super.edd,
    super.gravida,
    super.parity,
    super.bloodGroup,
    super.riskLevel,
    required super.registeredBy,
    super.isActive,
    required super.createdAt,
  });

  factory PatientModel.fromMap(Map<String, dynamic> map) => PatientModel(
        id: map['id']?.toString(),
        fullName: map['full_name'] as String,
        dateOfBirth: DateTime.parse(map['date_of_birth'] as String),
        phone: map['phone'] as String?,
        address: map['address'] as String?,
        village: map['village'] as String?,
        nextOfKin: map['next_of_kin'] as String?,
        nokPhone: map['nok_phone'] as String?,
        lmp: map['lmp'] != null ? DateTime.parse(map['lmp'] as String) : null,
        edd: map['edd'] != null ? DateTime.parse(map['edd'] as String) : null,
        gravida: (map['gravida'] as int?) ?? 0,
        parity: (map['parity'] as int?) ?? 0,
        bloodGroup: map['blood_group'] as String?,
        riskLevel: RiskLevel.fromString((map['risk_level'] as String?) ?? 'low'),
        registeredBy: map['registered_by']?.toString() ?? '',
        isActive: ((map['is_active'] as int?) ?? 1) == 1,
        createdAt: DateTime.parse(map['created_at'] as String),
      );

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'full_name': fullName,
        'date_of_birth': dateOfBirth.toIso8601String(),
        'phone': phone,
        'address': address,
        'village': village,
        'next_of_kin': nextOfKin,
        'nok_phone': nokPhone,
        'lmp': lmp?.toIso8601String(),
        'edd': edd?.toIso8601String(),
        'gravida': gravida,
        'parity': parity,
        'blood_group': bloodGroup,
        'risk_level': riskLevel.value,
        'registered_by': registeredBy,
        'is_active': isActive ? 1 : 0,
        'created_at': createdAt.toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };
}
