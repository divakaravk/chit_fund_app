import 'package:dio/dio.dart';
import '../storage/local_storage.dart';
import 'api_endpoints.dart';

class DioClient {
  static Dio? _instance;

  static Dio get instance {
    _instance ??= _createDio();
    return _instance!;
  }

  static Dio _createDio() {
    final dio = Dio(
      BaseOptions(
        baseUrl: ApiEndpoints.baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {'Content-Type': 'application/json'},
      ),
    );

    dio.interceptors.add(_AuthInterceptor());
    dio.interceptors.add(_ErrorInterceptor());

    return dio;
  }
}

class _AuthInterceptor extends Interceptor {
  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final userId = await LocalStorage.getUserId();
    final userRole = await LocalStorage.getUserRole();
    final companyId = await LocalStorage.getCompanyId();

    if (userId != null) options.headers['X-User-Id'] = userId;
    if (userRole != null) options.headers['X-User-Role'] = userRole;
    if (companyId != null) options.headers['X-Company-Id'] = companyId;

    handler.next(options);
  }
}

class _ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      LocalStorage.clearSession();
    }
    handler.next(err);
  }
}
