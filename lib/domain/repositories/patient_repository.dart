import 'package:dartz/dartz.dart';
import '../entities/patient_entity.dart';
import '../../core/errors/failures.dart';

abstract class PatientRepository {
  Future<Either<Failure, List<PatientEntity>>> getAllPatients();
  Future<Either<Failure, PatientEntity>> getPatientById(String id);
  Future<Either<Failure, PatientEntity>> createPatient(PatientEntity patient);
  Future<Either<Failure, PatientEntity>> updatePatient(PatientEntity patient);
  Future<Either<Failure, void>> deletePatient(String id);
  Future<Either<Failure, List<PatientEntity>>> searchPatients(String query);
}
