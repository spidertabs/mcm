// lib/data/repositories/patient_repository_impl.dart
import 'package:dartz/dartz.dart';
import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/patient_entity.dart';
import '../../domain/repositories/patient_repository.dart';
import '../datasources/local/patient_local_datasource.dart';

class PatientRepositoryImpl implements PatientRepository {
  final PatientLocalDataSource _dataSource;
  const PatientRepositoryImpl(this._dataSource);

  @override
  Future<Either<Failure, List<PatientEntity>>> getAllPatients() async {
    try {
      return Right(await _dataSource.getAllPatients());
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, PatientEntity>> getPatientById(String id) async {
    try {
      return Right(await _dataSource.getById(id));
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(e.message));
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, PatientEntity>> createPatient(PatientEntity patient) async {
    try {
      return Right(await _dataSource.insert(patient));
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, PatientEntity>> updatePatient(PatientEntity patient) async {
    try {
      return Right(await _dataSource.update(patient));
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deletePatient(String id) async {
    try {
      await _dataSource.delete(id);
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<PatientEntity>>> searchPatients(String query) async {
    try {
      return Right(await _dataSource.search(query));
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }
}
