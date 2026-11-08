import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' as getx;
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import '../storage/storage_service.dart';
import 'api_endpoints.dart';

/// Centralized service monitoring real-time network connectivity across the app.
class NetworkService extends getx.GetxService {
  static NetworkService get to => getx.Get.find<NetworkService>();

  final getx.RxBool isConnected = true.obs;
  final getx.Rx<InternetStatus> connectionStatus = InternetStatus.connected.obs;
  StreamSubscription<InternetStatus>? _subscription;
  bool _initialCheckDone = false;

  Future<NetworkService> init() async {
    // On web, browser CORS can block HEAD requests to DNS hosts; default to online
    if (kIsWeb) {
      isConnected.value = true;
      _initialCheckDone = true;
      return this;
    }

    try {
      final internetConnection = InternetConnection();
      final initialStatus = await internetConnection.internetStatus;
      connectionStatus.value = initialStatus;
      isConnected.value = initialStatus == InternetStatus.connected;

      _subscription = internetConnection.onStatusChange.listen((status) {
        final wasConnected = isConnected.value;
        connectionStatus.value = status;
        final connected = status == InternetStatus.connected;
        isConnected.value = connected;

        // Only notify user after initial startup check to avoid flashing alerts on launch
        if (_initialCheckDone && wasConnected != connected) {
          _notifyStatusChange(connected);
        }
      });
    } catch (e) {
      debugPrint('[NetworkService] init error: $e');
      isConnected.value = true;
    }
    _initialCheckDone = true;
    return this;
  }

  void _notifyStatusChange(bool online) {
    if (getx.Get.context == null) return;

    if (getx.Get.isSnackbarOpen) {
      getx.Get.closeCurrentSnackbar();
    }

    getx.Get.rawSnackbar(
      snackPosition: getx.SnackPosition.TOP,
      backgroundColor: online ? const Color(0xFF10B981) : const Color(0xFFEF4444),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      borderRadius: 12,
      duration: Duration(seconds: online ? 3 : 5),
      messageText: Row(
        children: [
          Icon(
            online ? Icons.wifi_rounded : Icons.wifi_off_rounded,
            color: Colors.white,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              online
                  ? 'Internet connection restored'
                  : 'No internet connection. Please check your network.',
              style: const TextStyle(
                fontFamily: 'Nunito',
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Manually trigger a fresh internet connectivity check
  Future<bool> checkConnection() async {
    if (kIsWeb) return isConnected.value;
    try {
      final hasInternet = await InternetConnection().hasInternetAccess;
      isConnected.value = hasInternet;
      return hasInternet;
    } catch (_) {
      return isConnected.value;
    }
  }

  @override
  void onClose() {
    _subscription?.cancel();
    super.onClose();
  }
}

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
