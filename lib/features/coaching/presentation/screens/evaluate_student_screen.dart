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
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _studentIdController = TextEditingController();
  final TextEditingController _studentNameController = TextEditingController();
  final TextEditingController _remarksController = TextEditingController();

  String? _selectedBatchId;
  String? _selectedStudentId;
  double _physicalScore = 48.0;
  double _mentalScore = 52.0;
  double _skillScore = 54.0;
  double _attitudeScore = 56.0;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initFromArguments();
    });
  }

  void _initFromArguments() {
    final controller = Get.isRegistered<CoachEvaluationController>()
        ? Get.find<CoachEvaluationController>()
        : Get.put(CoachEvaluationController());

    final args = Get.arguments;
    if (args is Map) {
      if (args['batchId'] != null) {
        final bId = args['batchId'].toString();
        setState(() {
          _selectedBatchId = bId;
        });
        controller.loadStudentsForBatch(bId);
      }
      if (args['studentId'] != null) {
        final sId = args['studentId'].toString();
        setState(() {
          _selectedStudentId = sId;
          _studentIdController.text = sId;
        });
      }
      if (args['studentName'] != null) {
        _studentNameController.text = args['studentName'].toString();
      }
    } else if (controller.batches.isNotEmpty && _selectedBatchId == null) {
      final firstBatchId = (controller.batches.first['_id'] ?? controller.batches.first['id'])?.toString();
      if (firstBatchId != null && firstBatchId.isNotEmpty) {
        setState(() {
          _selectedBatchId = firstBatchId;
        });
        controller.loadStudentsForBatch(firstBatchId);
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _studentIdController.dispose();
    _studentNameController.dispose();
    _remarksController.dispose();
    super.dispose();
  }

  /// Reset evaluation form fields and scroll smoothly back to top for the next student
  void _resetForm() {
    setState(() {
      _selectedStudentId = null;
      _studentNameController.clear();
      _studentIdController.clear();
      _remarksController.clear();
      _physicalScore = 48.0;
      _mentalScore = 52.0;
      _skillScore = 54.0;
      _attitudeScore = 56.0;
    });
    _formKey.currentState?.reset();

    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
      );
    }
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
    if (_selectedBatchId == null || _selectedBatchId!.isEmpty) {
      Get.snackbar(
        'Batch Required',
        'Please select a coaching batch first.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.white,
        colorText: const Color(0xFFEF4444),
        borderColor: const Color(0xFFEF4444),
        borderWidth: 1.2,
        margin: const EdgeInsets.all(16),
      );
      return;
    }

    if (_studentIdController.text.trim().isEmpty) {
      Get.snackbar(
        'Student Required',
        'Please select an enrolled student from the batch dropdown.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.white,
        colorText: const Color(0xFFEF4444),
        borderColor: const Color(0xFFEF4444),
        borderWidth: 1.2,
        margin: const EdgeInsets.all(16),
      );
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    final controller = Get.isRegistered<CoachEvaluationController>()
        ? Get.find<CoachEvaluationController>()
        : Get.put(CoachEvaluationController());

    setState(() => _isSubmitting = true);

    try {
      debugPrint('[EvaluateStudentScreen] Publishing evaluation for student ${_studentIdController.text} in batch $_selectedBatchId');
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
        debugPrint('[EvaluateStudentScreen] Success response confirmed!');

        // Refresh batch student roster and controller data
        if (_selectedBatchId != null && _selectedBatchId!.isNotEmpty) {
          controller.loadStudentsForBatch(_selectedBatchId!);
        }
        await controller.fetchCoachData();

        // Reset form fields & scores back to baseline for the next evaluation
        _resetForm();

        Get.snackbar(
          'Evaluation Published!',
          'Student report has been saved. Form has been reset for the next student.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.white,
          colorText: darkText,
          borderColor: goldAccent,
          borderWidth: 1.2,
          duration: const Duration(seconds: 4),
          margin: const EdgeInsets.all(16),
        );
      }
    } catch (e) {
      debugPrint('[EvaluateStudentScreen] Submission error: $e');
      Get.snackbar(
        'Submission Response',
        e.toString().replaceAll('Exception:', '').trim(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.white,
        colorText: const Color(0xFFEF4444),
        borderColor: const Color(0xFFEF4444),
        borderWidth: 1.2,
        duration: const Duration(seconds: 6),
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
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: goldAccent),
            tooltip: 'Reset Form',
            onPressed: _resetForm,
          ),
          SizedBox(width: 8.w),
        ],
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        padding: EdgeInsets.fromLTRB(18.w, 12.h, 18.w, 40.h),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Live Grade Preview Banner
              _buildGradePreviewBanner(),
              SizedBox(height: 20.h),

              // Student & Batch Info Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Student Information',
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w800,
                      color: darkText,
                    ),
                  ),
                  Text(
                    'Batch Roster',
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF9E7B1A),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10.h),

              // 1. Coaching Batch Dropdown
              Text(
                '1. Select Coaching Batch',
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 12.5.sp,
                  fontWeight: FontWeight.w700,
                  color: darkText,
                ),
              ),
              SizedBox(height: 6.h),
              Obx(() {
                final batches = controller.batches;
                final isBatchInList = batches.any(
                  (b) => ((b['_id'] ?? b['id'])?.toString() == _selectedBatchId),
                );
                final effectiveBatchId = isBatchInList ? _selectedBatchId : null;

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
                      value: effectiveBatchId,
                      hint: Row(
                        children: [
                          Icon(Icons.groups_rounded, size: 20.sp, color: const Color(0xFFD4AF37)),
                          SizedBox(width: 8.w),
                          Text(
                            'Select Coaching Batch',
                            style: TextStyle(
                              fontFamily: 'Nunito',
                              fontSize: 13.5.sp,
                              color: const Color(0xFF94A3B8),
                            ),
                          ),
                        ],
                      ),
                      icon: Icon(Icons.keyboard_arrow_down_rounded, color: darkText, size: 22.sp),
                      items: batches.map((b) {
                        final id = (b['_id'] ?? b['id'])?.toString() ?? '';
                        final name = b['name']?.toString() ?? b['title']?.toString() ?? 'Batch';
                        final sport = (b['sport'] is Map ? b['sport']['name'] : b['sport'])?.toString();
                        return DropdownMenuItem<String>(
                          value: id,
                          child: Row(
                            children: [
                              Icon(Icons.groups_rounded, size: 19.sp, color: const Color(0xFF9E7B1A)),
                              SizedBox(width: 8.w),
                              Expanded(
                                child: Text(
                                  sport != null && sport.isNotEmpty ? '$name ($sport)' : name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontFamily: 'Nunito',
                                    fontSize: 13.5.sp,
                                    fontWeight: FontWeight.w700,
                                    color: darkText,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != _selectedBatchId) {
                          setState(() {
                            _selectedBatchId = val;
                            _selectedStudentId = null;
                            _studentNameController.clear();
                            _studentIdController.clear();
                          });
                          if (val != null && val.isNotEmpty) {
                            controller.loadStudentsForBatch(val);
                          }
                        }
                      },
                    ),
                  ),
                );
              }),
              SizedBox(height: 14.h),

              // 2. Student Dropdown (ONLY students belonging to the selected batch)
              Text(
                '2. Select Student from Batch',
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 12.5.sp,
                  fontWeight: FontWeight.w700,
                  color: darkText,
                ),
              ),
              SizedBox(height: 6.h),
              Obx(() {
                final students = controller.batchStudents;
                final isLoading = controller.isLoadingStudents.value;

                if (_selectedBatchId == null || _selectedBatchId!.isEmpty) {
                  return Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(14.r),
                      border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.lock_outline_rounded, size: 20.sp, color: const Color(0xFF94A3B8)),
                        SizedBox(width: 8.w),
                        Text(
                          'Choose a coaching batch above first',
                          style: TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: 13.sp,
                            color: const Color(0xFF94A3B8),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                if (isLoading) {
                  return Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFFDF5),
                      borderRadius: BorderRadius.circular(14.r),
                      border: Border.all(color: const Color(0x60D4AF37), width: 1.2),
                    ),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 16.h,
                          height: 16.h,
                          child: const CircularProgressIndicator(
                            strokeWidth: 2,
                            color: goldAccent,
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Text(
                          'Loading students enrolled in this batch...',
                          style: TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: 13.sp,
                            color: const Color(0xFF9E7B1A),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                if (students.isEmpty) {
                  return Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFFDF5),
                      borderRadius: BorderRadius.circular(14.r),
                      border: Border.all(color: const Color(0x40D4AF37), width: 1.2),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline_rounded, size: 20.sp, color: const Color(0xFF9E7B1A)),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: Text(
                            'No enrolled students found in this batch',
                            style: TextStyle(
                              fontFamily: 'Nunito',
                              fontSize: 13.sp,
                              color: const Color(0xFF64748B),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                final isStudentInList = students.any(
                  (s) => ((s['id'] ?? s['value'] ?? s['_id'] ?? s['studentId'])?.toString() == _selectedStudentId),
                );
                final effectiveStudentId = isStudentInList ? _selectedStudentId : null;

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
                      value: effectiveStudentId,
                      hint: Row(
                        children: [
                          Icon(Icons.person_outline_rounded, size: 20.sp, color: const Color(0xFFD4AF37)),
                          SizedBox(width: 8.w),
                          Text(
                            'Select Student (${students.length} Enrolled)',
                            style: TextStyle(
                              fontFamily: 'Nunito',
                              fontSize: 13.5.sp,
                              color: const Color(0xFF94A3B8),
                            ),
                          ),
                        ],
                      ),
                      icon: Icon(Icons.keyboard_arrow_down_rounded, color: darkText, size: 22.sp),
                      items: students.map((s) {
                        final id = (s['id'] ?? s['value'] ?? s['_id'] ?? s['studentId'])?.toString() ?? '';
                        final label = s['label']?.toString() ?? '';
                        final name = (s['name'] ?? s['fullName'] ?? 'Trainee').toString();
                        final regNo = (s['regNo'] ?? s['employeeNo'] ?? s['phone'] ?? '').toString();
                        final displayText = label.isNotEmpty
                            ? label
                            : (regNo.isNotEmpty ? '$name ($regNo)' : name);

                        return DropdownMenuItem<String>(
                          value: id,
                          child: Row(
                            children: [
                              Icon(Icons.person_rounded, size: 19.sp, color: const Color(0xFF9E7B1A)),
                              SizedBox(width: 8.w),
                              Expanded(
                                child: Text(
                                  displayText,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontFamily: 'Nunito',
                                    fontSize: 13.5.sp,
                                    fontWeight: FontWeight.w700,
                                    color: darkText,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (val) {
                        final s = students.firstWhereOrNull(
                          (st) => (st['id'] ?? st['value'] ?? st['_id'] ?? st['studentId'])?.toString() == val,
                        );
                        setState(() {
                          _selectedStudentId = val;
                          if (s != null) {
                            final name = (s['name'] ?? s['fullName'] ?? s['label'] ?? 'Trainee').toString();
                            final idVal = (s['id'] ?? s['value'] ?? s['_id'] ?? s['studentId'] ?? val)?.toString() ?? '';
                            _studentNameController.text = name;
                            _studentIdController.text = idVal;
                          }
                        });
                      },
                    ),
                  ),
                );
              }),

              // 3. Selected Student Confirmation Card
              if (_selectedStudentId != null && _studentNameController.text.isNotEmpty) ...[
                SizedBox(height: 12.h),
                Builder(
                  builder: (context) {
                    final selectedStudentData = controller.batchStudents.firstWhereOrNull(
                      (st) => (st['id'] ?? st['value'] ?? st['_id'] ?? st['studentId'])?.toString() == _selectedStudentId,
                    );
                    final reg = selectedStudentData != null
                        ? (selectedStudentData['employeeNo'] ?? selectedStudentData['regNo'] ?? selectedStudentData['phone'] ?? _studentIdController.text)
                        : _studentIdController.text;
                    final skill = selectedStudentData?['skillLevel']?.toString();

                    return Container(
                      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 11.h),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFFDF5),
                        borderRadius: BorderRadius.circular(14.r),
                        border: Border.all(color: const Color(0xFFD4AF37), width: 1.2),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x12D4AF37),
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 40.h,
                            height: 40.h,
                            decoration: const BoxDecoration(
                              color: Color(0xFFFFF8E1),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Icon(
                                Icons.sports_tennis_rounded,
                                size: 22.sp,
                                color: const Color(0xFF9E7B1A),
                              ),
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _studentNameController.text,
                                  style: TextStyle(
                                    fontFamily: 'Nunito',
                                    fontSize: 14.5.sp,
                                    fontWeight: FontWeight.w800,
                                    color: darkText,
                                  ),
                                ),
                                SizedBox(height: 2.h),
                                Text(
                                  skill != null && skill.isNotEmpty
                                      ? 'Reg: $reg • $skill'
                                      : 'Reg: $reg',
                                  style: TextStyle(
                                    fontFamily: 'Nunito',
                                    fontSize: 11.5.sp,
                                    fontWeight: FontWeight.w600,
                                    color: slateText,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8F5E9),
                              borderRadius: BorderRadius.circular(8.r),
                              border: Border.all(color: const Color(0xFF81C784), width: 0.8),
                            ),
                            child: Text(
                              'READY',
                              style: TextStyle(
                                fontFamily: 'Nunito',
                                fontSize: 10.5.sp,
                                fontWeight: FontWeight.w900,
                                color: const Color(0xFF2E7D32),
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
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

