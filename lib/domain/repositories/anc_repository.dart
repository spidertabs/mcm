import 'package:dartz/dartz.dart';
import '../entities/anc_visit_entity.dart';
import '../../core/errors/failures.dart';

abstract class AncRepository {
  Future<Either<Failure, List<AncVisitEntity>>> getAllVisits();
  Future<Either<Failure, List<AncVisitEntity>>> getVisitsForPatient(String patientId);
  Future<Either<Failure, AncVisitEntity>> createVisit(AncVisitEntity visit);
  Future<Either<Failure, AncVisitEntity>> updateVisit(AncVisitEntity visit);
  Future<Either<Failure, void>> deleteVisit(String id);
  Future<Either<Failure, int>> countThisMonth();
}
