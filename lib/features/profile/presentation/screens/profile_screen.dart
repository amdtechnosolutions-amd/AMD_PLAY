import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../home/presentation/controllers/home_controller.dart';
import '../../../main_nav/presentation/controllers/main_nav_controller.dart';
import '../../../coaching/presentation/screens/coaching_batches_screen.dart';
import '../../../auth/presentation/widgets/change_password_sheet.dart';
import '../controllers/profile_controller.dart';

/// Pixel-perfect Profile Screen powered by live GET /api/v1/auth/me API.
/// If user is not registered or API responds with error, shows prompt to book a slot.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.isRegistered<ProfileController>()
        ? Get.find<ProfileController>()
        : Get.put(ProfileController());
    final homeCtrl = Get.isRegistered<HomeController>()
        ? Get.find<HomeController>()
        : Get.put(HomeController());

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'My Profile',
          style: TextStyle(
            fontFamily: 'Nunito',
            fontWeight: FontWeight.w800,
            fontSize: 18.sp,
            color: const Color(0xFF0F172A),
          ),
        ),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              Icons.refresh_rounded,
              color: const Color(0xFF0F172A),
              size: 22.sp,
            ),
            tooltip: 'Refresh Profile (/auth/me)',
            onPressed: () => controller.loadProfile(),
          ),
          SizedBox(width: 4.w),
        ],
      ),
      body: RefreshIndicator(
        color: const Color(0xFFD4AF37),
        backgroundColor: Colors.white,
        onRefresh: () async {
          await controller.loadProfile();
          if (Get.isRegistered<HomeController>()) {
            await Get.find<HomeController>().refreshDashboard();
          }
        },
        child: Obx(() {
          if (controller.isLoading.value) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Color(0xFFD4AF37),
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'Loading profile...',
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            );
          }

          // If user is not registered or API returned error
          if (!controller.isRegistered.value) {
            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 90.h),
              child: Column(
                children: [
                  // Not Registered Banner Card with #d4af37 shadow
                  _buildNotRegisteredCard(context),
                  SizedBox(height: 16.h),

                  // Quick navigation options
                  _buildQuickActionsCard(context, controller, homeCtrl),
                  SizedBox(height: 16.h),

                  // Login option if user already has an existing account
                  _buildSignInOptionCard(),
                ],
              ),
            );
          }

          // Registered user view: display REAL data from /auth/me
          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 90.h),
            child: Column(
              children: [
                // 1. Hero Profile Card with #d4af37 drop shadow
                _buildProfileHeroCard(controller, homeCtrl),
                SizedBox(height: 16.h),

                // 2. Account Details Card
                _buildAccountDetailsCard(controller),
                SizedBox(height: 16.h),

                // 3. Quick Actions & Navigation Section
                _buildQuickActionsCard(context, controller, homeCtrl),
                SizedBox(height: 16.h),

                // 4. System & API Status Card
                _buildSystemInfoCard(controller),
                SizedBox(height: 20.h),

                // 5. Logout Button
                _buildLogoutButton(context, controller),
              ],
            ),
          );
        }),
      ),
    );
  }

  // ===========================================================================
  // NOT REGISTERED / PROMPT TO BOOK A SLOT CARD
  // ===========================================================================

  Widget _buildNotRegisteredCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(22.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22.r),
        border: Border.all(
          color: const Color(0x60D4AF37),
          width: 1.5,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x28D4AF37),
            blurRadius: 22,
            offset: Offset(0, 8),
          ),
          BoxShadow(
            color: Color(0x0C000000),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Circular gold sports badge
          Container(
            width: 76.h,
            height: 76.h,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFFFFDF5),
              border: Border.all(
                color: const Color(0xFFD4AF37),
                width: 2,
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x25D4AF37),
                  blurRadius: 14,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Icon(
                Icons.sports_tennis_rounded,
                size: 38.sp,
                color: const Color(0xFFD4AF37),
              ),
            ),
          ),
          SizedBox(height: 16.h),

          // Status Badge
          Container(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 5.h),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFBEB),
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(color: const Color(0xFFF59E0B), width: 1),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 7.w,
                  height: 7.w,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF59E0B),
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: 6.w),
                Text(
                  'NOT REGISTERED',
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFFB45309),
                    letterSpacing: 0.6,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 14.h),

          // Heading
          Text(
            'Profile Not Registered',
            style: TextStyle(
              fontFamily: 'Nunito',
              fontSize: 20.sp,
              fontWeight: FontWeight.w900,
              color: const Color(0xFF0F172A),
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8.h),

          // Subtitle
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.w),
            child: Text(
              'You are not registered in the system yet. Please book a court slot to register your player profile and unlock your entry pass PIN.',
              style: TextStyle(
                fontFamily: 'Nunito',
                fontSize: 13.5.sp,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF64748B),
                height: 1.45,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: 20.h),

          // Primary CTA Button: Pure white with app color border and shadow
          Container(
            width: double.infinity,
            height: 50.h,
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
                onTap: () {
                  if (Get.isRegistered<MainNavController>()) {
                    Get.find<MainNavController>().changeTab(1); // Bookings tab
                  }
                },
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.calendar_month_rounded,
                        color: const Color(0xFFD4AF37),
                        size: 20.sp,
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        'PLEASE BOOK A SLOT',
                        style: TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.6,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                      SizedBox(width: 6.w),
                      Icon(
                        Icons.arrow_forward_rounded,
                        color: const Color(0xFFD4AF37),
                        size: 18.sp,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSignInOptionCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0x40D4AF37), width: 1.2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x18D4AF37),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(Icons.login_rounded, size: 20.sp, color: const Color(0xFFD4AF37)),
              SizedBox(width: 10.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Already have an account?',
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                  Text(
                    'Sign in with your phone or credentials',
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 11.5.sp,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ],
          ),
          TextButton(
            onPressed: () => Get.toNamed(AppRoutes.login),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF0F172A),
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            ),
            child: Text(
              'SIGN IN',
              style: TextStyle(
                fontFamily: 'Nunito',
                fontSize: 13.sp,
                fontWeight: FontWeight.w900,
                color: const Color(0xFFD4AF37),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // 1. HERO PROFILE CARD (REAL DATA ONLY)
  // ===========================================================================

  Widget _buildProfileHeroCard(ProfileController controller, HomeController homeCtrl) {
    return Obx(() {
      final name = controller.fullName.value.isNotEmpty
          ? controller.fullName.value
          : 'Player';
      final email = controller.email.value.isNotEmpty
          ? controller.email.value
          : 'Not provided';
      final phone = controller.phone.value.isNotEmpty
          ? controller.phone.value
          : 'Not provided';
      final roleText = controller.role.value.isNotEmpty
          ? controller.role.value.toUpperCase()
          : (homeCtrl.isPayAndPlay ? 'CUSTOMER' : 'STUDENT');
      final memberId = controller.memberId.value;

      return Container(
        width: double.infinity,
        padding: EdgeInsets.all(18.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: const Color(0x60D4AF37),
            width: 1.3,
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x28D4AF37),
              blurRadius: 18,
              spreadRadius: 0,
              offset: Offset(0, 6),
            ),
            BoxShadow(
              color: Color(0x0C000000),
              blurRadius: 6,
              spreadRadius: -1,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                // Avatar with gold border
                Container(
                  width: 62.h,
                  height: 62.h,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    border: Border.all(
                      color: const Color(0xFFD4AF37),
                      width: 2,
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x20D4AF37),
                        blurRadius: 8,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      'assets/logo/logo.png',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Center(
                        child: Text(
                          name.isNotEmpty ? name.substring(0, 1).toUpperCase() : 'P',
                          style: TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: 22.sp,
                            fontWeight: FontWeight.w900,
                            color: const Color(0xFFD4AF37),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 14.w),

                // Name & Badges
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name.toUpperCase(),
                        style: TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 17.sp,
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFF0F172A),
                          letterSpacing: 0.3,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 6.h),
                      Row(
                        children: [
                          // Role pill
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 3.h),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFFDF5),
                              borderRadius: BorderRadius.circular(6.r),
                              border: Border.all(
                                color: const Color(0xFFD4AF37),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              roleText,
                              style: TextStyle(
                                fontFamily: 'Nunito',
                                fontSize: 10.5.sp,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF9A7B1C),
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          SizedBox(width: 8.w),
                          // Status pill
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                            decoration: BoxDecoration(
                              color: const Color(0xFFECFDF5),
                              borderRadius: BorderRadius.circular(6.r),
                              border: Border.all(
                                color: const Color(0xFF10B981),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 6.w,
                                  height: 6.w,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF10B981),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                SizedBox(width: 4.w),
                                Text(
                                  controller.status.value.toUpperCase(),
                                  style: TextStyle(
                                    fontFamily: 'Nunito',
                                    fontSize: 10.sp,
                                    fontWeight: FontWeight.w800,
                                    color: const Color(0xFF059669),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 14.h),
            const Divider(color: Color(0x20D4AF37), height: 1),
            SizedBox(height: 12.h),

            // Contact / ID Row (Real data)
            Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Icon(Icons.email_outlined, size: 14.sp, color: const Color(0xFFD4AF37)),
                      SizedBox(width: 6.w),
                      Expanded(
                        child: Text(
                          email,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF64748B),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 8.w),
                Row(
                  children: [
                    Icon(Icons.phone_outlined, size: 14.sp, color: const Color(0xFFD4AF37)),
                    SizedBox(width: 6.w),
                    Text(
                      phone,
                      style: TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            if (memberId.isNotEmpty) ...[
              SizedBox(height: 8.h),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Account ID: $memberId',
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 10.5.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF94A3B8),
                  ),
                ),
              ),
            ],
          ],
        ),
      );
    });
  }

  // ===========================================================================
  // 2. ACCOUNT DETAILS CARD (REAL DATA ONLY)
  // ===========================================================================

  Widget _buildAccountDetailsCard(ProfileController controller) {
    return Obx(() {
      final email = controller.email.value.isNotEmpty ? controller.email.value : 'Not provided';
      final phone = controller.phone.value.isNotEmpty ? controller.phone.value : 'Not provided';
      final memberId = controller.memberId.value.isNotEmpty ? controller.memberId.value : '—';
      final role = controller.role.value.isNotEmpty ? controller.role.value : 'Customer';

      return Container(
        width: double.infinity,
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18.r),
          border: Border.all(
            color: const Color(0x50D4AF37),
            width: 1.2,
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x20D4AF37),
              blurRadius: 14,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.badge_outlined, size: 18.sp, color: const Color(0xFFD4AF37)),
                SizedBox(width: 8.w),
                Text(
                  'Account Details (Live /auth/me)',
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 14.5.sp,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF0F172A),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            _buildDetailRow('Email Address', email, Icons.alternate_email_rounded),
            const Divider(color: Color(0x1AD4AF37), height: 16),
            _buildDetailRow('Phone Number', phone, Icons.phone_android_rounded),
            const Divider(color: Color(0x1AD4AF37), height: 16),
            _buildDetailRow('Assigned Role', role.capitalizeFirst ?? role, Icons.admin_panel_settings_outlined),
            const Divider(color: Color(0x1AD4AF37), height: 16),
            _buildDetailRow('User Identifier', memberId, Icons.fingerprint_rounded),
          ],
        ),
      );
    });
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon, size: 15.sp, color: const Color(0xFF64748B)),
            SizedBox(width: 6.w),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Nunito',
                fontSize: 12.5.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF64748B),
              ),
            ),
          ],
        ),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: 'Nunito',
              fontSize: 12.5.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF0F172A),
            ),
          ),
        ),
      ],
    );
  }

  // ===========================================================================
  // 3. QUICK ACTIONS & NAVIGATION
  // ===========================================================================

  Widget _buildQuickActionsCard(
      BuildContext context, ProfileController controller, HomeController homeCtrl) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(
          color: const Color(0x50D4AF37),
          width: 1.2,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x20D4AF37),
            blurRadius: 14,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18.r),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            _buildActionTile(
              icon: Icons.confirmation_number_outlined,
              title: 'Booking History & Passes',
              subtitle: 'View active reservations & entry PINs',
              onTap: () {
                if (Get.isRegistered<MainNavController>()) {
                  Get.find<MainNavController>().changeTab(1); // Bookings
                }
              },
            ),
            const Divider(color: Color(0x1AD4AF37), height: 1),
            _buildActionTile(
              icon: Icons.receipt_long_outlined,
              title: 'Invoices & Payment Receipts',
              subtitle: 'Download receipts & settlement history',
              onTap: () => Get.toNamed(AppRoutes.invoices),
            ),
            Obx(() {
              if (homeCtrl.isCoach) {
                return Column(
                  children: [
                    const Divider(color: Color(0x1AD4AF37), height: 1),
                    _buildActionTile(
                      icon: Icons.sports_rounded,
                      title: 'My Coaching Batches',
                      subtitle: 'Training schedules & squad assignments',
                      onTap: () => Get.to(() => const CoachingBatchesScreen()),
                    ),
                    const Divider(color: Color(0x1AD4AF37), height: 1),
                    _buildActionTile(
                      icon: Icons.rate_review_outlined,
                      title: 'Student Performance & Evaluations',
                      subtitle: 'View live scorecards, radar charts & progress trends',
                      onTap: () => Get.toNamed(AppRoutes.coachEvaluations),
                    ),
                    const Divider(color: Color(0x1AD4AF37), height: 1),
                    _buildActionTile(
                      icon: Icons.add_chart_rounded,
                      title: 'Evaluate a Student',
                      subtitle: 'Score across 24 parameters in Physical, Mental, Skill & Attitude',
                      onTap: () => Get.toNamed(AppRoutes.evaluateStudent),
                    ),
                  ],
                );
              }
              if (homeCtrl.isPayAndPlay) return const SizedBox.shrink();
              return Column(
                children: [
                  const Divider(color: Color(0x1AD4AF37), height: 1),
                  _buildActionTile(
                    icon: Icons.fitness_center_outlined,
                    title: 'Coaching Academy & Batches',
                    subtitle: 'Training schedules & coach assignments',
                    onTap: () => Get.to(() => const CoachingBatchesScreen()),
                  ),
                  const Divider(color: Color(0x1AD4AF37), height: 1),
                  _buildActionTile(
                    icon: Icons.assessment_outlined,
                    title: 'Coaching Performance Report',
                    subtitle: 'Skill radar, 24-parameter metrics & scorecards',
                    onTap: () => Get.toNamed(AppRoutes.coachingReport),
                  ),
                  const Divider(color: Color(0x1AD4AF37), height: 1),
                  _buildActionTile(
                    icon: Icons.calendar_month_outlined,
                    title: 'Attendance Records',
                    subtitle: 'Daily check-in stats & history',
                    onTap: () {
                      if (Get.isRegistered<MainNavController>()) {
                        Get.find<MainNavController>().changeTab(2);
                      }
                    },
                  ),
                ],
              );
            }),
            const Divider(color: Color(0x1AD4AF37), height: 1),
            _buildActionTile(
              icon: Icons.password_rounded,
              title: 'Change Password',
              subtitle: 'Update your account login password',
              onTap: () {
                ChangePasswordBottomSheet.show(
                  context: context,
                  isStudent: !homeCtrl.isCoach && !homeCtrl.isPayAndPlay,
                );
              },
            ),
            const Divider(color: Color(0x1AD4AF37), height: 1),
            Obx(() => _buildActionTile(
                  icon: Icons.swap_horiz_rounded,
                  title: homeCtrl.isPayAndPlay
                      ? 'Switch to Trainee / Student Mode'
                      : 'Switch to Booking Mode',
                  subtitle: homeCtrl.isPayAndPlay
                      ? 'Current: Booking (Court reservations & equipment)'
                      : 'Current: Student (Batches, Attendance & Monthly fees)',
                  onTap: () => homeCtrl.toggleUserRole(),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
        leading: Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: const Color(0xFFFFFDF5),
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0x40D4AF37), width: 1),
          ),
          child: Icon(icon, size: 20.sp, color: const Color(0xFFD4AF37)),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontFamily: 'Nunito',
            fontSize: 14.sp,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF0F172A),
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontFamily: 'Nunito',
            fontSize: 11.5.sp,
            color: const Color(0xFF64748B),
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios_rounded,
          size: 13.sp,
          color: const Color(0xFF94A3B8),
        ),
        onTap: onTap,
      ),
    );
  }

  // ===========================================================================
  // 4. SYSTEM INFO CARD
  // ===========================================================================

  Widget _buildSystemInfoCard(ProfileController controller) {
    return Obx(() {
      final tenant = controller.tenantId.value.isNotEmpty
          ? controller.tenantId.value
          : '6ad6bd7fd33a91a36c41ff44';
      return Container(
        width: double.infinity,
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: const Color(0xFFFFFDF7),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: const Color(0x40D4AF37),
            width: 1.1,
          ),
        ),
        child: Row(
          children: [
            Icon(Icons.cloud_done_rounded, size: 18.sp, color: const Color(0xFF10B981)),
            SizedBox(width: 10.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Connected to Live AMD Play API',
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 12.5.sp,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    'Endpoint: /api/v1/auth/me • Tenant: ${tenant.substring(0, tenant.length > 8 ? 8 : tenant.length)}...',
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 11.sp,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  // ===========================================================================
  // 5. LOGOUT BUTTON
  // ===========================================================================

  Widget _buildLogoutButton(BuildContext context, ProfileController controller) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFFEF4444),
          side: const BorderSide(color: Color(0xFFEF4444), width: 1.3),
          padding: EdgeInsets.symmetric(vertical: 12.h),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
          elevation: 0,
        ),
        icon: const Icon(Icons.logout_rounded, size: 18),
        label: Text(
          'Log Out from Account',
          style: TextStyle(
            fontFamily: 'Nunito',
            fontSize: 14.sp,
            fontWeight: FontWeight.w800,
          ),
        ),
        onPressed: () {
          Get.defaultDialog(
            title: 'Logout',
            titleStyle: TextStyle(
              fontFamily: 'Nunito',
              fontSize: 18.sp,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF0F172A),
            ),
            middleText: 'Are you sure you want to log out from this device?',
            middleTextStyle: TextStyle(
              fontFamily: 'Nunito',
              fontSize: 13.5.sp,
              color: const Color(0xFF64748B),
            ),
            textConfirm: 'Logout',
            textCancel: 'Cancel',
            confirmTextColor: Colors.white,
            cancelTextColor: const Color(0xFF0F172A),
            buttonColor: const Color(0xFFEF4444),
            radius: 16.r,
            onConfirm: () => controller.logout(),
          );
        },
      ),
    );
  }
}
