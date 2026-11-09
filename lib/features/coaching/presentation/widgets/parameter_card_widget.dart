import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mobile_app/features/coaching/data/models/student_evaluation_model.dart';

/// Clean card displaying individual parameter evaluation metric
class ParameterCardWidget extends StatelessWidget {
  final ParameterCardModel parameter;

  const ParameterCardWidget({super.key, required this.parameter});

  @override
  Widget build(BuildContext context) {
    Color categoryColor = const Color(0xFFD4AF37);
    final catLower = parameter.category.toLowerCase();
    if (catLower.contains('physical')) {
      categoryColor = const Color(0xFF10B981);
    } else if (catLower.contains('mental')) {
      categoryColor = const Color(0xFF3B82F6);
    } else if (catLower.contains('attitude')) {
      categoryColor = const Color(0xFF8B5CF6);
    }

    final double progress = (parameter.percentage / 100.0).clamp(0.0, 1.0);

    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0x50D4AF37), width: 1.2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12D4AF37),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Parameter Name
              Expanded(
                child: Text(
                  parameter.name,
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF0F172A),
                  ),
                ),
              ),

              // Category Pill
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                decoration: BoxDecoration(
                  color: categoryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(
                    color: categoryColor.withValues(alpha: 0.4),
                    width: 0.8,
                  ),
                ),
                child: Text(
                  parameter.category.toUpperCase(),
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 9.5.sp,
                    fontWeight: FontWeight.w900,
                    color: categoryColor,
                    letterSpacing: 0.4,
                  ),
                ),
              ),
            ],
          ),

          if (parameter.description.isNotEmpty) ...[
            SizedBox(height: 6.h),
            Text(
              parameter.description,
              style: TextStyle(
                fontFamily: 'Nunito',
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF64748B),
                height: 1.35,
              ),
            ),
          ],
          SizedBox(height: 12.h),

          // Score bar & percentage
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6.r),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 8.h,
                    backgroundColor: const Color(0xFFF1F5F9),
                    valueColor: AlwaysStoppedAnimation<Color>(categoryColor),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Text(
                '${parameter.score.toStringAsFixed(parameter.score % 1 == 0 ? 0 : 1)}/${parameter.maxScore.toInt()}',
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF0F172A),
                ),
              ),
              SizedBox(width: 6.w),
              Text(
                '(${parameter.percentage.toInt()}%)',
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w700,
                  color: categoryColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
