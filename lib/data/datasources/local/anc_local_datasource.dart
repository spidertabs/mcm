// lib/data/datasources/local/anc_local_datasource.dart
import 'package:uuid/uuid.dart';
import '../../../core/storage/database_helper.dart';
import '../../../core/errors/exceptions.dart';
import '../../models/anc_visit_model.dart';
import '../../../domain/entities/anc_visit_entity.dart';

class AncLocalDataSource {
  final DatabaseHelper _db;
  const AncLocalDataSource(this._db);

  /// Fetches all ANC visits joined with patient full_name.
  Future<List<AncVisitModel>> getAllVisits() async {
    final db = await _db.database;
    final rows = await db.rawQuery('''
      SELECT anc_visits.*, patients.full_name AS patient_name
      FROM anc_visits
      LEFT JOIN patients ON anc_visits.patient_id = patients.id
      ORDER BY anc_visits.visit_date DESC
    ''');
    return rows.map(AncVisitModel.fromMap).toList();
  }

  Future<List<AncVisitModel>> getVisitsForPatient(String patientId) async {
    final db = await _db.database;
    final rows = await db.rawQuery('''
      SELECT anc_visits.*, patients.full_name AS patient_name
      FROM anc_visits
      LEFT JOIN patients ON anc_visits.patient_id = patients.id
      WHERE anc_visits.patient_id = ?
      ORDER BY anc_visits.visit_number ASC
    ''', [patientId]);
    return rows.map(AncVisitModel.fromMap).toList();
  }

  Future<AncVisitModel> insert(AncVisitEntity visit) async {
    final db = await _db.database;
    final model = AncVisitModel(
      id: const Uuid().v4(),
      patientId: visit.patientId,
      visitNumber: visit.visitNumber,
      visitDate: visit.visitDate,
      gestationalAge: visit.gestationalAge,
      bloodPressure: visit.bloodPressure,
      weight: visit.weight,
      fetalHeartRate: visit.fetalHeartRate,
      fundalHeight: visit.fundalHeight,
      hbLevel: visit.hbLevel,
      urinalysis: visit.urinalysis,
      ironFolicAcid: visit.ironFolicAcid,
      notes: visit.notes,
      nextVisitDate: visit.nextVisitDate,
      attendedBy: visit.attendedBy,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    await db.insert('anc_visits', model.toMap());
    return model;
  }

  Future<AncVisitModel> update(AncVisitEntity visit) async {
    if (visit.id == null) throw const DatabaseException('Visit id is null');
    final db = await _db.database;
    final model = AncVisitModel(
      id: visit.id,
      patientId: visit.patientId,
      visitNumber: visit.visitNumber,
      visitDate: visit.visitDate,
      gestationalAge: visit.gestationalAge,
      bloodPressure: visit.bloodPressure,
      weight: visit.weight,
      fetalHeartRate: visit.fetalHeartRate,
      fundalHeight: visit.fundalHeight,
      hbLevel: visit.hbLevel,
      urinalysis: visit.urinalysis,
      ironFolicAcid: visit.ironFolicAcid,
      notes: visit.notes,
      nextVisitDate: visit.nextVisitDate,
      attendedBy: visit.attendedBy,
      createdAt: visit.createdAt,
      updatedAt: DateTime.now(),
    );
    await db.update(
      'anc_visits',
      model.toMap(),
      where: 'id = ?',
      whereArgs: [visit.id],
    );
    return model;
  }

  Future<void> delete(String id) async {
    final db = await _db.database;
    await db.delete('anc_visits', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> countThisMonth() async {
    final db = await _db.database;
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, 1).toIso8601String();
    final end = DateTime(now.year, now.month + 1, 0).toIso8601String();
    final result = await db.rawQuery(
      'SELECT COUNT(*) FROM anc_visits WHERE visit_date BETWEEN ? AND ?',
      [start, end],
    );
    return result.first.values.first as int? ?? 0;
  }
}