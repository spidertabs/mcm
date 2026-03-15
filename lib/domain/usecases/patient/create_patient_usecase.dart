import 'package:dartz/dartz.dart';
import '../../entities/patient_entity.dart';
import '../../repositories/patient_repository.dart';
import '../../../core/errors/failures.dart';

class CreatePatientUseCase {
  final PatientRepository _repository;
  const CreatePatientUseCase(this._repository);

  Future<Either<Failure, PatientEntity>> call(PatientEntity patient) =>
      _repository.createPatient(patient);
}
