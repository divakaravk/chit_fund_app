import 'package:dio/dio.dart';
import '../core/network/dio_client.dart';
import '../core/network/api_endpoints.dart';
import '../core/network/api_response.dart';
import '../models/membership_model.dart';

class MembershipService {
  final _dio = DioClient.instance;

  Future<ApiResponse<List<MembershipModel>>> getMemberships({String? groupId}) async {
    try {
      final endpoint = groupId != null
          ? ApiEndpoints.getMembershipByGroup(groupId)
          : ApiEndpoints.getMembership;
      final response = await _dio.get(endpoint);
      final data = response.data['data'] ?? response.data;
      final list = (data as List).map((e) => MembershipModel.fromJson(e)).toList();
      return ApiResponse.success(list);
    } on DioException catch (e) {
      return ApiResponse.error(e.response?.data?['message'] ?? 'Failed to load memberships');
    }
  }

  Future<ApiResponse<MembershipModel>> addMembership(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post(ApiEndpoints.addMembership, data: data);
      final membership = MembershipModel.fromJson(response.data['data'] ?? response.data);
      return ApiResponse.success(membership);
    } on DioException catch (e) {
      return ApiResponse.error(e.response?.data?['message'] ?? 'Failed to add membership');
    }
  }

  Future<ApiResponse<bool>> deleteMembership(String id) async {
    try {
      await _dio.delete(ApiEndpoints.deleteMembership(id));
      return ApiResponse.success(true);
    } on DioException catch (e) {
      return ApiResponse.error(e.response?.data?['message'] ?? 'Failed to remove membership');
    }
  }
}
