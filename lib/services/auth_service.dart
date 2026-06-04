import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../core/network/api_endpoints.dart';
import '../core/network/api_response.dart';
import '../core/storage/local_storage.dart';
import '../models/company_model.dart';
import '../models/user_model.dart';

class AuthService {
  Future<ApiResponse<UserModel>> login({
    required String companyCode,
    required String phone,
    required String role,
  }) async {
    try {
      // ── STEP 1: Company lookup ────────────────────────────────────────────
      // Backend requires auth headers even for login endpoints.
      // Pass company_code as X-Company-Id placeholder so the "missing" check passes.
      final step1Dio = _makeDio(companyId: companyCode);

      debugPrint('[Login] Step1: GET get_company.php?company_code=$companyCode');
      final companyResp = await step1Dio.get(
        ApiEndpoints.getCompany,
        queryParameters: {'company_code': companyCode},
      );
      debugPrint('[Login] Step1 raw response: ${companyResp.data}');

      final companyData = companyResp.data as Map<String, dynamic>? ?? {};

      if (companyData['success'] == false) {
        return ApiResponse.error(
          companyData['message']?.toString() ?? 'Company lookup failed',
        );
      }

      final companyJson = _extractFirst(companyData);
      if (companyJson == null) {
        return ApiResponse.error(
          'Company "$companyCode" not found. Verify the company code.',
        );
      }

      final company = CompanyModel.fromJson(companyJson);
      final companyId = company.id.isNotEmpty
          ? company.id
          : companyJson['company_id']?.toString() ?? '';

      if (companyId.isEmpty) {
        return ApiResponse.error(
          'Company found but ID is missing. Raw: $companyJson',
        );
      }
      debugPrint('[Login] Step1 OK — companyId: $companyId, name: ${company.name}');

      // ── STEP 2: User lookup ───────────────────────────────────────────────
      // Now we have the real companyId — use it as X-Company-Id header.
      final step2Dio = _makeDio(companyId: companyId);

      debugPrint('[Login] Step2: GET get_user.php?company_id=$companyId&phone_number=$phone');
      final userResp = await step2Dio.get(
        ApiEndpoints.getUser,
        queryParameters: {
          'company_id': companyId,
          'phone_number': phone,
        },
      );
      debugPrint('[Login] Step2 raw response: ${userResp.data}');

      final userData = userResp.data as Map<String, dynamic>? ?? {};

      if (userData['success'] == false) {
        return ApiResponse.error(
          userData['message']?.toString() ?? 'User lookup failed',
        );
      }

      // Try to match user by phone — also fallback fetch all & filter
      UserModel? user = _findUser(userData, phone);

      if (user == null) {
        debugPrint('[Login] Step2 retry: fetching all users for company and filtering client-side');
        final allResp = await step2Dio.get(
          ApiEndpoints.getUser,
          queryParameters: {'company_id': companyId},
        );
        debugPrint('[Login] Step2 retry response: ${allResp.data}');
        final allData = allResp.data as Map<String, dynamic>? ?? {};
        user = _findUser(allData, phone);
      }

      if (user == null) {
        return ApiResponse.error(
          'No user found with phone "$phone" in company "$companyCode".\n'
          'Insert user in DB first via Postman.',
        );
      }

      // ── STEP 3: Validate role ─────────────────────────────────────────────
      debugPrint('[Login] Step3: user.role=${user.role}, selected=$role');
      if (user.role != role) {
        return ApiResponse.error(
          'Role mismatch — DB role is "${user.role}", you selected "$role"',
        );
      }
      if (!user.isActive) {
        return ApiResponse.error('Account is inactive. Contact admin.');
      }

      // ── STEP 4: Save session ──────────────────────────────────────────────
      await LocalStorage.saveUserSession(
        userId: user.id,
        userRole: user.role,
        companyId: companyId,
        userName: user.name,
        companyName: company.name,
        companyCode: company.code.isNotEmpty ? company.code : companyCode,
      );

      debugPrint('[Login] Success ✓ userId=${user.id} role=${user.role}');
      return ApiResponse.success(user);
    } on DioException catch (e) {
      debugPrint('[Login] DioException: ${e.type} — ${e.response?.data}');
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.unknown) {
        return ApiResponse.error(
          'Cannot reach server.\n'
          'URL: ${ApiEndpoints.baseUrl}\n'
          'Check XAMPP is running and phone is on same WiFi.',
        );
      }
      final serverMsg = e.response?.data;
      String msg;
      if (serverMsg is Map) {
        msg = serverMsg['message']?.toString() ?? 'HTTP ${e.response?.statusCode}';
      } else {
        msg = 'HTTP ${e.response?.statusCode}: ${e.message}';
      }
      return ApiResponse.error(msg, statusCode: e.response?.statusCode);
    } catch (e, st) {
      debugPrint('[Login] Unexpected: $e\n$st');
      return ApiResponse.error('Login error: $e');
    }
  }

  Future<ApiResponse<String>> registerCompany({
    required String name,
    required String code,
    required String ownerName,
    required String email,
    required String phone,
  }) async {
    // Registration: use code as placeholder company ID in headers
    final dio = _makeDio(companyId: code);
    try {
      debugPrint('[Register] POST register_company: code=$code');
      final response = await dio.post(
        ApiEndpoints.registerCompany,
        data: {
          'company_name': name,
          'company_code': code,
          'owner_name': ownerName,
          'email': email,
          'phone': phone,
        },
      );
      debugPrint('[Register] Response: ${response.data}');

      final data = response.data as Map<String, dynamic>? ?? {};
      if (data['success'] == false) {
        return ApiResponse.error(data['message']?.toString() ?? 'Registration failed');
      }
      if (data['success'] == true || data['company_id'] != null) {
        return ApiResponse.success(
          data['company_id']?.toString() ?? '',
          message: data['message']?.toString(),
        );
      }
      return ApiResponse.error(data['message']?.toString() ?? 'Registration failed');
    } on DioException catch (e) {
      debugPrint('[Register] DioException: ${e.type} — ${e.response?.data}');
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.unknown) {
        return ApiResponse.error('Cannot reach server. Check XAMPP.');
      }
      final serverMsg = e.response?.data;
      return ApiResponse.error(
        (serverMsg is Map ? serverMsg['message'] : null) ??
            'Registration failed (${e.response?.statusCode})',
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      debugPrint('[Register] Error: $e');
      return ApiResponse.error('Registration error: $e');
    }
  }

  Future<void> logout() => LocalStorage.clearSession();

  // ── Private helpers ───────────────────────────────────────────────────────

  /// Builds a Dio instance with auth headers pre-filled.
  /// During login we pass temporary values so backend "missing" check passes.
  /// After login the real Dio interceptor uses stored values.
  Dio _makeDio({required String companyId}) {
    return Dio(
      BaseOptions(
        baseUrl: ApiEndpoints.baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'X-Company-Id': companyId,   // real or temporary company code
          'X-User-Id': 'login',        // placeholder — tells backend this is a login call
          'X-User-Role': 'guest',      // placeholder
        },
      ),
    );
  }

  /// Extracts first record from common API response shapes:
  /// { data: {...} }  |  { data: [...] }  |  flat { id:..., company_name:... }
  Map<String, dynamic>? _extractFirst(Map<String, dynamic> raw) {
    final d = raw['data'];
    if (d is Map<String, dynamic>) return d;
    if (d is List && d.isNotEmpty) return d[0] as Map<String, dynamic>;
    if (raw['id'] != null ||
        raw['company_name'] != null ||
        raw['company_id'] != null) return raw;
    return null;
  }

  /// Finds a user matching [phone] inside various response shapes.
  /// Falls back to first record if only one result is returned.
  UserModel? _findUser(Map<String, dynamic> userData, String phone) {
    final d = userData['data'];

    if (d is List) {
      for (final item in d) {
        final m = item as Map<String, dynamic>;
        final p = m['phone_number']?.toString() ?? m['phone']?.toString() ?? '';
        if (p == phone || p.endsWith(phone)) return UserModel.fromJson(m);
      }
      if (d.length == 1) return UserModel.fromJson(d[0] as Map<String, dynamic>);
    } else if (d is Map<String, dynamic>) {
      final p = d['phone_number']?.toString() ?? d['phone']?.toString() ?? '';
      if (p == phone || p.endsWith(phone)) return UserModel.fromJson(d);
    } else if (userData['id'] != null) {
      final p = userData['phone_number']?.toString() ?? userData['phone']?.toString() ?? '';
      if (p == phone || p.endsWith(phone)) {
        return UserModel.fromJson(userData);
      }
    }
    return null;
  }
}
