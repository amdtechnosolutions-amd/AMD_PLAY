import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/storage/storage_service.dart';
import '../models/student_evaluation_model.dart';

/// Service interfacing live Coach modules & Student Evaluation endpoints:
/// - GET /api/v1/coaching/batches
/// - GET /api/v1/coaching/evaluations
/// - GET /api/v1/coaching/evaluations/student/:id
/// - GET /api/v1/coaching/evaluations/batch/:id
/// - POST /api/v1/coaching/evaluations
class CoachEvaluationService {
  final ApiClient _apiClient =
      Get.isRegistered<ApiClient>() ? Get.find<ApiClient>() : ApiClient();
  final StorageService _storage =
      Get.isRegistered<StorageService>() ? Get.find<StorageService>() : Get.put(StorageService());

  Future<String?> _getToken() async {
    final token = await _storage.getAccessToken();
    return token;
  }

  /// Fetch coaching batches assigned to the coach
  Future<List<Map<String, dynamic>>> getCoachBatches() async {
    try {
      final token = await _getToken();
      final response = await _apiClient.dio.get(
        ApiEndpoints.coachingBatches,
        options: Options(
          headers: token != null ? {'Authorization': 'Bearer $token'} : null,
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        final body = response.data;
        final list = body is Map && body['data'] is List
            ? body['data'] as List
            : (body is List ? body : []);
        return list.map((e) => Map<String, dynamic>.from(e as Map)).toList();
      }
    } catch (e) {
      debugPrint('[CoachEvaluationService] getCoachBatches error: $e');
    }
    return [];
  }

  /// Fetch students enrolled specifically in a batch
  Future<List<Map<String, dynamic>>> getBatchStudents(String batchId) async {
    if (batchId.isEmpty) return [];
    try {
      final token = await _getToken();
      final headers = token != null ? {'Authorization': 'Bearer $token'} : null;

      // 1. Query /students?batchId=:batchId
      try {
        final res = await _apiClient.dio.get(
          '/students',
          queryParameters: {'batchId': batchId, 'limit': 100},
          options: Options(headers: headers),
        );
        if (res.statusCode == 200 && res.data != null) {
          final body = res.data;
          final list = body is Map && body['data'] is List
              ? body['data'] as List
              : (body is List ? body : []);
          if (list.isNotEmpty) {
            return list.map((e) {
              final m = Map<String, dynamic>.from(e as Map);
              final firstName = m['firstName']?.toString() ?? '';
              final lastName = m['lastName']?.toString() ?? '';
              final name = (m['name'] ?? m['fullName'] ?? '$firstName $lastName').toString().trim();
              final regNo = (m['employeeNo'] ?? m['regNo'] ?? m['phone'] ?? m['_id'])?.toString() ?? '';
              return {
                '_id': m['_id']?.toString() ?? '',
                'studentId': m['_id']?.toString() ?? '',
                'name': name.isNotEmpty ? name : 'Trainee',
                'regNo': regNo,
                'email': m['email']?.toString() ?? '',
                'phone': m['phone']?.toString() ?? '',
              };
            }).toList();
          }
        }
      } catch (e) {
        debugPrint('[CoachEvaluationService] /students query notice: $e');
      }

      // 2. Fallback: Query /coaching/batches/:id
      final batchRes = await _apiClient.dio.get(
        '${ApiEndpoints.coachingBatches}/$batchId',
        options: Options(headers: headers),
      );
      if (batchRes.statusCode == 200 && batchRes.data != null) {
        final body = batchRes.data;
        final data = body is Map && body['data'] != null ? body['data'] : body;
        if (data is Map && data['students'] is List) {
          return (data['students'] as List).map((e) {
            final m = Map<String, dynamic>.from(e as Map);
            return {
              '_id': (m['_id'] ?? m['studentId'])?.toString() ?? '',
              'studentId': (m['_id'] ?? m['studentId'])?.toString() ?? '',
              'name': (m['name'] ?? m['fullName'] ?? 'Trainee').toString(),
              'regNo': (m['regNo'] ?? m['employeeNo'] ?? m['phone'] ?? m['_id'])?.toString() ?? '',
              'email': m['email']?.toString() ?? '',
              'phone': m['phone']?.toString() ?? '',
            };
          }).toList();
        }
      }
    } catch (e) {
      debugPrint('[CoachEvaluationService] getBatchStudents error: $e');
    }
    return [];
  }

  /// Fetch all student evaluations accessible to coach
  Future<List<Map<String, dynamic>>> getCoachingEvaluations() async {
    try {
      final token = await _getToken();
      if (token == null || token.isEmpty) {
        throw Exception('Please sign in to your coach account to view evaluations.');
      }

      final response = await _apiClient.dio.get(
        ApiEndpoints.coachEvaluations,
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        final body = response.data;
        final list = body is Map && body['data'] is List
            ? body['data'] as List
            : (body is List ? body : []);
        return list.map((e) => Map<String, dynamic>.from(e as Map)).toList();
      }
    } catch (e) {
      debugPrint('[CoachEvaluationService] getCoachingEvaluations error: $e');
      rethrow;
    }
    return [];
  }

  /// Fetch evaluation report for a specific student ID
  Future<StudentEvaluationReport?> getStudentEvaluation(String studentId) async {
    try {
      final token = await _getToken();
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
        }
      }
    } catch (e) {
      debugPrint('[CoachEvaluationService] getStudentEvaluation error: $e');
    }
    return null;
  }

  /// Create and submit a new student evaluation
  Future<bool> createEvaluation({
    required String studentId,
    String? batchId,
    required double physicalScore,
    required double mentalScore,
    required double skillScore,
    required double attitudeScore,
    required String remarks,
  }) async {
    try {
      final token = await _getToken();
      if (token == null || token.isEmpty) {
        throw Exception('Authentication required. Please sign in as coach.');
      }

      final payload = {
        'studentId': studentId,
        if (batchId != null && batchId.isNotEmpty) 'batchId': batchId,
        'physicalScore': physicalScore,
        'mentalScore': mentalScore,
        'skillScore': skillScore,
        'attitudeScore': attitudeScore,
        'coachRemarks': remarks,
        'remarks': remarks,
        'evaluationDate': DateTime.now().toIso8601String(),
      };

      final response = await _apiClient.dio.post(
        ApiEndpoints.coachEvaluations,
        data: payload,
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      debugPrint('[CoachEvaluationService] createEvaluation error: $e');
      rethrow;
    }
  }
}

