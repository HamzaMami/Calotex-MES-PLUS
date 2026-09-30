import 'package:dio/dio.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/dashboard_models.dart';

abstract class DashboardRemoteDataSource {
  /// Fetch all aggregated dashboard data in a single request.
  Future<DashboardDataEntityModel> getDashboardData();

  /// Update the approval status of a specific product.
  Future<void> updateProductApproval(int productId, bool finalApproval);

  /// Update the manually controlled status of a production order.
  Future<void> updateProductionOrderStatus(int orderId, String status);
  Future<void> updateExportPlanStatus(int planId, String status);
}

class DashboardRemoteDataSourceImpl implements DashboardRemoteDataSource {
  final Dio httpClient;

  DashboardRemoteDataSourceImpl({required this.httpClient});

  @override
  Future<DashboardDataEntityModel> getDashboardData() async {
    try {
      final response = await httpClient.get('/dashboard');
      if (response.statusCode == 200) {
        return DashboardDataEntityModel.fromJson(
          response.data['data'] as Map<String, dynamic>,
        );
      } else {
        throw ServerException(
          message: response.data['message'] ?? 'Failed to fetch dashboard data',
        );
      }
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data['message'] ?? 'Network error fetching dashboard data',
      );
    }
  }

  @override
  Future<void> updateProductApproval(int productId, bool finalApproval) async {
    try {
      final response = await httpClient.patch(
        '/products/$productId',
        data: {'final_approval': finalApproval},
      );
      if (response.statusCode != 200) {
        throw ServerException(
          message: response.data['message'] ?? 'Failed to update approval',
        );
      }
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data['message'] ?? 'Network error updating product approval',
      );
    }
  }

  @override
  Future<void> updateProductionOrderStatus(int orderId, String status) async {
    try {
      final response = await httpClient.patch(
        '/manufacturing-orders/$orderId',
        data: {'status': status},
      );
      if (response.statusCode != 200) {
        throw ServerException(
          message: response.data['message'] ?? 'Failed to update production order status',
        );
      }
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data['message'] ??
            'Network error updating production order status',
      );
    }
  }

  @override
  Future<void> updateExportPlanStatus(int planId, String status) async {
      try {
        final response = await httpClient.patch(
          '/export-planning/$planId',
          data: {'status': status},
        );
        if (response.statusCode != 200) {
          throw ServerException(
            message: response.data['message'] ?? 'Failed to update order status',
          );
        }
      } on DioException catch (e) {
        throw ServerException(
          message: e.response?.data['message'] ?? 'Network error updating order status',
        );
      }
    }
}