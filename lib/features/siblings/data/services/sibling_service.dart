import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart' hide Response;
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/storage/storage_service.dart';
import '../models/sibling_models.dart';

/// Client-side Service interfacing Student & Family Sibling GET endpoints:
/// - GET /api/v1/students/my/siblings (My Siblings - Mobile Switcher)
/// - GET /api/v1/students/:id/siblings (Get Sibling Records for Student)
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

  /// Fetch Sibling Records for a Specific Student
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
      return const StudentSiblingDetailsModel(hasSiblings: false, siblingCount: 0);
    }
  }

  /// Fetch My Siblings (Mobile App Profile Switcher)
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
}
