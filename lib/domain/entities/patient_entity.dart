// lib/domain/entities/patient_entity.dart
import 'package:equatable/equatable.dart';

enum RiskLevel {
  low('low', 'Low Risk'),
  medium('medium', 'Medium Risk'),
  high('high', 'High Risk');

  const RiskLevel(this.value, this.label);
  final String value;
  final String label;

  static RiskLevel fromString(String value) => RiskLevel.values.firstWhere(
        (r) => r.value == value,
        orElse: () => RiskLevel.low,
      );
}

class PatientEntity extends Equatable {
  final String? id;
  final String fullName;
  final DateTime dateOfBirth;
  final String? phone;
  final String? address;
  final String? village;
  final String? nextOfKin;
  final String? nokPhone;
  final DateTime? lmp;
  final DateTime? edd;
  final int gravida;
  final int parity;
  final String? bloodGroup;
  final RiskLevel riskLevel;
  final String registeredBy;
  final bool isActive;
  final DateTime createdAt;

  const PatientEntity({
    this.id,
    required this.fullName,
    required this.dateOfBirth,
    this.phone,
    this.address,
    this.village,
    this.nextOfKin,
    this.nokPhone,
    this.lmp,
    this.edd,
    this.gravida = 0,
    this.parity = 0,
    this.bloodGroup,
    this.riskLevel = RiskLevel.low,
    required this.registeredBy,
    this.isActive = true,
    required this.createdAt,
  });

  int get ageYears {
    final now = DateTime.now();
    int age = now.year - dateOfBirth.year;
    if (now.month < dateOfBirth.month ||
        (now.month == dateOfBirth.month && now.day < dateOfBirth.day)) {
      age--;
    }
    return age;
  }

  int? get gestationalAgeWeeks {
    if (lmp == null) return null;
    return DateTime.now().difference(lmp!).inDays ~/ 7;
  }

  PatientEntity copyWith({
    String? id,
    String? fullName,
    DateTime? dateOfBirth,
    String? phone,
    String? address,
    String? village,
    String? nextOfKin,
    String? nokPhone,
    DateTime? lmp,
    DateTime? edd,
    int? gravida,
    int? parity,
    String? bloodGroup,
    RiskLevel? riskLevel,
    String? registeredBy,
    bool? isActive,
    DateTime? createdAt,
  }) =>
      PatientEntity(
        id: id ?? this.id,
        fullName: fullName ?? this.fullName,
        dateOfBirth: dateOfBirth ?? this.dateOfBirth,
        phone: phone ?? this.phone,
        address: address ?? this.address,
        village: village ?? this.village,
        nextOfKin: nextOfKin ?? this.nextOfKin,
        nokPhone: nokPhone ?? this.nokPhone,
        lmp: lmp ?? this.lmp,
        edd: edd ?? this.edd,
        gravida: gravida ?? this.gravida,
        parity: parity ?? this.parity,
        bloodGroup: bloodGroup ?? this.bloodGroup,
        riskLevel: riskLevel ?? this.riskLevel,
        registeredBy: registeredBy ?? this.registeredBy,
        isActive: isActive ?? this.isActive,
        createdAt: createdAt ?? this.createdAt,
      );

  @override
  List<Object?> get props => [id, fullName, dateOfBirth];
}
