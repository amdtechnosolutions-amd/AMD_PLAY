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
  final RxList<Map<String, dynamic>> batchStudents = <Map<String, dynamic>>[].obs;
  final RxBool isLoadingStudents = false.obs;

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

  /// Load students belonging specifically to the requested batch
  Future<void> loadStudentsForBatch(String batchId, {String? search}) async {
    if (batchId.isEmpty) {
      batchStudents.clear();
      return;
    }

    isLoadingStudents.value = true;
    try {
      // 1. Primary: Fetch via Option 1 (/coaching/batches/:batchId/students/dropdown)
      final list = await _service.getBatchStudents(batchId, search: search);
      if (list.isNotEmpty) {
        batchStudents.value = list;
        isLoadingStudents.value = false;
        return;
      }

      // 2. Fallback: Check if cached batch in controller has students list
      final cachedBatch = batches.firstWhereOrNull((b) => (b['_id'] ?? b['id'])?.toString() == batchId);
      if (cachedBatch != null && cachedBatch['students'] is List && (cachedBatch['students'] as List).isNotEmpty) {
        final cachedList = (cachedBatch['students'] as List)
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList();
        batchStudents.value = cachedList;
        isLoadingStudents.value = false;
        return;
      }

      batchStudents.clear();
    } catch (e) {
      debugPrint('[CoachEvaluationController] loadStudentsForBatch error: $e');
      batchStudents.clear();
    } finally {
      isLoadingStudents.value = false;
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
      debugPrint('[CoachEvaluationController] submitEvaluation initiated: studentId=$studentId, batchId=$batchId');
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
        debugPrint('[CoachEvaluationController] Evaluation created successfully, refreshing coach data...');
        await fetchCoachData();
        return true;
      }
    } catch (e) {
      debugPrint('[CoachEvaluationController] submitEvaluation caught error: $e');
      rethrow;
    }
    return false;
  }
}

