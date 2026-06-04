import 'package:dio/dio.dart';
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
      return ApiResponse.error(e.response?.data?['message'] ?? 'Failed to load groups');
    }
  }

  Future<ApiResponse<GroupModel>> getGroupById(String id) async {
    try {
      final response = await _dio.get(ApiEndpoints.getGroupById(id));
      final data = response.data['data'] ?? response.data;
      return ApiResponse.success(GroupModel.fromJson(data));
    } on DioException catch (e) {
      return ApiResponse.error(e.response?.data?['message'] ?? 'Failed to load group');
    }
  }

  Future<ApiResponse<GroupModel>> addGroup(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post(ApiEndpoints.addGroup, data: data);
      final group = GroupModel.fromJson(response.data['data'] ?? response.data);
      return ApiResponse.success(group);
    } on DioException catch (e) {
      return ApiResponse.error(e.response?.data?['message'] ?? 'Failed to add group');
    }
  }

  Future<ApiResponse<bool>> patchGroupStatus(String id, String status) async {
    try {
      await _dio.patch(ApiEndpoints.patchGroupStatus(id), data: {'status': status});
      return ApiResponse.success(true);
    } on DioException catch (e) {
      return ApiResponse.error(e.response?.data?['message'] ?? 'Failed to update status');
    }
  }
}
