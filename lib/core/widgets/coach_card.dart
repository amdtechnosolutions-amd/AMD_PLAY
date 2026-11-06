import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_typography.dart';

/// Card displaying coaching program, coach name, rating, age group, and seats.
class CoachCard extends StatelessWidget {
  final String title;
  final String coachName;
  final String sportName;
  final String imageUrl;
  final double rating;
  final String ageGroup;
  final String feeText;
  final int availableSeats;
  final VoidCallback? onTap;

  const CoachCard({
    super.key,
    required this.title,
    required this.coachName,
    required this.sportName,
    required this.imageUrl,
    this.rating = 4.9,
    this.ageGroup = 'All Ages',
    this.feeText = '₹2,500/month',
    this.availableSeats = 4,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 240.w,
        margin: EdgeInsets.only(right: 14.w),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Coach Image
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
              child: SizedBox(
                height: 110.h,
                width: double.infinity,
                child: CachedNetworkImage(
                  imageUrl: imageUrl,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(color: AppColors.surfaceSubtle),
                  errorWidget: (context, url, error) => Container(
                    color: AppColors.primaryLight,
                    child: const Center(
                      child: Icon(Icons.person_rounded, size: 40, color: AppColors.primary),
                    ),
                  ),
                ),
              ),
            ),

            // Content
            Padding(
              padding: EdgeInsets.all(12.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: AppRadius.xsBorder,
                        ),
                        child: Text(
                          sportName.toUpperCase(),
                          style: AppTypography.badge.copyWith(
                            color: AppColors.primary,
                            fontSize: 10.sp,
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.star_rounded, size: 14, color: Color(0xFFFDB022)),
                          SizedBox(width: 2.w),
                          Text(
                            rating.toStringAsFixed(1),
                            style: AppTypography.caption.copyWith(fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    title,
                    style: AppTypography.cardTitle.copyWith(fontSize: 15.sp),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    'Coach $coachName • $ageGroup',
                    style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        feeText,
                        style: AppTypography.caption.copyWith(
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                          fontSize: 13.sp,
                        ),
                      ),
                      Text(
                        '$availableSeats seats left',
                        style: AppTypography.caption.copyWith(
                          color: availableSeats <= 3 ? AppColors.error : AppColors.success,
                          fontWeight: FontWeight.w600,
                          fontSize: 11.sp,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
