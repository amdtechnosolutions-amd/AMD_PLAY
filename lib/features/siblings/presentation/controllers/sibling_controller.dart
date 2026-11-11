import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/models/sibling_models.dart';
import '../../data/services/sibling_service.dart';

/// GetX Controller managing Sibling Families list, search, manual linking,
/// sibling phone updates, and group unlinking for Coaches & Academy Staff.
class SiblingController extends GetxController {
  final SiblingService _service = SiblingService();

  final RxBool isLoading = false.obs;
  final RxBool isSubmitting = false.obs;
  final RxBool hasError = false.obs;
  final RxString errorMessage = ''.obs;

  final RxList<SiblingFamilyGroupModel> families = <SiblingFamilyGroupModel>[].obs;
  final RxList<Map<String, dynamic>> studentOptions = <Map<String, dynamic>>[].obs;
  final RxBool isLoadingStudents = false.obs;

  final RxString searchQuery = ''.obs;
  final RxInt currentPage = 1.obs;
  final RxInt totalPages = 1.obs;
  final RxInt totalFamilies = 0.obs;

  @override
  void onInit() {
    super.onInit();
    fetchFamilies();
  }

  Future<void> fetchFamilies({int page = 1}) async {
    isLoading.value = true;
    hasError.value = false;
    errorMessage.value = '';

    try {
      final result = await _service.listSiblingFamilies(
        search: searchQuery.value.isNotEmpty ? searchQuery.value : null,
        page: page,
        limit: 20,
      );
      families.assignAll(result.families);
      currentPage.value = page;
      totalPages.value = result.totalPages;
      totalFamilies.value = result.total;
    } catch (e) {
      hasError.value = true;
      errorMessage.value = e.toString().replaceAll('Exception:', '').trim();
    } finally {
      isLoading.value = false;
    }
  }

  void updateSearch(String query) {
    searchQuery.value = query.trim();
    fetchFamilies(page: 1);
  }

  Future<void> loadStudentDropdown({String? search}) async {
    isLoadingStudents.value = true;
    try {
      final list = await _service.getStudentsDropdown(search: search);
      studentOptions.assignAll(list);
    } finally {
      isLoadingStudents.value = false;
    }
  }

  Future<StudentSiblingDetailsModel?> fetchStudentSiblings(String studentId) async {
    try {
      return await _service.getStudentSiblings(studentId);
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString().replaceAll('Exception:', '').trim(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.white,
        colorText: const Color(0xFFEF4444),
        borderColor: const Color(0xFFEF4444),
        borderWidth: 1.2,
        margin: const EdgeInsets.all(16),
      );
      return null;
    }
  }

  Future<bool> linkStudents({
    required String masterStudentId,
    required String newStudentId,
  }) async {
    if (masterStudentId.isEmpty || newStudentId.isEmpty) {
      Get.snackbar(
        'Selection Required',
        'Please select both Master Student and Sibling Student.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.white,
        colorText: const Color(0xFFEF4444),
        borderColor: const Color(0xFFEF4444),
        borderWidth: 1.2,
        margin: const EdgeInsets.all(16),
      );
      return false;
    }
    if (masterStudentId == newStudentId) {
      Get.snackbar(
        'Invalid Selection',
        'Master Student and Sibling Student must be different profiles.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.white,
        colorText: const Color(0xFFEF4444),
        borderColor: const Color(0xFFEF4444),
        borderWidth: 1.2,
        margin: const EdgeInsets.all(16),
      );
      return false;
    }

    isSubmitting.value = true;
    try {
      await _service.linkExistingSiblings(
        masterStudentId: masterStudentId,
        newStudentId: newStudentId,
      );
      await fetchFamilies(page: 1);
      Get.snackbar(
        'Siblings Linked',
        'Students linked into sibling family group successfully.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.white,
        colorText: const Color(0xFF0F172A),
        borderColor: const Color(0xFFD4AF37),
        borderWidth: 1.2,
        margin: const EdgeInsets.all(16),
      );
      return true;
    } catch (e) {
      Get.snackbar(
        'Link Failed',
        e.toString().replaceAll('Exception:', '').trim(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.white,
        colorText: const Color(0xFFEF4444),
        borderColor: const Color(0xFFEF4444),
        borderWidth: 1.2,
        margin: const EdgeInsets.all(16),
      );
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<bool> updateStudentPhone({
    required String studentId,
    required String phone,
    String? parentPhone,
    String? parentName,
  }) async {
    isSubmitting.value = true;
    try {
      await _service.updateSiblingPhone(
        studentId,
        phone: phone,
        parentPhone: parentPhone,
        parentName: parentName,
      );
      await fetchFamilies(page: currentPage.value);
      Get.snackbar(
        'Phone Updated',
        'Sibling mobile number updated while maintaining family group.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.white,
        colorText: const Color(0xFF0F172A),
        borderColor: const Color(0xFFD4AF37),
        borderWidth: 1.2,
        margin: const EdgeInsets.all(16),
      );
      return true;
    } catch (e) {
      Get.snackbar(
        'Update Failed',
        e.toString().replaceAll('Exception:', '').trim(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.white,
        colorText: const Color(0xFFEF4444),
        borderColor: const Color(0xFFEF4444),
        borderWidth: 1.2,
        margin: const EdgeInsets.all(16),
      );
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<bool> unlinkStudent(String studentId) async {
    isSubmitting.value = true;
    try {
      final ok = await _service.unlinkSibling(studentId);
      if (ok) {
        await fetchFamilies(page: 1);
        Get.snackbar(
          'Student Unlinked',
          'Student removed from the sibling family group.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.white,
          colorText: const Color(0xFF0F172A),
          borderColor: const Color(0xFFD4AF37),
          borderWidth: 1.2,
          margin: const EdgeInsets.all(16),
        );
      }
      return ok;
    } catch (e) {
      Get.snackbar(
        'Unlink Failed',
        e.toString().replaceAll('Exception:', '').trim(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.white,
        colorText: const Color(0xFFEF4444),
        borderColor: const Color(0xFFEF4444),
        borderWidth: 1.2,
        margin: const EdgeInsets.all(16),
      );
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }
}
