// lib/data/datasources/local/postnatal_local_datasource.dart
import 'package:uuid/uuid.dart';
import '../../../core/storage/database_helper.dart';
import '../../models/postnatal_model.dart';
import '../../../domain/entities/postnatal_entity.dart';

class PostnatalLocalDataSource {
  final DatabaseHelper _db;
  const PostnatalLocalDataSource(this._db);

  Future<List<PostnatalModel>> getAllRecords() async {
    final db = await _db.database;
    final rows = await db.rawQuery('''
      SELECT postnatal_records.*, patients.full_name AS patient_name
      FROM postnatal_records
      LEFT JOIN patients ON postnatal_records.patient_id = patients.id
      ORDER BY postnatal_records.visit_date DESC
    ''');
    return rows.map(PostnatalModel.fromMap).toList();
  }

  Future<List<PostnatalModel>> getRecordsForPatient(String patientId) async {
    final db = await _db.database;
    final rows = await db.rawQuery('''
      SELECT postnatal_records.*, patients.full_name AS patient_name
      FROM postnatal_records
      LEFT JOIN patients ON postnatal_records.patient_id = patients.id
      WHERE postnatal_records.patient_id = ?
      ORDER BY postnatal_records.visit_number ASC
    ''', [patientId]);
    return rows.map(PostnatalModel.fromMap).toList();
  }

  Future<PostnatalModel> insert(PostnatalEntity record) async {
    final db = await _db.database;
    final model = PostnatalModel(
      id: const Uuid().v4(),
      patientId: record.patientId,
      visitDate: record.visitDate,
      visitNumber: record.visitNumber,
      motherBpSystolic: record.motherBpSystolic,
      motherBpDiastolic: record.motherBpDiastolic,
      motherTemp: record.motherTemp,
      lochia: record.lochia,
      breastfeeding: record.breastfeeding,
      babyWeight: record.babyWeight,
      babyTemp: record.babyTemp,
      notes: record.notes,
      recordedBy: record.recordedBy,
      createdAt: DateTime.now(),
    );
    await db.insert('postnatal_records', model.toMap());
    return model;
  }

  Future<void> delete(String id) async {
    final db = await _db.database;
    await db.delete('postnatal_records', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> countThisMonth() async {
    final db = await _db.database;
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, 1).toIso8601String();
    final end = DateTime(now.year, now.month + 1, 0).toIso8601String();
    final result = await db.rawQuery(
      'SELECT COUNT(*) FROM postnatal_records WHERE visit_date BETWEEN ? AND ?',
      [start, end],
    );
    return result.first.values.first as int? ?? 0;
  }
}