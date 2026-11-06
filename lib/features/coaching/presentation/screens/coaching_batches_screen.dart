import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

class CoachingBatchesScreen extends StatelessWidget {
  const CoachingBatchesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final batches = [
      {
        'title': 'Elite Junior Badminton Academy',
        'sport': 'Badminton',
        'coach': 'Ramesh Sen (BWF Level 2)',
        'timing': 'Mon, Wed, Fri • 06:00 AM - 07:30 AM',
        'level': 'Intermediate / Advanced',
        'fee': '₹4,500/month',
        'enrolled': 10,
        'capacity': 12,
        'attendanceRate': '92%',
      },
      {
        'title': 'Junior Grand Slam Tennis Clinic',
        'sport': 'Tennis',
        'coach': 'Sania M. & Pro Academy Staff',
        'timing': 'Tue, Thu, Sat • 04:00 PM - 05:30 PM',
        'level': 'Beginner to Intermediate',
        'fee': '₹6,500/month',
        'enrolled': 8,
        'capacity': 8,
        'attendanceRate': '96%',
      },
      {
        'title': 'Pickleball Masters Training',
        'sport': 'Pickleball',
        'coach': 'Dev Chopra (National Champion)',
        'timing': 'Sat & Sun • 08:00 AM - 09:30 AM',
        'level': 'All Levels',
        'fee': '₹3,500/month',
        'enrolled': 14,
        'capacity': 16,
        'attendanceRate': '88%',
      },
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Coaching Academy & Batches', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0.5,
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(16.w),
        itemCount: batches.length,
        itemBuilder: (context, index) {
          final b = batches[index];
          final isFull = (b['enrolled'] as int) >= (b['capacity'] as int);

          return Container(
            margin: EdgeInsets.only(bottom: 16.h),
            padding: EdgeInsets.all(18.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: Colors.grey.shade200),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
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
                      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                      child: Text(
                        (b['sport'] as String).toUpperCase(),
                        style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.bold, color: AppColors.primary),
                      ),
                    ),
                    Text(
                      b['fee'] as String,
                      style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w800, color: AppColors.primary),
                    ),
                  ],
                ),
                SizedBox(height: 10.h),
                Text(b['title'] as String, style: AppTypography.cardTitle),
                SizedBox(height: 4.h),
                Text('Coach: ${b['coach']}', style: TextStyle(fontSize: 12.sp, color: AppColors.textSecondary)),
                const Divider(height: 20),
                Row(
                  children: [
                    const Icon(Icons.schedule_rounded, size: 15, color: AppColors.textSecondary),
                    SizedBox(width: 6.w),
                    Expanded(
                      child: Text(b['timing'] as String,
                          style: TextStyle(fontSize: 12.sp, color: AppColors.textSecondary)),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),

                // Capacity Bar
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Batch Capacity', style: TextStyle(fontSize: 11.sp, color: AppColors.textSecondary)),
                    Text(
                      isFull ? 'BATCH FULL (${b['capacity']}/${b['capacity']})' : '${b['enrolled']} / ${b['capacity']} Enrolled',
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.bold,
                        color: isFull ? const Color(0xFFD92D20) : const Color(0xFF079455),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 6.h),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4.r),
                  child: LinearProgressIndicator(
                    value: (b['enrolled'] as int) / (b['capacity'] as int),
                    backgroundColor: Colors.grey.shade100,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isFull ? const Color(0xFFD92D20) : AppColors.primary,
                    ),
                    minHeight: 6.h,
                  ),
                ),
                SizedBox(height: 16.h),

                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Get.bottomSheet(
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(b['title'] as String, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                  const SizedBox(height: 8),
                                  Text('Overall Student Attendance: ${b['attendanceRate']}', style: const TextStyle(color: Color(0xFF079455), fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 16),
                                  const Text('Recent Sessions:'),
                                  const ListTile(
                                    leading: Icon(Icons.check_circle, color: Color(0xFF079455)),
                                    title: Text('Session 24 - Net Play & Drills'),
                                    subtitle: Text('Present (Attendance marked)'),
                                  ),
                                  const ListTile(
                                    leading: Icon(Icons.check_circle, color: Color(0xFF079455)),
                                    title: Text('Session 23 - Footwork Agility'),
                                    subtitle: Text('Present (Attendance marked)'),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.grey.shade300),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text('ATTENDANCE'),
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: isFull
                            ? null
                            : () {
                                Get.snackbar(
                                  'Enrollment Request',
                                  'Enrolled in ${b['title']}. Academy admin will verify.',
                                  snackPosition: SnackPosition.BOTTOM,
                                );
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: Text(isFull ? 'FULL' : 'ENROLL', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
