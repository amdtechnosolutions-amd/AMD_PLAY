import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_typography.dart';
import 'app_button.dart';

/// Card displaying an upcoming or active booking, or an invitation to book if none exists.
class BookingCard extends StatelessWidget {
  final bool hasBooking;
  final String sportName;
  final String courtName;
  final String facilityName;
  final String dateText;
  final String timeText;
  final String status;
  final VoidCallback? onViewTap;
  final VoidCallback? onFindCourtTap;

  const BookingCard({
    super.key,
    this.hasBooking = true,
    this.sportName = 'Badminton',
    this.courtName = 'Court 02',
    this.facilityName = 'Smash Arena',
    this.dateText = 'Today',
    this.timeText = '7:00 PM – 8:00 PM',
    this.status = 'CONFIRMED',
    this.onViewTap,
    this.onFindCourtTap,
  });

  @override
  Widget build(BuildContext context) {
    if (!hasBooking) {
      return Container(
        padding: EdgeInsets.all(18.w),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppRadius.xlBorder,
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: const Color(0x0A101828),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 50.h,
              height: 50.h,
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.sports_tennis_rounded, color: AppColors.primary, size: 26),
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ready to play?',
                    style: AppTypography.cardTitle.copyWith(fontWeight: FontWeight.w700),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    'Find and book a court near you in seconds.',
                    style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            SizedBox(width: 8.w),
            AppButton(
              text: 'FIND',
              onPressed: onFindCourtTap,
              width: 82.w,
              height: 38.h,
            ),
          ],
        ),
      );
    }

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: AppRadius.xlBorder,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Sport Pill & Status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  borderRadius: AppRadius.pillBorder,
                ),
                child: Text(
                  sportName.toUpperCase(),
                  style: AppTypography.badge.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: AppRadius.pillBorder,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6.h,
                      height: 6.h,
                      decoration: const BoxDecoration(
                        color: AppColors.accent,
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      status,
                      style: AppTypography.badge.copyWith(
                        color: AppColors.textInverse,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),

          // Court & Venue Info
          Text(
            '$facilityName • $courtName',
            style: AppTypography.cardTitle.copyWith(
              color: AppColors.textInverse,
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 6.h),

          // Date & Time Row
          Row(
            children: [
              const Icon(Icons.calendar_today_rounded, size: 14, color: AppColors.accent),
              SizedBox(width: 6.w),
              Text(
                dateText,
                style: AppTypography.caption.copyWith(
                  color: AppColors.textInverse,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(width: 14.w),
              const Icon(Icons.access_time_rounded, size: 14, color: AppColors.accent),
              SizedBox(width: 6.w),
              Text(
                timeText,
                style: AppTypography.caption.copyWith(
                  color: AppColors.textInverse,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),

          // Action Button
          AppButton.cta(
            text: 'VIEW BOOKING (QR & PIN)',
            onPressed: onViewTap,
            height: 42.h,
          ),
        ],
      ),
    );
  }
}
