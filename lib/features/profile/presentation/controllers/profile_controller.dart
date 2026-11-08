import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/storage/storage_service.dart';
import '../../../home/presentation/controllers/home_controller.dart';

/// Controller for fetching live authenticated profile via GET /api/v1/auth/me.
class ProfileController extends GetxController {
  final StorageService _storage = Get.isRegistered<StorageService>()
      ? Get.find<StorageService>()
      : Get.put(StorageService());
  late final ApiClient _apiClient;

  final RxBool isLoading = false.obs;
  final RxString fullName = ''.obs;
  final RxString email = ''.obs;
  final RxString phone = ''.obs;
  final RxString role = ''.obs;
  final RxString memberId = ''.obs;
  final RxString tenantId = ''.obs;
  final RxString branchId = ''.obs;
  final RxString status = 'active'.obs;
  final RxMap<String, dynamic> rawUser = <String, dynamic>{}.obs;

  @override
  void onInit() {
    super.onInit();
    _apiClient = Get.isRegistered<ApiClient>() ? Get.find<ApiClient>() : ApiClient();
    loadProfile();
  }

  /// Fetch live user profile from GET /api/v1/auth/me
  Future<void> loadProfile() async {
    isLoading.value = true;
    try {
      // 1. Initial quick load from local storage cache
      final cachedName = await _storage.getUserName();
      if (cachedName != null && cachedName.isNotEmpty) {
        fullName.value = cachedName;
      }
      final cachedRole = await _storage.getUserRole();
      if (cachedRole != null && cachedRole.isNotEmpty) {
        role.value = cachedRole;
      }
      final cachedTenant = await _storage.getTenantId();
      if (cachedTenant != null && cachedTenant.isNotEmpty) {
        tenantId.value = cachedTenant;
      }
      final cachedStudentId = await _storage.getStudentId();
      if (cachedStudentId != null && cachedStudentId.isNotEmpty) {
        memberId.value = cachedStudentId;
      }

      // Check cached user JSON
      try {
        final cachedJson = await _storage.getUserJson();
        if (cachedJson != null && cachedJson.isNotEmpty) {
          final decoded = jsonDecode(cachedJson);
          if (decoded is Map<String, dynamic>) {
            _populateFromUserMap(decoded);
          }
        }
      } catch (_) {}

      // 2. Fetch LIVE profile from GET /api/v1/auth/me
      String? token = await _storage.getAccessToken();

      // If token is absent, ensure session through guest registration
      if (token == null || token.trim().isEmpty) {
        try {
          final regRes = await _apiClient.dio.post(
            ApiEndpoints.guestRegister,
            data: {
              'name': 'Guest Player',
              'phone': '9876543210',
              'tenantId': ApiEndpoints.defaultTenantId,
            },
          );
          if (regRes.statusCode == 200 || regRes.statusCode == 201) {
            final body = regRes.data['data'] ?? regRes.data;
            final guestToken = body['accessToken']?.toString() ?? '';
            if (guestToken.isNotEmpty) {
              await _storage.saveTokens(accessToken: guestToken, refreshToken: guestToken);
              token = guestToken;
            }
          }
        } catch (_) {}
      }

      // Live request to /api/v1/auth/me
      final response = await _apiClient.dio.get(ApiEndpoints.me);
      if (response.statusCode == 200 && response.data is Map) {
        final body = response.data as Map<String, dynamic>;
        final data = body['data'];
        if (data is Map<String, dynamic>) {
          if (data['tenantId'] != null) {
            tenantId.value = data['tenantId'].toString();
          }
          if (data['branchId'] != null) {
            branchId.value = data['branchId'].toString();
          }

          final user = data['user'];
          if (user is Map<String, dynamic>) {
            _populateFromUserMap(user);

            // Persist updated user profile to storage
            await _storage.saveUserSession(
              accessToken: token ?? '',
              refreshToken: token ?? '',
              tenantId: tenantId.value,
              role: role.value,
              userName: fullName.value,
              studentId: memberId.value,
              userJson: jsonEncode(user),
            );

            // Also keep HomeController in sync
            if (Get.isRegistered<HomeController>()) {
              final homeCtrl = Get.find<HomeController>();
              if (fullName.value.isNotEmpty) {
                homeCtrl.updateUserName(fullName.value);
              }
              if (role.value.isNotEmpty) {
                homeCtrl.userRole.value = role.value;
              }
            }
          }
        }
      }
    } catch (e) {
      debugPrint('[ProfileController] Error loading /auth/me: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void _populateFromUserMap(Map<String, dynamic> user) {
    rawUser.value = user;

    final fName = (user['firstName'] ?? '').toString().trim();
    final lName = (user['lastName'] ?? '').toString().trim();
    final name = (user['fullName'] ?? user['name'] ?? (fName.isNotEmpty ? '$fName $lName' : '')).toString().trim();
    if (name.isNotEmpty) {
      fullName.value = name;
    }

    if (user['email'] != null && user['email'].toString().trim().isNotEmpty) {
      email.value = user['email'].toString().trim();
    }
    if (user['phone'] != null && user['phone'].toString().trim().isNotEmpty) {
      phone.value = user['phone'].toString().trim();
    }
    if (user['role'] != null && user['role'].toString().trim().isNotEmpty) {
      role.value = user['role'].toString().trim();
    }
    if (user['status'] != null && user['status'].toString().trim().isNotEmpty) {
      status.value = user['status'].toString().trim();
    }

    final id = (user['regNo'] ?? user['cardNo'] ?? user['employeeNo'] ?? user['studentId'] ?? user['id'] ?? user['_id'])?.toString().trim();
    if (id != null && id.isNotEmpty) {
      memberId.value = id;
    }
  }

  Future<void> logout() async {
    await _storage.clearAll();
    Get.offAllNamed(AppRoutes.login);
  }
}
