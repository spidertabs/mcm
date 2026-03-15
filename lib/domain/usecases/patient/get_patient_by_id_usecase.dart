// lib/domain/usecases/patient/get_patient_by_id_usecase.dart
import 'package:dartz/dartz.dart';
import '../../entities/patient_entity.dart';
import '../../repositories/patient_repository.dart';
import '../../../core/errors/failures.dart';

class GetPatientByIdUseCase {
  final PatientRepository _repo;
  const GetPatientByIdUseCase(this._repo);

  Future<Either<Failure, PatientEntity>> call(String id) =>
      _repo.getPatientById(id);
}