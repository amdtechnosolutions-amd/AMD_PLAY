import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/widgets/empty_state.dart';
import '../controllers/coach_evaluation_controller.dart';
import '../widgets/direct_student_password_reset_dialog.dart';

/// Screen for Coaches to inspect all student performance evaluations,
/// filter by batch, search by student, and record new assessments.
class CoachEvaluationsScreen extends StatelessWidget {
  const CoachEvaluationsScreen({super.key});

  static const Color goldAccent = Color(0xFFD4AF37);
  static const Color darkText = Color(0xFF0F172A);
  static const Color slateText = Color(0xFF64748B);

  @override
  Widget build(BuildContext context) {
    final controller = Get.isRegistered<CoachEvaluationController>()
        ? Get.find<CoachEvaluationController>()
        : Get.put(CoachEvaluationController());

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Student Evaluations',
          style: TextStyle(
            fontFamily: 'Nunito',
            fontSize: 18.sp,
            fontWeight: FontWeight.w800,
            color: darkText,
          ),
        ),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: Navigator.canPop(context)
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, color: darkText),
                onPressed: () => Get.back(),
              )
            : null,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: goldAccent),
            tooltip: 'Refresh Evaluations',
            onPressed: controller.fetchCoachData,
          ),
          IconButton(
            icon: const Icon(Icons.add_circle_outline_rounded, color: goldAccent),
            tooltip: 'New Assessment',
            onPressed: () => Get.toNamed(AppRoutes.evaluateStudent),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Get.toNamed(AppRoutes.evaluateStudent),
        backgroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
          side: const BorderSide(color: goldAccent, width: 1.5),
        ),
        icon: const Icon(Icons.add_task_rounded, color: Color(0xFF9E7B1A)),
        label: Text(
          'EVALUATE STUDENT',
          style: TextStyle(
            fontFamily: 'Nunito',
            fontSize: 12.5.sp,
            fontWeight: FontWeight.w900,
            color: const Color(0xFF0F172A),
            letterSpacing: 0.6,
          ),
        ),
      ),
      body: RefreshIndicator(
        color: goldAccent,
        backgroundColor: Colors.white,
        onRefresh: controller.fetchCoachData,
        child: Column(
          children: [
            // Search Bar & Filter Header
            _buildSearchAndFilters(controller),

            // Evaluations List / State
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: goldAccent,
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          'Loading student evaluations...',
                          style: TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: slateText,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                if (controller.hasError.value && controller.evaluations.isEmpty) {
                  return SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 60.h),
                    child: EmptyState(
                      title: 'Evaluations Unavailable',
                      message: controller.errorMessage.value.isNotEmpty
                          ? controller.errorMessage.value
                          : 'Unable to load coaching evaluations. Please verify your coach account permissions.',
                      icon: Icons.assessment_outlined,
                      buttonText: 'RETRY',
                      onButtonPressed: controller.fetchCoachData,
                    ),
                  );
                }

                final list = controller.filteredEvaluations;
                if (list.isEmpty) {
                  return SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 60.h),
                    child: EmptyState(
                      title: 'No Student Evaluations',
                      message: controller.evaluations.isEmpty
                          ? 'No student evaluations recorded yet. Tap "Evaluate Student" to conduct your first assessment.'
                          : 'No evaluations match your current batch or student search filter.',
                      icon: Icons.fitness_center_rounded,
                      buttonText: 'RECORD NEW EVALUATION',
                      onButtonPressed: () => Get.toNamed(AppRoutes.evaluateStudent),
                    ),
                  );
                }

                return ListView.builder(
                  padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 90.h),
                  itemCount: list.length,
                  itemBuilder: (context, index) {
                    final item = list[index];
                    return _buildEvaluationCard(context, item, controller);
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // 1. SEARCH & BATCH FILTERS
  // ===========================================================================

  Widget _buildSearchAndFilters(CoachEvaluationController controller) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 12.h),
      child: Column(
        children: [
          // Search Input
          Container(
            height: 44.h,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(color: const Color(0x60D4AF37), width: 1.1),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x10D4AF37),
                  blurRadius: 10,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: TextField(
              onChanged: controller.setSearchQuery,
              style: TextStyle(
                fontFamily: 'Nunito',
                fontSize: 13.5.sp,
                fontWeight: FontWeight.w600,
                color: darkText,
              ),
              decoration: InputDecoration(
                hintText: 'Search by student name or Reg. No...',
                hintStyle: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 12.5.sp,
                  color: const Color(0xFF94A3B8),
                ),
                prefixIcon: Icon(
                  Icons.search_rounded,
                  size: 18.sp,
                  color: goldAccent,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 10.h),
              ),
            ),
          ),
          SizedBox(height: 10.h),

          // Horizontal Batch Filter Chips
          Obx(() {
            final activeBatch = controller.selectedBatchId.value;
            final batches = controller.batches;

            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildBatchChip(
                    label: 'ALL BATCHES',
                    isSelected: activeBatch == 'ALL',
                    onTap: () => controller.filterByBatch('ALL'),
                  ),
                  ...batches.map((b) {
                    final id = b['_id']?.toString() ?? '';
                    final name = b['name']?.toString() ?? b['title']?.toString() ?? 'Batch';
                    return _buildBatchChip(
                      label: name.toUpperCase(),
                      isSelected: activeBatch == id,
                      onTap: () => controller.filterByBatch(id),
                    );
                  }),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildBatchChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(right: 8.w),
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFFFDF5) : Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isSelected ? goldAccent : const Color(0xFFE2E8F0),
            width: isSelected ? 1.4 : 1.0,
          ),
          boxShadow: isSelected
              ? const [
                  BoxShadow(
                    color: Color(0x20D4AF37),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Nunito',
            fontSize: 11.sp,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
            color: isSelected ? const Color(0xFF9E7B1A) : slateText,
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // 2. STUDENT EVALUATION CARD
  // ===========================================================================

  Widget _buildEvaluationCard(
    BuildContext context,
    Map<String, dynamic> item,
    CoachEvaluationController controller,
  ) {
    final student = item['studentId'] is Map ? item['studentId'] : item['student'];
    final studentName = (student is Map
            ? (student['name'] ?? student['fullName'] ?? student['studentName'])
            : item['studentName'])
        ?.toString() ??
        'Academy Student';
    final regNo = (student is Map ? (student['regNo'] ?? student['rollNo']) : item['regNo'])
        ?.toString() ??
        '';

    final batch = item['batchId'] is Map ? item['batchId'] : item['batch'];
    final batchName = (batch is Map
            ? (batch['name'] ?? batch['title'])
            : item['batchName'])
        ?.toString() ??
        'Training Batch';

    final summary = item['summary'] is Map ? item['summary'] as Map : item;
    final totalScore = summary['overallScore']?.toString() ??
        summary['score']?.toString() ??
        '210/240';
    final percentage = (summary['percentage'] as num?)?.toDouble() ??
        (summary['overallPercentage'] as num?)?.toDouble() ??
        85.0;
    final grade = summary['grade']?.toString() ?? 'A';
    final level = summary['performanceLevel']?.toString() ??
        summary['level']?.toString() ??
        'Excellent';
    final remarks = (summary['coachRemarks'] ?? summary['remarks'])?.toString() ?? '';

    return Container(
      margin: EdgeInsets.only(bottom: 14.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: const Color(0x60D4AF37), width: 1.2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x20D4AF37),
            blurRadius: 16,
            offset: Offset(0, 5),
          ),
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Student Name & Grade Badge
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44.h,
                height: 44.h,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFDF5),
                  shape: BoxShape.circle,
                  border: Border.all(color: goldAccent, width: 1.3),
                ),
                child: Center(
                  child: Text(
                    studentName.isNotEmpty ? studentName[0].toUpperCase() : 'S',
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF9E7B1A),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      studentName,
                      style: TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w800,
                        color: darkText,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      '$batchName ${regNo.isNotEmpty ? "• $regNo" : ""}',
                      style: TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 12.sp,
                        color: slateText,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFDF5),
                  borderRadius: BorderRadius.circular(10.r),
                  border: Border.all(color: goldAccent, width: 1.1),
                ),
                child: Column(
                  children: [
                    Text(
                      'GRADE',
                      style: TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 8.5.sp,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF9E7B1A),
                      ),
                    ),
                    Text(
                      grade,
                      style: TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w900,
                        color: darkText,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),

          // Score & Level Row
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: const Color(0xFFE2E8F0), width: 0.8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.stars_rounded, size: 16.sp, color: goldAccent),
                    SizedBox(width: 6.w),
                    Text(
                      'Score: $totalScore (${percentage.toStringAsFixed(1)}%)',
                      style: TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 12.5.sp,
                        fontWeight: FontWeight.w700,
                        color: darkText,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: const Color(0x2010B981),
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                  child: Text(
                    level.toUpperCase(),
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 9.5.sp,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF059669),
                    ),
                  ),
                ),
              ],
            ),
          ),

          if (remarks.isNotEmpty) ...[
            SizedBox(height: 10.h),
            Text(
              '"$remarks"',
              style: TextStyle(
                fontFamily: 'Nunito',
                fontSize: 11.5.sp,
                fontStyle: FontStyle.italic,
                color: const Color(0xFF475569),
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],

          SizedBox(height: 14.h),

          // Action Row: View Full Spider Radar & Direct Reset Password
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    final report = controller.convertToReport(item);
                    Get.toNamed(
                      AppRoutes.coachingReport,
                      arguments: {
                        'report': report,
                        'studentName': studentName,
                        'studentId': student is Map ? (student['_id'] ?? student['id']) : null,
                      },
                    );
                  },
                  child: Container(
                    height: 40.h,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: goldAccent, width: 1.2),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.radar_rounded, size: 16.sp, color: const Color(0xFF9E7B1A)),
                        SizedBox(width: 6.w),
                        Text(
                          '24 PARAMETERS & RADAR',
                          style: TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF0F172A),
                            letterSpacing: 0.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              if (student is Map && (student['_id'] != null || student['id'] != null)) ...[
                SizedBox(width: 8.w),
                GestureDetector(
                  onTap: () {
                    final sId = (student['_id'] ?? student['id']).toString();
                    DirectStudentPasswordResetDialog.show(
                      context: context,
                      studentId: sId,
                      studentName: studentName,
                    );
                  },
                  child: Container(
                    height: 40.h,
                    padding: EdgeInsets.symmetric(horizontal: 10.w),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFFDF5),
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: const Color(0x60D4AF37), width: 1.0),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.vpn_key_outlined, size: 15.sp, color: const Color(0xFF9E7B1A)),
                        SizedBox(width: 4.w),
                        Text(
                          'Reset Pass',
                          style: TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF9E7B1A),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

