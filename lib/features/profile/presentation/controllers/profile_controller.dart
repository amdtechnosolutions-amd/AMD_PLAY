import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_app/features/attendance/presentation/controllers/attendance_controller.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/storage/storage_service.dart';
import '../../../home/presentation/controllers/home_controller.dart';
import '../../../siblings/data/models/sibling_models.dart';

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

  // Student & Sibling Profile Properties
  final RxString selectedStudentId = ''.obs;
  final RxString regNo = ''.obs;
  final RxString parentName = ''.obs;
  final RxString parentPhone = ''.obs;
  final RxString batchName = ''.obs;
  final RxString sportName = ''.obs;
  final RxBool hasSiblings = false.obs;
  final RxInt siblingCount = 0.obs;
  final RxList<SiblingStudentModel> siblings = <SiblingStudentModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    _apiClient = Get.isRegistered<ApiClient>()
        ? Get.find<ApiClient>()
        : ApiClient();
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
            final uPhone = (decoded['phone'] ?? '').toString().trim();
            final uEmail = (decoded['email'] ?? '').toString().trim();
            if (uPhone != '9876543210' && uEmail != 'admin@amdtechno.in') {
              _populateFromUserMap(decoded);
              isRegistered.value = true;
            }
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
            final userPhone = (user['phone'] ?? '').toString().trim();
            final userEmail = (user['email'] ?? '').toString().trim();
            final userId = (user['_id'] ?? user['id'] ?? '').toString().trim();

            // Guard against legacy tenant admin account being treated as logged in user
            if (userPhone == '9876543210' ||
                userEmail == 'admin@amdtechno.in' ||
                userId == '6ad67f8a21c35f3cf2139ef8') {
              await _storage.clearAll();
              _clearProfileData();
              isRegistered.value = false;
              isLoading.value = false;
              return;
            }

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

            // For student role, fetch recommended /students/my/profile
            final roleStr = role.value.toLowerCase().trim();
            final isStudent =
                roleStr == 'student' ||
                roleStr.contains('student') ||
                roleStr.contains('trainee');
            final storedStudentId = await _storage.getStudentId();

            if (isStudent ||
                (storedStudentId != null && storedStudentId.isNotEmpty)) {
              if (selectedStudentId.value.isEmpty &&
                  storedStudentId != null &&
                  storedStudentId.isNotEmpty) {
                selectedStudentId.value = storedStudentId;
              }
              try {
                final endpoint = (selectedStudentId.value.isNotEmpty &&
                        selectedStudentId.value != storedStudentId)
                    ? ApiEndpoints.studentProfileSwitch(selectedStudentId.value)
                    : ApiEndpoints.studentProfile;
                final profileRes = await _apiClient.dio.get(
                  endpoint,
                );
                if (profileRes.data is Map &&
                    profileRes.data['success'] == true &&
                    profileRes.data['data'] is Map) {
                  final pData = profileRes.data['data'] as Map;
                  final student = pData['student'] is Map
                      ? pData['student'] as Map
                      : null;
                  if (student != null) {
                    final sId =
                        (student['studentId'] ??
                                student['_id'] ??
                                student['id'] ??
                                '')
                            .toString();
                    if (sId.isNotEmpty) {
                      selectedStudentId.value = sId;
                    }
                    final sFullName = (student['fullName'] ?? '')
                        .toString()
                        .trim();
                    if (sFullName.isNotEmpty) {
                      fullName.value = sFullName;
                    }
                    if (student['phone'] != null &&
                        student['phone'].toString().trim().isNotEmpty) {
                      phone.value = student['phone'].toString().trim();
                    }
                    if (student['email'] != null &&
                        student['email'].toString().trim().isNotEmpty) {
                      email.value = student['email'].toString().trim();
                    }

                    regNo.value = (student['regNo'] ?? '').toString().trim();
                    parentName.value =
                        (student['parentName'] ?? pData['parentName'] ?? '')
                            .toString()
                            .trim();
                    parentPhone.value =
                        (student['parentPhone'] ?? pData['familyPhone'] ?? '')
                            .toString()
                            .trim();
                    final enrollments = student['enrollments'] as List? ?? [];
                    if (enrollments.isNotEmpty && enrollments.first is Map) {
                      final enr = enrollments.first as Map;
                      final b = enr['batchId'] is Map
                          ? enr['batchId'] as Map
                          : null;
                      batchName.value = (b?['name'] ?? '').toString().trim();
                      sportName.value =
                          (b?['sportId'] is Map ? b!['sportId']['name'] : '')
                              .toString()
                              .trim();
                    }
                  }
                  final sibList = pData['siblings'] is List
                      ? pData['siblings'] as List
                      : (student != null && student['siblings'] is List
                            ? student['siblings'] as List
                            : []);
                  if (sibList.isNotEmpty) {
                    final parsed = sibList
                        .whereType<Map>()
                        .map(
                          (s) => SiblingStudentModel.fromJson(
                            Map<String, dynamic>.from(s),
                          ),
                        )
                        .toList();
                    siblings.assignAll(parsed);
                    hasSiblings.value = parsed.length > 1;
                    siblingCount.value = parsed.length;
                  }
                }
              } catch (e) {
                debugPrint(
                  '[ProfileController] /students/my/profile error: $e',
                );
              }

              // Fallback to /students/my/siblings if siblings list still empty
              if (siblings.isEmpty) {
                try {
                  final sibRes = await _apiClient.dio.get(
                    ApiEndpoints.studentSiblings,
                  );
                  if (sibRes.data is Map && sibRes.data['data'] is List) {
                    final parsed = (sibRes.data['data'] as List)
                        .whereType<Map>()
                        .map(
                          (s) => SiblingStudentModel.fromJson(
                            Map<String, dynamic>.from(s),
                          ),
                        )
                        .toList();
                    if (parsed.isNotEmpty) {
                      siblings.assignAll(parsed);
                      hasSiblings.value = parsed.length > 1;
                      siblingCount.value = parsed.length;
                    }
                  }
                } catch (_) {}
              }

              // Fallback from HomeController's mySports if still empty
              if (siblings.isEmpty && Get.isRegistered<HomeController>()) {
                final hCtrl = Get.find<HomeController>();
                final uniqueStudents = <String, SiblingStudentModel>{};
                for (final sp in hCtrl.mySports) {
                  if (sp.studentId.isNotEmpty &&
                      !uniqueStudents.containsKey(sp.studentId)) {
                    uniqueStudents[sp.studentId] = SiblingStudentModel(
                      studentId: sp.studentId,
                      fullName: sp.name,
                      batchName: sp.batchName,
                      sportName: sp.sport,
                      isCurrent: sp.isCurrent,
                      isSelected: sp.isCurrent,
                    );
                  }
                }
                if (uniqueStudents.length > 1) {
                  siblings.assignAll(uniqueStudents.values);
                  hasSiblings.value = true;
                  siblingCount.value = uniqueStudents.length;
                }
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
    regNo.value = '';
    parentName.value = '';
    parentPhone.value = '';
    batchName.value = '';
    sportName.value = '';
    hasSiblings.value = false;
    siblingCount.value = 0;
    siblings.clear();
    rawUser.clear();
  }

  void _populateFromUserMap(Map<String, dynamic> user) {
    rawUser.value = user;

    final fName = (user['firstName'] ?? '').toString().trim();
    final lName = (user['lastName'] ?? '').toString().trim();
    final name =
        (user['fullName'] ??
                user['name'] ??
                (fName.isNotEmpty ? '$fName $lName' : ''))
            .toString()
            .trim();
    fullName.value = name;

    email.value = (user['email'] ?? '').toString().trim();
    phone.value = (user['phone'] ?? '').toString().trim();
    role.value = (user['role'] ?? '').toString().trim();
    status.value = (user['status'] ?? 'active').toString().trim();

    final id =
        (user['regNo'] ??
                user['cardNo'] ??
                user['employeeNo'] ??
                user['studentId'] ??
                user['id'] ??
                user['_id'])
            ?.toString()
            .trim();
    memberId.value = id ?? '';

    // Endpoint 4: Support preloaded user.siblings from GET /api/v1/auth/me
    final rawSiblings = user['siblings'];
    if (rawSiblings is List && rawSiblings.isNotEmpty) {
      final parsed = rawSiblings
          .whereType<Map>()
          .map(
            (s) => SiblingStudentModel.fromJson(Map<String, dynamic>.from(s)),
          )
          .toList();
      siblings.assignAll(parsed);
      hasSiblings.value = parsed.length > 1;
      siblingCount.value = parsed.length;
    }
  }

  /// Direct profile switching to selected sibling via GET /api/v1/students/my/profile?studentId=`<siblingId>`
  Future<void> switchStudentProfile(
    String targetStudentId, [
    HomeController? homeCtrl,
  ]) async {
    if (targetStudentId.isEmpty || targetStudentId == selectedStudentId.value) {
      return;
    }

    isLoading.value = true;
    try {
      final res = await _apiClient.dio.get(
        ApiEndpoints.studentProfileSwitch(targetStudentId),
      );

      if (res.data is Map &&
          res.data['success'] == true &&
          res.data['data'] is Map) {
        final data = res.data['data'] as Map;
        final student = data['student'] is Map ? data['student'] as Map : null;

        if (student != null) {
          final sId =
              (student['studentId'] ??
                      student['_id'] ??
                      student['id'] ??
                      targetStudentId)
                  .toString();
          selectedStudentId.value = sId;

          final fName = (student['firstName'] ?? '').toString().trim();
          final lName = (student['lastName'] ?? '').toString().trim();
          final combinedName = '$fName $lName'.trim();
          final name =
              (student['fullName']?.toString().trim().isNotEmpty == true)
              ? student['fullName'].toString().trim()
              : (combinedName.isNotEmpty ? combinedName : 'Trainee');
          fullName.value = name;

          if (student['email'] != null &&
              student['email'].toString().trim().isNotEmpty) {
            email.value = student['email'].toString().trim();
          }
          if (student['phone'] != null &&
              student['phone'].toString().trim().isNotEmpty) {
            phone.value = student['phone'].toString().trim();
          }

          regNo.value = (student['regNo'] ?? student['employeeNo'] ?? '')
              .toString()
              .trim();
          parentName.value = (student['parentName'] ?? data['parentName'] ?? '')
              .toString()
              .trim();
          parentPhone.value =
              (student['parentPhone'] ?? data['familyPhone'] ?? '')
                  .toString()
                  .trim();

          final enrollments = student['enrollments'] as List? ?? [];
          if (enrollments.isNotEmpty && enrollments.first is Map) {
            final enr = enrollments.first as Map;
            final b = enr['batchId'] is Map ? enr['batchId'] as Map : null;
            batchName.value = (b?['name'] ?? '').toString().trim();
            sportName.value =
                (b?['sportId'] is Map ? b!['sportId']['name'] : '')
                    .toString()
                    .trim();
          }

          final storedToken = await _storage.getAccessToken() ?? '';
          final tenantId = (data['tenantId'] ?? await _storage.getTenantId())
              ?.toString();
          final roleStr =
              (data['role'] ?? await _storage.getUserRole())?.toString() ??
              'student';

          await _storage.saveUserSession(
            accessToken: storedToken,
            refreshToken: storedToken,
            tenantId: tenantId,
            studentId: sId,
            role: roleStr,
            userName: name,
            userJson: jsonEncode(student),
          );

          // Sync HomeController if registered
          final hCtrl =
              homeCtrl ??
              (Get.isRegistered<HomeController>()
                  ? Get.find<HomeController>()
                  : null);
          if (hCtrl != null) {
            hCtrl.currentStudentId.value = sId;
            hCtrl.userName.value = name;
            hCtrl.greetingName.value = (fName.isNotEmpty ? fName : name)
                .toUpperCase();
            hCtrl.refreshDashboard();
          }

          // Sync AttendanceController if registered
          if (Get.isRegistered<AttendanceController>()) {
            Get.find<AttendanceController>().fetchLiveAttendance(
              studentId: sId,
            );
          }

          // Parse siblings list from response to update selection state
          final sibList = data['siblings'] is List
              ? data['siblings'] as List
              : (student['siblings'] is List
                    ? student['siblings'] as List
                    : []);
          if (sibList.isNotEmpty) {
            final parsed = sibList
                .whereType<Map>()
                .map(
                  (s) => SiblingStudentModel.fromJson(
                    Map<String, dynamic>.from(s),
                  ),
                )
                .toList();
            siblings.assignAll(parsed);
            hasSiblings.value = parsed.length > 1;
            siblingCount.value = parsed.length;
          }

          Get.snackbar(
            'Profile Switched',
            'Switched active profile to $name',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: const Color(0xFF0F172A),
            colorText: Colors.white,
            margin: const EdgeInsets.all(16),
            borderRadius: 12,
          );
        }
      }
    } catch (e) {
      debugPrint('[ProfileController] switchStudentProfile error: $e');
      final hCtrl =
          homeCtrl ??
          (Get.isRegistered<HomeController>()
              ? Get.find<HomeController>()
              : null);
      if (hCtrl != null) {
        await hCtrl.switchProfile(targetStudentId);
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    await _storage.clearAll();
    _clearProfileData();
    isRegistered.value = false;
    Get.offAllNamed(AppRoutes.login);
  }
}
