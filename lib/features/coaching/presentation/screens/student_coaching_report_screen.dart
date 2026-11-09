import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../core/widgets/empty_state.dart';
import '../controllers/student_evaluation_controller.dart';
import '../widgets/evaluation_radar_chart.dart';
import '../widgets/evaluation_trend_chart.dart';
import '../widgets/parameter_card_widget.dart';

/// Screen displaying Logged-in Student Coaching Performance Report & Scorecard
/// Backed by live endpoints:
/// - GET /api/v1/students/my/evaluations
/// - GET /api/v1/students/my/evaluations/latest
class StudentCoachingReportScreen extends StatelessWidget {
  const StudentCoachingReportScreen({super.key});

  static const Color goldAccent = Color(0xFFD4AF37);
  static const Color darkText = Color(0xFF0F172A);
  static const Color slateText = Color(0xFF64748B);

  @override
  Widget build(BuildContext context) {
    final controller = Get.isRegistered<StudentEvaluationController>()
        ? Get.find<StudentEvaluationController>()
        : Get.put(StudentEvaluationController());

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Coaching Report',
          style: TextStyle(
            fontFamily: 'Nunito',
            fontSize: 18.sp,
            fontWeight: FontWeight.w800,
            color: darkText,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: darkText),
          onPressed: () => Get.back(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: goldAccent),
            tooltip: 'Refresh Evaluations',
            onPressed: controller.fetchEvaluations,
          ),
        ],
      ),
      body: RefreshIndicator(
        color: goldAccent,
        backgroundColor: Colors.white,
        onRefresh: controller.fetchEvaluations,
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
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 60.h),
              child: EmptyState(
                title: 'Report Unavailable',
                message: controller.errorMessage.value.isNotEmpty
                    ? controller.errorMessage.value
                    : 'Unable to load coaching performance report. Please check your connection or sign in as a student.',
                icon: Icons.assessment_outlined,
                buttonText: 'RETRY',
                onButtonPressed: controller.fetchEvaluations,
              ),
            );
          }

          final report = controller.report.value;
          if (report == null) {
            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 60.h),
              child: EmptyState(
                title: 'No Performance Evaluations Yet',
                message:
                    'Your academy coaches have not published an evaluation scorecard for your profile yet. Once assessed, your skill radar, 24-parameter metrics, and historical trends will appear here.',
                icon: Icons.sports_score_rounded,
                buttonText: 'REFRESH',
                onButtonPressed: controller.fetchEvaluations,
              ),
            );
          }

          final summary = report.summary;

          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 40.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Overall Scorecard Summary Card
                _buildSummaryHeroCard(summary),
                SizedBox(height: 20.h),

                // 2. Coach Remarks Card
                if (summary.coachRemarks.isNotEmpty) ...[
                  _buildCoachRemarksCard(summary),
                  SizedBox(height: 20.h),
                ],

                // 3. Category Radar / Spider Chart (Physical, Mental, Skill, Attitude)
                if (report.radarData.isNotEmpty) ...[
                  EvaluationRadarChart(categories: report.radarData),
                  SizedBox(height: 20.h),
                ],

                // 4. Progress Trend Line Chart
                if (report.trend.isNotEmpty) ...[
                  EvaluationTrendChart(trend: report.trend),
                  SizedBox(height: 20.h),
                ],

                // 5. Individual Parameter Cards (All 24 parameters formatted)
                if (report.parameterCards.isNotEmpty) ...[
                  _buildParametersHeader(controller),
                  SizedBox(height: 12.h),
                  _buildCategoryFilterBar(controller),
                  SizedBox(height: 14.h),
                  ...controller.filteredParameters.map(
                    (param) => ParameterCardWidget(parameter: param),
                  ),
                ],
              ],
            ),
          );
        }),
      ),
    );
  }

  // ==========================================
  // HERO SCORECARD SUMMARY
  // ==========================================

  Widget _buildSummaryHeroCard(dynamic summary) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22.r),
        border: Border.all(
          color: const Color(0x60D4AF37),
          width: 1.5,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x28D4AF37),
            blurRadius: 20,
            offset: Offset(0, 6),
          ),
          BoxShadow(
            color: Color(0x0C000000),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFBEB),
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(color: const Color(0xFFF59E0B), width: 1),
                ),
                child: Row(
                  children: [
                    Icon(Icons.workspace_premium_rounded, size: 13.sp, color: const Color(0xFFB45309)),
                    SizedBox(width: 4.w),
                    Text(
                      'LATEST SCORECARD',
                      style: TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 10.5.sp,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFFB45309),
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFECFDF5),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: const Color(0xFF10B981), width: 1),
                ),
                child: Text(
                  summary.performanceLevel.toUpperCase(),
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 10.5.sp,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF047857),
                    letterSpacing: 0.4,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),

          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Circular Grade Badge
              Container(
                width: 72.h,
                height: 72.h,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFFFFDF5),
                  border: Border.all(color: goldAccent, width: 2.2),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x30D4AF37),
                      blurRadius: 14,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        summary.grade,
                        style: TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 26.sp,
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFF9E7B1A),
                          height: 1.0,
                        ),
                      ),
                      Text(
                        'GRADE',
                        style: TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 8.5.sp,
                          fontWeight: FontWeight.w800,
                          color: slateText,
                          letterSpacing: 0.6,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(width: 16.w),

              // Overall Score & Percentage
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${summary.percentage.toStringAsFixed(1)}%',
                      style: TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 28.sp,
                        fontWeight: FontWeight.w900,
                        color: darkText,
                        height: 1.1,
                      ),
                    ),
                    SizedBox(height: 3.h),
                    Text(
                      'Score: ${summary.scoreText} points',
                      style: TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 13.5.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF9E7B1A),
                      ),
                    ),
                    if (summary.batchName.isNotEmpty) ...[
                      SizedBox(height: 3.h),
                      Text(
                        '${summary.sportName} • ${summary.batchName}',
                        style: TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w500,
                          color: slateText,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==========================================
  // COACH REMARKS CARD
  // ==========================================

  Widget _buildCoachRemarksCard(dynamic summary) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: const Color(0x50D4AF37), width: 1.2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14D4AF37),
            blurRadius: 14,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.format_quote_rounded, color: goldAccent, size: 22.sp),
              SizedBox(width: 6.w),
              Text(
                'Coach Remarks & Recommendations',
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 14.5.sp,
                  fontWeight: FontWeight.w800,
                  color: darkText,
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Text(
            summary.coachRemarks,
            style: TextStyle(
              fontFamily: 'Nunito',
              fontSize: 13.sp,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF334155),
              height: 1.45,
            ),
          ),
          SizedBox(height: 10.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                '- ${summary.coachName}',
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF9E7B1A),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==========================================
  // PARAMETERS LIST & CATEGORY FILTER
  // ==========================================

  Widget _buildParametersHeader(StudentEvaluationController controller) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(Icons.checklist_rtl_rounded, color: goldAccent, size: 22.sp),
            SizedBox(width: 8.w),
            Text(
              'Detailed Parameters',
              style: TextStyle(
                fontFamily: 'Nunito',
                fontSize: 16.5.sp,
                fontWeight: FontWeight.w900,
                color: darkText,
              ),
            ),
          ],
        ),
        Obx(
          () => Text(
            '${controller.filteredParameters.length} Metrics',
            style: TextStyle(
              fontFamily: 'Nunito',
              fontSize: 12.sp,
              fontWeight: FontWeight.w700,
              color: slateText,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryFilterBar(StudentEvaluationController controller) {
    return Obx(() {
      final categories = controller.availableCategories;
      final selected = controller.selectedCategoryFilter.value;

      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: categories.map((cat) {
            final isSelected = selected == cat;
            return Padding(
              padding: EdgeInsets.only(right: 8.w),
              child: GestureDetector(
                onTap: () => controller.setCategoryFilter(cat),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFFFFFDF5) : Colors.white,
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(
                      color: isSelected ? goldAccent : const Color(0xFFE2E8F0),
                      width: isSelected ? 1.5 : 1.0,
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
                    cat,
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 11.5.sp,
                      fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                      color: isSelected ? const Color(0xFF9E7B1A) : slateText,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      );
    });
  }
}

