import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_button.dart';
import '../controllers/onboarding_controller.dart';

/// Premium 3-screen Onboarding flow with sports imagery, smooth page indicators, and vibrant CTA.
class OnboardingScreen extends GetView<OnboardingController> {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar: Skip Button
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Obx(() {
                    if (controller.currentPage.value == controller.items.length - 1) {
                      return SizedBox(height: 36.h);
                    }
                    return TextButton(
                      onPressed: controller.finishOnboarding,
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.textSecondary,
                        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                      ),
                      child: Text(
                        'SKIP',
                        style: AppTypography.button.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 13.sp,
                          letterSpacing: 0.5,
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),

            // Page View
            Expanded(
              child: PageView.builder(
                controller: controller.pageController,
                itemCount: controller.items.length,
                onPageChanged: controller.onPageChanged,
                itemBuilder: (context, index) {
                  final item = controller.items[index];
                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Large rounded sports imagery container
                        Expanded(
                          flex: 6,
                          child: Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: AppRadius.xxlBorder,
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0x1A101828),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: AppRadius.xxlBorder,
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  CachedNetworkImage(
                                    imageUrl: item.imageUrl,
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) => Container(
                                      color: AppColors.surfaceSubtle,
                                      child: const Center(
                                        child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                                      ),
                                    ),
                                    errorWidget: (context, url, error) => Container(
                                      color: AppColors.primaryDark,
                                      child: Center(
                                        child: Icon(item.sportIcon, size: 72.h, color: AppColors.accent),
                                      ),
                                    ),
                                  ),
                                  // Gradient Overlay
                                  Container(
                                    decoration: const BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Colors.transparent,
                                          Color(0x80101828),
                                        ],
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 28.h),

                        // Headline & Subtitle
                        Expanded(
                          flex: 3,
                          child: Column(
                            children: [
                              Text(
                                item.headline,
                                style: AppTypography.display.copyWith(
                                  fontSize: 28.sp,
                                  fontWeight: FontWeight.w800,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: 12.h),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 16.w),
                                child: Text(
                                  item.subtitle,
                                  style: AppTypography.subtitle.copyWith(
                                    fontSize: 15.sp,
                                    color: AppColors.textSecondary,
                                    height: 1.45,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Bottom Navigation Controls
            Padding(
              padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 24.h),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Page Indicators
                  Obx(() => Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          controller.items.length,
                          (index) {
                            final isCurrent = controller.currentPage.value == index;
                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              curve: Curves.easeInOut,
                              margin: EdgeInsets.symmetric(horizontal: 4.w),
                              width: isCurrent ? 28.w : 8.w,
                              height: 8.h,
                              decoration: BoxDecoration(
                                color: isCurrent ? AppColors.primary : AppColors.border,
                                borderRadius: AppRadius.pillBorder,
                              ),
                            );
                          },
                        ),
                      )),
                  SizedBox(height: 24.h),

                  // Action Button
                  Obx(() {
                    final isLastPage = controller.currentPage.value == controller.items.length - 1;
                    return AppButton.cta(
                      text: isLastPage ? 'GET STARTED' : 'CONTINUE',
                      onPressed: controller.next,
                      height: 52.h,
                      icon: isLastPage
                          ? const Icon(Icons.bolt_rounded, color: AppColors.textPrimary)
                          : const Icon(Icons.arrow_forward_rounded, color: AppColors.textPrimary),
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
