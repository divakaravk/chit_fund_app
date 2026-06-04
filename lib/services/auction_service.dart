import 'package:dio/dio.dart';
import '../core/network/dio_client.dart';
import '../core/network/api_endpoints.dart';
import '../core/network/api_response.dart';
import '../models/auction_model.dart';
import '../models/bid_model.dart';

class AuctionService {
  final _dio = DioClient.instance;

  Future<ApiResponse<List<AuctionModel>>> getAuctions({String? groupId}) async {
    try {
      final endpoint = groupId != null
          ? ApiEndpoints.getAuctionByGroup(groupId)
          : ApiEndpoints.getAuction;
      final response = await _dio.get(endpoint);
      final data = response.data['data'] ?? response.data;
      final list = (data as List).map((e) => AuctionModel.fromJson(e)).toList();
      return ApiResponse.success(list);
    } on DioException catch (e) {
      return ApiResponse.error(e.response?.data?['message'] ?? 'Failed to load auctions');
    }
  }

  Future<ApiResponse<AuctionModel>> addAuction(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post(ApiEndpoints.addAuction, data: data);
      final auction = AuctionModel.fromJson(response.data['data'] ?? response.data);
      return ApiResponse.success(auction);
    } on DioException catch (e) {
      return ApiResponse.error(e.response?.data?['message'] ?? 'Failed to add auction');
    }
  }

  Future<ApiResponse<bool>> closeAuction(String id, Map<String, dynamic> data) async {
    try {
      await _dio.post(ApiEndpoints.closeAuction(id), data: data);
      return ApiResponse.success(true);
    } on DioException catch (e) {
      return ApiResponse.error(e.response?.data?['message'] ?? 'Failed to close auction');
    }
  }

  Future<ApiResponse<List<BidModel>>> getBids(String auctionId) async {
    try {
      final response = await _dio.get(ApiEndpoints.getBidsByAuction(auctionId));
      final data = response.data['data'] ?? response.data;
      final list = (data as List).map((e) => BidModel.fromJson(e)).toList();
      return ApiResponse.success(list);
    } on DioException catch (e) {
      return ApiResponse.error(e.response?.data?['message'] ?? 'Failed to load bids');
    }
  }

  Future<ApiResponse<BidModel>> addBid(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post(ApiEndpoints.addBid, data: data);
      final bid = BidModel.fromJson(response.data['data'] ?? response.data);
      return ApiResponse.success(bid);
    } on DioException catch (e) {
      return ApiResponse.error(e.response?.data?['message'] ?? 'Failed to add bid');
    }
  }
}
