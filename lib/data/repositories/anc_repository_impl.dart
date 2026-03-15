import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/anc_visit_entity.dart';
import '../../domain/repositories/anc_repository.dart';
import '../datasources/local/anc_local_datasource.dart';

class AncRepositoryImpl implements AncRepository {
  final AncLocalDataSource _dataSource;
  const AncRepositoryImpl(this._dataSource);

  @override
  Future<Either<Failure, List<AncVisitEntity>>> getAllVisits() async {
    try {
      return Right(await _dataSource.getAllVisits());
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<AncVisitEntity>>> getVisitsForPatient(
      String patientId) async {
    try {
      return Right(await _dataSource.getVisitsForPatient(patientId));
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, AncVisitEntity>> createVisit(
      AncVisitEntity visit) async {
    try {
      return Right(await _dataSource.insert(visit));
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, AncVisitEntity>> updateVisit(
      AncVisitEntity visit) async {
    try {
      return Right(await _dataSource.update(visit));
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteVisit(String id) async {
    try {
      await _dataSource.delete(id);
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, int>> countThisMonth() async {
    try {
      return Right(await _dataSource.countThisMonth());
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }
}
