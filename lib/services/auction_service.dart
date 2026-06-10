import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
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
      debugPrint('[AuctionService] getAuctions error: ${e.response?.data}');
      return ApiResponse.error(e.response?.data?['message'] ?? 'Failed to load auctions');
    } catch (e) {
      debugPrint('[AuctionService] getAuctions unexpected: $e');
      return ApiResponse.error('Failed to load auctions: $e');
    }
  }

  Future<ApiResponse<AuctionModel>> addAuction(Map<String, dynamic> data) async {
    try {
      debugPrint('[AuctionService] addAuction payload: $data');
      final response = await _dio.post(ApiEndpoints.addAuction, data: data);
      debugPrint('[AuctionService] addAuction response: ${response.data}');

      final respData = response.data as Map<String, dynamic>? ?? {};
      if (respData['success'] == false) {
        return ApiResponse.error(respData['message']?.toString() ?? 'Failed to add auction');
      }

      // PHP returns {success, message, id} — merge with sent data
      final merged = {
        ...data,
        'id': respData['id']?.toString() ?? '',
        'status': 'scheduled',
      };
      return ApiResponse.success(AuctionModel.fromJson(merged));
    } on DioException catch (e) {
      debugPrint('[AuctionService] addAuction DioError: ${e.response?.statusCode} — ${e.response?.data}');
      final msg = e.response?.data;
      return ApiResponse.error(
        (msg is Map ? msg['message'] : null) ??
            'Failed to add auction (${e.response?.statusCode})',
      );
    } catch (e) {
      debugPrint('[AuctionService] addAuction unexpected: $e');
      return ApiResponse.error('Failed to add auction: $e');
    }
  }

  Future<ApiResponse<bool>> closeAuction(String id, Map<String, dynamic> data) async {
    try {
      debugPrint('[AuctionService] closeAuction id=$id payload: $data');
      final response = await _dio.post(ApiEndpoints.closeAuction(id), data: data);
      debugPrint('[AuctionService] closeAuction response: ${response.data}');
      final respData = response.data as Map<String, dynamic>? ?? {};
      if (respData['success'] == false) {
        return ApiResponse.error(respData['message']?.toString() ?? 'Failed to close auction');
      }
      return ApiResponse.success(true);
    } on DioException catch (e) {
      debugPrint('[AuctionService] closeAuction error: ${e.response?.data}');
      final msg = e.response?.data;
      return ApiResponse.error(
        (msg is Map ? msg['message'] : null) ?? 'Failed to close auction',
      );
    } catch (e) {
      debugPrint('[AuctionService] closeAuction unexpected: $e');
      return ApiResponse.error('Failed to close auction: $e');
    }
  }

  Future<ApiResponse<AuctionModel>> getAuctionById(String id) async {
    try {
      final response = await _dio.get(ApiEndpoints.getAuctionById(id));
      final data = response.data['data'] ?? response.data;
      final auction = data is List
          ? AuctionModel.fromJson(data.first as Map<String, dynamic>)
          : AuctionModel.fromJson(data as Map<String, dynamic>);
      return ApiResponse.success(auction);
    } on DioException catch (e) {
      debugPrint('[AuctionService] getAuctionById error: ${e.response?.data}');
      return ApiResponse.error(e.response?.data?['message'] ?? 'Failed to load auction');
    } catch (e) {
      debugPrint('[AuctionService] getAuctionById unexpected: $e');
      return ApiResponse.error('Failed to load auction: $e');
    }
  }

  Future<ApiResponse<List<BidModel>>> getBids(String auctionId) async {
    try {
      final response = await _dio.get(ApiEndpoints.getBidsByAuction(auctionId));
      final data = response.data['data'] ?? response.data;
      final list = (data as List).map((e) => BidModel.fromJson(e)).toList();
      return ApiResponse.success(list);
    } on DioException catch (e) {
      debugPrint('[AuctionService] getBids error: ${e.response?.data}');
      return ApiResponse.error(e.response?.data?['message'] ?? 'Failed to load bids');
    }
  }

  Future<ApiResponse<BidModel>> addBid(Map<String, dynamic> data) async {
    try {
      debugPrint('[AuctionService] addBid payload: $data');
      final response = await _dio.post(ApiEndpoints.addBid, data: data);
      debugPrint('[AuctionService] addBid response: ${response.data}');
      final respData = response.data as Map<String, dynamic>? ?? {};
      if (respData['success'] == false) {
        return ApiResponse.error(respData['message']?.toString() ?? 'Failed to add bid');
      }
      final merged = {...data, 'id': respData['id']?.toString() ?? ''};
      return ApiResponse.success(BidModel.fromJson(merged));
    } on DioException catch (e) {
      debugPrint('[AuctionService] addBid error: ${e.response?.data}');
      final msg = e.response?.data;
      return ApiResponse.error(
        (msg is Map ? msg['message'] : null) ?? 'Failed to add bid',
      );
    } catch (e) {
      debugPrint('[AuctionService] addBid unexpected: $e');
      return ApiResponse.error('Failed to add bid: $e');
    }
  }
}
