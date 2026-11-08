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

  static const Color goldAccent = Color(0xFFD4AF37);

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ==========================================
            // TOP HERO SECTION (CLEAN WHITE WITH GOLD)
            // ==========================================
            Container(
              width: double.infinity,
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 24.h,
                bottom: 28.h,
                left: 20.w,
                right: 20.w,
              ),
              decoration: const BoxDecoration(color: Colors.white),
              child: CustomPaint(
                painter: _InertiaGridPainter(),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Original Brand Logo
                    _buildLogo(),
                    SizedBox(height: 16.h),

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
                            color: const Color(0xFF0F172A),
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
                            color: goldAccent,
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
                        color: const Color(0xFF64748B),
                        height: 1.4,
                      ),
                    ),
                    SizedBox(height: 18.h),

                    // Amenity Badges Row: Rackets, Nets, Arena Turf
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

            // ==========================================
            // USER ROLE SELECTION SECTION
            // ==========================================
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
              ),
              padding: EdgeInsets.fromLTRB(20.w, 10.h, 20.w, 32.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Subtle divider pill
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
                  SizedBox(height: 18.h),

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

                  // User Role Selection Cards with #d4af37 Shadow
                  _buildRoleSelectionCards(),
                  SizedBox(height: 28.h),

                  // Bottom Home Bar Indicator
                  Center(
                    child: Container(
                      width: 120.w,
                      height: 4.h,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE2E8F0),
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
          color: goldAccent,
        ),
      ),
    );
  }

  Widget _buildAmenityBadge({required IconData icon, required String label}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 13.w, vertical: 6.5.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: const Color(0x66D4AF37), width: 1.0),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1FD4AF37),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15.sp, color: goldAccent),
          SizedBox(width: 6.w),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12.5.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF334155),
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
        SizedBox(height: 14.h),
        _buildRoleCard(
          profile: MembershipProfile.parents,
          roleName: 'Student',
          title: 'Students',
          badgeText: 'STUDENT PORTAL',
          subtitle: 'Student training batches, attendance, fees & court booking',
          icon: Icons.school_rounded,
        ),
        SizedBox(height: 14.h),
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
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 15.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: const Color(0x59D4AF37),
            width: 1.2,
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x38D4AF37),
              blurRadius: 16,
              spreadRadius: 1,
              offset: Offset(0, 5),
            ),
            BoxShadow(
              color: Color(0x08000000),
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
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
              child: Icon(icon, size: 22.sp, color: goldAccent),
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
                          horizontal: 7.w,
                          vertical: 2.5.h,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0x24D4AF37),
                          borderRadius: BorderRadius.circular(6.r),
                          border: Border.all(
                            color: const Color(0x80D4AF37),
                            width: 0.8,
                          ),
                        ),
                        child: Text(
                          badgeText,
                          style: GoogleFonts.inter(
                            fontSize: 9.sp,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF9E7B1A),
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
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0x40D4AF37),
                  width: 1,
                ),
              ),
              child: const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 13,
                color: Color(0xFF0F172A),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Custom grid lines painter for subtle warm hero background
class _InertiaGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0x0FD4AF37)
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
