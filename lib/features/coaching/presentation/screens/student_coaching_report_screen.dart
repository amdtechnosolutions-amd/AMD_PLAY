import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/widgets/empty_state.dart';
import '../../../home/presentation/controllers/home_controller.dart';
import '../../data/models/student_evaluation_model.dart';
import '../controllers/student_evaluation_controller.dart';
import '../widgets/evaluation_radar_chart.dart';
import '../widgets/evaluation_trend_chart.dart';
import '../widgets/parameter_card_widget.dart';

/// Screen displaying Student Coaching Performance Report & 24-Parameter Scorecard
/// Formatted to match the official Academy Report UI:
/// - Dynamic Student Header with Student Name & Coaching Batch
/// - Categorized parameter lists: Physical :, mental :, skill :, attitude :
/// - Exact 24 parameters with custom illustrations, descriptions & bold score
/// - Collapsible Radar Chart, historical progress trend & coach remarks
class StudentCoachingReportScreen extends StatefulWidget {
  const StudentCoachingReportScreen({super.key});

  @override
  State<StudentCoachingReportScreen> createState() =>
      _StudentCoachingReportScreenState();
}

class _StudentCoachingReportScreenState
    extends State<StudentCoachingReportScreen> {
  static const Color goldAccent = Color(0xFFD4AF37);
  static const Color darkText = Color(0xFF0F172A);
  static const Color slateText = Color(0xFF64748B);

  bool _showFullAnalytics = false;

  @override
  Widget build(BuildContext context) {
    final controller = Get.isRegistered<StudentEvaluationController>()
        ? Get.find<StudentEvaluationController>()
        : Get.put(StudentEvaluationController());

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Student Performance Report',
          style: TextStyle(
            fontFamily: 'Nunito',
            fontSize: 17.5.sp,
            fontWeight: FontWeight.w800,
            color: darkText,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: darkText),
          onPressed: () => Get.back(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: goldAccent),
            tooltip: 'Refresh Evaluations',
            onPressed: controller.refreshActiveReport,
          ),
        ],
      ),
      body: RefreshIndicator(
        color: goldAccent,
        backgroundColor: Colors.white,
        onRefresh: controller.refreshActiveReport,
        child: Obx(() {
          final hasSiblings = controller.familyProfiles.length > 1;

          Widget buildMainContent() {
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
                      'Loading performance report...',
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

            if (controller.hasError.value && controller.report.value == null) {
              return SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 40.h),
                child: EmptyState(
                  title: 'Report Unavailable',
                  message: controller.errorMessage.value.isNotEmpty
                      ? controller.errorMessage.value
                      : 'Unable to load coaching performance report. Please check your connection or sign in as a student.',
                  icon: Icons.assessment_outlined,
                  buttonText: 'RETRY',
                  onButtonPressed: controller.refreshActiveReport,
                ),
              );
            }

            final report = controller.report.value;
            if (report == null) {
              return SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 40.h),
                child: EmptyState(
                  title: 'No Performance Evaluations Yet',
                  message:
                      'Your academy coaches have not published an evaluation scorecard for ${controller.targetStudentName.value.isNotEmpty ? controller.targetStudentName.value : "this profile"} yet.',
                  icon: Icons.sports_score_rounded,
                  buttonText: 'REFRESH',
                  onButtonPressed: controller.refreshActiveReport,
                ),
              );
            }

            final summary = report.summary;
            final physicalParams = report.parameterCards
                .where((p) => p.category.toLowerCase().contains('physical'))
                .toList();
            final mentalParams = report.parameterCards
                .where((p) => p.category.toLowerCase().contains('mental'))
                .toList();
            final skillParams = report.parameterCards
                .where((p) => p.category.toLowerCase().contains('skill'))
                .toList();
            final attitudeParams = report.parameterCards
                .where((p) => p.category.toLowerCase().contains('attitude'))
                .toList();

            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 40.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Dynamic Student Profile Header
                  _buildStudentHeader(summary, controller),
                  SizedBox(height: 12.h),

                  // 2. Quick Score Bar & Toggle for Spider Radar / Trend Charts
                  _buildScoreSummaryBar(summary, report),
                  SizedBox(height: 8.h),

                  // 3. Collapsible Analytics (Radar & Trend)
                  if (_showFullAnalytics) ...[
                    if (summary.coachRemarks.isNotEmpty) ...[
                      _buildCoachRemarksCard(summary),
                      SizedBox(height: 16.h),
                    ],
                    if (report.radarData.isNotEmpty) ...[
                      EvaluationRadarChart(categories: report.radarData),
                      SizedBox(height: 16.h),
                    ],
                    if (report.trend.isNotEmpty) ...[
                      EvaluationTrendChart(trend: report.trend),
                      SizedBox(height: 16.h),
                    ],
                  ] else if (summary.coachRemarks.isNotEmpty) ...[
                    _buildCoachRemarksCard(summary),
                    SizedBox(height: 8.h),
                  ],

                  // 4. Physical Section
                  _buildCategorySection('PHYSICAL :', physicalParams),

                  // 5. Mental Section
                  _buildCategorySection('MENTAL :', mentalParams),

                  // 6. Skill Section
                  _buildCategorySection('SKILL :', skillParams),

                  // 7. Attitude Section
                  _buildCategorySection('ATTITUDE :', attitudeParams),
                ],
              ),
            );
          }

          return Column(
            children: [
              if (hasSiblings) _buildSiblingSwitcherBar(controller),
              Expanded(child: buildMainContent()),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildSiblingSwitcherBar(StudentEvaluationController controller) {
    final activeId = controller.selectedStudentId.value;
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 10.h),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: controller.familyProfiles.map((sib) {
            final isSelected = sib.studentId == activeId;
            return GestureDetector(
              onTap: () => controller.selectSiblingScorecard(sib),
              child: Container(
                margin: EdgeInsets.only(right: 8.w),
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 7.h),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFFFFFDF5) : const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(14.r),
                  border: Border.all(
                    color: isSelected ? goldAccent : const Color(0xFFE2E8F0),
                    width: isSelected ? 1.4 : 1.0,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircleAvatar(
                      radius: 10.r,
                      backgroundColor: isSelected ? goldAccent : const Color(0xFFCBD5E1),
                      child: Text(
                        sib.fullName.isNotEmpty ? sib.fullName[0].toUpperCase() : 'S',
                        style: TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    SizedBox(width: 7.w),
                    Text(
                      sib.regNo.isNotEmpty ? '${sib.fullName} (${sib.regNo})' : sib.fullName,
                      style: TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 12.sp,
                        fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                        color: isSelected ? darkText : slateText,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  // ==========================================
  // 1. DYNAMIC STUDENT HEADER
  // ==========================================

  Widget _buildStudentHeader(
    EvaluationSummary summary,
    StudentEvaluationController controller,
  ) {
    String studentName = controller.targetStudentName.value.trim();
    if (studentName.isEmpty && summary.studentName.isNotEmpty) {
      studentName = summary.studentName.trim();
    }
    if (studentName.isEmpty &&
        controller.report.value?.studentName.isNotEmpty == true) {
      studentName = controller.report.value!.studentName.trim();
    }
    if (studentName.isEmpty && Get.isRegistered<HomeController>()) {
      final hName = Get.find<HomeController>().userName.value.trim();
      if (hName.isNotEmpty &&
          hName.toLowerCase() != 'player' &&
          hName.toLowerCase() != 'coach') {
        studentName = hName;
      }
    }
    if (studentName.isEmpty) {
      studentName = 'Academy Trainee';
    }

    final initial = studentName.isNotEmpty ? studentName[0].toUpperCase() : 'S';
    final sportLabel = summary.sportName.isNotEmpty
        ? summary.sportName.toUpperCase()
        : 'BADMINTON';
    final batchLabel = summary.batchName.isNotEmpty
        ? summary.batchName
        : 'Student Performance Report';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Golden Student Initial Crest / Avatar
        Container(
          width: 48.w,
          height: 48.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFFFFFDF5),
            border: Border.all(color: const Color(0xFFD4AF37), width: 1.8),
            boxShadow: const [
              BoxShadow(
                color: Color(0x18D4AF37),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: Text(
              initial,
              style: TextStyle(
                fontFamily: 'Nunito',
                fontSize: 20.sp,
                fontWeight: FontWeight.w900,
                color: const Color(0xFF9E7B1A),
              ),
            ),
          ),
        ),
        SizedBox(width: 12.w),

        // Dynamic Student Name & Batch Tag
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                studentName.toUpperCase(),
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 16.5.sp,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF0F172A),
                  letterSpacing: 0.6,
                  height: 1.15,
                ),
              ),
              SizedBox(height: 3.h),
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 7.w,
                      vertical: 2.h,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFFDF5),
                      borderRadius: BorderRadius.circular(6.r),
                      border: Border.all(
                        color: const Color(0x60D4AF37),
                        width: 0.9,
                      ),
                    ),
                    child: Text(
                      sportLabel,
                      style: TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 9.5.sp,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF9E7B1A),
                        letterSpacing: 0.4,
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      batchLabel,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ==========================================
  // 2. SCORE SUMMARY BAR WITH ANALYTICS TOGGLE
  // ==========================================

  Widget _buildScoreSummaryBar(
    EvaluationSummary summary,
    StudentEvaluationReport report,
  ) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFDF5),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: const Color(0x60D4AF37), width: 1.2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x10D4AF37),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Align(
              alignment: Alignment.centerLeft,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 3.h),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD4AF37),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Text(
                        'GRADE ${summary.grade}',
                        style: TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 10.5.sp,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ),
                    SizedBox(width: 7.w),
                    Text(
                      'Total: ${summary.scoreText}',
                      style: TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    SizedBox(width: 5.w),
                    Text(
                      '(${summary.percentage.toStringAsFixed(1)}%)',
                      style: TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 11.5.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF9E7B1A),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(width: 6.w),
          InkWell(
            onTap: () {
              setState(() {
                _showFullAnalytics = !_showFullAnalytics;
              });
            },
            borderRadius: BorderRadius.circular(8.r),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 4.h),
              child: Row(
                children: [
                  Text(
                    _showFullAnalytics ? 'Hide Charts' : 'Radar Chart',
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 11.5.sp,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF9E7B1A),
                    ),
                  ),
                  SizedBox(width: 3.w),
                  Icon(
                    _showFullAnalytics
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    size: 16.sp,
                    color: const Color(0xFF9E7B1A),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // 3. CATEGORY SECTION WITH PARAMETER CARDS
  // ==========================================

  Widget _buildCategorySection(
    String headerTitle,
    List<ParameterCardModel> items,
  ) {
    if (items.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(top: 14.h, bottom: 8.h, left: 2.w),
          child: Text(
            headerTitle.toUpperCase(),
            style: TextStyle(
              fontFamily: 'Nunito',
              fontSize: 16.sp,
              fontWeight: FontWeight.w900,
              color: const Color(0xFF0F172A),
              letterSpacing: 0.2,
            ),
          ),
        ),
        ...items.map((param) => ParameterCardWidget(parameter: param)),
      ],
    );
  }

  // ==========================================
  // 4. COACH REMARKS CARD
  // ==========================================

  Widget _buildCoachRemarksCard(EvaluationSummary summary) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0x50D4AF37), width: 1.2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14D4AF37),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.format_quote_rounded, color: goldAccent, size: 20.sp),
              SizedBox(width: 6.w),
              Text(
                'Coach Remarks & Recommendations',
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w800,
                  color: darkText,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            summary.coachRemarks,
            style: TextStyle(
              fontFamily: 'Nunito',
              fontSize: 12.5.sp,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF334155),
              height: 1.4,
            ),
          ),
          SizedBox(height: 6.h),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              '- ${summary.coachName}',
              style: TextStyle(
                fontFamily: 'Nunito',
                fontSize: 11.5.sp,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF9E7B1A),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
