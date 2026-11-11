import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart' hide Response;
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/storage/storage_service.dart';
import '../models/sibling_models.dart';

/// Service integrating the complete Sibling Family APIs:
/// 1. POST   /api/v1/students/siblings          (Manual Link Existing Siblings)
/// 2. GET    /api/v1/students/siblings          (List All Sibling Families)
/// 3. GET    /api/v1/students/:id/siblings      (Get Sibling Records for Student)
/// 4. GET    /api/v1/students/my/siblings       (My Siblings - Mobile Switcher)
/// 5. PATCH  /api/v1/students/siblings/:id      (Assign / Update Sibling Phone)
/// 6. DELETE /api/v1/students/siblings/:id      (Unlink Student from Sibling Group)
/// 7. POST   /api/v1/students                   (Auto-Link on Registration)
class SiblingService {
  final ApiClient _apiClient =
      Get.isRegistered<ApiClient>() ? Get.find<ApiClient>() : ApiClient();
  final StorageService _storage =
      Get.isRegistered<StorageService>() ? Get.find<StorageService>() : Get.put(StorageService());

  Future<Map<String, String>?> _authHeaders() async {
    final token = await _storage.getAccessToken();
    if (token == null || token.trim().isEmpty) return null;
    return {'Authorization': 'Bearer $token'};
  }

  String _extractDioError(Object e, String fallback) {
    if (e is DioException) {
      final data = e.response?.data;
      if (data is Map) {
        final nestedError = data['error'] is Map ? data['error']['message'] : data['error'];
        final msg = (nestedError ?? data['message'])?.toString().trim();
        if (msg != null && msg.isNotEmpty) return msg;
      }
      if (e.message != null && e.message!.isNotEmpty) return e.message!;
    }
    return fallback;
  }

  /// 1. Manual Link Existing Students as Siblings
  /// POST /api/v1/students/siblings
  Future<StudentSiblingDetailsModel> linkExistingSiblings({
    required String masterStudentId,
    required String newStudentId,
  }) async {
    try {
      final headers = await _authHeaders();
      final payload = {
        'masterStudentId': masterStudentId,
        'newStudentId': newStudentId,
      };
      debugPrint('[SiblingService] POST ${ApiEndpoints.siblings} -> $payload');
      final response = await _apiClient.dio.post(
        ApiEndpoints.siblings,
        data: payload,
        options: Options(headers: headers),
      );
      debugPrint('[SiblingService] Link response (${response.statusCode}): ${response.data}');

      final body = response.data;
      final data = body is Map && body['data'] is Map
          ? Map<String, dynamic>.from(body['data'] as Map)
          : <String, dynamic>{};
      return StudentSiblingDetailsModel.fromJson(data);
    } catch (e) {
      debugPrint('[SiblingService] linkExistingSiblings error: $e');
      throw Exception(_extractDioError(e, 'Unable to link students as siblings.'));
    }
  }

  /// 2. List All Sibling Families in Academy
  /// GET /api/v1/students/siblings
  Future<({List<SiblingFamilyGroupModel> families, int total, int totalPages})> listSiblingFamilies({
    String? search,
    String? branchId,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final headers = await _authHeaders();
      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
        if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
        if (branchId != null && branchId.trim().isNotEmpty) 'branchId': branchId.trim(),
      };

      debugPrint('[SiblingService] GET ${ApiEndpoints.siblings} query=$queryParams');
      final response = await _apiClient.dio.get(
        ApiEndpoints.siblings,
        queryParameters: queryParams,
        options: Options(headers: headers),
      );
      debugPrint('[SiblingService] Families response (${response.statusCode}): ${response.data}');

      final body = response.data;
      final rawList = body is Map && body['data'] is List
          ? body['data'] as List
          : (body is List ? body : []);
      final pagination = body is Map && body['pagination'] is Map
          ? body['pagination'] as Map
          : const {};

      final families = rawList
          .whereType<Map>()
          .map((item) => SiblingFamilyGroupModel.fromJson(Map<String, dynamic>.from(item)))
          .toList();

      return (
        families: families,
        total: (pagination['total'] as num?)?.toInt() ?? families.length,
        totalPages: (pagination['totalPages'] as num?)?.toInt() ?? 1,
      );
    } catch (e) {
      debugPrint('[SiblingService] listSiblingFamilies error: $e');
      throw Exception(_extractDioError(e, 'Failed to load sibling families.'));
    }
  }

  /// 3. Get Sibling Records for a Specific Student
  /// GET /api/v1/students/:id/siblings
  Future<StudentSiblingDetailsModel> getStudentSiblings(String studentId) async {
    try {
      final headers = await _authHeaders();
      final endpoint = ApiEndpoints.studentSiblingsById(studentId);
      debugPrint('[SiblingService] GET $endpoint');
      final response = await _apiClient.dio.get(
        endpoint,
        options: Options(headers: headers),
      );
      debugPrint('[SiblingService] Student siblings response (${response.statusCode}): ${response.data}');

      final body = response.data;
      final data = body is Map && body['data'] is Map
          ? Map<String, dynamic>.from(body['data'] as Map)
          : <String, dynamic>{};
      return StudentSiblingDetailsModel.fromJson(data);
    } catch (e) {
      debugPrint('[SiblingService] getStudentSiblings error: $e');
      throw Exception(_extractDioError(e, 'Failed to fetch student sibling details.'));
    }
  }

  /// 4. My Siblings (Mobile App Profile Switcher)
  /// GET /api/v1/students/my/siblings
  Future<List<SiblingStudentModel>> getMySiblings() async {
    try {
      final headers = await _authHeaders();
      debugPrint('[SiblingService] GET ${ApiEndpoints.studentSiblings}');
      final response = await _apiClient.dio.get(
        ApiEndpoints.studentSiblings,
        options: Options(headers: headers),
      );
      debugPrint('[SiblingService] My siblings response (${response.statusCode}): ${response.data}');

      final body = response.data;
      final rawList = body is Map && body['data'] is List
          ? body['data'] as List
          : (body is List ? body : []);

      return rawList
          .whereType<Map>()
          .map((item) => SiblingStudentModel.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    } catch (e) {
      debugPrint('[SiblingService] getMySiblings error: $e');
      return [];
    }
  }

  /// 5. Assign / Update Sibling Personal Mobile Number
  /// PATCH /api/v1/students/siblings/:id
  Future<StudentSiblingDetailsModel> updateSiblingPhone(
    String studentId, {
    required String phone,
    String? parentPhone,
    String? parentName,
  }) async {
    try {
      final headers = await _authHeaders();
      final payload = <String, dynamic>{
        'phone': phone.trim(),
        if (parentPhone != null && parentPhone.trim().isNotEmpty) 'parentPhone': parentPhone.trim(),
        if (parentName != null && parentName.trim().isNotEmpty) 'parentName': parentName.trim(),
      };

      final endpoint = ApiEndpoints.siblingById(studentId);
      debugPrint('[SiblingService] PATCH $endpoint -> $payload');
      final response = await _apiClient.dio.patch(
        endpoint,
        data: payload,
        options: Options(headers: headers),
      );
      debugPrint('[SiblingService] Update phone response (${response.statusCode}): ${response.data}');

      final body = response.data;
      final data = body is Map && body['data'] is Map
          ? Map<String, dynamic>.from(body['data'] as Map)
          : <String, dynamic>{};
      return StudentSiblingDetailsModel.fromJson(data);
    } catch (e) {
      debugPrint('[SiblingService] updateSiblingPhone error: $e');
      throw Exception(_extractDioError(e, 'Unable to update sibling phone number.'));
    }
  }

  /// 6. Unlink a Student from Sibling Group
  /// DELETE /api/v1/students/siblings/:id
  Future<bool> unlinkSibling(String studentId) async {
    try {
      final headers = await _authHeaders();
      final endpoint = ApiEndpoints.siblingById(studentId);
      debugPrint('[SiblingService] DELETE $endpoint');
      final response = await _apiClient.dio.delete(
        endpoint,
        options: Options(headers: headers),
      );
      debugPrint('[SiblingService] Unlink response (${response.statusCode}): ${response.data}');
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      debugPrint('[SiblingService] unlinkSibling error: $e');
      throw Exception(_extractDioError(e, 'Unable to unlink student from sibling group.'));
    }
  }

  /// 7. Register student with auto-sibling linking check
  /// POST /api/v1/students
  Future<Map<String, dynamic>> registerStudent(Map<String, dynamic> payload) async {
    try {
      final headers = await _authHeaders();
      debugPrint('[SiblingService] POST ${ApiEndpoints.students} -> $payload');
      final response = await _apiClient.dio.post(
        ApiEndpoints.students,
        data: payload,
        options: Options(headers: headers),
      );
      debugPrint('[SiblingService] Register student response (${response.statusCode}): ${response.data}');
      final body = response.data;
      return body is Map && body['data'] is Map
          ? Map<String, dynamic>.from(body['data'] as Map)
          : <String, dynamic>{};
    } catch (e) {
      debugPrint('[SiblingService] registerStudent error: $e');
      throw Exception(_extractDioError(e, 'Unable to register student.'));
    }
  }

  /// Helper: Fetch students dropdown for selecting Master & Sibling students to link
  /// GET /api/v1/students/dropdown
  Future<List<Map<String, dynamic>>> getStudentsDropdown({String? search}) async {
    try {
      final headers = await _authHeaders();
      final response = await _apiClient.dio.get(
        ApiEndpoints.studentsDropdown,
        queryParameters: {
          if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
        },
        options: Options(headers: headers),
      );
      final body = response.data;
      final list = body is Map && body['data'] is List
          ? body['data'] as List
          : (body is List ? body : []);
      return list.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
    } catch (e) {
      debugPrint('[SiblingService] getStudentsDropdown error: $e');
      return [];
    }
  }
}
