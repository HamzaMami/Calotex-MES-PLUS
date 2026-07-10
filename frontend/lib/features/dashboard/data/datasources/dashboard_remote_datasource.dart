import 'package:dio/dio.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/dashboard_models.dart';

abstract class DashboardRemoteDataSource {
  Future<List<ProductModel>> getProducts();
  Future<List<ManufacturingOrderModel>> getManufacturingOrders();
  Future<List<EventModel>> getEvents();
  Future<void> updateProductApproval(int productId, bool finalApproval);
}

class DashboardRemoteDataSourceImpl implements DashboardRemoteDataSource {
  final Dio httpClient;

  DashboardRemoteDataSourceImpl({required this.httpClient});

  @override
  Future<List<ProductModel>> getProducts() async {
    try {
      final response = await httpClient.get('/products');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'];
        return data.map((json) => ProductModel.fromJson(json)).toList();
      } else {
        throw ServerException(
            message: response.data['message'] ?? 'Failed to fetch products');
      }
    } on DioException catch (e) {
      throw ServerException(
          message: e.response?.data['message'] ?? 'Network error fetching products');
    }
  }

  @override
  Future<List<ManufacturingOrderModel>> getManufacturingOrders() async {
    try {
      final response = await httpClient.get('/manufacturing-orders');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'];
        return data.map((json) => ManufacturingOrderModel.fromJson(json)).toList();
      } else {
        throw ServerException(
            message: response.data['message'] ?? 'Failed to fetch manufacturing orders');
      }
    } on DioException catch (e) {
      throw ServerException(
          message: e.response?.data['message'] ?? 'Network error fetching orders');
    }
  }

  @override
  Future<List<EventModel>> getEvents() async {
    try {
      final response = await httpClient.get('/events');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'];
        return data.map((json) => EventModel.fromJson(json)).toList();
      } else {
        throw ServerException(
            message: response.data['message'] ?? 'Failed to fetch events');
      }
    } on DioException catch (e) {
      throw ServerException(
          message: e.response?.data['message'] ?? 'Network error fetching events');
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
            message: response.data['message'] ?? 'Failed to update approval');
      }
    } on DioException catch (e) {
      throw ServerException(
          message: e.response?.data['message'] ?? 'Network error updating approval');
    }
  }
}
