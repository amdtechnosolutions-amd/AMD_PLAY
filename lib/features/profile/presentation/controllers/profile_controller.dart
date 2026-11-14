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

            // Check if a specific student is already active/selected
            final storedStudentId = await _storage.getStudentId();
            if (selectedStudentId.value.isEmpty &&
                storedStudentId != null &&
                storedStudentId.isNotEmpty) {
              selectedStudentId.value = storedStudentId;
            }
            final activeStudentId = selectedStudentId.value;

            // Only populate name/memberId from /auth/me if NO specific student has been switched yet
            if (activeStudentId.isEmpty) {
              _populateFromUserMap(user);
              await _storage.saveUserSession(
                accessToken: token,
                refreshToken: token,
                tenantId: tenantId.value,
                role: role.value,
                userName: fullName.value,
                studentId: memberId.value,
                userJson: jsonEncode(user),
              );
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
              rawUser.value = user;
              role.value = (user['role'] ?? 'student').toString().trim();
              status.value = (user['status'] ?? 'active').toString().trim();
            }

            isRegistered.value = true;
            hasError.value = false;

            // For student role, fetch recommended /students/my/profile
            final roleStr = role.value.toLowerCase().trim();
            final isStudent =
                roleStr == 'student' ||
                roleStr.contains('student') ||
                roleStr.contains('trainee');

            if (isStudent ||
                activeStudentId.isNotEmpty ||
                (storedStudentId != null && storedStudentId.isNotEmpty)) {
              final targetId = activeStudentId.isNotEmpty
                  ? activeStudentId
                  : (storedStudentId ?? '');
              try {
                final endpoint = targetId.isNotEmpty
                    ? ApiEndpoints.studentProfileSwitch(targetId)
                    : ApiEndpoints.studentProfile;
                final profileRes = await _apiClient.dio.get(
                  endpoint,
                );
                if (profileRes.data is Map &&
                    profileRes.data['success'] == true &&
                    profileRes.data['data'] is Map) {
                  final pData = profileRes.data['data'] as Map;
                  final student = _findStudentInPayload(pData, targetId) ??
                      (targetId.isEmpty && pData['student'] is Map
                          ? pData['student'] as Map
                          : (pData['user'] is Map
                              ? pData['user'] as Map
                              : (pData.containsKey('fullName') ||
                                      pData.containsKey('firstName')
                                  ? pData
                                  : null)));
                  if (student != null) {
                    final rawSId = student['studentId'] is Map
                        ? (student['studentId']['_id'] ??
                            student['studentId']['id'])
                        : (student['studentId'] ??
                            student['_id'] ??
                            student['id'] ??
                            targetId);
                    final sId = (rawSId ?? targetId).toString();
                    if (sId.isNotEmpty) {
                      selectedStudentId.value = sId;
                      memberId.value = sId;
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

                    regNo.value = (student['regNo'] ??
                            student['employeeNo'] ??
                            '')
                        .toString()
                        .trim();
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

                    // Save session with active selected student details
                    await _storage.saveUserSession(
                      accessToken: token,
                      refreshToken: token,
                      tenantId: tenantId.value,
                      role: role.value,
                      userName: fullName.value,
                      studentId: sId.isNotEmpty ? sId : targetId,
                      userJson: jsonEncode(student),
                    );
                  }
                  final sibList = pData['siblings'] is List
                      ? pData['siblings'] as List
                      : (student != null && student['siblings'] is List
                            ? student['siblings'] as List
                            : []);
                  if (sibList.isNotEmpty) {
                    final currentId = selectedStudentId.value.isNotEmpty
                        ? selectedStudentId.value
                        : targetId;
                    final parsed = sibList
                        .whereType<Map>()
                        .map(
                          (s) {
                            final model = SiblingStudentModel.fromJson(
                              Map<String, dynamic>.from(s),
                            );
                            final isSel = model.studentId == currentId;
                            return model.copyWith(
                              isSelected: isSel,
                              isCurrent: isSel,
                            );
                          },
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

  Map<String, dynamic>? _findStudentInPayload(Map data, String targetId) {
    if (targetId.isEmpty) {
      if (data['selectedStudent'] is Map) {
        return Map<String, dynamic>.from(data['selectedStudent'] as Map);
      }
      if (data['student'] is Map) {
        return Map<String, dynamic>.from(data['student'] as Map);
      }
      return null;
    }

    // 1. Check data['selectedStudent']
    if (data['selectedStudent'] is Map) {
      final s = Map<String, dynamic>.from(data['selectedStudent'] as Map);
      final id = (s['studentId'] is Map
              ? s['studentId']['_id'] ?? s['studentId']['id']
              : s['studentId'] ?? s['_id'] ?? s['id'])
          ?.toString();
      if (id == targetId) return s;
    }

    // 2. Check data['siblings'] or data['student']['siblings']
    final sibList = data['siblings'] is List
        ? data['siblings'] as List
        : (data['student'] is Map && data['student']['siblings'] is List
            ? data['student']['siblings'] as List
            : null);
    if (sibList != null) {
      for (final item in sibList) {
        if (item is Map) {
          final id = (item['studentId'] is Map
                  ? item['studentId']['_id'] ?? item['studentId']['id']
                  : item['studentId'] ?? item['_id'] ?? item['id'])
              ?.toString();
          if (id == targetId) return Map<String, dynamic>.from(item);
        }
      }
    }

    // 3. Check data['student']
    if (data['student'] is Map) {
      final s = Map<String, dynamic>.from(data['student'] as Map);
      final id = (s['studentId'] is Map
              ? s['studentId']['_id'] ?? s['studentId']['id']
              : s['studentId'] ?? s['_id'] ?? s['id'])
          ?.toString();
      if (id == targetId) return s;
    }

    // 4. Check root data if it has student fields matching targetId
    final rootId = (data['studentId'] is Map
            ? data['studentId']['_id'] ?? data['studentId']['id']
            : data['studentId'] ?? data['_id'] ?? data['id'])
        ?.toString();
    if (rootId == targetId &&
        (data.containsKey('fullName') || data.containsKey('firstName'))) {
      return Map<String, dynamic>.from(data);
    }

    return null;
  }

  /// Direct profile switching to selected sibling via GET /api/v1/students/my/profile?studentId=`<siblingId>`
  Future<void> switchStudentProfile(
    String targetStudentId, [
    HomeController? homeCtrl,
  ]) async {
    if (targetStudentId.isEmpty) return;

    // 1. Immediately apply cached sibling info so UI updates instantly!
    final cached = siblings.firstWhereOrNull((s) => s.studentId == targetStudentId);
    if (cached != null) {
      selectedStudentId.value = cached.studentId;
      memberId.value = cached.studentId;
      if (cached.fullName.isNotEmpty) fullName.value = cached.fullName;
      if (cached.phone.isNotEmpty) phone.value = cached.phone;
      if (cached.email.isNotEmpty) email.value = cached.email;
      if (cached.regNo.isNotEmpty) regNo.value = cached.regNo;
      if (cached.parentName.isNotEmpty) parentName.value = cached.parentName;
      if (cached.parentPhone.isNotEmpty) parentPhone.value = cached.parentPhone;
      if (cached.batchName.isNotEmpty) batchName.value = cached.batchName;
      if (cached.sportName.isNotEmpty) sportName.value = cached.sportName;

      // Update switcher bar selection state immediately
      final updated = siblings.map((s) {
        final isSel = s.studentId == targetStudentId;
        return s.copyWith(isSelected: isSel, isCurrent: isSel);
      }).toList();
      siblings.assignAll(updated);
    } else {
      selectedStudentId.value = targetStudentId;
    }

    isLoading.value = true;
    try {
      Map? studentData;
      String? tenantIdStr;
      String? roleStr;

      // 1. Recommended: GET /api/v1/students/my/profile?studentId=<siblingId>
      try {
        final res = await _apiClient.dio.get(
          ApiEndpoints.studentProfileSwitch(targetStudentId),
        );
        if (res.data is Map && res.data['success'] == true && res.data['data'] is Map) {
          final data = res.data['data'] as Map;
          studentData = _findStudentInPayload(data, targetStudentId);
          tenantIdStr = data['tenantId']?.toString();
          roleStr = data['role']?.toString();

          final sibList = data['siblings'] is List
              ? data['siblings'] as List
              : (data['student'] is Map && data['student']['siblings'] is List
                  ? data['student']['siblings'] as List
                  : []);
          if (sibList.isNotEmpty) {
            final parsed = sibList
                .whereType<Map>()
                .map((s) {
                  final model = SiblingStudentModel.fromJson(Map<String, dynamic>.from(s));
                  final isSel = model.studentId == targetStudentId;
                  return model.copyWith(isSelected: isSel, isCurrent: isSel);
                })
                .toList();
            siblings.assignAll(parsed);
            hasSiblings.value = parsed.length > 1;
            siblingCount.value = parsed.length;
          }
        }
      } catch (e) {
        debugPrint('[ProfileController] GET switch error: $e');
      }

      // 2. Direct endpoint: GET /api/v1/students/:id (Universal student endpoint)
      if (studentData == null) {
        try {
          final res = await _apiClient.dio.get(
            ApiEndpoints.studentById(targetStudentId),
          );
          if (res.data is Map && res.data['success'] == true && res.data['data'] is Map) {
            final data = res.data['data'] as Map;
            studentData = _findStudentInPayload(data, targetStudentId) ??
                (data['student'] is Map
                    ? Map<String, dynamic>.from(data['student'] as Map)
                    : (data.containsKey('fullName') || data.containsKey('firstName') ? Map<String, dynamic>.from(data) : null));
          }
        } catch (e) {
          debugPrint('[ProfileController] GET studentById error: $e');
        }
      }

      // 3. Fallback: POST /api/v1/auth/student/switch-profile
      if (studentData == null) {
        try {
          final res = await _apiClient.dio.post(
            ApiEndpoints.switchStudentProfile,
            data: {'targetStudentId': targetStudentId},
          );
          if (res.data is Map && res.data['success'] == true && res.data['data'] is Map) {
            final data = res.data['data'] as Map;
            studentData = _findStudentInPayload(data, targetStudentId) ??
                (data['user'] is Map
                    ? Map<String, dynamic>.from(data['user'] as Map)
                    : (data['student'] is Map ? Map<String, dynamic>.from(data['student'] as Map) : null));
            tenantIdStr = data['tenantId']?.toString();
            roleStr = data['role']?.toString();
          }
        } catch (e) {
          debugPrint('[ProfileController] POST switch error: $e');
        }
      }

      // 4. Fallback to cached model if backend returned generic root student
      if (studentData == null && cached != null) {
        studentData = {
          'studentId': cached.studentId,
          'fullName': cached.fullName,
          'regNo': cached.regNo,
          'phone': cached.phone,
          'email': cached.email,
          'parentName': cached.parentName,
          'parentPhone': cached.parentPhone,
          'batchName': cached.batchName,
          'sportName': cached.sportName,
        };
      }

      // Populate resolved student details
      if (studentData != null) {
        final rawSId = studentData['studentId'] is Map
            ? (studentData['studentId']['_id'] ?? studentData['studentId']['id'])
            : (studentData['studentId'] ?? studentData['_id'] ?? studentData['id'] ?? targetStudentId);
        final sId = (rawSId ?? targetStudentId).toString();
        selectedStudentId.value = sId;
        memberId.value = sId;

        final fName = (studentData['firstName'] ?? '').toString().trim();
        final lName = (studentData['lastName'] ?? '').toString().trim();
        final combinedName = '$fName $lName'.trim();
        final name = (studentData['fullName']?.toString().trim().isNotEmpty == true)
            ? studentData['fullName'].toString().trim()
            : (combinedName.isNotEmpty ? combinedName : (cached?.fullName ?? 'Trainee'));
        fullName.value = name;

        if (studentData['email'] != null && studentData['email'].toString().trim().isNotEmpty) {
          email.value = studentData['email'].toString().trim();
        }
        if (studentData['phone'] != null && studentData['phone'].toString().trim().isNotEmpty) {
          phone.value = studentData['phone'].toString().trim();
        }

        regNo.value = (studentData['regNo'] ?? studentData['employeeNo'] ?? cached?.regNo ?? '').toString().trim();
        parentName.value = (studentData['parentName'] ?? cached?.parentName ?? '').toString().trim();
        parentPhone.value = (studentData['parentPhone'] ?? cached?.parentPhone ?? '').toString().trim();

        final enrollments = studentData['enrollments'] as List? ?? [];
        if (enrollments.isNotEmpty && enrollments.first is Map) {
          final enr = enrollments.first as Map;
          final b = enr['batchId'] is Map ? enr['batchId'] as Map : null;
          batchName.value = (b?['name'] ?? enr['batchName'] ?? '').toString().trim();
          sportName.value = (b?['sportId'] is Map ? b!['sportId']['name'] : (enr['sportName'] ?? '')).toString().trim();
        } else if (studentData['batchName'] != null && studentData['batchName'].toString().isNotEmpty) {
          batchName.value = studentData['batchName'].toString().trim();
          sportName.value = (studentData['sportName'] ?? 'Badminton').toString().trim();
        } else if (cached != null) {
          if (cached.batchName.isNotEmpty) batchName.value = cached.batchName;
          if (cached.sportName.isNotEmpty) sportName.value = cached.sportName;
        }

        final storedToken = await _storage.getAccessToken() ?? '';
        final resolvedTenant = tenantIdStr ?? await _storage.getTenantId();
        final resolvedRole = roleStr ?? await _storage.getUserRole() ?? 'student';

        await _storage.saveUserSession(
          accessToken: storedToken,
          refreshToken: storedToken,
          tenantId: resolvedTenant,
          studentId: sId,
          role: resolvedRole,
          userName: name,
          userJson: jsonEncode(studentData),
        );

        // Sync HomeController state safely without full auth reset
        final hCtrl = homeCtrl ?? (Get.isRegistered<HomeController>() ? Get.find<HomeController>() : null);
        if (hCtrl != null) {
          hCtrl.currentStudentId.value = sId;
          hCtrl.userName.value = name;
          hCtrl.greetingName.value = (fName.isNotEmpty ? fName : name).toUpperCase();
        }

        // Sync AttendanceController
        if (Get.isRegistered<AttendanceController>()) {
          Get.find<AttendanceController>().fetchLiveAttendance(studentId: sId);
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
    } catch (e) {
      debugPrint('[ProfileController] switchStudentProfile unexpected error: $e');
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
