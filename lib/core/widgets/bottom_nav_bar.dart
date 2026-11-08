import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:curved_nav_bar/curved_nav_bar.dart';

class BottomNavItemData {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const BottomNavItemData({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}

/// Curved navigation bar matching brand styling and powered by curved_nav_bar 0.1.0.
class AppBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<BottomNavItemData>? customItems;

  static const List<BottomNavItemData> items = [
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
      icon: Icons.calendar_today_outlined,
      activeIcon: Icons.calendar_month_rounded,
      label: 'Attendance',
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
  ];

  const AppBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.customItems,
  });

  @override
  Widget build(BuildContext context) {
    final activeItems = customItems ?? items;
    final appBarItems = activeItems
        .map(
          (item) => FABBottomAppBarItem(
            activeIcon: Icon(
              item.activeIcon,
              size: 22.sp,
              color: const Color(0xFFD4AF37),
            ),
            inActiveIcon: Icon(
              item.icon,
              size: 22.sp,
              color: const Color(0xFF94A3B8),
            ),
            text: item.label,
          ),
        )
        .toList();

    return FABBottomAppBar(
      items: appBarItems,
      selectedIndex: currentIndex,
      showCenterItem: false,
      onTabSelected: onTap,
      backgroundColor: Colors.white,
      activeColor: const Color(0xFFD4AF37),
      inActiveColor: const Color(0xFF94A3B8),
      height: 62.h,
      itemTextStyle: TextStyle(
        fontFamily: 'Nunito',
        fontSize: 10.5.sp,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}
