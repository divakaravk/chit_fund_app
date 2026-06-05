import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../core/network/dio_client.dart';
import '../core/network/api_endpoints.dart';
import '../core/network/api_response.dart';
import '../models/group_model.dart';

class GroupService {
  final _dio = DioClient.instance;

  Future<ApiResponse<List<GroupModel>>> getGroups() async {
    try {
      final response = await _dio.get(ApiEndpoints.getGroup);
      final data = response.data['data'] ?? response.data;
      final list = (data as List).map((e) => GroupModel.fromJson(e)).toList();
      return ApiResponse.success(list);
    } on DioException catch (e) {
      debugPrint('[GroupService] getGroups error: ${e.response?.data}');
      return ApiResponse.error(e.response?.data?['message'] ?? 'Failed to load groups');
    } catch (e) {
      debugPrint('[GroupService] getGroups unexpected: $e');
      return ApiResponse.error('Failed to load groups: $e');
    }
  }

  Future<ApiResponse<GroupModel>> getGroupById(String id) async {
    try {
      final response = await _dio.get(ApiEndpoints.getGroupById(id));
      final data = response.data['data'] ?? response.data;
      return ApiResponse.success(GroupModel.fromJson(data));
    } on DioException catch (e) {
      debugPrint('[GroupService] getGroupById error: ${e.response?.data}');
      return ApiResponse.error(e.response?.data?['message'] ?? 'Failed to load group');
    }
  }

  Future<ApiResponse<GroupModel>> addGroup(Map<String, dynamic> data) async {
    try {
      debugPrint('[GroupService] addGroup payload: $data');
      final response = await _dio.post(ApiEndpoints.addGroup, data: data);
      debugPrint('[GroupService] addGroup response: ${response.data}');

      final respData = response.data as Map<String, dynamic>? ?? {};
      if (respData['success'] == false) {
        return ApiResponse.error(respData['message']?.toString() ?? 'Failed to add group');
      }

      // PHP returns {success, message, id} — build minimal model from sent data
      final merged = {
        ...data,
        'id': respData['id']?.toString() ?? '',
        'status': 'active',
        'current_month': 1,
        'member_count': 0,
        'scheme_name': '',
      };
      return ApiResponse.success(GroupModel.fromJson(merged));
    } on DioException catch (e) {
      debugPrint('[GroupService] addGroup DioError: ${e.response?.statusCode} — ${e.response?.data}');
      final msg = e.response?.data;
      return ApiResponse.error(
        (msg is Map ? msg['message'] : null) ?? 'Failed to add group (${e.response?.statusCode})',
      );
    } catch (e) {
      debugPrint('[GroupService] addGroup unexpected: $e');
      return ApiResponse.error('Failed to add group: $e');
    }
  }

  Future<ApiResponse<bool>> patchGroupStatus(String id, String status) async {
    try {
      await _dio.patch(ApiEndpoints.patchGroupStatus(id), data: {'status': status});
      return ApiResponse.success(true);
    } on DioException catch (e) {
      debugPrint('[GroupService] patchGroupStatus error: ${e.response?.data}');
      return ApiResponse.error(e.response?.data?['message'] ?? 'Failed to update status');
    }
  }
}
