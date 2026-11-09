import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../controllers/coach_evaluation_controller.dart';

/// Screen allowing Coaches to conduct and record performance evaluations
/// across Physical, Mental, Skill, and Attitude categories with live grading.
class EvaluateStudentScreen extends StatefulWidget {
  const EvaluateStudentScreen({super.key});

  @override
  State<EvaluateStudentScreen> createState() => _EvaluateStudentScreenState();
}

class _EvaluateStudentScreenState extends State<EvaluateStudentScreen> {
  static const Color goldAccent = Color(0xFFD4AF37);
  static const Color darkText = Color(0xFF0F172A);
  static const Color slateText = Color(0xFF64748B);

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _studentIdController = TextEditingController();
  final TextEditingController _studentNameController = TextEditingController();
  final TextEditingController _remarksController = TextEditingController();

  String? _selectedBatchId;
  double _physicalScore = 48.0;
  double _mentalScore = 52.0;
  double _skillScore = 54.0;
  double _attitudeScore = 56.0;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _studentIdController.dispose();
    _studentNameController.dispose();
    _remarksController.dispose();
    super.dispose();
  }

  double get _totalScore => _physicalScore + _mentalScore + _skillScore + _attitudeScore;
  double get _percentage => (_totalScore / 240.0) * 100.0;

  String get _computedGrade {
    if (_percentage >= 90) return 'A+';
    if (_percentage >= 80) return 'A';
    if (_percentage >= 70) return 'B';
    if (_percentage >= 60) return 'C';
    return 'D';
  }

  String get _performanceLevel {
    if (_percentage >= 90) return 'Elite';
    if (_percentage >= 80) return 'Excellent';
    if (_percentage >= 70) return 'Good';
    if (_percentage >= 60) return 'Satisfactory';
    return 'Needs Improvement';
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    final controller = Get.isRegistered<CoachEvaluationController>()
        ? Get.find<CoachEvaluationController>()
        : Get.put(CoachEvaluationController());

    setState(() => _isSubmitting = true);

    try {
      final success = await controller.submitEvaluation(
        studentId: _studentIdController.text.trim(),
        batchId: _selectedBatchId,
        physicalScore: _physicalScore,
        mentalScore: _mentalScore,
        skillScore: _skillScore,
        attitudeScore: _attitudeScore,
        remarks: _remarksController.text.trim().isNotEmpty
            ? _remarksController.text.trim()
            : 'Strong performance and positive engagement in coaching drills.',
      );

      if (success) {
        Get.snackbar(
          'Evaluation Published',
          'Student performance report has been successfully recorded.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.white,
          colorText: darkText,
          borderColor: goldAccent,
          borderWidth: 1.2,
          margin: const EdgeInsets.all(16),
        );
        Get.back();
      }
    } catch (e) {
      Get.snackbar(
        'Submission Failed',
        e.toString().replaceAll('Exception:', '').trim(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.white,
        colorText: const Color(0xFFEF4444),
        borderColor: const Color(0xFFEF4444),
        borderWidth: 1.2,
        margin: const EdgeInsets.all(16),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.isRegistered<CoachEvaluationController>()
        ? Get.find<CoachEvaluationController>()
        : Get.put(CoachEvaluationController());

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Evaluate Student',
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: darkText),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(18.w, 12.h, 18.w, 40.h),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Live Grade Preview Banner
              _buildGradePreviewBanner(),
              SizedBox(height: 20.h),

              // Student & Batch Info
              Text(
                'Student Information',
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w800,
                  color: darkText,
                ),
              ),
              SizedBox(height: 10.h),

              // Student Name
              _buildTextFormField(
                controller: _studentNameController,
                label: 'Student Name',
                hint: 'e.g. Rahul Sharma',
                icon: Icons.person_outline_rounded,
                validator: (val) =>
                    val == null || val.trim().isEmpty ? 'Please enter student name' : null,
              ),
              SizedBox(height: 12.h),

              // Student ID / Reg No
              _buildTextFormField(
                controller: _studentIdController,
                label: 'Student Reg. No / Student ID',
                hint: 'e.g. 1024 or MongoDB Student ID',
                icon: Icons.badge_outlined,
                validator: (val) =>
                    val == null || val.trim().isEmpty ? 'Please enter student ID' : null,
              ),
              SizedBox(height: 12.h),

              // Batch Selector
              Obx(() {
                final batches = controller.batches;
                return Container(
                  padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14.r),
                    border: Border.all(color: const Color(0x60D4AF37), width: 1.2),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: _selectedBatchId,
                      hint: Text(
                        'Select Coaching Batch',
                        style: TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 13.5.sp,
                          color: const Color(0xFF94A3B8),
                        ),
                      ),
                      items: batches.map((b) {
                        final id = b['_id']?.toString() ?? '';
                        final name = b['name']?.toString() ?? b['title']?.toString() ?? 'Batch';
                        return DropdownMenuItem<String>(
                          value: id,
                          child: Text(
                            name,
                            style: TextStyle(
                              fontFamily: 'Nunito',
                              fontSize: 13.5.sp,
                              fontWeight: FontWeight.w700,
                              color: darkText,
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (val) {
                        setState(() => _selectedBatchId = val);
                      },
                    ),
                  ),
                );
              }),
              SizedBox(height: 24.h),

              // 4 Core Category Sliders
              Text(
                'Performance Assessment (0 - 60 pts)',
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w800,
                  color: darkText,
                ),
              ),
              SizedBox(height: 14.h),

              // 1. Physical Score
              _buildCategorySlider(
                title: 'Physical Condition & Stamina',
                value: _physicalScore,
                color: const Color(0xFF10B981),
                onChanged: (val) => setState(() => _physicalScore = val),
              ),
              SizedBox(height: 12.h),

              // 2. Mental Score
              _buildCategorySlider(
                title: 'Mental Focus & Resilience',
                value: _mentalScore,
                color: const Color(0xFF6366F1),
                onChanged: (val) => setState(() => _mentalScore = val),
              ),
              SizedBox(height: 12.h),

              // 3. Skill Score
              _buildCategorySlider(
                title: 'Technical Skill & Execution',
                value: _skillScore,
                color: const Color(0xFFF59E0B),
                onChanged: (val) => setState(() => _skillScore = val),
              ),
              SizedBox(height: 12.h),

              // 4. Attitude Score
              _buildCategorySlider(
                title: 'Discipline & Sportsmanship',
                value: _attitudeScore,
                color: const Color(0xFF8B5CF6),
                onChanged: (val) => setState(() => _attitudeScore = val),
              ),
              SizedBox(height: 20.h),

              // Coach Remarks Field
              Text(
                'Coach Remarks & Recommendations',
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w800,
                  color: darkText,
                ),
              ),
              SizedBox(height: 8.h),
              TextFormField(
                controller: _remarksController,
                maxLines: 4,
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 13.5.sp,
                  color: darkText,
                ),
                decoration: InputDecoration(
                  hintText: 'Provide specific feedback, drill strengths, and areas to improve in next training sessions...',
                  hintStyle: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 12.5.sp,
                    color: const Color(0xFF94A3B8),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: EdgeInsets.all(14.w),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14.r),
                    borderSide: const BorderSide(color: Color(0x60D4AF37), width: 1.2),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14.r),
                    borderSide: const BorderSide(color: Color(0x60D4AF37), width: 1.2),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14.r),
                    borderSide: const BorderSide(color: goldAccent, width: 1.5),
                  ),
                ),
              ),
              SizedBox(height: 28.h),

              // Submit Button
              Container(
                width: double.infinity,
                height: 50.h,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(color: goldAccent, width: 1.5),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x28D4AF37),
                      blurRadius: 16,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16.r),
                    onTap: _isSubmitting ? null : _handleSubmit,
                    child: Center(
                      child: _isSubmitting
                          ? SizedBox(
                              width: 22.w,
                              height: 22.w,
                              child: const CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: goldAccent,
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.check_circle_outline_rounded,
                                    size: 20.sp, color: const Color(0xFF9E7B1A)),
                                SizedBox(width: 8.w),
                                Text(
                                  'PUBLISH EVALUATION REPORT',
                                  style: TextStyle(
                                    fontFamily: 'Nunito',
                                    fontSize: 13.5.sp,
                                    fontWeight: FontWeight.w900,
                                    color: const Color(0xFF0F172A),
                                    letterSpacing: 0.6,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // HELPER WIDGETS
  // ===========================================================================

  Widget _buildGradePreviewBanner() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFDF5),
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: goldAccent, width: 1.2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x18D4AF37),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'LIVE SCORE PREVIEW',
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 10.5.sp,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF9E7B1A),
                  letterSpacing: 1.0,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                '${_totalScore.toInt()} / 240 pts (${_percentage.toStringAsFixed(1)}%)',
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 17.sp,
                  fontWeight: FontWeight.w900,
                  color: darkText,
                ),
              ),
              Text(
                'Tier: $_performanceLevel',
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 11.5.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF059669),
                ),
              ),
            ],
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(color: goldAccent, width: 1.3),
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
                  _computedGrade,
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 22.sp,
                    fontWeight: FontWeight.w900,
                    color: darkText,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      style: TextStyle(
        fontFamily: 'Nunito',
        fontSize: 13.5.sp,
        fontWeight: FontWeight.w600,
        color: darkText,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          fontFamily: 'Nunito',
          fontSize: 13.sp,
          color: slateText,
        ),
        hintText: hint,
        hintStyle: TextStyle(
          fontFamily: 'Nunito',
          fontSize: 12.5.sp,
          color: const Color(0xFF94A3B8),
        ),
        prefixIcon: Icon(icon, size: 18.sp, color: goldAccent),
        filled: true,
        fillColor: Colors.white,
        contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14.r),
          borderSide: const BorderSide(color: Color(0x60D4AF37), width: 1.2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14.r),
          borderSide: const BorderSide(color: Color(0x60D4AF37), width: 1.2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14.r),
          borderSide: const BorderSide(color: goldAccent, width: 1.5),
        ),
      ),
    );
  }

  Widget _buildCategorySlider({
    required String title,
    required double value,
    required Color color,
    required ValueChanged<double> onChanged,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 12.5.sp,
                  fontWeight: FontWeight.w700,
                  color: darkText,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Text(
                  '${value.toInt()} / 60',
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 11.5.sp,
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: color,
              inactiveTrackColor: color.withValues(alpha: 0.15),
              thumbColor: color,
              overlayColor: color.withValues(alpha: 0.2),
              trackHeight: 4.h,
            ),
            child: Slider(
              value: value,
              min: 0,
              max: 60,
              divisions: 60,
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}
