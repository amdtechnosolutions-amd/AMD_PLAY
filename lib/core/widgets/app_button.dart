import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_typography.dart';

enum AppButtonVariant {
  primary,   // Electric Blue
  cta,       // Vibrant Athletic Yellow
  secondary, // Light Blue / Subtle Surface
  outline,   // Bordered
  danger,    // Red / Warning
}

/// A modern, responsive button component supporting various brand themes and states.
class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final bool isLoading;
  final Widget? icon;
  final double? width;
  final double? height;

  const AppButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.isLoading = false,
    this.icon,
    this.width,
    this.height,
  });

  const AppButton.cta({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
    this.width,
    this.height,
  }) : variant = AppButtonVariant.cta;

  const AppButton.outline({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
    this.width,
    this.height,
  }) : variant = AppButtonVariant.outline;

  const AppButton.secondary({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
    this.width,
    this.height,
  }) : variant = AppButtonVariant.secondary;

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    BorderSide border = BorderSide.none;

    switch (variant) {
      case AppButtonVariant.cta:
        bg = AppColors.accent;
        fg = AppColors.textPrimary;
        break;
      case AppButtonVariant.secondary:
        bg = AppColors.primaryLight;
        fg = AppColors.primary;
        break;
      case AppButtonVariant.outline:
        bg = Colors.transparent;
        fg = AppColors.primary;
        border = const BorderSide(color: AppColors.primary, width: 1.5);
        break;
      case AppButtonVariant.danger:
        bg = AppColors.error;
        fg = AppColors.textInverse;
        break;
      case AppButtonVariant.primary:
        bg = AppColors.primary;
        fg = AppColors.textInverse;
        break;
    }

    final effectiveHeight = height ?? 52.h;

    return SizedBox(
      width: width ?? double.infinity,
      height: effectiveHeight,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: bg,
          foregroundColor: fg,
          elevation: variant == AppButtonVariant.primary || variant == AppButtonVariant.cta ? 2 : 0,
          shadowColor: bg.withValues(alpha: 0.35),
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.mdBorder,
            side: border,
          ),
          padding: EdgeInsets.symmetric(horizontal: 12.w),
        ),
        child: isLoading
            ? SizedBox(
                width: 22.h,
                height: 22.h,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(fg),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    icon!,
                    SizedBox(width: 6.w),
                  ],
                  Flexible(
                    child: Text(
                      text,
                      style: AppTypography.button.copyWith(color: fg),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      softWrap: false,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
