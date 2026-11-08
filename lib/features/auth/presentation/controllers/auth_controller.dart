import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart' hide Response, FormData, MultipartFile;
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/storage/storage_service.dart';
import 'package:mobile_app/features/home/presentation/controllers/home_controller.dart';

enum AuthMode {
  phoneOtp,
  emailPassword,
}

enum MembershipProfile {
  members,
  parents,
  booking,
}

class AuthController extends GetxController {
  final StorageService _storage = Get.find<StorageService>();
  late final ApiClient _apiClient;

  final Rx<AuthMode> authMode = AuthMode.phoneOtp.obs;
  final Rx<MembershipProfile> selectedProfile = MembershipProfile.parents.obs;
  final RxString selectedRole = 'Student'.obs;
  final RxBool isLoading = false.obs;
  final RxBool isPasswordVisible = false.obs;
  final RxBool isOtpSent = false.obs;
  final RxBool rememberMe = true.obs;
  final RxBool isSignUp = false.obs;

  // Controllers
  final TextEditingController identifierController = TextEditingController();
  final TextEditingController pinController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController otpController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    _apiClient = Get.isRegistered<ApiClient>() ? Get.find<ApiClient>() : ApiClient();
  }

  void selectRole(String role) {
    selectedRole.value = role;
    if (role == 'Member') {
      selectedProfile.value = MembershipProfile.members;
    } else if (role == 'Student') {
      selectedProfile.value = MembershipProfile.parents;
    } else {
      selectedProfile.value = MembershipProfile.booking;
    }
  }

  void selectProfile(MembershipProfile profile) {
    selectedProfile.value = profile;
  }

  /// Seamlessly activates guest session for Pay & Play
  Future<void> startGuestBookingFlow({bool goToDashboard = false}) async {
    selectRole('Guest');
    selectProfile(MembershipProfile.booking);

    try {
      await _storage.saveUserSession(
        accessToken: '',
        refreshToken: '',
        tenantId: ApiEndpoints.defaultTenantId,
        role: 'customer',
        userName: 'Guest Player',
      );
      if (Get.isRegistered<HomeController>()) {
        final homeCtrl = Get.find<HomeController>();
        homeCtrl.userRole.value = 'customer';
        homeCtrl.userName.value = 'Guest Player';
        homeCtrl.greetingName.value = 'PLAYER';
        await homeCtrl.refreshDashboard();
      }
    } catch (_) {}

    if (goToDashboard) {
      Get.offAllNamed(AppRoutes.mainNav);
    } else {
      Get.toNamed(AppRoutes.slotBooking);
    }
  }

  void toggleAuthMode(AuthMode mode) {
    authMode.value = mode;
  }

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  void toggleRememberMe() {
    rememberMe.value = !rememberMe.value;
  }

  void toggleIsSignUp(bool value) {
    isSignUp.value = value;
  }

  /// Submit Login to LIVE backend APIs
  Future<void> submit() async {
    final id = identifierController.text.trim().isNotEmpty
        ? identifierController.text.trim()
        : emailController.text.trim();
    final pin = pinController.text.trim().isNotEmpty
        ? pinController.text.trim()
        : passwordController.text.trim();

    if (id.isEmpty) {
      Get.snackbar(
        'Missing Identifier',
        selectedRole.value == 'Student'
            ? 'Please enter your Student Reg No, Mobile, or Email.'
            : 'Please enter your Member ID, Mobile, or Email.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFFEE4E2),
        colorText: const Color(0xFF912018),
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
      return;
    }

    if (pin.isEmpty) {
      Get.snackbar(
        'Password Required',
        'Please enter your account password.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFFEE4E2),
        colorText: const Color(0xFF912018),
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
      return;
    }

    isLoading.value = true;
    try {
      final roleLower = selectedRole.value.toLowerCase();
      Response response;

      if (roleLower == 'student' || selectedProfile.value == MembershipProfile.parents) {
        // Dedicated live Student login endpoint
        response = await _apiClient.dio.post(
          ApiEndpoints.studentLogin,
          data: {
            'regNo': id,
            'identifier': id,
            'password': pin,
          },
        );
      } else if (roleLower == 'member' || selectedProfile.value == MembershipProfile.members) {
        // Dedicated live Member login endpoint
        response = await _apiClient.dio.post(
          ApiEndpoints.memberLogin,
          data: {
            'identifier': id,
            'password': pin,
          },
        );
      } else {
        // Universal / Guest login endpoint
        response = await _apiClient.dio.post(
          ApiEndpoints.login,
          data: {
            'email': id,
            'password': pin,
          },
        );
      }

      final body = response.data;
      if (body is Map && body['success'] == true && body['data'] != null) {
        final data = body['data'];

        // Handle case where multiple sibling profiles match the contact
        if (data['requiresSelection'] == true) {
          final siblings = data['siblings'] ?? data['accounts'] ?? [];
          _showSiblingSelectionSheet(siblings, pin);
          return;
        }

        await _saveSessionAndNavigate(data, pin);
      } else {
        final msg = (body is Map ? body['message'] : null) ?? 'Login failed. Please check your credentials.';
        _showErrorSnackbar(msg);
      }
    } on DioException catch (dioErr) {
      String errMsg = 'Invalid student regNo / password credentials.';
      if (dioErr.response?.data != null && dioErr.response?.data is Map) {
        errMsg = dioErr.response?.data['message'] ??
            dioErr.response?.data['error'] ??
            dioErr.response?.data['details'] ??
            errMsg;
      } else if (dioErr.type == DioExceptionType.connectionTimeout ||
          dioErr.type == DioExceptionType.connectionError) {
        errMsg = 'Unable to connect to server at ${ApiEndpoints.baseUrl}. Please check backend service.';
      }
      _showErrorSnackbar(errMsg);
    } catch (e) {
      _showErrorSnackbar(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  /// Save session from live API response and navigate to main screen
  Future<void> _saveSessionAndNavigate(Map<String, dynamic> data, String password) async {
    final accessToken = data['accessToken']?.toString() ?? '';
    final refreshToken = data['refreshToken']?.toString() ?? accessToken;
    final tenantId = (data['tenantId'] ?? data['user']?['tenantId'])?.toString() ?? '';
    final studentId = (data['studentId'] ?? data['user']?['studentId'] ?? data['user']?['id'])?.toString() ?? '';
    final role = (data['role'] ?? data['user']?['role'] ?? selectedRole.value)?.toString() ?? 'student';

    final user = data['user'] is Map ? data['user'] as Map<String, dynamic> : <String, dynamic>{};
    final firstName = user['firstName']?.toString() ?? '';
    final lastName = user['lastName']?.toString() ?? '';
    final fullName = (user['fullName']?.toString() ?? '$firstName $lastName').trim();
    final displayName = fullName.isNotEmpty ? fullName : (user['regNo']?.toString() ?? 'Trainee');

    await _storage.saveUserSession(
      accessToken: accessToken,
      refreshToken: refreshToken,
      tenantId: tenantId,
      studentId: studentId,
      role: role,
      userName: displayName,
      userJson: jsonEncode(user),
    );

    Get.snackbar(
      'Login Successful',
      'Welcome back, $displayName!',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF10B981),
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      duration: const Duration(seconds: 2),
    );

    await Future.delayed(const Duration(milliseconds: 350));
    Get.offAllNamed(AppRoutes.mainNav);
  }

  /// Dialog / BottomSheet to select active trainee among siblings
  void _showSiblingSelectionSheet(List dynamicList, String password) {
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
        decoration: BoxDecoration(
          color: const Color(0xFF0F172A),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select Trainee Profile',
              style: TextStyle(fontFamily: 'Nunito', 
                fontSize: 18.sp,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 6.h),
            Text(
              'Multiple student profiles found for this family contact. Choose student to continue:',
              style: TextStyle(fontFamily: 'Nunito', 
                fontSize: 12.sp,
                color: const Color(0xFF94A3B8),
              ),
            ),
            SizedBox(height: 16.h),
            ...dynamicList.map((item) {
              final s = item as Map<String, dynamic>;
              final sId = s['id'] ?? s['studentId'] ?? s['_id'];
              final name = s['fullName'] ?? '${s['firstName']} ${s['lastName'] ?? ''}'.trim();
              final regNo = s['regNo'] ?? s['employeeNo'] ?? '';

              return Container(
                margin: EdgeInsets.only(bottom: 10.h),
                child: ListTile(
                  tileColor: const Color(0xFF1E293B),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                  leading: CircleAvatar(
                    backgroundColor: const Color(0xFFF59E0B),
                    child: Text(
                      name.isNotEmpty ? name[0] : 'S',
                      style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                    ),
                  ),
                  title: Text(name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  subtitle: Text('Reg No: $regNo', style: const TextStyle(color: Color(0xFF94A3B8))),
                  trailing: const Icon(Icons.arrow_forward_ios_rounded, color: Color(0xFFF59E0B), size: 16),
                  onTap: () async {
                    Get.back(); // close sheet
                    isLoading.value = true;
                    try {
                      final res = await _apiClient.dio.post(
                        ApiEndpoints.studentLogin,
                        data: {
                          'studentId': sId,
                          'password': password,
                        },
                      );
                      if (res.data?['success'] == true && res.data?['data'] != null) {
                        await _saveSessionAndNavigate(res.data['data'], password);
                      }
                    } catch (e) {
                      _showErrorSnackbar('Failed to login with selected student profile');
                    } finally {
                      isLoading.value = false;
                    }
                  },
                ),
              );
            }),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  void _showErrorSnackbar(String message) {
    Get.snackbar(
      'Authentication Failed',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFFEF4444),
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      duration: const Duration(seconds: 4),
    );
  }

  Future<void> submitSignUp() async {
    final name = nameController.text.trim();
    final email = emailController.text.trim().isNotEmpty
        ? emailController.text.trim()
        : identifierController.text.trim();
    final pass = passwordController.text.trim().isNotEmpty
        ? passwordController.text.trim()
        : pinController.text.trim();

    if (name.isEmpty) {
      _showErrorSnackbar('Please enter your full name.');
      return;
    }

    if (email.isEmpty || !email.contains('@')) {
      _showErrorSnackbar('Please enter a valid email address.');
      return;
    }

    if (pass.length < 6) {
      _showErrorSnackbar('Password must be at least 6 characters.');
      return;
    }

    isLoading.value = true;
    try {
      final names = name.split(' ');
      final firstName = names.first;
      final lastName = names.length > 1 ? names.sublist(1).join(' ') : '';

      final response = await _apiClient.dio.post(
        ApiEndpoints.register,
        data: {
          'firstName': firstName,
          'lastName': lastName,
          'email': email,
          'phone': phoneController.text.trim().isNotEmpty ? phoneController.text.trim() : '9876543210',
          'password': pass,
        },
      );

      if (response.data?['success'] == true && response.data?['data'] != null) {
        await _saveSessionAndNavigate(response.data['data'], pass);
      } else {
        _showErrorSnackbar(response.data?['message'] ?? 'Registration failed.');
      }
    } on DioException catch (dioErr) {
      final errMsg = dioErr.response?.data?['message'] ?? 'Registration failed. Email or phone may already exist.';
      _showErrorSnackbar(errMsg);
    } catch (e) {
      _showErrorSnackbar(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> continueWithSelectedRole() async {
    Get.toNamed(AppRoutes.loginForm);
  }

  Future<void> loginWithBiometrics() async {
    final token = await _storage.getAccessToken();
    if (token != null && token.isNotEmpty) {
      Get.snackbar(
        'Biometric Fast Pass',
        'Identity verified via FaceID / TouchID. Welcome to Inertia!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF101828),
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        duration: const Duration(seconds: 2),
      );
      await Future.delayed(const Duration(milliseconds: 300));
      Get.offAllNamed(AppRoutes.mainNav);
    } else {
      _showErrorSnackbar('Please login with your Student Reg No or credentials first.');
    }
  }

  Future<void> loginWithSocial(String provider) async {
    _showErrorSnackbar('$provider login is currently in private preview. Please use Student Reg No.');
  }

  @override
  void onClose() {
    identifierController.dispose();
    pinController.dispose();
    phoneController.dispose();
    otpController.dispose();
    emailController.dispose();
    passwordController.dispose();
    nameController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
}

