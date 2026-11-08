import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/bottom_nav_bar.dart';
import 'package:mobile_app/features/home/presentation/screens/home_screen.dart';
import 'package:mobile_app/features/home/presentation/controllers/home_controller.dart';
import 'package:mobile_app/features/booking/presentation/screens/court_booking_screen.dart';
import 'package:mobile_app/features/attendance/presentation/screens/attendance_screen.dart';
import 'package:mobile_app/features/coaching/presentation/screens/coaching_batches_screen.dart';
import 'package:mobile_app/features/finance/presentation/screens/payments_invoices_screen.dart';
import '../controllers/main_nav_controller.dart';

/// Main scaffold hosting the bottom navigation bar and page tabs.
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

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Obx(() {
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

        // Dynamic bottom navigation items: For Pay & Play, Attendance is removed!
        final List<BottomNavItemData> navItems = isPayAndPlay
            ? const [
                BottomNavItemData(
                  icon: Icons.home_rounded,
                  activeIcon: Icons.home_rounded,
                  label: 'Home',
                ),
                BottomNavItemData(
                  icon: Icons.sports_tennis_rounded,
                  activeIcon: Icons.sports_tennis_rounded,
                  label: 'Book',
                ),
                BottomNavItemData(
                  icon: Icons.credit_card_outlined,
                  activeIcon: Icons.credit_card_rounded,
                  label: 'Payments',
                ),
                BottomNavItemData(
                  icon: Icons.person_outline_rounded,
                  activeIcon: Icons.person_rounded,
                  label: 'Profile',
                ),
              ]
            : AppBottomNavBar.items;

        final rawIndex = navCtrl.currentTabIndex.value;
        final safeIndex = (rawIndex >= 0 && rawIndex < pages.length) ? rawIndex : 0;

        return Stack(
          children: [
            IndexedStack(
              index: safeIndex,
              children: pages,
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: AppBottomNavBar(
                currentIndex: safeIndex,
                onTap: navCtrl.changeTab,
                customItems: navItems,
              ),
            ),
          ],
        );
      }),
    );
  }
}

class _ProfileTab extends StatelessWidget {
  const _ProfileTab();

  @override
  Widget build(BuildContext context) {
    final homeCtrl = Get.isRegistered<HomeController>() ? Get.find<HomeController>() : Get.put(HomeController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          Obx(() {
            final isPayAndPlay = homeCtrl.isPayAndPlay;
            final name = homeCtrl.userName.value.isNotEmpty ? homeCtrl.userName.value : (isPayAndPlay ? 'Guest Player' : 'Academy Trainee');
            final role = isPayAndPlay ? 'BOOKING' : homeCtrl.userRole.value.toUpperCase();
            final stId = homeCtrl.currentStudentId.value;
            final subtitle = isPayAndPlay
                ? 'Profile: Booking • Instant Court Access'
                : (stId.isNotEmpty
                    ? 'Role: $role • ID: #${stId.substring(stId.length > 6 ? stId.length - 6 : 0).toUpperCase()}'
                    : 'Role: $role • Active Member');

            return ListTile(
              leading: CircleAvatar(
                backgroundColor: AppColors.primaryLight,
                child: Text(
                  name.isNotEmpty ? name[0].toUpperCase() : (isPayAndPlay ? 'B' : 'T'),
                  style: const TextStyle(color: AppColors.accentDark, fontWeight: FontWeight.bold),
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
              leading: const Icon(Icons.confirmation_number_outlined, color: AppColors.primary),
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
              leading: const Icon(Icons.receipt_long_outlined, color: AppColors.primary),
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
                  leading: const Icon(Icons.fitness_center_outlined, color: AppColors.primary),
                  title: const Text('Coaching Academy & Batches'),
                  trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                  onTap: () => Get.to(() => const CoachingBatchesScreen()),
                ),
                ListTile(
                  leading: const Icon(Icons.calendar_month_outlined, color: AppColors.primary),
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
            leading: const Icon(Icons.swap_horiz_rounded, color: AppColors.primary),
            title: Obx(() => Text(
                  homeCtrl.isPayAndPlay ? 'Switch to Trainee / Student Mode' : 'Switch to Booking Mode',
                )),
            subtitle: Obx(() => Text(
                  homeCtrl.isPayAndPlay
                      ? 'Currently: Booking (Home + Payments only)'
                      : 'Currently: Student (Includes Attendance & Monthly Fees)',
                  style: const TextStyle(fontSize: 12),
                )),
            trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
            onTap: () => homeCtrl.toggleUserRole(),
          ),
          ListTile(
            leading: const Icon(Icons.notifications_outlined, color: AppColors.primary),
            title: const Text('Notification Preferences'),
            trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
            onTap: () {
              Get.snackbar('Notifications', 'SMS & In-app PIN alerts are active', snackPosition: SnackPosition.BOTTOM);
            },
          ),
          ListTile(
            leading: const Icon(Icons.help_outline_rounded, color: AppColors.primary),
            title: const Text('Help & Support'),
            trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
            onTap: () {
              Get.snackbar('Support', 'Connecting to 24/7 Academy Helpdesk', snackPosition: SnackPosition.BOTTOM);
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout_rounded, color: AppColors.error),
            title: const Text('Logout', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.w600)),
            onTap: () {
              Get.offAllNamed('/login');
            },
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }
}
