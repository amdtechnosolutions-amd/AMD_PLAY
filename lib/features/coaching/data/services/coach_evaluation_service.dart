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
      final url = '${ApiEndpoints.baseUrl}${ApiEndpoints.coachingBatches}';
      debugPrint('[CoachEvaluationService] FETCHING BATCHES: $url');
      final response = await _apiClient.dio.get(
        ApiEndpoints.coachingBatches,
        options: Options(
          headers: token != null ? {'Authorization': 'Bearer $token'} : null,
        ),
      );

      debugPrint('[CoachEvaluationService] BATCHES RESPONSE: status=${response.statusCode}');
      if (response.statusCode == 200 && response.data != null) {
        final body = response.data;
        final list = body is Map && body['data'] is List
            ? body['data'] as List
            : (body is List ? body : []);
        final parsed = list.map((e) => Map<String, dynamic>.from(e as Map)).toList();
        debugPrint('[CoachEvaluationService] Parsed ${parsed.length} coaching batches');
        return parsed;
      }
    } catch (e) {
      debugPrint('[CoachEvaluationService] getCoachBatches error: $e');
    }
    return [];
  }

  /// Fetch students enrolled specifically in a batch
  /// Option 1: GET /api/v1/coaching/batches/:batchId/students/dropdown
  Future<List<Map<String, dynamic>>> getBatchStudents(String batchId, {String? search}) async {
    if (batchId.isEmpty) return [];
    try {
      final token = await _getToken();
      final headers = token != null ? {'Authorization': 'Bearer $token'} : null;
      final queryParams = <String, dynamic>{
        'status': 'active',
        if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
      };

      // 1. Primary endpoint: /coaching/batches/:batchId/students/dropdown
      try {
        final res = await _apiClient.dio.get(
          ApiEndpoints.batchStudentsDropdown(batchId),
          queryParameters: queryParams,
          options: Options(headers: headers),
        );
        if (res.statusCode == 200 && res.data != null) {
          final body = res.data;
          final list = body is Map && body['data'] is List
              ? body['data'] as List
              : (body is List ? body : []);
          if (list.isNotEmpty) {
            return list.map((e) => Map<String, dynamic>.from(e as Map)).toList();
          }
        }
      } catch (e) {
        debugPrint('[CoachEvaluationService] /batches/:id/students/dropdown notice: $e');
      }

      // 2. Alias: /coaching/batches/:batchId/students
      try {
        final res = await _apiClient.dio.get(
          '${ApiEndpoints.coachingBatches}/$batchId/students',
          queryParameters: queryParams,
          options: Options(headers: headers),
        );
        if (res.statusCode == 200 && res.data != null) {
          final body = res.data;
          final list = body is Map && body['data'] is List
              ? body['data'] as List
              : (body is List ? body : []);
          if (list.isNotEmpty) {
            return list.map((e) => Map<String, dynamic>.from(e as Map)).toList();
          }
        }
      } catch (e) {
        debugPrint('[CoachEvaluationService] /batches/:id/students notice: $e');
      }

      // 3. Option 3: /students/dropdown?batchId=:batchId
      try {
        final res = await _apiClient.dio.get(
          ApiEndpoints.studentsDropdown,
          queryParameters: {'batchId': batchId, ...queryParams},
          options: Options(headers: headers),
        );
        if (res.statusCode == 200 && res.data != null) {
          final body = res.data;
          final list = body is Map && body['data'] is List
              ? body['data'] as List
              : (body is List ? body : []);
          if (list.isNotEmpty) {
            return list.map((e) => Map<String, dynamic>.from(e as Map)).toList();
          }
        }
      } catch (e) {
        debugPrint('[CoachEvaluationService] /students/dropdown notice: $e');
      }

      // 4. Fallback: Query /coaching/batches/:id
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
            final name = (m['name'] ?? m['fullName'] ?? 'Trainee').toString();
            final regNo = (m['regNo'] ?? m['employeeNo'] ?? m['phone'] ?? m['_id'])?.toString() ?? '';
            return {
              'id': (m['_id'] ?? m['studentId'] ?? m['id'])?.toString() ?? '',
              'value': (m['_id'] ?? m['studentId'] ?? m['id'])?.toString() ?? '',
              'label': regNo.isNotEmpty ? '$name ($regNo)' : name,
              'name': name,
              'employeeNo': regNo,
              'regNo': regNo,
              'email': m['email']?.toString() ?? '',
              'phone': m['phone']?.toString() ?? '',
              'status': m['status']?.toString() ?? 'active',
            };
          }).toList();
        }
      }
    } catch (e) {
      debugPrint('[CoachEvaluationService] getBatchStudents error: $e');
    }
    return [];
  }

  /// Option 2: Fetch all batches and enrolled students in one single request
  Future<List<Map<String, dynamic>>> getBatchWiseStudents({String? search, String? sportId}) async {
    try {
      final token = await _getToken();
      final headers = token != null ? {'Authorization': 'Bearer $token'} : null;
      final queryParams = <String, dynamic>{
        if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
        if (sportId != null && sportId.isNotEmpty) 'sportId': sportId,
      };

      final res = await _apiClient.dio.get(
        ApiEndpoints.batchWiseStudents,
        queryParameters: queryParams,
        options: Options(headers: headers),
      );
      if (res.statusCode == 200 && res.data != null) {
        final body = res.data;
        final list = body is Map && body['data'] is List
            ? body['data'] as List
            : (body is List ? body : []);
        return list.map((e) => Map<String, dynamic>.from(e as Map)).toList();
      }
    } catch (e) {
      debugPrint('[CoachEvaluationService] getBatchWiseStudents error: $e');
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

      final url = '${ApiEndpoints.baseUrl}${ApiEndpoints.coachEvaluations}';
      debugPrint('====================================================');
      debugPrint('[CoachEvaluationService] FETCHING LIVE EVALUATIONS:');
      debugPrint('URL: $url');
      debugPrint('Authorization: Bearer ${token.substring(0, token.length > 12 ? 12 : token.length)}...');
      debugPrint('====================================================');

      final response = await _apiClient.dio.get(
        ApiEndpoints.coachEvaluations,
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      debugPrint('====================================================');
      debugPrint('[CoachEvaluationService] EVALUATIONS API RESPONSE:');
      debugPrint('Status Code: ${response.statusCode}');
      debugPrint('Response Body: ${response.data}');
      debugPrint('====================================================');

      if (response.statusCode == 200 && response.data != null) {
        final body = response.data;
        final list = body is Map && body['data'] is List
            ? body['data'] as List
            : (body is Map && body['evaluations'] is List
                ? body['evaluations'] as List
                : (body is List ? body : []));

        final result = list.map((e) => Map<String, dynamic>.from(e as Map)).toList();
        debugPrint('[CoachEvaluationService] Successfully parsed ${result.length} student evaluations');
        return result;
      }
    } catch (e) {
      debugPrint('====================================================');
      debugPrint('[CoachEvaluationService] GET COACH EVALUATIONS ERROR:');
      if (e is DioException) {
        debugPrint('DioException Status: ${e.response?.statusCode}');
        debugPrint('DioException Data: ${e.response?.data}');
        debugPrint('DioException Message: ${e.message}');
      } else {
        debugPrint('Error: $e');
      }
      debugPrint('====================================================');
      rethrow;
    }
    return [];
  }

  /// Fetch evaluation report for a specific student ID
  Future<StudentEvaluationReport?> getStudentEvaluation(String studentId) async {
    try {
      final token = await _getToken();
      final url = '${ApiEndpoints.baseUrl}${ApiEndpoints.coachStudentEvaluations}/$studentId';
      debugPrint('====================================================');
      debugPrint('[CoachEvaluationService] FETCHING STUDENT EVALUATION:');
      debugPrint('URL: $url');
      debugPrint('====================================================');

      final response = await _apiClient.dio.get(
        '${ApiEndpoints.coachStudentEvaluations}/$studentId',
        options: Options(
          headers: token != null ? {'Authorization': 'Bearer $token'} : null,
        ),
      );

      debugPrint('====================================================');
      debugPrint('[CoachEvaluationService] STUDENT EVALUATION RESPONSE:');
      debugPrint('Status Code: ${response.statusCode}');
      debugPrint('Response Body: ${response.data}');
      debugPrint('====================================================');

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

      debugPrint('====================================================');
      debugPrint('[CoachEvaluationService] SUBMITTING EVALUATION:');
      debugPrint('URL: ${ApiEndpoints.coachEvaluations}');
      debugPrint('Payload: $payload');
      debugPrint('====================================================');

      final response = await _apiClient.dio.post(
        ApiEndpoints.coachEvaluations,
        data: payload,
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      debugPrint('====================================================');
      debugPrint('[CoachEvaluationService] EVALUATION RESPONSE:');
      debugPrint('Status Code: ${response.statusCode}');
      debugPrint('Response Body: ${response.data}');
      debugPrint('====================================================');

      final isSuccess = response.statusCode == 200 || response.statusCode == 201;
      if (!isSuccess) {
        debugPrint('[CoachEvaluationService] Non-success response: ${response.data}');
      }
      return isSuccess;
    } catch (e) {
      debugPrint('====================================================');
      debugPrint('[CoachEvaluationService] EVALUATION ERROR:');
      if (e is DioException) {
        debugPrint('DioException Status: ${e.response?.statusCode}');
        debugPrint('DioException Response Data: ${e.response?.data}');
        debugPrint('DioException Message: ${e.message}');
        debugPrint('====================================================');
        final serverMsg = e.response?.data is Map
            ? (e.response?.data['message'] ?? e.response?.data['error'])?.toString()
            : null;
        if (serverMsg != null && serverMsg.isNotEmpty) {
          throw Exception(serverMsg);
        }
      } else {
        debugPrint('Error: $e');
        debugPrint('====================================================');
      }
      rethrow;
    }
  }
}

