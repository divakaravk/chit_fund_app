import 'package:dio/dio.dart';
import '../core/network/dio_client.dart';
import '../core/network/api_endpoints.dart';
import '../core/network/api_response.dart';
import '../models/scheme_model.dart';

class SchemeService {
  final _dio = DioClient.instance;

  Future<ApiResponse<List<SchemeModel>>> getSchemes() async {
    try {
      final response = await _dio.get(ApiEndpoints.getScheme);
      final data = response.data['data'] ?? response.data;
      final list = (data as List).map((e) => SchemeModel.fromJson(e)).toList();
      return ApiResponse.success(list);
    } on DioException catch (e) {
      return ApiResponse.error(e.response?.data?['message'] ?? 'Failed to load schemes');
    }
  }

  Future<ApiResponse<SchemeModel>> addScheme(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post(ApiEndpoints.addScheme, data: data);
      final scheme = SchemeModel.fromJson(response.data['data'] ?? response.data);
      return ApiResponse.success(scheme);
    } on DioException catch (e) {
      return ApiResponse.error(e.response?.data?['message'] ?? 'Failed to add scheme');
    }
  }

  Future<ApiResponse<SchemeModel>> updateScheme(String id, Map<String, dynamic> data) async {
    try {
      final response = await _dio.put(ApiEndpoints.updateScheme(id), data: data);
      final scheme = SchemeModel.fromJson(response.data['data'] ?? response.data);
      return ApiResponse.success(scheme);
    } on DioException catch (e) {
      return ApiResponse.error(e.response?.data?['message'] ?? 'Failed to update scheme');
    }
  }

  Future<ApiResponse<bool>> deleteScheme(String id) async {
    try {
      await _dio.delete(ApiEndpoints.deleteScheme(id));
      return ApiResponse.success(true);
    } on DioException catch (e) {
      return ApiResponse.error(e.response?.data?['message'] ?? 'Failed to delete scheme');
    }
  }
}
