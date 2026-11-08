import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:curved_nav_bar/curved_nav_bar.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/storage/storage_service.dart';
import 'package:mobile_app/features/home/presentation/screens/home_screen.dart';
import 'package:mobile_app/features/home/presentation/controllers/home_controller.dart';
import 'package:mobile_app/features/booking/presentation/screens/court_booking_screen.dart';
import 'package:mobile_app/features/attendance/presentation/screens/attendance_screen.dart';
import 'package:mobile_app/features/coaching/presentation/screens/coaching_batches_screen.dart';
import 'package:mobile_app/features/finance/presentation/screens/payments_invoices_screen.dart';
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
      final isPayAndPlay = homeCtrl.isPayAndPlay;

      // Dynamic tab pages: For Pay & Play, Attendance is removed!
      final List<Widget> pages = isPayAndPlay
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
      final List<FABBottomAppBarItem> navItems = isPayAndPlay
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

      return CurvedNavBar(
        key: ValueKey('curved_nav_bar_${isPayAndPlay ? "booking" : "student"}'),
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
    final homeCtrl = Get.isRegistered<HomeController>()
        ? Get.find<HomeController>()
        : Get.put(HomeController());

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('My Profile', style: TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          Obx(() {
            final isPayAndPlay = homeCtrl.isPayAndPlay;
            final name = homeCtrl.greetingName.value.isNotEmpty
                ? homeCtrl.greetingName.value
                : (isPayAndPlay ? 'Booking Player' : 'Academy Student');
            final subtitle = isPayAndPlay ? 'Booking Account' : 'Student Account';

            return ListTile(
              leading: CircleAvatar(
                backgroundColor: const Color(0xFFFFFDF5),
                child: Text(
                  name.isNotEmpty ? name.substring(0, 1).toUpperCase() : 'U',
                  style: const TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.bold),
                ),
              ),
              title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(subtitle),
            );
          }),
          const Divider(),
          Obx(() {
            final isPayAndPlay = homeCtrl.isPayAndPlay;
            return ListTile(
              leading: const Icon(Icons.confirmation_number_outlined, color: Color(0xFFD4AF37)),
              title: const Text('Booking History & Passes'),
              trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
              onTap: () {
                final nav = Get.isRegistered<MainNavController>()
                    ? Get.find<MainNavController>()
                    : Get.put(MainNavController());
                nav.changeTab(isPayAndPlay ? 2 : 1);
              },
            );
          }),
          Obx(() {
            final isPayAndPlay = homeCtrl.isPayAndPlay;
            return ListTile(
              leading: const Icon(Icons.receipt_long_outlined, color: Color(0xFFD4AF37)),
              title: const Text('Invoices & Payment Receipts'),
              trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
              onTap: () {
                final nav = Get.isRegistered<MainNavController>()
                    ? Get.find<MainNavController>()
                    : Get.put(MainNavController());
                nav.changeTab(isPayAndPlay ? 2 : 3);
              },
            );
          }),
          // Only show Coaching Batches & Attendance for Academy Students!
          Obx(() {
            if (homeCtrl.isPayAndPlay) return const SizedBox.shrink();
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.fitness_center_outlined, color: Color(0xFFD4AF37)),
                  title: const Text('Coaching Academy & Batches'),
                  trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                  onTap: () => Get.to(() => const CoachingBatchesScreen()),
                ),
                ListTile(
                  leading: const Icon(Icons.calendar_month_outlined, color: Color(0xFFD4AF37)),
                  title: const Text('Attendance Records'),
                  trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                  onTap: () {
                    final nav = Get.isRegistered<MainNavController>()
                        ? Get.find<MainNavController>()
                        : Get.put(MainNavController());
                    nav.changeTab(2);
                  },
                ),
              ],
            );
          }),
          ListTile(
            leading: const Icon(Icons.swap_horiz_rounded, color: Color(0xFFD4AF37)),
            title: Obx(() => Text(
                  homeCtrl.isPayAndPlay ? 'Switch to Trainee / Student Mode' : 'Switch to Booking Mode',
                )),
            subtitle: Obx(() => Text(
                  homeCtrl.isPayAndPlay
                      ? 'Currently: Booking (Home + Payments only)'
                      : 'Currently: Student (Includes Attendance & Monthly Fees)',
                )),
            trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
            onTap: () => homeCtrl.toggleUserRole(),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Logout', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            onTap: () async {
              if (Get.isRegistered<StorageService>()) {
                await Get.find<StorageService>().clearAll();
              }
              Get.offAllNamed(AppRoutes.login);
            },
          ),
        ],
      ),
    );
  }
}
