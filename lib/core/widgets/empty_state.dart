import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import 'app_button.dart';

/// Friendly, illustrated empty state widget adhering to sports academy design standards.
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String? buttonText;
  final VoidCallback? onButtonPressed;

  const EmptyState({
    super.key,
    this.icon = Icons.sports_tennis_rounded,
    required this.title,
    required this.message,
    this.buttonText,
    this.onButtonPressed,
  });

  const EmptyState.bookings({
    super.key,
    this.icon = Icons.confirmation_number_outlined,
    this.title = 'Your next game is waiting.',
    this.message = 'Find and book the best courts and facilities around you.',
    this.buttonText = 'FIND A COURT',
    this.onButtonPressed,
  });

  const EmptyState.membership({
    super.key,
    this.icon = Icons.card_membership_outlined,
    this.title = 'Unlock more benefits.',
    this.message = 'Get exclusive court discounts, guest passes, and priority booking.',
    this.buttonText = 'EXPLORE MEMBERSHIPS',
    this.onButtonPressed,
  });

  const EmptyState.coaching({
    super.key,
    this.icon = Icons.fitness_center_rounded,
    this.title = 'Train with the pros.',
    this.message = 'Join expert training academies and level up your skills.',
    this.buttonText = 'FIND COACHING',
    this.onButtonPressed,
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
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppColors.primary, size: 36.h),
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
            if (buttonText != null) ...[
              SizedBox(height: 22.h),
              AppButton.cta(
                text: buttonText!,
                onPressed: onButtonPressed,
                width: 200.w,
                height: 44.h,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
