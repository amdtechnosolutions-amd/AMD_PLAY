import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import 'app_button.dart';

/// Friendly error state with retry button, avoiding raw API errors.
class ErrorState extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback? onRetry;

  const ErrorState({
    super.key,
    this.title = "Oops! We couldn't load the courts.",
    this.message = 'Please check your internet connection or try again.',
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 76.h,
              height: 76.h,
              decoration: const BoxDecoration(
                color: AppColors.errorLight,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.cloud_off_rounded, color: AppColors.error, size: 36.h),
            ),
            SizedBox(height: 18.h),
            Text(
              title,
              style: AppTypography.cardTitle.copyWith(fontSize: 18.sp, fontWeight: FontWeight.w700),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 6.h),
            Text(
              message,
              style: AppTypography.caption.copyWith(
                fontSize: 13.sp,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              SizedBox(height: 22.h),
              AppButton(
                text: 'TRY AGAIN',
                onPressed: onRetry,
                width: 160.w,
                height: 44.h,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
