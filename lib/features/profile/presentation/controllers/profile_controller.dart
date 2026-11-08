import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/storage/storage_service.dart';
import '../../../home/presentation/controllers/home_controller.dart';

/// Controller for fetching live authenticated profile via GET /api/v1/auth/me.
/// Strictly presents real data and manages "not registered" / booking required states.
class ProfileController extends GetxController {
  final StorageService _storage = Get.isRegistered<StorageService>()
      ? Get.find<StorageService>()
      : Get.put(StorageService());
  late final ApiClient _apiClient;

  final RxBool isLoading = false.obs;
  final RxBool isRegistered = false.obs;
  final RxBool hasError = false.obs;
  final RxString errorMessage = ''.obs;

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
    hasError.value = false;
    errorMessage.value = '';

    try {
      final token = await _storage.getAccessToken();

      // If user has not logged in / has no access token, they are not registered
      if (token == null || token.trim().isEmpty) {
        _clearProfileData();
        isRegistered.value = false;
        isLoading.value = false;
        return;
      }

      // Check cached user JSON temporarily
      try {
        final cachedJson = await _storage.getUserJson();
        if (cachedJson != null && cachedJson.isNotEmpty) {
          final decoded = jsonDecode(cachedJson);
          if (decoded is Map<String, dynamic>) {
            _populateFromUserMap(decoded);
            isRegistered.value = true;
          }
        }
      } catch (_) {}

      // Fetch LIVE profile from GET /api/v1/auth/me
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
            isRegistered.value = true;
            hasError.value = false;

            // Persist updated user profile to storage
            await _storage.saveUserSession(
              accessToken: token,
              refreshToken: token,
              tenantId: tenantId.value,
              role: role.value,
              userName: fullName.value,
              studentId: memberId.value,
              userJson: jsonEncode(user),
            );

            // Keep HomeController in sync with real user name
            if (Get.isRegistered<HomeController>()) {
              final homeCtrl = Get.find<HomeController>();
              if (fullName.value.isNotEmpty) {
                homeCtrl.updateUserName(fullName.value);
              }
              if (role.value.isNotEmpty) {
                homeCtrl.userRole.value = role.value;
              }
            }
          } else {
            // No valid user data returned
            _clearProfileData();
            isRegistered.value = false;
          }
        } else {
          _clearProfileData();
          isRegistered.value = false;
        }
      } else {
        _clearProfileData();
        isRegistered.value = false;
      }
    } catch (e) {
      debugPrint('[ProfileController] /auth/me error: $e');
      // If error or unauthorized, mark as not registered / error
      hasError.value = true;
      errorMessage.value = e.toString();
      _clearProfileData();
      isRegistered.value = false;
    } finally {
      isLoading.value = false;
    }
  }

  void _clearProfileData() {
    fullName.value = '';
    email.value = '';
    phone.value = '';
    role.value = '';
    memberId.value = '';
    rawUser.clear();
  }

  void _populateFromUserMap(Map<String, dynamic> user) {
    rawUser.value = user;

    final fName = (user['firstName'] ?? '').toString().trim();
    final lName = (user['lastName'] ?? '').toString().trim();
    final name = (user['fullName'] ?? user['name'] ?? (fName.isNotEmpty ? '$fName $lName' : '')).toString().trim();
    fullName.value = name;

    email.value = (user['email'] ?? '').toString().trim();
    phone.value = (user['phone'] ?? '').toString().trim();
    role.value = (user['role'] ?? '').toString().trim();
    status.value = (user['status'] ?? 'active').toString().trim();

    final id = (user['regNo'] ?? user['cardNo'] ?? user['employeeNo'] ?? user['studentId'] ?? user['id'] ?? user['_id'])?.toString().trim();
    memberId.value = id ?? '';
  }

  Future<void> logout() async {
    await _storage.clearAll();
    _clearProfileData();
    isRegistered.value = false;
    Get.offAllNamed(AppRoutes.login);
  }
}
