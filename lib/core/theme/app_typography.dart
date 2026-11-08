import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'app_colors.dart';

/// Typography hierarchy implementing asset font Nunito with responsive font scaling.
class AppTypography {
  AppTypography._();

  static const String fontFamily = 'Nunito';

  static TextStyle nunito({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? letterSpacing,
    double? height,
    TextDecoration? decoration,
  }) {
    return TextStyle(
      fontFamily: fontFamily,
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      letterSpacing: letterSpacing,
      height: height,
      decoration: decoration,
    );
  }

  // Display (Hero / Big Onboarding)
  static TextStyle get display => nunito(
        fontSize: 34.sp,
        fontWeight: FontWeight.w800,
        color: AppColors.textPrimary,
        letterSpacing: -0.8,
        height: 1.15,
      );

  // Screen Title (Header of main pages)
  static TextStyle get screenTitle => nunito(
        fontSize: 26.sp,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        letterSpacing: -0.5,
        height: 1.25,
      );

  // Section Title (Section headings)
  static TextStyle get sectionTitle => nunito(
        fontSize: 19.sp,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        letterSpacing: -0.3,
        height: 1.3,
      );

  // Card Title
  static TextStyle get cardTitle => nunito(
        fontSize: 16.sp,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
        letterSpacing: -0.2,
        height: 1.35,
      );

  // Subtitle / Medium
  static TextStyle get subtitle => nunito(
        fontSize: 15.sp,
        fontWeight: FontWeight.w500,
        color: AppColors.textSecondary,
        height: 1.4,
      );

  // Body Regular
  static TextStyle get body => nunito(
        fontSize: 14.sp,
        fontWeight: FontWeight.w400,
        color: AppColors.textPrimary,
        height: 1.45,
      );

  // Body Medium
  static TextStyle get bodyMedium => nunito(
        fontSize: 14.sp,
        fontWeight: FontWeight.w500,
        color: AppColors.textPrimary,
        height: 1.45,
      );

  // Button Label
  static TextStyle get button => nunito(
        fontSize: 15.sp,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
        height: 1.2,
      );

  // Caption / Micro
  static TextStyle get caption => nunito(
        fontSize: 12.sp,
        fontWeight: FontWeight.w400,
        color: AppColors.textSecondary,
        height: 1.3,
      );

  // Badge / Chip
  static TextStyle get badge => nunito(
        fontSize: 11.sp,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.3,
        height: 1.2,
      );
}
