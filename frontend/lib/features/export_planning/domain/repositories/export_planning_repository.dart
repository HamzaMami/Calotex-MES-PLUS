import 'dart:typed_data';

import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/export_plan.dart';

abstract class ExportPlanningRepository {
  Future<Either<Failure, List<ExportPlan>>> list({int? year});
  Future<Either<Failure, ExportPlan>> get(int id);
  Future<Either<Failure, ExportPlan>> create(ExportPlanInput input);
  Future<Either<Failure, ExportPlan>> update(int id, ExportPlanInput input);
  Future<Either<Failure, void>> delete(int id);
  Future<Either<Failure, void>> clearAll({required int year, required int week});
  Future<Either<Failure, List<ExportPlanInput>>> preview(
    Uint8List bytes,
    String fileName,
  );
  Future<Either<Failure, List<ExportPlan>>> upload(
    Uint8List bytes,
    String fileName,
  );
}
