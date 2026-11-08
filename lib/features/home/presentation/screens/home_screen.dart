import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/storage/storage_service.dart';
import '../../../main_nav/presentation/controllers/main_nav_controller.dart';
import '../controllers/home_controller.dart';
import '../widgets/payment_receipt_dialog.dart';
import 'package:mobile_app/features/booking/data/models/booking_pass_model.dart';
import 'package:mobile_app/features/booking/presentation/screens/digital_pass_screen.dart';
import 'package:mobile_app/features/booking/presentation/screens/court_booking_screen.dart';

/// Pixel-perfect Dashboard Screen matching original layout with Brand Yellow (#F9D106) color scheme.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
    );

    final controller = Get.isRegistered<HomeController>()
        ? Get.find<HomeController>()
        : Get.put(HomeController());

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: Text(
          'Dashboard',
          style: GoogleFonts.inter(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF0F172A),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.refresh_rounded,
              color: const Color(0xFF0F172A),
              size: 22.sp,
            ),
            tooltip: 'Refresh Dashboard',
            onPressed: () => controller.refreshDashboard(),
          ),
          IconButton(
            icon: Icon(
              Icons.logout_rounded,
              color: const Color(0xFF0F172A),
              size: 22.sp,
            ),
            onPressed: () {
              Get.defaultDialog(
                title: 'Logout',
                middleText: 'Are you sure you want to log out?',
                textConfirm: 'Logout',
                textCancel: 'Cancel',
                confirmTextColor: const Color(0xFF0F172A),
                buttonColor: const Color(0xFFF9D106),
                onConfirm: () async {
                  if (Get.isRegistered<StorageService>()) {
                    await Get.find<StorageService>().clearAll();
                  }
                  Get.offAllNamed(AppRoutes.login);
                },
              );
            },
          ),
          SizedBox(width: 4.w),
        ],
      ),
      body: RefreshIndicator(
        color: const Color(0xFF0F172A),
        backgroundColor: const Color(0xFFF9D106),
        onRefresh: controller.refreshDashboard,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 90.h),
          child: Obx(() {
            final isPayAndPlay = controller.isPayAndPlay;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Greeting Row: Avatar + Dynamic "Hi, {NAME}!" + Role/Date Pill Badge
                _buildGreetingRow(controller),
                SizedBox(height: 16.h),

                // 2. Hero Banner: "Book a Court - Reserve your slot now"
                _buildBookCourtHero(),
                SizedBox(height: 24.h),

                if (isPayAndPlay) ...[
                  // ========================================================
                  // PAY & PLAY MODE: NO ATTENDANCE, NO MONTHLY FEES!
                  // ========================================================
                  _buildPayAndPlaySportsCatalog(controller),
                  SizedBox(height: 24.h),

                  _buildActivePassesSection(controller),
                  SizedBox(height: 24.h),

                  _buildBookingPaymentsSection(controller, context),
                  SizedBox(height: 16.h),
                ] else ...[
                  // ========================================================
                  // STUDENT MODE: ACADEMY BATCHES, ATTENDANCE & MONTHLY FEES
                  // ========================================================
                  _buildMySportsSection(controller),
                  SizedBox(height: 24.h),

                  _buildTodayAttendanceSection(controller),
                  SizedBox(height: 24.h),

                  _buildMonthlyFeesSection(controller, context),
                  SizedBox(height: 16.h),
                ],
              ],
            );
          }),
        ),
      ),
    );
  }

  // ===========================================================================
  // 1. GREETING ROW
  // ===========================================================================

  Widget _buildGreetingRow(HomeController controller) {
    return Obx(() {
      final isPayAndPlay = controller.isPayAndPlay;
      var rawName = controller.greetingName.value.trim();

      // Ensure that in Pay & Play mode, we never display 'TRAINEE'
      if (rawName.isEmpty || (isPayAndPlay && rawName.toUpperCase() == 'TRAINEE')) {
        rawName = isPayAndPlay ? 'PLAYER' : 'TRAINEE';
      }
      final name = rawName;

      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                // Avatar / Initial
                Container(
                  width: 46.h,
                  height: 46.h,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isPayAndPlay ? const Color(0xFFEFF6FF) : const Color(0xFFFFF9DB),
                    border: Border.all(
                      color: isPayAndPlay ? const Color(0xFF3B82F6) : const Color(0xFFF9D106),
                      width: 1.5,
                    ),
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      'assets/logo/logo.png',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Center(
                        child: Text(
                          name.isNotEmpty ? name.substring(0, 1) : (isPayAndPlay ? 'P' : 'S'),
                          style: GoogleFonts.inter(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.w800,
                            color: isPayAndPlay ? const Color(0xFF1D4ED8) : const Color(0xFFD97706),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),

                // Greeting Text
                Expanded(
                  child: Text(
                    'Hi, $name!',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 22.sp,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF0F172A),
                      letterSpacing: -0.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 8.w),

          // Role / "Today" Badge
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
            decoration: BoxDecoration(
              color: isPayAndPlay ? const Color(0xFFEFF6FF) : const Color(0xFFFFF9DB),
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Row(
              children: [
                Icon(
                  isPayAndPlay ? Icons.sports_tennis_rounded : Icons.calendar_today_outlined,
                  size: 13.sp,
                  color: isPayAndPlay ? const Color(0xFF2563EB) : const Color(0xFFD97706),
                ),
                SizedBox(width: 5.w),
                Text(
                  isPayAndPlay ? 'Booking' : 'Today',
                  style: GoogleFonts.inter(
                    fontSize: 12.5.sp,
                    fontWeight: FontWeight.w700,
                    color: isPayAndPlay ? const Color(0xFF2563EB) : const Color(0xFFD97706),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    });
  }

  // ===========================================================================
  // 2. HERO BANNER: "BOOK A COURT"
  // ===========================================================================

  Widget _buildBookCourtHero() {
    return GestureDetector(
      onTap: () {
        if (Get.isRegistered<MainNavController>()) {
          Get.find<MainNavController>().changeTab(1);
        } else {
          Get.toNamed(AppRoutes.slotBooking);
        }
      },
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 18.h),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color(0xFFFFDE38),
              Color(0xFFF9D106),
              Color(0xFFE5BE00),
            ],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFF9D106).withValues(alpha: 0.35),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            // Left Search / Racket Icon Box
            Container(
              width: 52.h,
              height: 52.h,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.30),
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Center(
                child: Icon(
                  Icons.sports_tennis_rounded,
                  size: 28.sp,
                  color: const Color(0xFF0F172A),
                ),
              ),
            ),
            SizedBox(width: 14.w),

            // Middle Titles
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Book a Court',
                    style: GoogleFonts.inter(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF0F172A),
                      letterSpacing: -0.2,
                    ),
                  ),
                  SizedBox(height: 3.h),
                  Text(
                    'Reserve your slot now',
                    style: GoogleFonts.inter(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF0F172A).withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),

            // Right Forward Arrow Button
            Container(
              width: 36.h,
              height: 36.h,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFF0F172A),
              ),
              child: Icon(
                Icons.arrow_forward_rounded,
                size: 20.sp,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // 3. "MY SPORTS" SECTION
  // ===========================================================================

  Widget _buildMySportsSection(HomeController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'My Sports',
              style: GoogleFonts.inter(
                fontSize: 18.sp,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF0F172A),
              ),
            ),
            Obx(() {
              if (controller.mySports.length > 1) {
                return Text(
                  'Tap to switch profile',
                  style: GoogleFonts.inter(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFFD97706),
                  ),
                );
              }
              return const SizedBox.shrink();
            }),
          ],
        ),
        SizedBox(height: 12.h),

        Obx(() {
          if (controller.isLoading.value && controller.mySports.isEmpty) {
            return Container(
              height: 90.h,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18.r),
              ),
              child: const Center(
                child: CircularProgressIndicator(color: Color(0xFFF9D106)),
              ),
            );
          }

          if (controller.mySports.isEmpty) {
            return Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18.r),
                border: Border.all(color: const Color(0xFFF1F5F9)),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: const Color(0xFF64748B), size: 20.sp),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Text(
                      'No active sports enrollments found.',
                      style: GoogleFonts.inter(fontSize: 13.sp, color: const Color(0xFF64748B)),
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: controller.mySports.length,
            separatorBuilder: (context, index) => SizedBox(height: 12.h),
            itemBuilder: (context, index) {
              final sportItem = controller.mySports[index];
              return _buildSportMemberCard(
                sportItem: sportItem,
                onTap: () {
                  if (!sportItem.isCurrent && sportItem.studentId.isNotEmpty) {
                    controller.switchProfile(sportItem.studentId);
                  }
                },
              );
            },
          );
        }),
      ],
    );
  }

  Widget _buildSportMemberCard({
    required EnrolledSportItem sportItem,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18.r),
          border: Border.all(
            color: sportItem.isCurrent
                ? const Color(0xFFF9D106)
                : const Color(0xFFF1F5F9),
            width: sportItem.isCurrent ? 1.5 : 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            // Member Avatar
            Container(
              width: 48.h,
              height: 48.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: sportItem.isCurrent
                    ? const Color(0xFFFFF9DB)
                    : const Color(0xFFE2E8F0),
              ),
              child: ClipOval(
                child: Image.asset(
                  'assets/logo/logo.png',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Center(
                    child: Text(
                      sportItem.name.isNotEmpty ? sportItem.name.substring(0, 1) : 'S',
                      style: GoogleFonts.inter(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w700,
                        color: sportItem.isCurrent
                            ? const Color(0xFFD97706)
                            : const Color(0xFF64748B),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(width: 14.w),

            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        sportItem.name,
                        style: GoogleFonts.inter(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                      if (sportItem.isCurrent) ...[
                        SizedBox(width: 6.w),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF9DB),
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Text(
                            'Active',
                            style: GoogleFonts.inter(
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFFD97706),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  SizedBox(height: 4.h),
                  Row(
                    children: [
                      Icon(
                        Icons.sports_tennis_rounded,
                        size: 14.sp,
                        color: const Color(0xFF64748B),
                      ),
                      SizedBox(width: 5.w),
                      Text(
                        sportItem.sport,
                        style: GoogleFonts.inter(
                          fontSize: 12.5.sp,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 2.h),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time_rounded,
                        size: 14.sp,
                        color: const Color(0xFF64748B),
                      ),
                      SizedBox(width: 5.w),
                      Expanded(
                        child: Text(
                          sportItem.schedule,
                          style: GoogleFonts.inter(
                            fontSize: 12.5.sp,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF64748B),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Trailing Chevron
            Icon(
              Icons.chevron_right_rounded,
              size: 22.sp,
              color: const Color(0xFF94A3B8),
            ),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // 4. "TODAY'S ATTENDANCE" SECTION
  // ===========================================================================

  Widget _buildTodayAttendanceSection(HomeController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Today's Attendance",
              style: GoogleFonts.inter(
                fontSize: 18.sp,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF0F172A),
              ),
            ),
            Obx(() {
              if (controller.attendancePercentage.value > 0) {
                return Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF9DB),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Text(
                    '${controller.attendancePercentage.value}% Overall',
                    style: GoogleFonts.inter(
                      fontSize: 11.5.sp,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFFD97706),
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            }),
          ],
        ),
        SizedBox(height: 12.h),

        // Attendance Card
        Obx(() {
          final isChecked = controller.isCheckedIn.value;
          final todayDate = controller.todayDateFormatted.value;
          final title = controller.attendanceTitle.value;
          final subtitle = controller.attendanceSubtitle.value;

          return Container(
            width: double.infinity,
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(color: const Color(0xFFF1F5F9), width: 1.2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Date & Status Badge
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      todayDate.isNotEmpty ? todayDate : 'Today',
                      style: GoogleFonts.inter(
                        fontSize: 13.5.sp,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: isChecked
                            ? const Color(0xFFFFF9DB)
                            : const Color(0xFFFEE2E2),
                        borderRadius: BorderRadius.circular(14.r),
                      ),
                      child: Text(
                        isChecked ? 'Checked In' : 'Not Checked In',
                        style: GoogleFonts.inter(
                          fontSize: 11.5.sp,
                          fontWeight: FontWeight.w700,
                          color: isChecked
                              ? const Color(0xFFD97706)
                              : const Color(0xFFEF4444),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),

                // Title
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                SizedBox(height: 4.h),

                // Subtitle
                Text(
                  subtitle,
                  style: GoogleFonts.inter(
                    fontSize: 12.5.sp,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF64748B),
                  ),
                ),
                SizedBox(height: 16.h),

                // Check In & Check Out Buttons
                Row(
                  children: [
                    // Check In Button
                    Expanded(
                      child: GestureDetector(
                        onTap: controller.isMarkingAttendance.value
                            ? null
                            : () => controller.checkInLive(),
                        child: Container(
                          height: 42.h,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF9D106),
                            borderRadius: BorderRadius.circular(21.r),
                          ),
                          child: Center(
                            child: controller.isMarkingAttendance.value
                                ? SizedBox(
                                    width: 18.h,
                                    height: 18.h,
                                    child: const CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Color(0xFF0F172A),
                                    ),
                                  )
                                : Text(
                                    isChecked ? 'Check In Again' : 'Check In',
                                    style: GoogleFonts.inter(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFF0F172A),
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),

                    // Check Out Button
                    Expanded(
                      child: GestureDetector(
                        onTap: () => controller.checkOutLive(),
                        child: Container(
                          height: 42.h,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(21.r),
                            border: Border.all(
                              color: const Color(0xFFCBD5E1),
                              width: 1.2,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              'Check Out',
                              style: GoogleFonts.inter(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF475569),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  // ===========================================================================
  // 5. "MONTHLY FEES" SECTION
  // ===========================================================================

  Widget _buildMonthlyFeesSection(HomeController controller, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Monthly Fees',
          style: GoogleFonts.inter(
            fontSize: 18.sp,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF0F172A),
          ),
        ),
        SizedBox(height: 12.h),

        Obx(() {
          if (controller.isLoading.value && controller.monthlyFees.isEmpty) {
            return Container(
              height: 100.h,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18.r),
              ),
              child: const Center(
                child: CircularProgressIndicator(color: Color(0xFFF9D106)),
              ),
            );
          }

          if (controller.monthlyFees.isEmpty) {
            return Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18.r),
                border: Border.all(color: const Color(0xFFF1F5F9)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle_outline_rounded, color: Color(0xFF10B981)),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Text(
                      'All caught up! No pending fees for this month.',
                      style: GoogleFonts.inter(
                        fontSize: 13.5.sp,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: controller.monthlyFees.length,
            separatorBuilder: (context, index) => SizedBox(height: 12.h),
            itemBuilder: (context, index) {
              final fee = controller.monthlyFees[index];
              return Obx(() {
                final isSelected = controller.selectedFeeIds.contains(fee.id);
                return _buildFeeCard(
                  context: context,
                  controller: controller,
                  fee: fee,
                  isSelected: isSelected,
                  onTap: () => controller.toggleSelectFee(fee.id),
                );
              });
            },
          );
        }),

        SizedBox(height: 20.h),

        // Bottom CTA Button: "Select fees to pay" / "Pay ₹XXXX"
        _buildPayFeesButton(controller),
      ],
    );
  }

  Widget _buildFeeCard({
    required BuildContext context,
    required HomeController controller,
    required FeeItem fee,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final isPaid = fee.isPaid;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: isPaid
          ? () {
              PaymentReceiptDialog.show(
                context,
                fee: fee,
                studentName: controller.userName.value,
              );
            }
          : onTap,
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18.r),
          border: Border.all(
            color: isPaid
                ? const Color(0xFFE2E8F0)
                : (isSelected ? const Color(0xFFF9D106) : const Color(0xFFF1F5F9)),
            width: isSelected ? 1.8 : 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? const Color(0xFFF9D106).withValues(alpha: 0.15)
                  : Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          fee.title,
                          style: GoogleFonts.inter(
                            fontSize: 14.5.sp,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF0F172A),
                          ),
                        ),
                      ),
                      if (isPaid)
                        Container(
                          margin: EdgeInsets.only(left: 8.w),
                          padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 2.h),
                          decoration: BoxDecoration(
                            color: const Color(0xFFECFDF5),
                            borderRadius: BorderRadius.circular(5.r),
                            border: Border.all(color: const Color(0xFFA7F3D0)),
                          ),
                          child: Text(
                            'PAID',
                            style: TextStyle(
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF059669),
                            ),
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    isPaid ? (fee.paidAt != null ? 'Paid: ${fee.paidAt}' : fee.dueDate) : fee.dueDate,
                    style: GoogleFonts.inter(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    '₹${fee.amount}',
                    style: GoogleFonts.inter(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w800,
                      color: isPaid ? const Color(0xFF10B981) : const Color(0xFFD97706),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(width: 12.w),

            // Checkbox or Receipt Icon
            if (isPaid)
              IconButton(
                icon: const Icon(Icons.receipt_long_rounded, color: Color(0xFF10B981)),
                tooltip: 'View Live Receipt',
                onPressed: () {
                  PaymentReceiptDialog.show(
                    context,
                    fee: fee,
                    studentName: controller.userName.value,
                  );
                },
              )
            else
              Container(
                width: 24.h,
                height: 24.h,
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFFF9D106)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(6.r),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF0F172A)
                        : const Color(0xFF94A3B8),
                    width: 1.8,
                  ),
                ),
                child: isSelected
                    ? Center(
                        child: Icon(
                          Icons.check_rounded,
                          size: 18.sp,
                          color: const Color(0xFF0F172A),
                        ),
                      )
                    : null,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPayFeesButton(HomeController controller) {
    return Obx(() {
      final hasSelection = controller.selectedFeeIds.isNotEmpty;
      final totalAmount = controller.totalSelectedAmount;
      final isPaying = controller.isPayingFees.value;

      return GestureDetector(
        onTap: hasSelection && !isPaying
            ? () => controller.paySelectedFees()
            : null,
        child: Container(
          width: double.infinity,
          height: 48.h,
          decoration: BoxDecoration(
            color: hasSelection
                ? const Color(0xFFF9D106)
                : const Color(0xFFE2E8F0),
            borderRadius: BorderRadius.circular(24.r),
          ),
          child: Center(
            child: isPaying
                ? SizedBox(
                    width: 20.h,
                    height: 20.h,
                    child: const CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Color(0xFF0F172A),
                    ),
                  )
                : Text(
                    hasSelection ? 'Pay ₹$totalAmount' : 'Select fees to pay',
                    style: GoogleFonts.inter(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w700,
                      color: hasSelection
                          ? const Color(0xFF0F172A)
                          : const Color(0xFF94A3B8),
                    ),
                  ),
          ),
        ),
      );
    });
  }

  // ===========================================================================
  // PAY & PLAY: 1. SPORTS CATALOG (QUICK SELECTION)
  // ===========================================================================

  Widget _buildPayAndPlaySportsCatalog(HomeController controller) {
    final defaultSports = [
      {'name': 'Badminton', 'icon': Icons.sports_tennis_rounded, 'slug': 'badminton'},
      {'name': 'Box Cricket', 'icon': Icons.sports_cricket_rounded, 'slug': 'box-cricket'},
      {'name': 'Tennis', 'icon': Icons.sports_baseball_rounded, 'slug': 'tennis'},
      {'name': 'Pickleball', 'icon': Icons.sports_volleyball_rounded, 'slug': 'pickleball'},
      {'name': 'Football', 'icon': Icons.sports_soccer_rounded, 'slug': 'football'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                'Select Sport',
                style: GoogleFonts.inter(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF0F172A),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(width: 8.w),
            GestureDetector(
              onTap: () {
                if (Get.isRegistered<MainNavController>()) {
                  Get.find<MainNavController>().changeTab(1);
                } else {
                  Get.to(() => const CourtBookingScreen());
                }
              },
              child: Text(
                'View All Courts →',
                style: GoogleFonts.inter(
                  fontSize: 12.5.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFFD97706),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        SizedBox(
          height: 114.h,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: defaultSports.length,
            separatorBuilder: (_, _) => SizedBox(width: 12.w),
            itemBuilder: (context, index) {
              final sp = defaultSports[index];
              return GestureDetector(
                onTap: () {
                  if (Get.isRegistered<MainNavController>()) {
                    Get.find<MainNavController>().changeTab(1);
                  } else {
                    Get.to(() => const CourtBookingScreen());
                  }
                },
                child: Container(
                  width: 96.w,
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: EdgeInsets.all(7.w),
                        decoration: const BoxDecoration(
                          color: Color(0xFFFFF9DB),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(sp['icon'] as IconData, size: 22.sp, color: const Color(0xFFD97706)),
                      ),
                      SizedBox(height: 6.h),
                      Text(
                        sp['name'] as String,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          fontSize: 11.5.sp,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ===========================================================================
  // PAY & PLAY: 2. ACTIVE COURT PASSES & ACCESS PINS
  // ===========================================================================

  Widget _buildActivePassesSection(HomeController controller) {
    return Obx(() {
      final passes = controller.myBookings;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'My Active Passes',
                style: GoogleFonts.inter(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF0F172A),
                ),
              ),
              if (passes.isNotEmpty)
                GestureDetector(
                  onTap: () {
                    if (Get.isRegistered<MainNavController>()) {
                      Get.find<MainNavController>().changeTab(2); // Payments/Passes tab
                    }
                  },
                  child: Text(
                    'All Passes (${passes.length})',
                    style: GoogleFonts.inter(
                      fontSize: 12.5.sp,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFFD97706),
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: 12.h),
          if (passes.isEmpty)
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(18.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18.r),
                border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
              ),
              child: Column(
                children: [
                  Icon(Icons.confirmation_number_outlined, size: 40.sp, color: const Color(0xFF94A3B8)),
                  SizedBox(height: 8.h),
                  Text(
                    'No Active Court Passes',
                    style: GoogleFonts.inter(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF334155),
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'Book a court to receive your digital PIN & entry turnstile QR code.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(fontSize: 12.sp, color: const Color(0xFF64748B)),
                  ),
                  SizedBox(height: 12.h),
                  ElevatedButton(
                    onPressed: () {
                      if (Get.isRegistered<MainNavController>()) {
                        Get.find<MainNavController>().changeTab(1);
                      } else {
                        Get.to(() => const CourtBookingScreen());
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF9D106),
                      foregroundColor: const Color(0xFF0F172A),
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                    ),
                    child: const Text('Book Court Now', style: TextStyle(fontWeight: FontWeight.w800)),
                  ),
                ],
              ),
            )
          else
            ...passes.take(2).map((pass) => _buildPassCard(pass)),
        ],
      );
    });
  }

  Widget _buildPassCard(BookingPassModel pass) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF9DB),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  pass.sportName.toUpperCase(),
                  style: GoogleFonts.inter(
                    fontSize: 10.5.sp,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFFD97706),
                    letterSpacing: 0.8,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Text(
                  pass.status,
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF10B981),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Text(
            pass.courtName,
            style: GoogleFonts.inter(
              fontSize: 17.sp,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 4.h),
          Row(
            children: [
              Icon(Icons.calendar_today_rounded, size: 13.sp, color: const Color(0xFF94A3B8)),
              SizedBox(width: 5.w),
              Text(
                '${pass.dateText} • ${pass.timeWindow}',
                style: GoogleFonts.inter(fontSize: 12.sp, color: const Color(0xFFCBD5E1)),
              ),
            ],
          ),
          SizedBox(height: 14.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'GATE ACCESS PIN',
                      style: GoogleFonts.inter(
                        fontSize: 9.5.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF94A3B8),
                        letterSpacing: 0.5,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      pass.accessPin,
                      style: GoogleFonts.inter(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFFF9D106),
                        letterSpacing: 4.0,
                      ),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: () => Get.to(() => DigitalPassScreen(pass: pass)),
                  icon: const Icon(Icons.qr_code_rounded, size: 16),
                  label: const Text('View Pass'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF9D106),
                    foregroundColor: const Color(0xFF0F172A),
                    elevation: 0,
                    padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // PAY & PLAY: 3. RECENT BOOKING PAYMENTS & INVOICES
  // ===========================================================================

  Widget _buildBookingPaymentsSection(HomeController controller, BuildContext context) {
    return Obx(() {
      final payments = controller.monthlyFees.where((f) => f.isPaid).toList();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Recent Payments',
                  style: GoogleFonts.inter(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF0F172A),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(width: 8.w),
              GestureDetector(
                onTap: () {
                  if (Get.isRegistered<MainNavController>()) {
                    Get.find<MainNavController>().changeTab(2); // Payments tab
                  }
                },
                child: Text(
                  'View All Invoices →',
                  style: GoogleFonts.inter(
                    fontSize: 12.5.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFFD97706),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          if (payments.isEmpty)
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(18.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18.r),
                border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
              ),
              child: Center(
                child: Text(
                  'No past payment transactions recorded yet.',
                  style: GoogleFonts.inter(fontSize: 13.sp, color: const Color(0xFF64748B)),
                ),
              ),
            )
          else
            ...payments.take(3).map((fee) => Container(
                  margin: EdgeInsets.only(bottom: 10.h),
                  padding: EdgeInsets.all(14.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(10.w),
                        decoration: const BoxDecoration(
                          color: Color(0xFFECFDF5),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.receipt_long_rounded, color: const Color(0xFF10B981), size: 22.sp),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              fee.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.inter(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF0F172A),
                              ),
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              'Paid via Razorpay Gateway • ${fee.dueDate}',
                              style: GoogleFonts.inter(
                                fontSize: 11.sp,
                                color: const Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '₹${fee.amount}',
                            style: GoogleFonts.inter(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF0F172A),
                            ),
                          ),
                          SizedBox(height: 3.h),
                          GestureDetector(
                            onTap: () => PaymentReceiptDialog.show(context, fee: fee),
                            child: Text(
                              'Receipt',
                              style: GoogleFonts.inter(
                                fontSize: 11.5.sp,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF2563EB),
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                )),
        ],
      );
    });
  }
}
