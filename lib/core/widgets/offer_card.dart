import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_typography.dart';
import 'app_button.dart';

/// Card for promotional discounts and coupons with athletic energy.
class OfferCard extends StatelessWidget {
  final String discount;
  final String title;
  final String subtitle;
  final String? promoCode;
  final VoidCallback? onClaimTap;

  const OfferCard({
    super.key,
    required this.discount,
    required this.title,
    required this.subtitle,
    this.promoCode,
    this.onClaimTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: const Color(0xFF101828),
        borderRadius: AppRadius.xxlBorder,
        boxShadow: [
          BoxShadow(
            color: const Color(0x22101828),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background decorative subtle circles
          Positioned(
            right: -20.w,
            top: -20.h,
            child: Container(
              width: 120.h,
              height: 120.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withValues(alpha: 0.2),
              ),
            ),
          ),
          Positioned(
            right: 40.w,
            bottom: -30.h,
            child: Container(
              width: 90.h,
              height: 90.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.accent.withValues(alpha: 0.15),
              ),
            ),
          ),

          // Content
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  borderRadius: AppRadius.pillBorder,
                ),
                child: Text(
                  discount,
                  style: AppTypography.badge.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w900,
                    fontSize: 12.sp,
                  ),
                ),
              ),
              SizedBox(height: 12.h),
              Text(
                title,
                style: AppTypography.cardTitle.copyWith(
                  color: AppColors.textInverse,
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                subtitle,
                style: AppTypography.caption.copyWith(
                  color: AppColors.textMuted,
                  fontSize: 13.sp,
                ),
              ),
              SizedBox(height: 16.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (promoCode != null)
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.accent.withValues(alpha: 0.6), style: BorderStyle.solid),
                        borderRadius: AppRadius.smBorder,
                      ),
                      child: Text(
                        'CODE: $promoCode',
                        style: AppTypography.caption.copyWith(
                          color: AppColors.accent,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                    )
                  else
                    const SizedBox.shrink(),
                  AppButton.cta(
                    text: 'CLAIM OFFER',
                    onPressed: onClaimTap,
                    width: 125.w,
                    height: 38.h,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
