// lib/domain/entities/anc_visit_entity.dart
import 'package:equatable/equatable.dart';

class AncVisitEntity extends Equatable {
  final String? id;          // nullable — null means not yet persisted
  final String patientId;
  final String? patientName; // joined from patients table
  final int visitNumber;
  final DateTime visitDate;

  // Clinical fields — stored as typed values
  final int? gestationalAge;     // gestation weeks
  final String? bloodPressure;   // e.g. "120/80"
  final double? weight;          // kg
  final int? fetalHeartRate;     // bpm
  final double? fundalHeight;    // cm
  final double? hbLevel;         // haemoglobin g/dL
  final String? urinalysis;
  final bool? malariaTest;
  final bool? hivTest;
  final bool? syphilisTest;
  final int? tetanusDose;
  final bool? ironFolicAcid;
  final String? notes;
  final DateTime? nextVisitDate;

  final String attendedBy;       // recorded_by in DB
  final DateTime createdAt;
  final DateTime updatedAt;

  const AncVisitEntity({
    this.id,
    required this.patientId,
    this.patientName,
    required this.visitNumber,
    required this.visitDate,
    this.gestationalAge,
    this.bloodPressure,
    this.weight,
    this.fetalHeartRate,
    this.fundalHeight,
    this.hbLevel,
    this.urinalysis,
    this.malariaTest,
    this.hivTest,
    this.syphilisTest,
    this.tetanusDose,
    this.ironFolicAcid,
    this.notes,
    this.nextVisitDate,
    required this.attendedBy,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Convenience: split bloodPressure string into systolic component.
  int? get bpSystolic {
    if (bloodPressure == null) return null;
    final parts = bloodPressure!.split('/');
    return parts.isNotEmpty ? int.tryParse(parts[0].trim()) : null;
  }

  /// Convenience: split bloodPressure string into diastolic component.
  int? get bpDiastolic {
    if (bloodPressure == null) return null;
    final parts = bloodPressure!.split('/');
    return parts.length > 1 ? int.tryParse(parts[1].trim()) : null;
  }

  bool get isHighBloodPressure =>
      (bpSystolic != null && bpSystolic! >= 140) ||
      (bpDiastolic != null && bpDiastolic! >= 90);

  @override
  List<Object?> get props => [id, patientId, visitNumber];
}