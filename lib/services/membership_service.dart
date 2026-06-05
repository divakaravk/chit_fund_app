import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
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
      debugPrint('[MembershipService] getMemberships error: ${e.response?.data}');
      return ApiResponse.error(e.response?.data?['message'] ?? 'Failed to load memberships');
    } catch (e) {
      debugPrint('[MembershipService] getMemberships unexpected: $e');
      return ApiResponse.error('Failed to load memberships: $e');
    }
  }

  Future<ApiResponse<MembershipModel>> addMembership(Map<String, dynamic> data) async {
    try {
      debugPrint('[MembershipService] addMembership payload: $data');
      final response = await _dio.post(ApiEndpoints.addMembership, data: data);
      debugPrint('[MembershipService] addMembership response: ${response.data}');

      final respData = response.data as Map<String, dynamic>? ?? {};
      if (respData['success'] == false) {
        return ApiResponse.error(respData['message']?.toString() ?? 'Failed to add membership');
      }

      // PHP returns {success, message, id} — build model from sent data
      final merged = {
        ...data,
        'id': respData['id']?.toString() ?? '',
        'status': 'active',
        'has_won_auction': 0,
      };
      return ApiResponse.success(MembershipModel.fromJson(merged));
    } on DioException catch (e) {
      debugPrint('[MembershipService] addMembership DioError: ${e.response?.statusCode} — ${e.response?.data}');
      final msg = e.response?.data;
      return ApiResponse.error(
        (msg is Map ? msg['message'] : null) ?? 'Failed to add membership (${e.response?.statusCode})',
      );
    } catch (e) {
      debugPrint('[MembershipService] addMembership unexpected: $e');
      return ApiResponse.error('Failed to add membership: $e');
    }
  }

  Future<ApiResponse<bool>> deleteMembership(String id) async {
    try {
      await _dio.delete(ApiEndpoints.deleteMembership(id));
      return ApiResponse.success(true);
    } on DioException catch (e) {
      debugPrint('[MembershipService] deleteMembership error: ${e.response?.data}');
      return ApiResponse.error(e.response?.data?['message'] ?? 'Failed to remove membership');
    }
  }
}
