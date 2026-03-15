import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/delivery_entity.dart';
import '../../domain/repositories/delivery_repository.dart';
import '../datasources/local/delivery_local_datasource.dart';

class DeliveryRepositoryImpl implements DeliveryRepository {
  final DeliveryLocalDataSource _dataSource;
  const DeliveryRepositoryImpl(this._dataSource);

  @override
  Future<Either<Failure, List<DeliveryEntity>>> getAllRecords() async {
    try {
      return Right(await _dataSource.getAllRecords());
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<DeliveryEntity>>> getRecordsForPatient(
      String patientId) async {
    try {
      return Right(await _dataSource.getRecordsForPatient(patientId));
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, DeliveryEntity>> createRecord(
      DeliveryEntity delivery) async {
    try {
      return Right(await _dataSource.insert(delivery));
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteRecord(String id) async {
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
