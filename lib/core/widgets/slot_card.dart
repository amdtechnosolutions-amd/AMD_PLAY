import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_typography.dart';

enum SlotState {
  available,
  selected,
  booked,
  maintenance,
}

/// SlotCard presenting a court booking slot with distinct visual states and pricing.
class SlotCard extends StatelessWidget {
  final String timeText;
  final String? priceText;
  final SlotState state;
  final VoidCallback? onTap;

  const SlotCard({
    super.key,
    required this.timeText,
    this.priceText,
    this.state = SlotState.available,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    BorderSide border;
    Widget? stateIcon;
    String statusLabel;

    switch (state) {
      case SlotState.selected:
        bg = AppColors.primary;
        fg = AppColors.textInverse;
        border = BorderSide.none;
        stateIcon = const Icon(Icons.check_circle_rounded, color: AppColors.accent, size: 14);
        statusLabel = 'Selected';
        break;
      case SlotState.booked:
        bg = AppColors.surfaceSubtle;
        fg = AppColors.textMuted;
        border = const BorderSide(color: AppColors.borderSubtle);
        stateIcon = const Icon(Icons.lock_rounded, color: AppColors.textMuted, size: 14);
        statusLabel = 'Booked';
        break;
      case SlotState.maintenance:
        bg = AppColors.warningLight;
        fg = AppColors.warning;
        border = const BorderSide(color: AppColors.warning);
        stateIcon = const Icon(Icons.build_rounded, color: AppColors.warning, size: 14);
        statusLabel = 'Maintenance';
        break;
      case SlotState.available:
        bg = AppColors.surface;
        fg = AppColors.textPrimary;
        border = const BorderSide(color: AppColors.border);
        stateIcon = const Icon(Icons.circle_outlined, color: AppColors.success, size: 12);
        statusLabel = 'Available';
        break;
    }

    final isClickable = state == SlotState.available || state == SlotState.selected;

    return GestureDetector(
      onTap: isClickable ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: AppRadius.mdBorder,
          border: Border.fromBorderSide(border),
          boxShadow: state == SlotState.selected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.28),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              timeText,
              style: AppTypography.cardTitle.copyWith(
                color: fg,
                fontSize: 14.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 4.h),
            if (priceText != null && state != SlotState.booked && state != SlotState.maintenance) ...[
              Text(
                priceText!,
                style: AppTypography.caption.copyWith(
                  color: state == SlotState.selected ? AppColors.accent : AppColors.primary,
                  fontWeight: FontWeight.w700,
                  fontSize: 12.sp,
                ),
              ),
              SizedBox(height: 2.h),
            ],
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                stateIcon,
                SizedBox(width: 4.w),
                Text(
                  statusLabel,
                  style: AppTypography.caption.copyWith(
                    color: fg.withValues(alpha: 0.8),
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
