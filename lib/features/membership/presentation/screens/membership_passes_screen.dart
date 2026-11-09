import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../home/presentation/controllers/home_controller.dart';
import '../../../main_nav/presentation/controllers/main_nav_controller.dart';
import '../../../booking/data/models/booking_pass_model.dart';
import '../../../home/presentation/widgets/payment_receipt_dialog.dart';

/// Screen displaying Academy Memberships & Season Passes.
/// Strictly presents real data and empty states with zero mock/dummy plans.
class MembershipPassesScreen extends StatelessWidget {
  const MembershipPassesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final HomeController? homeCtrl =
        Get.isRegistered<HomeController>() ? Get.find<HomeController>() : null;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Academy Memberships',
          style: TextStyle(
            fontFamily: 'Nunito',
            fontSize: 18.sp,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF0F172A),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF0F172A)),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 40.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Check if user has active court passes from live bookings
            if (homeCtrl != null)
              Obx(() {
                final passes = homeCtrl.myBookings;
                if (passes.isEmpty) {
                  return const SizedBox.shrink();
                }

                final activePass = passes.first;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ACTIVE ACCESS PASS',
                      style: TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                        color: const Color(0xFFD4AF37),
                      ),
                    ),
                    SizedBox(height: 10.h),
                    _buildActiveBookingPassCard(context, activePass),
                    SizedBox(height: 24.h),
                  ],
                );
              }),

            // Status & Information Card
            _buildMembershipStatusCard(context),
            SizedBox(height: 20.h),

            // Benefits & Facility Privileges
            _buildPrivilegesCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveBookingPassCard(BuildContext context, dynamic pass) {
    final courtName = pass.courtName.isNotEmpty ? pass.courtName : 'Court Reservation';
    final sportName = pass.sportName.isNotEmpty ? pass.sportName : 'Academy Slot';
    final date = pass.dateText.isNotEmpty ? pass.dateText : 'Confirmed';
    final time = pass.timeWindow.isNotEmpty ? pass.timeWindow : '';
    final pin = pass.accessPin.isNotEmpty ? pass.accessPin : 'Active';

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: const Color(0xFFD4AF37),
          width: 1.5,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x28D4AF37),
            blurRadius: 18,
            offset: Offset(0, 6),
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
                  color: const Color(0xFFECFDF5),
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(color: const Color(0xFF10B981), width: 1),
                ),
                child: Text(
                  'CONFIRMED PASS',
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF047857),
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              Row(
                children: [
                  Icon(Icons.vpn_key_rounded, size: 14.sp, color: const Color(0xFFD4AF37)),
                  SizedBox(width: 4.w),
                  Text(
                    'PIN: $pin',
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            courtName,
            style: TextStyle(
              fontFamily: 'Nunito',
              fontSize: 17.sp,
              fontWeight: FontWeight.w900,
              color: const Color(0xFF0F172A),
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            '$sportName • $date ${time.isNotEmpty ? '• $time' : ''}',
            style: TextStyle(
              fontFamily: 'Nunito',
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF64748B),
            ),
          ),
          SizedBox(height: 12.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFFD4AF37), width: 1.1),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                ),
                icon: const Icon(Icons.receipt_long_rounded, size: 14, color: Color(0xFF9E7B1A)),
                label: Text(
                  'VIEW INVOICE',
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                onPressed: () {
                  if (pass is BookingPassModel) {
                    PaymentReceiptDialog.showBooking(context, pass: pass);
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMembershipStatusCard(BuildContext context) {
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
          Container(
            width: 72.h,
            height: 72.h,
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
                Icons.card_membership_rounded,
                size: 36.sp,
                color: const Color(0xFFD4AF37),
              ),
            ),
          ),
          SizedBox(height: 16.h),

          Container(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 5.h),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFBEB),
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(color: const Color(0xFFF59E0B), width: 1),
            ),
            child: Text(
              'ACADEMY MEMBERSHIP PACKAGES',
              style: TextStyle(
                fontFamily: 'Nunito',
                fontSize: 10.5.sp,
                fontWeight: FontWeight.w800,
                color: const Color(0xFFB45309),
                letterSpacing: 0.6,
              ),
            ),
          ),
          SizedBox(height: 14.h),

          Text(
            'Memberships Available Soon',
            style: TextStyle(
              fontFamily: 'Nunito',
              fontSize: 19.sp,
              fontWeight: FontWeight.w900,
              color: const Color(0xFF0F172A),
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8.h),

          Padding(
            padding: EdgeInsets.symmetric(horizontal: 6.w),
            child: Text(
              'Monthly subscription passes and multi-court packages are currently managed directly by academy administration. You can book individual hourly slots with instant gate PIN confirmation.',
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
                  Get.back();
                  if (Get.isRegistered<MainNavController>()) {
                    Get.find<MainNavController>().changeTab(1);
                  }
                },
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.sports_tennis_rounded,
                        color: const Color(0xFFD4AF37),
                        size: 20.sp,
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        'BOOK COURT SLOT NOW',
                        style: TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFF0F172A),
                          letterSpacing: 0.5,
                        ),
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

  Widget _buildPrivilegesCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(
          color: const Color(0x35D4AF37),
          width: 1.2,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x18D4AF37),
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
              Icon(Icons.workspace_premium_rounded, color: const Color(0xFFD4AF37), size: 22.sp),
              SizedBox(width: 8.w),
              Text(
                'Member Privileges & Inquiries',
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),
          _buildPrivilegeRow(
            icon: Icons.flash_on_rounded,
            title: 'Automated Smart Gate Access',
            subtitle: 'Instant unique PIN and QR code generation for entry gates.',
          ),
          SizedBox(height: 10.h),
          _buildPrivilegeRow(
            icon: Icons.schedule_rounded,
            title: 'Flexible Pay & Play Slots',
            subtitle: 'Reserve badminton courts and sports turf by the hour.',
          ),
          SizedBox(height: 10.h),
          _buildPrivilegeRow(
            icon: Icons.support_agent_rounded,
            title: 'Desk Inquiries & Corporate Plans',
            subtitle: 'Contact the academy front desk for customized corporate passes.',
          ),
        ],
      ),
    );
  }

  Widget _buildPrivilegeRow({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(6.w),
          decoration: BoxDecoration(
            color: const Color(0xFFFFFBEB),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Icon(icon, size: 16.sp, color: const Color(0xFFD4AF37)),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF0F172A),
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                subtitle,
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
