import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_app/core/storage/storage_service.dart';
import 'package:mobile_app/features/coaching/data/models/student_evaluation_model.dart';
import 'package:mobile_app/features/coaching/data/services/student_evaluation_service.dart';
import 'package:mobile_app/features/home/presentation/controllers/home_controller.dart';

/// Controller for Student Coaching Performance Reports & Scorecard
class StudentEvaluationController extends GetxController {
  final StudentEvaluationService _service = StudentEvaluationService();
  final StorageService _storage =
      Get.isRegistered<StorageService>() ? Get.find<StorageService>() : Get.put(StorageService());

  final RxBool isLoading = false.obs;
  final RxBool hasError = false.obs;
  final RxString errorMessage = ''.obs;
  final Rxn<StudentEvaluationReport> report = Rxn<StudentEvaluationReport>();
  final RxString selectedCategoryFilter = 'ALL'.obs;

  final RxString targetStudentId = ''.obs;
  final RxString targetStudentName = ''.obs;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is Map) {
      if (args['report'] is StudentEvaluationReport) {
        report.value = args['report'] as StudentEvaluationReport;
        if (args['studentName'] != null && args['studentName'].toString().trim().isNotEmpty) {
          targetStudentName.value = args['studentName'].toString().trim();
        }
        resolveStudentName();
        return;
      }
      if (args['studentId'] != null) {
        targetStudentId.value = args['studentId'].toString();
        if (args['studentName'] != null && args['studentName'].toString().trim().isNotEmpty) {
          targetStudentName.value = args['studentName'].toString().trim();
        }
        fetchStudentEvaluations(targetStudentId.value);
        return;
      }
    }
    resolveStudentName();
    fetchEvaluations();
  }

  /// Automatically resolves the active student's name from live state or storage
  Future<void> resolveStudentName() async {
    if (targetStudentName.value.trim().isNotEmpty &&
        targetStudentName.value.toLowerCase() != 'player' &&
        targetStudentName.value.toLowerCase() != 'coach') {
      return;
    }

    if (report.value != null && report.value!.studentName.trim().isNotEmpty) {
      targetStudentName.value = report.value!.studentName.trim();
      return;
    }

    if (report.value != null && report.value!.summary.studentName.trim().isNotEmpty) {
      targetStudentName.value = report.value!.summary.studentName.trim();
      return;
    }

    if (Get.isRegistered<HomeController>()) {
      final hName = Get.find<HomeController>().userName.value.trim();
      if (hName.isNotEmpty &&
          hName.toLowerCase() != 'player' &&
          hName.toLowerCase() != 'coach') {
        targetStudentName.value = hName;
        return;
      }
    }

    final name = await _storage.getUserName();
    if (name != null &&
        name.trim().isNotEmpty &&
        name.trim().toLowerCase() != 'player' &&
        name.trim().toLowerCase() != 'coach') {
      targetStudentName.value = name.trim();
      return;
    }

    final userJson = await _storage.getUserJson();
    if (userJson != null && userJson.isNotEmpty) {
      try {
        final decoded = jsonDecode(userJson);
        if (decoded is Map) {
          final fName = (decoded['firstName'] ?? '').toString().trim();
          final lName = (decoded['lastName'] ?? '').toString().trim();
          final full = (decoded['fullName'] ??
                  decoded['name'] ??
                  (fName.isNotEmpty ? '$fName $lName' : ''))
              .toString()
              .trim();
          if (full.isNotEmpty && full.toLowerCase() != 'player' && full.toLowerCase() != 'coach') {
            targetStudentName.value = full;
            return;
          }
        }
      } catch (_) {}
    }
  }

  Future<void> fetchStudentEvaluations(String studentId) async {
    isLoading.value = true;
    hasError.value = false;
    errorMessage.value = '';

    try {
      final res = await _service.getEvaluationForStudent(studentId);
      if (res != null) {
        report.value = res;
      } else {
        await fetchEvaluations();
      }
      await resolveStudentName();
    } catch (e) {
      debugPrint('[StudentEvaluationController] fetchStudentEvaluations error: $e');
      hasError.value = true;
      errorMessage.value = e.toString().replaceAll('Exception:', '').trim();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchEvaluations() async {
    isLoading.value = true;
    hasError.value = false;
    errorMessage.value = '';

    try {
      final res = await _service.getMyEvaluations();
      if (res != null) {
        report.value = res;
      } else {
        report.value = null;
      }
      await resolveStudentName();
    } catch (e) {
      debugPrint('[StudentEvaluationController] error: $e');
      hasError.value = true;
      errorMessage.value = e.toString().replaceAll('Exception:', '').trim();
    } finally {
      isLoading.value = false;
    }
  }

  void setCategoryFilter(String category) {
    selectedCategoryFilter.value = category;
  }

  /// Filtered parameter cards based on active category chip
  List<ParameterCardModel> get filteredParameters {
    final all = report.value?.parameterCards ?? [];
    if (selectedCategoryFilter.value == 'ALL') return all;
    return all
        .where((p) => p.category.toUpperCase() == selectedCategoryFilter.value)
        .toList();
  }

  /// Get list of available categories
  List<String> get availableCategories {
    final all = report.value?.parameterCards ?? [];
    final set = {'ALL'};
    for (final p in all) {
      if (p.category.isNotEmpty) set.add(p.category.toUpperCase());
    }
    return set.toList();
  }
}
