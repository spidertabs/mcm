// lib/data/datasources/local/patient_local_datasource.dart
import 'package:uuid/uuid.dart';
import '../../../core/storage/database_helper.dart';
import '../../../core/errors/exceptions.dart';
import '../../models/patient_model.dart';
import '../../../domain/entities/patient_entity.dart';

class PatientLocalDataSource {
  final DatabaseHelper _db;
  const PatientLocalDataSource(this._db);

  Future<List<PatientModel>> getAllPatients() async {
    final db = await _db.database;
    final rows = await db.query('patients', orderBy: 'full_name ASC');
    return rows.map(PatientModel.fromMap).toList();
  }

  Future<PatientModel> getById(String id) async {
    final db = await _db.database;
    final rows = await db.query('patients', where: 'id = ?', whereArgs: [id]);
    if (rows.isEmpty) throw const NotFoundException('Patient not found');
    return PatientModel.fromMap(rows.first);
  }

  Future<PatientModel> insert(PatientEntity patient) async {
    final db = await _db.database;
    final model = PatientModel(
      id: const Uuid().v4(),
      fullName: patient.fullName,
      dateOfBirth: patient.dateOfBirth,
      phone: patient.phone,
      address: patient.address,
      village: patient.village,
      nextOfKin: patient.nextOfKin,
      nokPhone: patient.nokPhone,
      lmp: patient.lmp,
      edd: patient.edd,
      gravida: patient.gravida,
      parity: patient.parity,
      bloodGroup: patient.bloodGroup,
      registeredBy: patient.registeredBy,
      createdAt: DateTime.now(),
    );
    await db.insert('patients', model.toMap());
    return model;
  }

  Future<PatientModel> update(PatientEntity patient) async {
    final db = await _db.database;
    final model = PatientModel(
      id: patient.id, fullName: patient.fullName,
      dateOfBirth: patient.dateOfBirth, phone: patient.phone,
      address: patient.address, village: patient.village,
      nextOfKin: patient.nextOfKin, nokPhone: patient.nokPhone,
      lmp: patient.lmp, edd: patient.edd, gravida: patient.gravida,
      parity: patient.parity, bloodGroup: patient.bloodGroup,
      registeredBy: patient.registeredBy, createdAt: patient.createdAt,
    );
    await db.update('patients', model.toMap(), where: 'id = ?', whereArgs: [patient.id]);
    return model;
  }

  Future<void> delete(String id) async {
    final db = await _db.database;
    await db.delete('patients', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<PatientModel>> search(String query) async {
    final db = await _db.database;
    final rows = await db.query(
      'patients',
      where: 'full_name LIKE ? OR phone LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
      orderBy: 'full_name ASC',
    );
    return rows.map(PatientModel.fromMap).toList();
  }
}
