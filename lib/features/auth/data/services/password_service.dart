import 'package:dio/dio.dart';
import 'package:get/get.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/storage/storage_service.dart';

/// Password recovery and reset service interfacing live backend endpoints:
/// 1. POST /api/v1/auth/reset-password (Coach & Admin public forgot password)
/// 2. POST /api/v1/auth/student/reset-password (Student public forgot password by regNo or phone)
/// 3. POST /api/v1/auth/change-password (Authenticated password update for student/coach/admin)
/// 4. POST /api/v1/users/:id/reset-password (Direct reset for coach/staff by ID)
/// 5. POST /api/v1/students/:id/reset-password (Direct reset for student by ID)
class PasswordService {
  final ApiClient _apiClient =
      Get.isRegistered<ApiClient>() ? Get.find<ApiClient>() : ApiClient();
  final StorageService _storage =
      Get.isRegistered<StorageService>() ? Get.find<StorageService>() : Get.put(StorageService());

  /// 1. Reset Password for Coach & Admin (Public Forgot Password)
  Future<Map<String, dynamic>> resetCoachOrAdminPassword({
    required String email,
    required String newPassword,
    String tenantSlug = 'gba',
  }) async {
    try {
      final payload = {
        'email': email.trim(),
        'newPassword': newPassword.trim(),
        'tenantSlug': tenantSlug,
      };

      final response = await _apiClient.dio.post(
        ApiEndpoints.resetPassword,
        data: payload,
      );

      final data = response.data;
      if (data is Map<String, dynamic> && data['success'] == true) {
        return data;
      }
      throw Exception(data['message'] ?? 'Failed to reset password.');
    } on DioException catch (e) {
      final msg = e.response?.data is Map
          ? (e.response?.data['message'] ?? e.response?.data['error'])
          : null;
      throw Exception(msg ?? 'Unable to reset password. Please verify your email.');
    }
  }

  /// 2A. Reset Password for Students by Admission Reg No (Public Forgot Password)
  Future<Map<String, dynamic>> resetStudentPasswordByRegNo({
    required String regNo,
    required String newPassword,
    String tenantSlug = 'gba',
  }) async {
    try {
      final payload = {
        'regNo': regNo.trim(),
        'newPassword': newPassword.trim(),
        'tenantSlug': tenantSlug,
      };

      final response = await _apiClient.dio.post(
        ApiEndpoints.studentResetPassword,
        data: payload,
      );

      final data = response.data;
      if (data is Map<String, dynamic> && data['success'] == true) {
        return data;
      }
      throw Exception(data['message'] ?? 'Failed to reset student password.');
    } on DioException catch (e) {
      final msg = e.response?.data is Map
          ? (e.response?.data['message'] ?? e.response?.data['error'])
          : null;
      throw Exception(msg ?? 'Unable to reset password. Please check your registration number.');
    }
  }

  /// 2B. Reset Password for Students by Mobile Phone (Public Forgot Password)
  Future<Map<String, dynamic>> resetStudentPasswordByPhone({
    required String phone,
    required String newPassword,
    String? studentId,
  }) async {
    try {
      final payload = <String, dynamic>{
        'phone': phone.trim(),
        'newPassword': newPassword.trim(),
      };
      if (studentId != null && studentId.trim().isNotEmpty) {
        payload['studentId'] = studentId.trim();
      }

      final response = await _apiClient.dio.post(
        ApiEndpoints.studentResetPassword,
        data: payload,
      );

      final data = response.data;
      if (data is Map<String, dynamic> && data['success'] == true) {
        return data;
      }
      throw Exception(data['message'] ?? 'Failed to reset student password.');
    } on DioException catch (e) {
      final msg = e.response?.data is Map
          ? (e.response?.data['message'] ?? e.response?.data['error'])
          : null;
      throw Exception(msg ?? 'Unable to reset password. Please check your phone number.');
    }
  }

  /// 3. Change Password When Logged In (For Coach, Admin, or Student)
  Future<Map<String, dynamic>> changePasswordLoggedIn({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final token = await _storage.getAccessToken();
      if (token == null || token.trim().isEmpty) {
        throw Exception('You must be logged in to change your password.');
      }

      final payload = {
        'currentPassword': currentPassword.trim(),
        'newPassword': newPassword.trim(),
      };

      final response = await _apiClient.dio.post(
        ApiEndpoints.changePassword,
        data: payload,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      final data = response.data;
      if (data is Map<String, dynamic> && data['success'] == true) {
        return data;
      }
      throw Exception(data['message'] ?? 'Failed to change password.');
    } on DioException catch (e) {
      final msg = e.response?.data is Map
          ? (e.response?.data['message'] ?? e.response?.data['error'])
          : null;
      throw Exception(msg ?? 'Incorrect current password or invalid new password.');
    }
  }

  /// 4. Admin / Coach Direct Password Reset for User/Coach by ID
  Future<Map<String, dynamic>> directResetUserPassword({
    required String userId,
    required String newPassword,
  }) async {
    try {
      final token = await _storage.getAccessToken();
      final endpoint = ApiEndpoints.userDirectResetPassword(userId);

      final response = await _apiClient.dio.post(
        endpoint,
        data: {
          'newPassword': newPassword.trim(),
        },
        options: Options(
          headers: token != null ? {'Authorization': 'Bearer $token'} : null,
        ),
      );

      final data = response.data;
      if (data is Map<String, dynamic> && data['success'] == true) {
        return data;
      }
      throw Exception(data['message'] ?? 'Failed to reset user password.');
    } on DioException catch (e) {
      final msg = e.response?.data is Map
          ? (e.response?.data['message'] ?? e.response?.data['error'])
          : null;
      throw Exception(msg ?? 'Unable to reset user password.');
    }
  }

  /// 5. Admin / Coach Direct Password Reset for Student by ID
  Future<Map<String, dynamic>> directResetStudentPassword({
    required String studentId,
    required String newPassword,
  }) async {
    try {
      final token = await _storage.getAccessToken();
      final endpoint = ApiEndpoints.studentDirectResetPassword(studentId);

      final response = await _apiClient.dio.post(
        endpoint,
        data: {
          'newPassword': newPassword.trim(),
        },
        options: Options(
          headers: token != null ? {'Authorization': 'Bearer $token'} : null,
        ),
      );

      final data = response.data;
      if (data is Map<String, dynamic> && data['success'] == true) {
        return data;
      }
      throw Exception(data['message'] ?? 'Failed to reset student password.');
    } on DioException catch (e) {
      final msg = e.response?.data is Map
          ? (e.response?.data['message'] ?? e.response?.data['error'])
          : null;
      throw Exception(msg ?? 'Unable to reset student password.');
    }
  }
}
