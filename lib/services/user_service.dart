import 'package:dio/dio.dart';
import '../core/network/dio_client.dart';
import '../core/network/api_endpoints.dart';
import '../core/network/api_response.dart';
import '../models/user_model.dart';

class UserService {
  final _dio = DioClient.instance;

  Future<ApiResponse<List<UserModel>>> getUsers() async {
    try {
      final response = await _dio.get(ApiEndpoints.getUser);
      final data = response.data['data'] ?? response.data;
      final list = (data as List).map((e) => UserModel.fromJson(e)).toList();
      return ApiResponse.success(list);
    } on DioException catch (e) {
      return ApiResponse.error(e.response?.data?['message'] ?? 'Failed to load users');
    }
  }

  Future<ApiResponse<UserModel>> getUserById(String id) async {
    try {
      final response = await _dio.get(ApiEndpoints.getUserById(id));
      final data = response.data['data'] ?? response.data;
      return ApiResponse.success(UserModel.fromJson(data));
    } on DioException catch (e) {
      return ApiResponse.error(e.response?.data?['message'] ?? 'Failed to load user');
    }
  }

  Future<ApiResponse<UserModel>> addUser(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post(ApiEndpoints.addUser, data: data);
      final user = UserModel.fromJson(response.data['data'] ?? response.data);
      return ApiResponse.success(user);
    } on DioException catch (e) {
      return ApiResponse.error(e.response?.data?['message'] ?? 'Failed to add user');
    }
  }

  Future<ApiResponse<UserModel>> updateUser(String id, Map<String, dynamic> data) async {
    try {
      final response = await _dio.put(ApiEndpoints.updateUser(id), data: data);
      final user = UserModel.fromJson(response.data['data'] ?? response.data);
      return ApiResponse.success(user);
    } on DioException catch (e) {
      return ApiResponse.error(e.response?.data?['message'] ?? 'Failed to update user');
    }
  }

  Future<ApiResponse<bool>> patchUserStatus(String id, String status) async {
    try {
      await _dio.patch(ApiEndpoints.patchUserStatus(id), data: {'status': status});
      return ApiResponse.success(true);
    } on DioException catch (e) {
      return ApiResponse.error(e.response?.data?['message'] ?? 'Failed to update status');
    }
  }

  Future<ApiResponse<bool>> deleteUser(String id) async {
    try {
      await _dio.delete(ApiEndpoints.deleteUser(id));
      return ApiResponse.success(true);
    } on DioException catch (e) {
      return ApiResponse.error(e.response?.data?['message'] ?? 'Failed to delete user');
    }
  }
}
