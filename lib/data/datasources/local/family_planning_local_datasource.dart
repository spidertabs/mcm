// lib/data/datasources/local/family_planning_local_datasource.dart
import 'package:uuid/uuid.dart';
import '../../../core/storage/database_helper.dart';
import '../../models/family_planning_model.dart';
import '../../../domain/entities/family_planning_entity.dart';

class FamilyPlanningLocalDataSource {
  final DatabaseHelper _db;
  const FamilyPlanningLocalDataSource(this._db);

  Future<List<FamilyPlanningModel>> getAllRecords() async {
    final db = await _db.database;
    final rows = await db.rawQuery('''
      SELECT family_planning.*, patients.full_name AS patient_name
      FROM family_planning
      LEFT JOIN patients ON family_planning.patient_id = patients.id
      ORDER BY family_planning.service_date DESC
    ''');
    return rows.map(FamilyPlanningModel.fromMap).toList();
  }

  Future<List<FamilyPlanningModel>> getRecordsForPatient(
      String patientId) async {
    final db = await _db.database;
    final rows = await db.rawQuery('''
      SELECT family_planning.*, patients.full_name AS patient_name
      FROM family_planning
      LEFT JOIN patients ON family_planning.patient_id = patients.id
      WHERE family_planning.patient_id = ?
      ORDER BY family_planning.service_date DESC
    ''', [patientId]);
    return rows.map(FamilyPlanningModel.fromMap).toList();
  }

  Future<FamilyPlanningModel> insert(FamilyPlanningEntity record) async {
    final db = await _db.database;
    final model = FamilyPlanningModel(
      id: const Uuid().v4(),
      patientId: record.patientId,
      serviceDate: record.serviceDate,
      method: record.method,
      isNewClient: record.isNewClient,
      followUp: record.followUp,
      notes: record.notes,
      recordedBy: record.recordedBy,
      createdAt: DateTime.now(),
    );
    await db.insert('family_planning', model.toMap());
    return model;
  }

  Future<void> delete(String id) async {
    final db = await _db.database;
    await db.delete('family_planning', where: 'id = ?', whereArgs: [id]);
  }

  /// Count services per method this month — used by the summary chips.
  Future<Map<String, int>> countByMethodThisMonth() async {
    final db = await _db.database;
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, 1).toIso8601String();
    final end = DateTime(now.year, now.month + 1, 0).toIso8601String();
    final rows = await db.rawQuery('''
      SELECT method, COUNT(*) as cnt
      FROM family_planning
      WHERE service_date BETWEEN ? AND ?
      GROUP BY method
    ''', [start, end]);
    return {for (final r in rows) r['method'] as String: r['cnt'] as int};
  }
}