import 'package:dio/dio.dart';
import '../core/network/dio_client.dart';
import '../core/network/api_endpoints.dart';
import '../core/network/api_response.dart';
import '../models/notification_model.dart';

class NotificationService {
  final _dio = DioClient.instance;

  Future<ApiResponse<List<NotificationModel>>> getNotifications() async {
    try {
      final response = await _dio.get(ApiEndpoints.getNotification);
      final data = response.data['data'] ?? response.data;
      final list = (data as List).map((e) => NotificationModel.fromJson(e)).toList();
      return ApiResponse.success(list);
    } on DioException catch (e) {
      return ApiResponse.error(e.response?.data?['message'] ?? 'Failed to load notifications');
    }
  }

  Future<ApiResponse<bool>> markRead(String id) async {
    try {
      await _dio.patch(ApiEndpoints.markRead(id));
      return ApiResponse.success(true);
    } on DioException catch (e) {
      return ApiResponse.error(e.response?.data?['message'] ?? 'Failed to mark as read');
    }
  }

  Future<ApiResponse<bool>> deleteNotification(String id) async {
    try {
      await _dio.delete(ApiEndpoints.deleteNotification(id));
      return ApiResponse.success(true);
    } on DioException catch (e) {
      return ApiResponse.error(e.response?.data?['message'] ?? 'Failed to delete notification');
    }
  }
}
