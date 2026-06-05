import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
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
      debugPrint('[SchemeService] getSchemes error: ${e.response?.data}');
      return ApiResponse.error(e.response?.data?['message'] ?? 'Failed to load schemes');
    } catch (e) {
      debugPrint('[SchemeService] getSchemes unexpected: $e');
      return ApiResponse.error('Failed to load schemes: $e');
    }
  }

  Future<ApiResponse<SchemeModel>> addScheme(Map<String, dynamic> data) async {
    try {
      debugPrint('[SchemeService] addScheme payload: $data');
      final response = await _dio.post(ApiEndpoints.addScheme, data: data);
      debugPrint('[SchemeService] addScheme response: ${response.data}');

      final respData = response.data;
      if (respData['success'] == false) {
        return ApiResponse.error(respData['message']?.toString() ?? 'Failed to add scheme');
      }

      final schemeData = respData['data'] ?? respData;
      // API returns {success, message, id} — build minimal model from it
      if (schemeData is Map<String, dynamic> && schemeData['scheme_name'] == null) {
        // Response only has id — merge with sent data to build model
        final merged = {...data, 'id': respData['id'] ?? ''};
        return ApiResponse.success(SchemeModel.fromJson(merged));
      }
      return ApiResponse.success(SchemeModel.fromJson(schemeData as Map<String, dynamic>));
    } on DioException catch (e) {
      debugPrint('[SchemeService] addScheme DioError: ${e.response?.statusCode} — ${e.response?.data}');
      final msg = e.response?.data;
      return ApiResponse.error(
        (msg is Map ? msg['message'] : null) ?? 'Failed to add scheme (${e.response?.statusCode})',
      );
    } catch (e) {
      debugPrint('[SchemeService] addScheme unexpected: $e');
      return ApiResponse.error('Failed to add scheme: $e');
    }
  }

  Future<ApiResponse<SchemeModel>> updateScheme(String id, Map<String, dynamic> data) async {
    try {
      final response = await _dio.put(ApiEndpoints.updateScheme(id), data: data);
      final scheme = SchemeModel.fromJson(response.data['data'] ?? response.data);
      return ApiResponse.success(scheme);
    } on DioException catch (e) {
      debugPrint('[SchemeService] updateScheme error: ${e.response?.data}');
      return ApiResponse.error(e.response?.data?['message'] ?? 'Failed to update scheme');
    }
  }

  Future<ApiResponse<bool>> deleteScheme(String id) async {
    try {
      await _dio.delete(ApiEndpoints.deleteScheme(id));
      return ApiResponse.success(true);
    } on DioException catch (e) {
      debugPrint('[SchemeService] deleteScheme error: ${e.response?.data}');
      return ApiResponse.error(e.response?.data?['message'] ?? 'Failed to delete scheme');
    }
  }
}
