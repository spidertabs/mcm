// lib/data/models/anc_visit_model.dart
import 'package:uuid/uuid.dart';
import '../../domain/entities/anc_visit_entity.dart';

class AncVisitModel extends AncVisitEntity {
  const AncVisitModel({
    super.id,
    required super.patientId,
    super.patientName,
    required super.visitNumber,
    required super.visitDate,
    super.gestationalAge,
    super.bloodPressure,
    super.weight,
    super.fetalHeartRate,
    super.fundalHeight,
    super.hbLevel,
    super.urinalysis,
    super.malariaTest,
    super.hivTest,
    super.syphilisTest,
    super.tetanusDose,
    super.ironFolicAcid,
    super.notes,
    super.nextVisitDate,
    required super.attendedBy,
    required super.createdAt,
    required super.updatedAt,
  });

  factory AncVisitModel.fromMap(Map<String, dynamic> map) {
    final bpS = map['bp_systolic'] as int?;
    final bpD = map['bp_diastolic'] as int?;
    final bp  = (bpS != null && bpD != null) ? '$bpS/$bpD' : null;

    return AncVisitModel(
      id:             map['id']?.toString(),
      patientId:      map['patient_id']?.toString() ?? '',
      patientName:    map['patient_name'] as String?,
      visitNumber:    (map['visit_number'] as int?) ?? 1,
      visitDate:      DateTime.parse(map['visit_date'] as String),
      gestationalAge: map['gestation_weeks'] as int?,
      bloodPressure:  bp,
      weight:         map['weight_kg'] as double?,
      fetalHeartRate: map['fetal_heartrate'] as int?,
      fundalHeight:   map['fundal_height'] as double?,
      hbLevel:        map['haemoglobin'] as double?,
      urinalysis:     map['urinalysis'] as String?,
      malariaTest:    map['malaria_test'] == null
          ? null
          : (map['malaria_test'] as int) == 1,
      hivTest:        map['hiv_test'] == null
          ? null
          : (map['hiv_test'] as int) == 1,
      syphilisTest:   map['syphilis_test'] == null
          ? null
          : (map['syphilis_test'] as int) == 1,
      tetanusDose:    map['tetanus_dose'] as int?,
      ironFolicAcid:  map['iron_folic_acid'] == null
          ? null
          : (map['iron_folic_acid'] as int) == 1,
      notes:          map['notes'] as String?,
      nextVisitDate:  map['next_visit_date'] != null
          ? DateTime.tryParse(map['next_visit_date'] as String)
          : null,
      attendedBy:     map['recorded_by']?.toString() ?? '',
      createdAt:      DateTime.parse(map['created_at'] as String),
      updatedAt:      map['updated_at'] != null
          ? DateTime.parse(map['updated_at'] as String)
          : DateTime.parse(map['created_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    int? systolic;
    int? diastolic;
    if (bloodPressure != null) {
      final parts = bloodPressure!.split('/');
      if (parts.length == 2) {
        systolic  = int.tryParse(parts[0].trim());
        diastolic = int.tryParse(parts[1].trim());
      }
    }

    return {
      'id':              id ?? const Uuid().v4(),
      'patient_id':      patientId,
      'visit_number':    visitNumber,
      'visit_date':      visitDate.toIso8601String(),
      'gestation_weeks': gestationalAge,
      'weight_kg':       weight,
      'bp_systolic':     systolic,
      'bp_diastolic':    diastolic,
      'fetal_heartrate': fetalHeartRate,
      'fundal_height':   fundalHeight,
      'haemoglobin':     hbLevel,
      'urinalysis':      urinalysis,
      'malaria_test':    malariaTest == null ? null : (malariaTest! ? 1 : 0),
      'hiv_test':        hivTest == null ? null : (hivTest! ? 1 : 0),
      'syphilis_test':   syphilisTest == null ? null : (syphilisTest! ? 1 : 0),
      'tetanus_dose':    tetanusDose,
      'iron_folic_acid': ironFolicAcid == null ? null : (ironFolicAcid! ? 1 : 0),
      'next_visit_date': nextVisitDate?.toIso8601String(),
      'notes':           notes,
      'recorded_by':     attendedBy,
      'created_at':      createdAt.toIso8601String(),
      'updated_at':      updatedAt.toIso8601String(),
    };
  }
}