import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/routes/app_routes.dart';
import '../controllers/auth_controller.dart';

/// Clean, dedicated User Role Selection Screen for INERTIA SPORTS
class UserSelectionScreen extends GetView<AuthController> {
  const UserSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
    );

    return Scaffold(
      backgroundColor: const Color(0xFF0E1015),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ==========================================
            // TOP HERO SECTION (DARK WITH GOLD ACCENTS)
            // ==========================================
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.only(
                    top: MediaQuery.of(context).padding.top + 28.h,
                    bottom: 42.h,
                    left: 20.w,
                    right: 20.w,
                  ),
                  decoration: const BoxDecoration(color: Color(0xFF0E1015)),
                  child: CustomPaint(
                    painter: _InertiaGridPainter(),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Original Brand Logo
                        _buildLogo(),
                        SizedBox(height: 18.h),

                        // Brand Title: INERTIA (Top), SPORTS ACADEMY (Bottom)
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'INERTIA',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.inter(
                                fontSize: 28.sp,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                letterSpacing: 2.0,
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              'SPORTS ACADEMY',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.inter(
                                fontSize: 17.sp,
                                fontWeight: FontWeight.w900,
                                color: const Color(0xFFF59E0B),
                                letterSpacing: 3.5,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10.h),

                        // Subtitle
                        Text(
                          'Multi-Sport Training, High Performance &\nArena Bookings',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            fontSize: 13.5.sp,
                            fontWeight: FontWeight.w400,
                            color: const Color(0xFF94A3B8),
                            height: 1.4,
                          ),
                        ),
                        SizedBox(height: 18.h),

                        // Amenity Badges Row: Rackets, Nets, Arena Turf (Enlarged)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildAmenityBadge(
                              icon: Icons.sports_tennis_rounded,
                              label: 'Rackets',
                            ),
                            SizedBox(width: 10.w),
                            _buildAmenityBadge(
                              icon: Icons.sports_rounded,
                              label: 'Nets',
                            ),
                            SizedBox(width: 10.w),
                            _buildAmenityBadge(
                              icon: Icons.sports_soccer_rounded,
                              label: 'Arena Turf',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // ==========================================
            // BOTTOM SHEET / USER ROLE SELECTION
            // ==========================================
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30.r)),
                border: const Border(
                  top: BorderSide(color: Color(0xFFE2E8F0), width: 1.5),
                ),
              ),
              padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 32.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Pull indicator handle
                  Center(
                    child: Container(
                      width: 40.w,
                      height: 4.h,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE2E8F0),
                        borderRadius: BorderRadius.circular(2.r),
                      ),
                    ),
                  ),
                  SizedBox(height: 16.h),

                  // Header: Welcome to the Club
                  Center(
                    child: Text(
                      'Welcome to the Club',
                      style: GoogleFonts.inter(
                        fontSize: 23.sp,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF0F172A),
                        letterSpacing: -0.4,
                      ),
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Center(
                    child: Text(
                      'Select your membership profile to sign in',
                      style: GoogleFonts.inter(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ),
                  SizedBox(height: 24.h),

                  // User Role Selection Cards (Members | Parents | Booking)
                  _buildRoleSelectionCards(),
                  SizedBox(height: 28.h),

                  // Bottom Home Bar Indicator
                  Center(
                    child: Container(
                      width: 120.w,
                      height: 4.h,
                      decoration: BoxDecoration(
                        color: const Color(0xFFCBD5E1),
                        borderRadius: BorderRadius.circular(2.r),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // HELPER WIDGETS
  // ==========================================

  Widget _buildLogo() {
    return Image.asset(
      'assets/logo/logo.png',
      height: 120.h,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) => Center(
        child: Icon(
          Icons.sports_tennis_rounded,
          size: 72.sp,
          color: const Color(0xFFF59E0B),
        ),
      ),
    );
  }

  Widget _buildAmenityBadge({required IconData icon, required String label}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 13.w, vertical: 6.5.h),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1F2C),
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: const Color(0x66F59E0B), width: 1.0),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15.sp, color: const Color(0xFFF59E0B)),
          SizedBox(width: 6.w),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12.5.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFFE2E8F0),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleSelectionCards() {
    return Column(
      children: [
        _buildRoleCard(
          profile: MembershipProfile.booking,
          roleName: 'Guest',
          title: 'Booking',
          badgeText: 'COURT BOOKING',
          subtitle: 'Instant court reservations, guest access & equipment',
          icon: Icons.confirmation_number_outlined,
        ),
        SizedBox(height: 12.h),
        _buildRoleCard(
          profile: MembershipProfile.parents,
          roleName: 'Student',
          title: 'Students',
          badgeText: 'STUDENT PORTAL',
          subtitle: 'Student training batches, attendance, fees & court booking',
          icon: Icons.school_rounded,
        ),
        SizedBox(height: 12.h),
        _buildRoleCard(
          profile: MembershipProfile.members,
          roleName: 'Member',
          title: 'Members',
          badgeText: 'VIP ACCESS',
          subtitle: 'VIP Lounge, court reservations & locker access',
          icon: Icons.military_tech_rounded,
        ),
      ],
    );
  }

  Widget _buildRoleCard({
    required MembershipProfile profile,
    required String roleName,
    required String title,
    required String badgeText,
    required String subtitle,
    required IconData icon,
  }) {
    return GestureDetector(
      onTap: () {
        controller.selectRole(roleName);
        controller.selectProfile(profile);
        if (profile == MembershipProfile.booking) {
          controller.startGuestBookingFlow(goToDashboard: true);
        } else {
          Get.toNamed(AppRoutes.login);
        }
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
        ),
        child: Row(
          children: [
            // Role Icon Container
            Container(
              width: 44.h,
              height: 44.h,
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(icon, size: 22.sp, color: const Color(0xFFF59E0B)),
            ),
            SizedBox(width: 14.w),

            // Text Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.inter(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 6.w,
                          vertical: 2.h,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0x26F59E0B),
                          borderRadius: BorderRadius.circular(6.r),
                          border: Border.all(
                            color: const Color(0x66F59E0B),
                            width: 0.8,
                          ),
                        ),
                        child: Text(
                          badgeText,
                          style: GoogleFonts.inter(
                            fontSize: 9.sp,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFFB45309),
                            letterSpacing: 0.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 3.h),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 11.5.sp,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF64748B),
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 8.w),

            // Forward Arrow Icon
            Container(
              width: 32.h,
              height: 32.h,
              decoration: const BoxDecoration(
                color: Color(0xFFF1F5F9),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.arrow_forward_ios_rounded,
                size: 13.sp,
                color: const Color(0xFF0F172A),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Custom grid lines painter for dark hero background
class _InertiaGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0x0AF59E0B)
      ..strokeWidth = 0.8
      ..style = PaintingStyle.stroke;

    const double step = 28.0;

    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
