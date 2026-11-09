import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/models/student_evaluation_model.dart';
import '../../data/services/student_evaluation_service.dart';

/// Controller for Student Coaching Performance Reports & Scorecard
class StudentEvaluationController extends GetxController {
  final StudentEvaluationService _service = StudentEvaluationService();

  final RxBool isLoading = false.obs;
  final RxBool hasError = false.obs;
  final RxString errorMessage = ''.obs;
  final Rxn<StudentEvaluationReport> report = Rxn<StudentEvaluationReport>();
  final RxString selectedCategoryFilter = 'ALL'.obs;

  @override
  void onInit() {
    super.onInit();
    fetchEvaluations();
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
    return all.where((p) => p.category.toUpperCase() == selectedCategoryFilter.value).toList();
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
