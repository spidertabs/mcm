// lib/data/datasources/local/delivery_local_datasource.dart
import 'package:uuid/uuid.dart';
import '../../../core/storage/database_helper.dart';
import '../../models/delivery_model.dart';
import '../../../domain/entities/delivery_entity.dart';

class DeliveryLocalDataSource {
  final DatabaseHelper _db;
  const DeliveryLocalDataSource(this._db);

  Future<List<DeliveryModel>> getAllRecords() async {
    final db = await _db.database;
    final rows = await db.rawQuery('''
      SELECT delivery_records.*, patients.full_name AS patient_name
      FROM delivery_records
      LEFT JOIN patients ON delivery_records.patient_id = patients.id
      ORDER BY delivery_records.delivery_date DESC
    ''');
    return rows.map(DeliveryModel.fromMap).toList();
  }

  Future<List<DeliveryModel>> getRecordsForPatient(String patientId) async {
    final db = await _db.database;
    final rows = await db.rawQuery('''
      SELECT delivery_records.*, patients.full_name AS patient_name
      FROM delivery_records
      LEFT JOIN patients ON delivery_records.patient_id = patients.id
      WHERE delivery_records.patient_id = ?
      ORDER BY delivery_records.delivery_date DESC
    ''', [patientId]);
    return rows.map(DeliveryModel.fromMap).toList();
  }

  Future<DeliveryModel> insert(DeliveryEntity delivery) async {
    final db = await _db.database;
    final model = DeliveryModel(
      id: const Uuid().v4(),
      patientId: delivery.patientId,
      deliveryDate: delivery.deliveryDate,
      deliveryMode: delivery.deliveryMode,
      birthOutcome: delivery.birthOutcome,
      birthWeightKg: delivery.birthWeightKg,
      babySex: delivery.babySex,
      apgarScore: delivery.apgarScore,
      complications: delivery.complications,
      bloodLossMl: delivery.bloodLossMl,
      placentaComplete: delivery.placentaComplete,
      notes: delivery.notes,
      recordedBy: delivery.recordedBy,
      createdAt: DateTime.now(),
    );
    await db.insert('delivery_records', model.toMap());
    return model;
  }

  Future<void> delete(String id) async {
    final db = await _db.database;
    await db.delete('delivery_records', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> countThisMonth() async {
    final db = await _db.database;
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, 1).toIso8601String();
    final end = DateTime(now.year, now.month + 1, 0).toIso8601String();
    final result = await db.rawQuery(
      'SELECT COUNT(*) FROM delivery_records WHERE delivery_date BETWEEN ? AND ?',
      [start, end],
    );
    return result.first.values.first as int? ?? 0;
  }
}