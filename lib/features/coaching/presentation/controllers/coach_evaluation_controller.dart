import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/models/student_evaluation_model.dart';
import '../../data/services/coach_evaluation_service.dart';

/// GetX Controller orchestrating Coach Performance Evaluations,
/// Student Scorecards, Batch Filters, and Assessment Creation.
class CoachEvaluationController extends GetxController {
  final CoachEvaluationService _service = CoachEvaluationService();

  final RxBool isLoading = false.obs;
  final RxBool hasError = false.obs;
  final RxString errorMessage = ''.obs;

  final RxList<Map<String, dynamic>> evaluations = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> batches = <Map<String, dynamic>>[].obs;

  final RxString selectedBatchId = 'ALL'.obs;
  final RxString searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchCoachData();
  }

  Future<void> fetchCoachData() async {
    isLoading.value = true;
    hasError.value = false;
    errorMessage.value = '';

    try {
      final results = await Future.wait([
        _service.getCoachingEvaluations(),
        _service.getCoachBatches(),
      ]);

      evaluations.value = results[0];
      batches.value = results[1];
    } catch (e) {
      debugPrint('[CoachEvaluationController] fetchCoachData error: $e');
      hasError.value = true;
      errorMessage.value = e.toString().replaceAll('Exception:', '').trim();
    } finally {
      isLoading.value = false;
    }
  }

  void filterByBatch(String batchId) {
    selectedBatchId.value = batchId;
  }

  void setSearchQuery(String q) {
    searchQuery.value = q.trim().toLowerCase();
  }

  /// Evaluated student cards filtered by active batch filter and search bar query
  List<Map<String, dynamic>> get filteredEvaluations {
    return evaluations.where((ev) {
      // 1. Batch filter
      if (selectedBatchId.value != 'ALL') {
        final evBatchId = ev['batchId'] is Map
            ? ev['batchId']['_id']?.toString()
            : ev['batchId']?.toString();
        if (evBatchId != selectedBatchId.value) return false;
      }

      // 2. Search query filter
      if (searchQuery.value.isNotEmpty) {
        final student = ev['studentId'] is Map ? ev['studentId'] : ev['student'];
        final name = (student is Map
                ? (student['name'] ?? student['fullName'] ?? student['studentName'])
                : ev['studentName'])
            ?.toString()
            .toLowerCase() ??
            '';
        final regNo = (student is Map ? (student['regNo'] ?? student['rollNo']) : ev['regNo'])
            ?.toString()
            .toLowerCase() ??
            '';
        final q = searchQuery.value;
        if (!name.contains(q) && !regNo.contains(q)) return false;
      }

      return true;
    }).toList();
  }

  /// Convert a raw evaluation JSON map into a full StudentEvaluationReport
  StudentEvaluationReport convertToReport(Map<String, dynamic> raw) {
    return StudentEvaluationReport.fromJson(raw);
  }

  /// Create and submit evaluation assessment
  Future<bool> submitEvaluation({
    required String studentId,
    String? batchId,
    required double physicalScore,
    required double mentalScore,
    required double skillScore,
    required double attitudeScore,
    required String remarks,
  }) async {
    try {
      final success = await _service.createEvaluation(
        studentId: studentId,
        batchId: batchId,
        physicalScore: physicalScore,
        mentalScore: mentalScore,
        skillScore: skillScore,
        attitudeScore: attitudeScore,
        remarks: remarks,
      );
      if (success) {
        await fetchCoachData();
        return true;
      }
    } catch (e) {
      debugPrint('[CoachEvaluationController] submitEvaluation error: $e');
      rethrow;
    }
    return false;
  }
}

