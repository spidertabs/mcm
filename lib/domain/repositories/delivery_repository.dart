import 'package:dartz/dartz.dart';
import '../entities/delivery_entity.dart';
import '../../core/errors/failures.dart';

abstract class DeliveryRepository {
  Future<Either<Failure, List<DeliveryEntity>>> getAllRecords();
  Future<Either<Failure, List<DeliveryEntity>>> getRecordsForPatient(String patientId);
  Future<Either<Failure, DeliveryEntity>> createRecord(DeliveryEntity delivery);
  Future<Either<Failure, void>> deleteRecord(String id);
  Future<Either<Failure, int>> countThisMonth();
}
