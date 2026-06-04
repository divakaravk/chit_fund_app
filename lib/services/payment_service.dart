import 'package:dio/dio.dart';
import '../core/network/dio_client.dart';
import '../core/network/api_endpoints.dart';
import '../core/network/api_response.dart';
import '../models/payment_model.dart';

class PaymentService {
  final _dio = DioClient.instance;

  Future<ApiResponse<List<PaymentModel>>> getPayments({String? membershipId}) async {
    try {
      final endpoint = membershipId != null
          ? ApiEndpoints.getPaymentByMembership(membershipId)
          : ApiEndpoints.getPayment;
      final response = await _dio.get(endpoint);
      final data = response.data['data'] ?? response.data;
      final list = (data as List).map((e) => PaymentModel.fromJson(e)).toList();
      return ApiResponse.success(list);
    } on DioException catch (e) {
      return ApiResponse.error(e.response?.data?['message'] ?? 'Failed to load payments');
    }
  }

  Future<ApiResponse<PaymentModel>> addPayment(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post(ApiEndpoints.addPayment, data: data);
      final payment = PaymentModel.fromJson(response.data['data'] ?? response.data);
      return ApiResponse.success(payment);
    } on DioException catch (e) {
      return ApiResponse.error(e.response?.data?['message'] ?? 'Failed to add payment');
    }
  }

  Future<ApiResponse<bool>> markPaid(String id) async {
    try {
      await _dio.post(ApiEndpoints.markPaid(id));
      return ApiResponse.success(true);
    } on DioException catch (e) {
      return ApiResponse.error(e.response?.data?['message'] ?? 'Failed to mark as paid');
    }
  }

  Future<ApiResponse<bool>> deletePayment(String id) async {
    try {
      await _dio.delete(ApiEndpoints.deletePayment(id));
      return ApiResponse.success(true);
    } on DioException catch (e) {
      return ApiResponse.error(e.response?.data?['message'] ?? 'Failed to delete payment');
    }
  }
}
