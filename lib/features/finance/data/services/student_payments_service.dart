import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart' hide Response;
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/storage/storage_service.dart';
import '../models/student_payments_model.dart';

/// Service fetching personal & sibling payment records from:
/// GET /api/v1/students/my/payments
class StudentPaymentsService {
  final ApiClient _apiClient =
      Get.isRegistered<ApiClient>() ? Get.find<ApiClient>() : ApiClient();
  final StorageService _storage =
      Get.isRegistered<StorageService>() ? Get.find<StorageService>() : Get.put(StorageService());

  Future<StudentPaymentsResponse?> getMyPayments() async {
    try {
      final token = await _storage.getAccessToken();
      if (token == null || token.trim().isEmpty) return null;

      debugPrint('[StudentPaymentsService] GET ${ApiEndpoints.baseUrl}${ApiEndpoints.studentPayments}');
      final response = await _apiClient.dio.get(
        ApiEndpoints.studentPayments,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      debugPrint('[StudentPaymentsService] Response (${response.statusCode}): ${response.data}');

      if (response.statusCode == 200 && response.data is Map) {
        final body = response.data as Map;
        if (body['success'] == true && body['data'] is Map) {
          return StudentPaymentsResponse.fromJson(
            Map<String, dynamic>.from(body['data'] as Map),
          );
        }
      }
    } catch (e) {
      debugPrint('[StudentPaymentsService] getMyPayments error: $e');
    }
    return null;
  }
}

