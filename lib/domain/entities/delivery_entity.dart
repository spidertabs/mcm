// lib/domain/entities/delivery_entity.dart
import 'package:equatable/equatable.dart';

enum DeliveryMode {
  svd('svd', 'Spontaneous Vaginal Delivery'),
  cs('cs', 'Caesarean Section'),
  assisted('assisted', 'Assisted Delivery'),
  other('other', 'Other');

  const DeliveryMode(this.value, this.label);
  final String value;
  final String label;

  static DeliveryMode fromString(String v) => DeliveryMode.values.firstWhere(
        (d) => d.value == v,
        orElse: () => DeliveryMode.svd,
      );
}

enum BirthOutcome {
  liveBirth('live_birth', 'Live Birth'),
  stillbirth('stillbirth', 'Stillbirth'),
  abortion('abortion', 'Abortion / Miscarriage');

  const BirthOutcome(this.value, this.label);
  final String value;
  final String label;

  static BirthOutcome fromString(String v) => BirthOutcome.values.firstWhere(
        (b) => b.value == v,
        orElse: () => BirthOutcome.liveBirth,
      );
}

class DeliveryEntity extends Equatable {
  final String? id;
  final String patientId;
  final DateTime deliveryDate;
  final DeliveryMode deliveryMode;
  final BirthOutcome birthOutcome;
  final double? birthWeightKg;
  final String? babySex;
  final int? apgarScore;
  final String? complications;
  final double? bloodLossMl;
  final bool placentaComplete;
  final String? notes;
  final String recordedBy;
  final DateTime createdAt;

  const DeliveryEntity({
    this.id,
    required this.patientId,
    required this.deliveryDate,
    required this.deliveryMode,
    required this.birthOutcome,
    this.birthWeightKg,
    this.babySex,
    this.apgarScore,
    this.complications,
    this.bloodLossMl,
    this.placentaComplete = true,
    this.notes,
    required this.recordedBy,
    required this.createdAt,
  });

  bool get isLowBirthWeight =>
      birthWeightKg != null && birthWeightKg! < 2.5;

  bool get hasLowApgar => apgarScore != null && apgarScore! < 7;

  @override
  List<Object?> get props => [id, patientId, deliveryDate];
}
