import 'package:dio/dio.dart';
import 'package:get/get.dart' as getx;
import '../storage/storage_service.dart';
import 'api_endpoints.dart';

/// Dio API Client with authorization headers and centralized error handling.
class ApiClient {
  late final Dio dio;

  ApiClient() {
    dio = Dio(
      BaseOptions(
        baseUrl: ApiEndpoints.baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Always ensure the baseUrl is up-to-date
          options.baseUrl = ApiEndpoints.baseUrl;

          if (getx.Get.isRegistered<StorageService>()) {
            final storage = getx.Get.find<StorageService>();
            final token = await storage.getAccessToken();
            if (token != null && token.isNotEmpty) {
              options.headers['Authorization'] = 'Bearer $token';
            }
            var tenantId = await storage.getTenantId();
            if (ApiEndpoints.isProduction && (tenantId == null || tenantId.isEmpty || tenantId == ApiEndpoints.localTenantId)) {
              tenantId = ApiEndpoints.liveTenantId;
              await storage.saveTenantId(ApiEndpoints.liveTenantId);
            }
            options.headers['X-Tenant-ID'] = (tenantId != null && tenantId.isNotEmpty) ? tenantId : ApiEndpoints.defaultTenantId;
          } else {
            options.headers['X-Tenant-ID'] = ApiEndpoints.defaultTenantId;
          }
          return handler.next(options);
        },
        onError: (DioException error, handler) async {
          // Centrally handle unauthorized or network error
          return handler.next(error);
        },
      ),
    );
  }
}
