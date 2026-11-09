import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
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

      final response = await _apiClient.dio.get(
        ApiEndpoints.studentEvaluations,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
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
    } on DioException catch (dioErr) {
      final msg = dioErr.response?.data is Map
          ? (dioErr.response?.data['message'] ?? dioErr.response?.data['error'])
          : null;
      debugPrint('[StudentEvaluationService] /students/my/evaluations error: $msg');
      if (dioErr.response?.statusCode == 404 || dioErr.response?.statusCode == 401) {
        // Fall back to latest evaluation if list is not found
        return await getLatestEvaluation();
      }
      rethrow;
    } catch (e) {
      debugPrint('[StudentEvaluationService] error: $e');
      rethrow;
    }
    return null;
  }

  /// Fetch Latest Scorecard Only
  Future<StudentEvaluationReport?> getLatestEvaluation() async {
    try {
      final token = await _storage.getAccessToken();
      if (token == null || token.trim().isEmpty) return null;

      final response = await _apiClient.dio.get(
        ApiEndpoints.studentLatestEvaluation,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
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

