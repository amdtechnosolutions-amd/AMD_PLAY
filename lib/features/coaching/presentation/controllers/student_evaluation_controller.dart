import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_app/core/storage/storage_service.dart';
import 'package:mobile_app/features/coaching/data/models/student_evaluation_model.dart';
import 'package:mobile_app/features/coaching/data/services/student_evaluation_service.dart';
import 'package:mobile_app/features/home/presentation/controllers/home_controller.dart';
import 'package:mobile_app/features/siblings/data/models/sibling_models.dart';
import 'package:mobile_app/features/siblings/data/services/sibling_service.dart';

/// Controller for Student Coaching Performance Reports & Scorecard
class StudentEvaluationController extends GetxController {
  final StudentEvaluationService _service = StudentEvaluationService();
  final SiblingService _siblingService = SiblingService();
  final StorageService _storage =
      Get.isRegistered<StorageService>() ? Get.find<StorageService>() : Get.put(StorageService());

  final RxBool isLoading = false.obs;
  final RxBool hasError = false.obs;
  final RxString errorMessage = ''.obs;
  final Rxn<StudentEvaluationReport> report = Rxn<StudentEvaluationReport>();
  final RxString selectedCategoryFilter = 'ALL'.obs;

  final RxString targetStudentId = ''.obs;
  final RxString targetStudentName = ''.obs;

  /// Sibling family profiles for instant side-by-side scorecard viewing without switching tokens
  final RxList<SiblingStudentModel> familyProfiles = <SiblingStudentModel>[].obs;
  final RxString selectedStudentId = ''.obs;

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
        if (args['studentId'] != null) {
          targetStudentId.value = args['studentId'].toString();
          selectedStudentId.value = targetStudentId.value;
        }
        resolveStudentName();
        return;
      }
      if (args['studentId'] != null && args['studentId'].toString().trim().isNotEmpty) {
        targetStudentId.value = args['studentId'].toString().trim();
        selectedStudentId.value = targetStudentId.value;
        if (args['studentName'] != null && args['studentName'].toString().trim().isNotEmpty) {
          targetStudentName.value = args['studentName'].toString().trim();
        }
        loadFamilyProfiles(activeStudentId: targetStudentId.value);
        fetchStudentEvaluations(targetStudentId.value, fallbackToMy: false);
        return;
      }
    }
    _initWithCurrentUserAndSiblings();
  }

  Future<void> _initWithCurrentUserAndSiblings() async {
    final storedId = await _storage.getStudentId() ?? '';
    final activeId = storedId.isNotEmpty
        ? storedId
        : (Get.isRegistered<HomeController>() ? Get.find<HomeController>().currentStudentId.value : '');

    if (activeId.isNotEmpty) {
      selectedStudentId.value = activeId;
      targetStudentId.value = activeId;
    }

    await resolveStudentName();
    // Load sibling switcher options and active scorecard concurrently
    await Future.wait([
      loadFamilyProfiles(activeStudentId: activeId),
      if (activeId.isNotEmpty)
        fetchStudentEvaluations(activeId, fallbackToMy: true)
      else
        fetchEvaluations(),
    ]);
  }

  /// Load current student + linked siblings so user can switch scorecards on the same screen
  Future<void> loadFamilyProfiles({String? activeStudentId}) async {
    try {
      final activeId = activeStudentId?.trim().isNotEmpty == true
          ? activeStudentId!.trim()
          : (await _storage.getStudentId() ?? '');
      if (activeId.isEmpty) return;

      final results = await Future.wait([
        _siblingService.getStudentSiblings(activeId),
        _siblingService.getMySiblings(),
      ]);

      final details = results[0] as StudentSiblingDetailsModel;
      final mySiblings = results[1] as List<SiblingStudentModel>;

      final List<SiblingStudentModel> combined = [];
      if (details.student != null && details.student!.studentId.isNotEmpty) {
        combined.add(details.student!);
      } else {
        final fallbackName = targetStudentName.value.isNotEmpty
            ? targetStudentName.value
            : (await _storage.getUserName() ?? 'Active Student');
        combined.add(SiblingStudentModel(studentId: activeId, fullName: fallbackName));
      }

      final seen = combined.map((e) => e.studentId).toSet();
      for (final sib in [...details.siblings, ...mySiblings]) {
        if (sib.studentId.isNotEmpty && !seen.contains(sib.studentId)) {
          seen.add(sib.studentId);
          combined.add(sib);
        }
      }

      familyProfiles.assignAll(combined);
      if (selectedStudentId.value.isEmpty && combined.isNotEmpty) {
        selectedStudentId.value = combined.first.studentId;
      }
    } catch (e) {
      debugPrint('[StudentEvaluationController] loadFamilyProfiles error: $e');
    }
  }

  /// Switch scorecard directly by studentId (GET /students/:id/evaluations/latest)
  /// without needing to switch auth token
  Future<void> selectSiblingScorecard(SiblingStudentModel sibling) async {
    if (sibling.studentId.isEmpty) return;
    selectedStudentId.value = sibling.studentId;
    targetStudentId.value = sibling.studentId;
    targetStudentName.value = sibling.fullName;
    await fetchStudentEvaluations(sibling.studentId, fallbackToMy: false);
  }

  /// Refresh whichever scorecard is currently active (selected sibling or my evaluations)
  Future<void> refreshActiveReport() async {
    final sId = selectedStudentId.value.isNotEmpty ? selectedStudentId.value : targetStudentId.value;
    if (sId.isNotEmpty) {
      await fetchStudentEvaluations(sId, fallbackToMy: false);
    } else {
      await fetchEvaluations();
    }
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

  Future<void> fetchStudentEvaluations(String studentId, {bool fallbackToMy = false}) async {
    isLoading.value = true;
    hasError.value = false;
    errorMessage.value = '';

    try {
      final res = await _service.getEvaluationForStudent(studentId);
      if (res != null) {
        report.value = res;
      } else if (fallbackToMy) {
        await fetchEvaluations();
      } else {
        report.value = null;
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
