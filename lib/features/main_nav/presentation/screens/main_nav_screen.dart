import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:curved_nav_bar/curved_nav_bar.dart';
import 'package:mobile_app/features/home/presentation/screens/home_screen.dart';
import 'package:mobile_app/features/home/presentation/controllers/home_controller.dart';
import 'package:mobile_app/features/booking/presentation/screens/court_booking_screen.dart';
import 'package:mobile_app/features/attendance/presentation/screens/attendance_screen.dart';
import 'package:mobile_app/features/finance/presentation/screens/payments_invoices_screen.dart';
import 'package:mobile_app/features/coaching/presentation/screens/coaching_batches_screen.dart';
import 'package:mobile_app/features/coaching/presentation/screens/coach_evaluations_screen.dart';
import 'package:mobile_app/features/profile/presentation/screens/profile_screen.dart';
import '../controllers/main_nav_controller.dart';

/// Main scaffold hosting the curved bottom navigation bar and page tabs.
class MainNavScreen extends StatelessWidget {
  const MainNavScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final navCtrl = Get.isRegistered<MainNavController>()
        ? Get.find<MainNavController>()
        : Get.put(MainNavController());
    final homeCtrl = Get.isRegistered<HomeController>()
        ? Get.find<HomeController>()
        : Get.put(HomeController());

    return Obx(() {
      final isCoach = homeCtrl.isCoach;
      final isPayAndPlay = homeCtrl.isPayAndPlay;

      // Dynamic tab pages:
      // - Coach: Dashboard, Batches, Student Evaluations, Court Booking, Profile
      // - Pay & Play: Dashboard, Court Booking, Payments, Profile
      // - Student: Dashboard, Court Booking, Attendance, Tuition Payments, Profile
      final List<Widget> pages = isCoach
          ? const [
              HomeScreen(),
              CoachingBatchesScreen(),
              CoachEvaluationsScreen(),
              CourtBookingScreen(),
              _ProfileTab(),
            ]
          : isPayAndPlay
              ? const [
                  HomeScreen(),
                  CourtBookingScreen(),
                  PaymentsInvoicesScreen(),
                  _ProfileTab(),
                ]
              : const [
                  HomeScreen(),
                  CourtBookingScreen(),
                  AttendanceScreen(),
                  PaymentsInvoicesScreen(),
                  _ProfileTab(),
                ];

      // Dynamic navigation items powered by curved_nav_bar 0.1.0
      final List<FABBottomAppBarItem> navItems = isCoach
          ? [
              FABBottomAppBarItem(
                activeIcon: Icon(Icons.home_rounded, color: const Color(0xFFD4AF37), size: 23.sp),
                inActiveIcon: Icon(Icons.home_rounded, color: const Color(0xFF94A3B8), size: 23.sp),
                text: 'Home',
              ),
              FABBottomAppBarItem(
                activeIcon: Icon(Icons.groups_rounded, color: const Color(0xFFD4AF37), size: 23.sp),
                inActiveIcon: Icon(Icons.groups_outlined, color: const Color(0xFF94A3B8), size: 23.sp),
                text: 'Batches',
              ),
              FABBottomAppBarItem(
                activeIcon: Icon(Icons.rate_review_rounded, color: const Color(0xFFD4AF37), size: 23.sp),
                inActiveIcon: Icon(Icons.rate_review_outlined, color: const Color(0xFF94A3B8), size: 23.sp),
                text: 'Evaluations',
              ),
              FABBottomAppBarItem(
                activeIcon: Icon(Icons.sports_tennis_rounded, color: const Color(0xFFD4AF37), size: 23.sp),
                inActiveIcon: Icon(Icons.sports_tennis_rounded, color: const Color(0xFF94A3B8), size: 23.sp),
                text: 'Book',
              ),
              FABBottomAppBarItem(
                activeIcon: Icon(Icons.person_rounded, color: const Color(0xFFD4AF37), size: 23.sp),
                inActiveIcon: Icon(Icons.person_outline_rounded, color: const Color(0xFF94A3B8), size: 23.sp),
                text: 'Profile',
              ),
            ]
          : isPayAndPlay
              ? [
                  FABBottomAppBarItem(
                    activeIcon: Icon(Icons.home_rounded, color: const Color(0xFFD4AF37), size: 23.sp),
                    inActiveIcon: Icon(Icons.home_rounded, color: const Color(0xFF94A3B8), size: 23.sp),
                    text: 'Home',
                  ),
                  FABBottomAppBarItem(
                    activeIcon: Icon(Icons.sports_tennis_rounded, color: const Color(0xFFD4AF37), size: 23.sp),
                    inActiveIcon: Icon(Icons.sports_tennis_rounded, color: const Color(0xFF94A3B8), size: 23.sp),
                    text: 'Book',
                  ),
                  FABBottomAppBarItem(
                    activeIcon: Icon(Icons.credit_card_rounded, color: const Color(0xFFD4AF37), size: 23.sp),
                    inActiveIcon: Icon(Icons.credit_card_outlined, color: const Color(0xFF94A3B8), size: 23.sp),
                    text: 'Payments',
                  ),
                  FABBottomAppBarItem(
                    activeIcon: Icon(Icons.person_rounded, color: const Color(0xFFD4AF37), size: 23.sp),
                    inActiveIcon: Icon(Icons.person_outline_rounded, color: const Color(0xFF94A3B8), size: 23.sp),
                    text: 'Profile',
                  ),
                ]
              : [
                  FABBottomAppBarItem(
                    activeIcon: Icon(Icons.home_rounded, color: const Color(0xFFD4AF37), size: 23.sp),
                    inActiveIcon: Icon(Icons.home_rounded, color: const Color(0xFF94A3B8), size: 23.sp),
                    text: 'Home',
                  ),
                  FABBottomAppBarItem(
                    activeIcon: Icon(Icons.sports_tennis_rounded, color: const Color(0xFFD4AF37), size: 23.sp),
                    inActiveIcon: Icon(Icons.sports_tennis_rounded, color: const Color(0xFF94A3B8), size: 23.sp),
                    text: 'Book',
                  ),
                  FABBottomAppBarItem(
                    activeIcon: Icon(Icons.calendar_month_rounded, color: const Color(0xFFD4AF37), size: 23.sp),
                    inActiveIcon: Icon(Icons.calendar_today_outlined, color: const Color(0xFF94A3B8), size: 23.sp),
                    text: 'Attendance',
                  ),
                  FABBottomAppBarItem(
                    activeIcon: Icon(Icons.credit_card_rounded, color: const Color(0xFFD4AF37), size: 23.sp),
                    inActiveIcon: Icon(Icons.credit_card_outlined, color: const Color(0xFF94A3B8), size: 23.sp),
                    text: 'Payments',
                  ),
                  FABBottomAppBarItem(
                    activeIcon: Icon(Icons.person_rounded, color: const Color(0xFFD4AF37), size: 23.sp),
                    inActiveIcon: Icon(Icons.person_outline_rounded, color: const Color(0xFF94A3B8), size: 23.sp),
                    text: 'Profile',
                  ),
                ];

      final rawIndex = navCtrl.currentTabIndex.value;
      final safeIndex = (rawIndex >= 0 && rawIndex < pages.length) ? rawIndex : 0;
      final String navKey = isCoach
          ? 'coach'
          : (isPayAndPlay ? 'booking' : 'student');

      return CurvedNavBar(
        key: ValueKey('curved_nav_bar_$navKey'),
        initialIndex: safeIndex,
        onTap: (int index) => navCtrl.changeTab(index),
        scaffoldBackgroundColor: Colors.white,
        navBarBackgroundColor: Colors.white,
        activeColor: const Color(0xFFD4AF37),
        inActiveColor: const Color(0xFF94A3B8),
        navBarHeight: 64.h,
        extendBody: false,
        itemTextStyle: TextStyle(
          fontFamily: 'Nunito',
          fontSize: 10.5.sp,
          fontWeight: FontWeight.w700,
        ),
        appBarItems: navItems,
        bodyItems: pages,
      );
    });
  }
}

class _ProfileTab extends StatelessWidget {
  const _ProfileTab();

  @override
  Widget build(BuildContext context) {
    return const ProfileScreen();
  }
}
