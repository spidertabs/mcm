import 'package:dartz/dartz.dart';
import '../../entities/patient_entity.dart';
import '../../repositories/patient_repository.dart';
import '../../../core/errors/failures.dart';

class GetAllPatientsUseCase {
  final PatientRepository _repository;
  const GetAllPatientsUseCase(this._repository);

  Future<Either<Failure, List<PatientEntity>>> call() =>
      _repository.getAllPatients();
}
