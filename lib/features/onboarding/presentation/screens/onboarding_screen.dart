import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../controllers/onboarding_controller.dart';

/// Premium animated 3-screen Onboarding flow showcasing Badminton, Turf & Pickleball.
/// Features pure white background, #d4af37 luxury drop shadows, and cinematic image breathing animation.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  late final OnboardingController controller;
  late final AnimationController _ambientAnimController;
  late final Animation<double> _scaleAnimation;
  double _pageOffset = 0.0;

  @override
  void initState() {
    super.initState();
    controller = Get.isRegistered<OnboardingController>()
        ? Get.find<OnboardingController>()
        : Get.put(OnboardingController());

    // Ambient Ken-Burns breathing animation for the active sports imagery
    _ambientAnimController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.06).animate(
      CurvedAnimation(
        parent: _ambientAnimController,
        curve: Curves.easeInOutSine,
      ),
    );

    // Listen to PageController to drive interactive swipe parallax
    controller.pageController.addListener(() {
      if (mounted && controller.pageController.hasClients) {
        setState(() {
          _pageOffset = controller.pageController.page ?? 0.0;
        });
      }
    });
  }

  @override
  void dispose() {
    _ambientAnimController.dispose();
    super.dispose();
  }

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
                        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                      ),
                      child: Text(
                        'SKIP',
                        style: TextStyle(
                          fontFamily: 'Nunito',
                          color: const Color(0xFF64748B),
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.6,
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),

            // Page View with 3D Parallax & Animated Sports Cards
            Expanded(
              child: PageView.builder(
                controller: controller.pageController,
                itemCount: controller.items.length,
                onPageChanged: controller.onPageChanged,
                itemBuilder: (context, index) {
                  final item = controller.items[index];
                  // Calculate page displacement for parallax effect
                  final diff = (index - _pageOffset);
                  final cardScale = (1.0 - (diff.abs() * 0.08)).clamp(0.9, 1.0);
                  final cardOpacity = (1.0 - (diff.abs() * 0.35)).clamp(0.0, 1.0);

                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    child: Opacity(
                      opacity: cardOpacity,
                      child: Transform.scale(
                        scale: cardScale,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Sports Imagery Container with #d4af37 shadow & breathing animation
                            Expanded(
                              flex: 6,
                              child: Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(26.r),
                                  border: Border.all(
                                    color: const Color(0x60D4AF37),
                                    width: 1.6,
                                  ),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Color(0x2CD4AF37),
                                      blurRadius: 26,
                                      spreadRadius: 0,
                                      offset: Offset(0, 12),
                                    ),
                                    BoxShadow(
                                      color: Color(0x0C000000),
                                      blurRadius: 8,
                                      spreadRadius: -1,
                                      offset: Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(24.5.r),
                                  child: Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      // Animated sports image (Badminton, Turf, Pickleball)
                                      AnimatedBuilder(
                                        animation: _scaleAnimation,
                                        builder: (context, child) {
                                          return Transform.scale(
                                            scale: _scaleAnimation.value,
                                            child: child,
                                          );
                                        },
                                        child: Image.asset(
                                          item.assetPath,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) => Container(
                                            color: const Color(0xFF0F172A),
                                            child: Center(
                                              child: Icon(
                                                item.sportIcon,
                                                size: 76.h,
                                                color: const Color(0xFFD4AF37),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),

                                      // Soft dark vignette gradient overlay
                                      Container(
                                        decoration: const BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              Colors.transparent,
                                              Color(0x30000000),
                                              Color(0x8A0F172A),
                                            ],
                                            stops: [0.4, 0.7, 1.0],
                                            begin: Alignment.topCenter,
                                            end: Alignment.bottomCenter,
                                          ),
                                        ),
                                      ),

                                      // Floating Sport Badge
                                      Positioned(
                                        top: 16.h,
                                        left: 16.w,
                                        child: Container(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 12.w,
                                            vertical: 6.h,
                                          ),
                                          decoration: BoxDecoration(
                                            color: const Color(0xDEFFFFFF),
                                            borderRadius: BorderRadius.circular(20.r),
                                            border: Border.all(
                                              color: const Color(0xFFD4AF37),
                                              width: 1.2,
                                            ),
                                            boxShadow: const [
                                              BoxShadow(
                                                color: Color(0x25000000),
                                                blurRadius: 8,
                                                offset: Offset(0, 2),
                                              ),
                                            ],
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                item.sportBadge,
                                                style: TextStyle(
                                                  fontFamily: 'Nunito',
                                                  fontSize: 12.sp,
                                                  fontWeight: FontWeight.w800,
                                                  color: const Color(0xFF0F172A),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 28.h),

                            // Animated Headline & Subtitle
                            Expanded(
                              flex: 3,
                              child: Column(
                                children: [
                                  AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 300),
                                    transitionBuilder: (child, animation) {
                                      return FadeTransition(
                                        opacity: animation,
                                        child: SlideTransition(
                                          position: Tween<Offset>(
                                            begin: const Offset(0.0, 0.15),
                                            end: Offset.zero,
                                          ).animate(animation),
                                          child: child,
                                        ),
                                      );
                                    },
                                    child: Text(
                                      item.headline,
                                      key: ValueKey<String>('${item.headline}_$index'),
                                      style: TextStyle(
                                        fontFamily: 'Nunito',
                                        fontSize: 23.sp,
                                        fontWeight: FontWeight.w900,
                                        color: const Color(0xFF0F172A),
                                        letterSpacing: -0.2,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  SizedBox(height: 12.h),
                                  Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                                    child: AnimatedSwitcher(
                                      duration: const Duration(milliseconds: 300),
                                      transitionBuilder: (child, animation) {
                                        return FadeTransition(
                                          opacity: animation,
                                          child: child,
                                        );
                                      },
                                      child: Text(
                                        item.subtitle,
                                        key: ValueKey<String>('${item.subtitle}_$index'),
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
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
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
                  // Smooth Page Indicators
                  Obx(() => Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          controller.items.length,
                          (index) {
                            final isCurrent = controller.currentPage.value == index;
                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                              margin: EdgeInsets.symmetric(horizontal: 4.w),
                              width: isCurrent ? 28.w : 8.w,
                              height: 8.h,
                              decoration: BoxDecoration(
                                color: isCurrent
                                    ? const Color(0xFFD4AF37)
                                    : const Color(0x35D4AF37),
                                borderRadius: BorderRadius.circular(4.r),
                                boxShadow: isCurrent
                                    ? const [
                                        BoxShadow(
                                          color: Color(0x40D4AF37),
                                          blurRadius: 6,
                                          offset: Offset(0, 2),
                                        ),
                                      ]
                                    : null,
                              ),
                            );
                          },
                        ),
                      )),
                  SizedBox(height: 24.h),

                  // Signature Action Button: Pure white with #D4AF37 border and gold drop shadow
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
                            blurRadius: 16,
                            offset: Offset(0, 5),
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
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 0.8,
                                    color: const Color(0xFF0F172A),
                                  ),
                                ),
                                SizedBox(width: 8.w),
                                AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 250),
                                  transitionBuilder: (child, animation) =>
                                      ScaleTransition(scale: animation, child: child),
                                  child: Icon(
                                    isLastPage ? Icons.bolt_rounded : Icons.arrow_forward_rounded,
                                    key: ValueKey<bool>(isLastPage),
                                    color: const Color(0xFFD4AF37),
                                    size: 20.sp,
                                  ),
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
