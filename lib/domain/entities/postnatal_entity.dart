// lib/domain/entities/postnatal_entity.dart
import 'package:equatable/equatable.dart';

class PostnatalEntity extends Equatable {
  final String? id;
  final String patientId;
  final DateTime visitDate;
  final int visitNumber;
  final int? motherBpSystolic;
  final int? motherBpDiastolic;
  final double? motherTemp;
  final String? lochia;
  final bool breastfeeding;
  final double? babyWeight;
  final double? babyTemp;
  final String? notes;
  final String recordedBy;
  final DateTime createdAt;

  const PostnatalEntity({
    this.id,
    required this.patientId,
    required this.visitDate,
    required this.visitNumber,
    this.motherBpSystolic,
    this.motherBpDiastolic,
    this.motherTemp,
    this.lochia,
    this.breastfeeding = true,
    this.babyWeight,
    this.babyTemp,
    this.notes,
    required this.recordedBy,
    required this.createdAt,
  });

  String get visitLabel {
    switch (visitNumber) {
      case 1:
        return 'Day 1';
      case 2:
        return 'Day 3';
      case 3:
        return 'Week 1';
      case 4:
        return '6-Week Check';
      default:
        return 'Visit $visitNumber';
    }
  }

  @override
  List<Object?> get props => [id, patientId, visitDate, visitNumber];
}
