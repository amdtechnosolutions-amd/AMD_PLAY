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
    // 1. Resolve Student Name from Live Item / Student Object
    final student = item['studentId'] is Map
        ? item['studentId'] as Map
        : (item['student'] is Map ? item['student'] as Map : null);

    String studentName = (item['studentName'] ?? '').toString().trim();
    if (studentName.isEmpty && student != null) {
      final fName = (student['firstName'] ?? '').toString().trim();
      final lName = (student['lastName'] ?? '').toString().trim();
      final full = '$fName $lName'.trim();
      if (full.isNotEmpty) {
        studentName = full;
      } else {
        studentName = (student['name'] ?? student['fullName'] ?? student['studentName'] ?? '').toString().trim();
      }
    }
    if (studentName.isEmpty) {
      studentName = 'Academy Student';
    }

    // 2. Resolve Reg No / Biometric ID
    String regNo = (item['regNo'] ?? item['employeeNo'] ?? '').toString().trim();
    if (regNo.isEmpty && student != null) {
      regNo = (student['employeeNo'] ?? student['regNo'] ?? student['cardNo'] ?? student['rollNo'] ?? '').toString().trim();
    }

    // 3. Resolve Batch Name
    final batch = item['batchId'] is Map
        ? item['batchId'] as Map
        : (item['batch'] is Map ? item['batch'] as Map : null);
    String batchName = (item['batchName'] ?? '').toString().trim();
    if (batchName.isEmpty && batch != null) {
      batchName = (batch['name'] ?? batch['title'] ?? batch['batchName'] ?? '').toString().trim();
    }
    if (batchName.isEmpty) {
      batchName = 'Training Squad';
    }

    // 4. Resolve Live Scores, Percentages, and Grade
    final summary = item['summary'] is Map ? item['summary'] as Map : item;
    final num overallScoreNum = (summary['overallScore'] ?? summary['score'] ?? summary['totalScore'] as num?) ?? 0;
    final num totalPossibleScoreNum = (summary['totalPossibleScore'] ?? summary['maxScore'] as num?) ?? 240;
    final double percentage = (summary['percentage'] as num?)?.toDouble() ??
        (summary['overallPercentage'] as num?)?.toDouble() ??
        (totalPossibleScoreNum > 0 ? (overallScoreNum / totalPossibleScoreNum) * 100.0 : 0.0);

    // Compute live grade if absent
    String grade = (summary['grade']?.toString() ?? '').trim().toUpperCase();
    if (grade.isEmpty || grade == 'N/A') {
      if (percentage >= 90) {
        grade = 'A+';
      } else if (percentage >= 80) {
        grade = 'A';
      } else if (percentage >= 70) {
        grade = 'B';
      } else if (percentage >= 60) {
        grade = 'C';
      } else {
        grade = 'D';
      }
    }

    // Compute live performance tier
    String level = (summary['performanceLevel'] ?? summary['level']?.toString() ?? '').trim();
    if (level.isEmpty || level.toLowerCase() == 'unassessed') {
      if (percentage >= 90) {
        level = 'Elite';
      } else if (percentage >= 80) {
        level = 'Excellent';
      } else if (percentage >= 70) {
        level = 'Good';
      } else if (percentage >= 60) {
        level = 'Satisfactory';
      } else {
        level = 'Needs Improvement';
      }
    }

    final remarks = (summary['coachRemarks'] ?? summary['remarks'] ?? item['remarks'] ?? item['coachRemarks'])?.toString().trim() ?? '';
    final totalScoreText = '${overallScoreNum.toInt()} / ${totalPossibleScoreNum.toInt()}';

    // Category breakdown scores
    final pScore = (summary['physicalScore'] ?? item['physicalScore'] as num?)?.toDouble();
    final mScore = (summary['mentalScore'] ?? item['mentalScore'] as num?)?.toDouble();
    final sScore = (summary['skillScore'] ?? item['skillScore'] as num?)?.toDouble();
    final aScore = (summary['attitudeScore'] ?? item['attitudeScore'] as num?)?.toDouble();

    // Date
    final rawDate = summary['evaluationDate'] ?? summary['date'] ?? item['createdAt'] ?? item['evaluationDate'];
    String formattedDate = '';
    if (rawDate != null) {
      try {
        final dt = DateTime.parse(rawDate.toString()).toLocal();
        const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
        formattedDate = '${dt.day} ${months[dt.month - 1]} ${dt.year}';
      } catch (_) {}
    }

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
                    if (formattedDate.isNotEmpty) ...[
                      SizedBox(height: 2.h),
                      Text(
                        'Evaluated on $formattedDate',
                        style: TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 11.sp,
                          color: const Color(0xFF94A3B8),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
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
                      'Score: $totalScoreText (${percentage.toStringAsFixed(1)}%)',
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

          // Category Score Breakdown Pills if available
          if (pScore != null || mScore != null || sScore != null || aScore != null) ...[
            SizedBox(height: 10.h),
            Wrap(
              spacing: 6.w,
              runSpacing: 6.h,
              children: [
                if (pScore != null)
                  _buildCategoryBadge('Physical', pScore.toInt(), const Color(0xFF10B981)),
                if (mScore != null)
                  _buildCategoryBadge('Mental', mScore.toInt(), const Color(0xFF3B82F6)),
                if (sScore != null)
                  _buildCategoryBadge('Skill', sScore.toInt(), const Color(0xFFD4AF37)),
                if (aScore != null)
                  _buildCategoryBadge('Attitude', aScore.toInt(), const Color(0xFF8B5CF6)),
              ],
            ),
          ],

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
                    final enrichedItem = Map<String, dynamic>.from(item);
                    enrichedItem['studentName'] = studentName;
                    enrichedItem['regNo'] = regNo;
                    enrichedItem['batchName'] = batchName;
                    final report = controller.convertToReport(enrichedItem);
                    Get.toNamed(
                      AppRoutes.coachingReport,
                      arguments: {
                        'report': report,
                        'studentName': studentName,
                        'studentId': student is Map ? (student['_id'] ?? student['id']) : (item['studentId']?.toString()),
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

  Widget _buildCategoryBadge(String title, int score, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: color.withValues(alpha: 0.4), width: 0.9),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6.w,
            height: 6.w,
            decoration: BoxDecoration(shape: BoxShape.circle, color: color),
          ),
          SizedBox(width: 5.w),
          Text(
            '$title: $score/60',
            style: TextStyle(
              fontFamily: 'Nunito',
              fontSize: 10.5.sp,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

