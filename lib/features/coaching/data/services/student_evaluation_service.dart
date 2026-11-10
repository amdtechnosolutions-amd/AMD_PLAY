import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Response;
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/storage/storage_service.dart';
import '../models/student_evaluation_model.dart';

/// Service interfacing live backend endpoints:
/// - GET /api/v1/students/my/evaluations
/// - GET /api/v1/students/my/evaluations/latest
class StudentEvaluationService {
  final ApiClient _apiClient =
      Get.isRegistered<ApiClient>() ? Get.find<ApiClient>() : ApiClient();
  final StorageService _storage =
      Get.isRegistered<StorageService>() ? Get.find<StorageService>() : Get.put(StorageService());

  /// Fetch complete Student Performance Report
  Future<StudentEvaluationReport?> getMyEvaluations() async {
    try {
      final token = await _storage.getAccessToken();
      if (token == null || token.trim().isEmpty) {
        throw Exception('Authentication required. Please sign in to view coaching report.');
      }

      final url = '${ApiEndpoints.baseUrl}${ApiEndpoints.studentEvaluations}';
      debugPrint('====================================================');
      debugPrint('[StudentEvaluationService] FETCHING MY EVALUATIONS:');
      debugPrint('URL: $url');
      debugPrint('====================================================');

      Response? response;
      try {
        response = await _apiClient.dio.get(
          ApiEndpoints.studentEvaluations,
          options: Options(headers: {'Authorization': 'Bearer $token'}),
        );
      } catch (dioErr) {
        debugPrint('[StudentEvaluationService] Primary /students/my/evaluations error: $dioErr');
      }

      // If primary endpoint didn't respond with 200, try /coaching/evaluations
      if (response == null || response.statusCode != 200) {
        final fallbackUrl = '${ApiEndpoints.baseUrl}${ApiEndpoints.coachEvaluations}';
        debugPrint('[StudentEvaluationService] Trying fallback endpoint: $fallbackUrl');
        try {
          response = await _apiClient.dio.get(
            ApiEndpoints.coachEvaluations,
            options: Options(headers: {'Authorization': 'Bearer $token'}),
          );
        } catch (e) {
          debugPrint('[StudentEvaluationService] Fallback error: $e');
        }
      }

      if (response != null && response.statusCode == 200 && response.data != null) {
        debugPrint('====================================================');
        debugPrint('[StudentEvaluationService] LIVE EVALUATIONS RESPONSE:');
        debugPrint('Status Code: ${response.statusCode}');
        debugPrint('Response Body: ${response.data}');
        debugPrint('====================================================');

        final body = response.data;
        final rawData = body is Map && body['data'] != null ? body['data'] : body;

        if (rawData is Map<String, dynamic>) {
          return StudentEvaluationReport.fromJson(rawData);
        } else if (rawData is List) {
          if (rawData.isNotEmpty && rawData.first is Map) {
            return StudentEvaluationReport.fromJson(Map<String, dynamic>.from(rawData.first as Map));
          } else {
            return StudentEvaluationReport.initialEmpty();
          }
        }
      }

      // Final fallback to latest evaluation
      return await getLatestEvaluation();
    } catch (e) {
      debugPrint('[StudentEvaluationService] getMyEvaluations error: $e');
      rethrow;
    }
  }

  /// Fetch Latest Scorecard Only
  Future<StudentEvaluationReport?> getLatestEvaluation() async {
    try {
      final token = await _storage.getAccessToken();
      if (token == null || token.trim().isEmpty) return null;

      final url = '${ApiEndpoints.baseUrl}${ApiEndpoints.studentLatestEvaluation}';
      debugPrint('[StudentEvaluationService] FETCHING LATEST EVALUATION: $url');

      final response = await _apiClient.dio.get(
        ApiEndpoints.studentLatestEvaluation,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      debugPrint('[StudentEvaluationService] LATEST EVALUATION STATUS: ${response.statusCode}');
      if (response.statusCode == 200 && response.data != null) {
        final body = response.data;
        final rawData = body is Map && body['data'] != null ? body['data'] : body;

        if (rawData is Map<String, dynamic>) {
          return StudentEvaluationReport.fromJson(rawData);
        } else if (rawData is List) {
          if (rawData.isNotEmpty && rawData.first is Map) {
            return StudentEvaluationReport.fromJson(Map<String, dynamic>.from(rawData.first as Map));
          } else {
            return StudentEvaluationReport.initialEmpty();
          }
        }
      }
    } catch (e) {
      debugPrint('[StudentEvaluationService] /students/my/evaluations/latest error: $e');
    }
    return null;
  }

  /// Fetch evaluation for a specific student (used by coaches)
  Future<StudentEvaluationReport?> getEvaluationForStudent(String studentId) async {
    try {
      final token = await _storage.getAccessToken();
      final response = await _apiClient.dio.get(
        '${ApiEndpoints.coachStudentEvaluations}/$studentId',
        options: Options(
          headers: token != null ? {'Authorization': 'Bearer $token'} : null,
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        final body = response.data;
        final rawData = body is Map && body['data'] != null ? body['data'] : body;
        if (rawData is Map<String, dynamic>) {
          return StudentEvaluationReport.fromJson(rawData);
        } else if (rawData is List) {
          if (rawData.isNotEmpty && rawData.first is Map) {
            return StudentEvaluationReport.fromJson(Map<String, dynamic>.from(rawData.first as Map));
          } else {
            return StudentEvaluationReport.initialEmpty();
          }
        }
      }
    } catch (e) {
      debugPrint('[StudentEvaluationService] getEvaluationForStudent error: $e');
    }
    return null;
  }
}

