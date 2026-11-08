import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../controllers/onboarding_controller.dart';

/// Premium 3-screen Onboarding flow with sports imagery, smooth page indicators, and luxury gold-bordered CTA.
class OnboardingScreen extends GetView<OnboardingController> {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
                        foregroundColor: const Color(0xFF64748B),
                        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                      ),
                      child: Text(
                        'SKIP',
                        style: TextStyle(
                          fontFamily: 'Nunito',
                          color: const Color(0xFF64748B),
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w700,
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
                        // Large rounded sports imagery container with gold card shadow
                        Expanded(
                          flex: 6,
                          child: Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(24.r),
                              border: Border.all(
                                color: const Color(0x60D4AF37),
                                width: 1.5,
                              ),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x28D4AF37),
                                  blurRadius: 24,
                                  offset: Offset(0, 10),
                                ),
                                BoxShadow(
                                  color: Color(0x0C000000),
                                  blurRadius: 6,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(22.5.r),
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  CachedNetworkImage(
                                    imageUrl: item.imageUrl,
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) => Container(
                                      color: const Color(0xFFFFFDF5),
                                      child: const Center(
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Color(0xFFD4AF37),
                                        ),
                                      ),
                                    ),
                                    errorWidget: (context, url, error) => Container(
                                      color: const Color(0xFF0F172A),
                                      child: Center(
                                        child: Icon(
                                          item.sportIcon,
                                          size: 72.h,
                                          color: const Color(0xFFD4AF37),
                                        ),
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
                                style: TextStyle(
                                  fontFamily: 'Nunito',
                                  fontSize: 26.sp,
                                  fontWeight: FontWeight.w900,
                                  color: const Color(0xFF0F172A),
                                  letterSpacing: -0.3,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: 12.h),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 16.w),
                                child: Text(
                                  item.subtitle,
                                  style: TextStyle(
                                    fontFamily: 'Nunito',
                                    fontSize: 14.5.sp,
                                    fontWeight: FontWeight.w500,
                                    color: const Color(0xFF64748B),
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
                                color: isCurrent
                                    ? const Color(0xFFD4AF37)
                                    : const Color(0x40D4AF37),
                                borderRadius: BorderRadius.circular(4.r),
                              ),
                            );
                          },
                        ),
                      )),
                  SizedBox(height: 24.h),

                  // Action Button - pure white with app color border and gold shadow
                  Obx(() {
                    final isLastPage = controller.currentPage.value == controller.items.length - 1;
                    return Container(
                      width: double.infinity,
                      height: 52.h,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16.r),
                        border: Border.all(
                          color: const Color(0xFFD4AF37),
                          width: 1.8,
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x28D4AF37),
                            blurRadius: 14,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16.r),
                          onTap: controller.next,
                          child: Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  isLastPage ? 'GET STARTED' : 'CONTINUE',
                                  style: TextStyle(
                                    fontFamily: 'Nunito',
                                    fontSize: 15.sp,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.8,
                                    color: const Color(0xFF0F172A),
                                  ),
                                ),
                                SizedBox(width: 8.w),
                                Icon(
                                  isLastPage ? Icons.bolt_rounded : Icons.arrow_forward_rounded,
                                  color: const Color(0xFFD4AF37),
                                  size: 20.sp,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
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
