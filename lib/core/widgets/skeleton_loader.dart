import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';

/// Skeleton loader using Shimmer to avoid full-screen spinners.
class SkeletonLoader extends StatelessWidget {
  final double width;
  final double height;
  final BorderRadius? borderRadius;

  const SkeletonLoader({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius,
  });

  const SkeletonLoader.circle({
    super.key,
    required double size,
  })  : width = size,
        height = size,
        borderRadius = const BorderRadius.all(Radius.circular(999));

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: const Color(0xFFE4E7EC),
      highlightColor: const Color(0xFFF2F4F7),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: borderRadius ?? AppRadius.mdBorder,
        ),
      ),
    );
  }
}

/// Facility card skeleton loader.
class FacilityCardSkeleton extends StatelessWidget {
  const FacilityCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.xlBorder,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SkeletonLoader(
            width: double.infinity,
            height: 160.h,
            borderRadius: AppRadius.lgBorder,
          ),
          SizedBox(height: 12.h),
          SkeletonLoader(width: 180.w, height: 18.h),
          SizedBox(height: 6.h),
          SkeletonLoader(width: 120.w, height: 14.h),
          SizedBox(height: 14.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SkeletonLoader(width: 80.w, height: 22.h),
              SkeletonLoader(width: 90.w, height: 36.h, borderRadius: AppRadius.mdBorder),
            ],
          ),
        ],
      ),
    );
  }
}
