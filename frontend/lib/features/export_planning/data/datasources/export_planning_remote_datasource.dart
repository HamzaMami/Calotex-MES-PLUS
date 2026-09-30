import 'dart:typed_data';
import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/http_client.dart';
import '../models/export_plan_model.dart';

abstract class ExportPlanningRemoteDataSource {
  Future<List<ExportPlanModel>> list({int? year});
  Future<ExportPlanModel> get(int id);
  Future<ExportPlanModel> create(Map<String, dynamic> input);
  Future<ExportPlanModel> update(int id, Map<String, dynamic> input);
  Future<void> delete(int id);
  Future<void> clearAll({required int year, required int week});
  Future<List<ExportPlanModel>> preview(Uint8List bytes, String fileName);
  Future<List<ExportPlanModel>> upload(Uint8List bytes, String fileName);
}

class ExportPlanningRemoteDataSourceImpl implements ExportPlanningRemoteDataSource {
  final HttpClient httpClient;

  ExportPlanningRemoteDataSourceImpl({required this.httpClient});

  String _message(DioException error, String fallback) {
    final data = error.response?.data;
    if (data is Map && data['details'] is List && (data['details'] as List).isNotEmpty) {
      return (data['details'] as List).join(', ');
    }
    if (data is Map && data['message'] != null) return data['message'].toString();
    return fallback;
  }

  Map<String, dynamic> _map(dynamic data) =>
      Map<String, dynamic>.from((data as Map)['data'] as Map);

  List<ExportPlanModel> _list(dynamic data) {
    final values = (data as Map)['data'] as List<dynamic>? ?? const [];
    return values.map((item) => ExportPlanModel.fromJson(Map<String, dynamic>.from(item as Map))).toList();
  }

  Future<T> _request<T>(Future<Response<dynamic>> request, T Function(Response<dynamic>) parse) async {
    try {
      final response = await request;
      return parse(response);
    } on DioException catch (error) {
      throw ServerException(message: _message(error, 'Export planning request failed'),
          statusCode: error.response?.statusCode, originalError: error);
    }
  }

  @override
  Future<List<ExportPlanModel>> list({int? year}) => _request(
        httpClient.dio.get(ApiConstants.exportPlanningEndpoint,
            queryParameters: year == null ? null : {'year': year}),
        (response) => _list(response.data),
      );

  @override
  Future<ExportPlanModel> get(int id) => _request(
        httpClient.dio.get('${ApiConstants.exportPlanningEndpoint}/$id'),
        (response) => ExportPlanModel.fromJson(_map(response.data)),
      );

  @override
  Future<ExportPlanModel> create(Map<String, dynamic> input) => _request(
        httpClient.dio.post(ApiConstants.exportPlanningEndpoint, data: input),
        (response) => ExportPlanModel.fromJson(_map(response.data)),
      );

  @override
  Future<ExportPlanModel> update(int id, Map<String, dynamic> input) => _request(
        httpClient.dio.patch('${ApiConstants.exportPlanningEndpoint}/$id', data: input),
        (response) => ExportPlanModel.fromJson(_map(response.data)),
      );

  @override
  Future<void> delete(int id) async {
    await _request<void>(
      httpClient.dio.delete('${ApiConstants.exportPlanningEndpoint}/$id'),
      (_) {},
    );
  }

  @override
  Future<void> clearAll({required int year, required int week}) async {
    await _request<void>(
      httpClient.dio.delete(
        '${ApiConstants.exportPlanningEndpoint}/clear',
        queryParameters: {'year': year, 'week': week},
      ),
      (_) {},
    );
  }

  FormData _form(Uint8List bytes, String fileName) => FormData.fromMap({
        'file': MultipartFile.fromBytes(bytes, filename: fileName),
      });

  @override
  Future<List<ExportPlanModel>> preview(Uint8List bytes, String fileName) => _request(
        httpClient.dio.post('${ApiConstants.exportPlanningEndpoint}/preview',
            data: _form(bytes, fileName)),
        (response) => _list(response.data),
      );

  @override
  Future<List<ExportPlanModel>> upload(Uint8List bytes, String fileName) => _request(
        httpClient.dio.post('${ApiConstants.exportPlanningEndpoint}/upload',
            data: _form(bytes, fileName)),
        (response) => _list(response.data),
      );
}
