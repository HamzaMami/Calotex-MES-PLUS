import 'dart:typed_data';
import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/export_plan.dart';
import '../../domain/repositories/export_planning_repository.dart';
import '../datasources/export_planning_remote_datasource.dart';

class ExportPlanningRepositoryImpl implements ExportPlanningRepository {
  final ExportPlanningRemoteDataSource remoteDataSource;
  ExportPlanningRepositoryImpl({required this.remoteDataSource});

  Future<Either<Failure, T>> _run<T>(Future<T> Function() operation) async {
    try {
      return Right(await operation());
    } on ServerException catch (error) {
      return Left(ServerFailure(message: error.message, statusCode: error.statusCode));
    } catch (error) {
      return Left(UnknownFailure(message: 'Export planning request failed: $error'));
    }
  }

  @override
  Future<Either<Failure, List<ExportPlan>>> list({int? year}) =>
      _run(() => remoteDataSource.list(year: year));

  @override
  Future<Either<Failure, ExportPlan>> get(int id) => _run(() => remoteDataSource.get(id));

  @override
  Future<Either<Failure, ExportPlan>> create(ExportPlanInput input) =>
      _run(() => remoteDataSource.create(input.toJson()));

  @override
  Future<Either<Failure, ExportPlan>> update(int id, ExportPlanInput input) =>
      _run(() => remoteDataSource.update(id, input.toJson()));

  @override
  Future<Either<Failure, void>> delete(int id) => _run(() => remoteDataSource.delete(id));

  @override
  Future<Either<Failure, void>> clearAll({required int year, required int week}) =>
      _run(() => remoteDataSource.clearAll(year: year, week: week));

  @override
  Future<Either<Failure, List<ExportPlanInput>>> preview(Uint8List bytes, String fileName) async {
    final result = await _run(() => remoteDataSource.preview(bytes, fileName));
    return result.map((plans) => plans
        .map((plan) => ExportPlanInput(
              calendarWeekKw: plan.calendarWeekKw,
              year: plan.year,
              orderNumber: plan.orderNumber,
              productCode: plan.productCode,
              quantity: plan.quantity,
              destination: plan.destination,
            ))
        .toList());
  }

  @override
  Future<Either<Failure, List<ExportPlan>>> upload(Uint8List bytes, String fileName) =>
      _run(() => remoteDataSource.upload(bytes, fileName));
}
