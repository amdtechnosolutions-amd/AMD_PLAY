import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../data/models/booking_pass_model.dart';
import '../../../main_nav/presentation/controllers/main_nav_controller.dart';
import '../../../home/presentation/widgets/payment_receipt_dialog.dart';

class DigitalPassScreen extends StatelessWidget {
  final BookingPassModel pass;

  const DigitalPassScreen({super.key, required this.pass});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A), // Dark obsidian theme for digital pass
      appBar: AppBar(
        title: const Text('Digital Entry Pass', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: Colors.white),
          onPressed: () {
            // Navigate back to main nav
            if (Get.isRegistered<MainNavController>()) {
              Get.find<MainNavController>().changeTab(1); // Bookings tab
            }
            Get.until((route) => route.isFirst);
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.w),
        child: Column(
          children: [
            // Success Header
            const Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 48),
            SizedBox(height: 8.h),
            Text(
              pass.isMultiSlot ? 'Multi-Slot Booking Confirmed!' : 'Booking Confirmed!',
              style: AppTypography.screenTitle.copyWith(color: Colors.white),
            ),
            Text(
              'Ref: ${pass.groupBookingNumber ?? pass.bookingReference}${pass.isMultiSlot ? " • ${pass.totalSlots} Sessions" : ""}',
              style: TextStyle(fontSize: 12.sp, color: Colors.white70, fontFamily: 'monospace'),
            ),
            SizedBox(height: 24.h),

            // Pass Ticket Card
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Upper Ticket Part
                  Padding(
                    padding: EdgeInsets.all(20.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (pass.isMultiSlot && pass.subBookings.isNotEmpty) ...[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${pass.totalSlots} SESSIONS RESERVED',
                                style: TextStyle(
                                  fontSize: 11.sp,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                  letterSpacing: 1.2,
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFECFDF5),
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                                child: Text(
                                  pass.status,
                                  style: const TextStyle(
                                      fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF059669)),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 12.h),
                          ...pass.subBookings.map((b) => Container(
                                margin: EdgeInsets.only(bottom: 8.h),
                                padding: EdgeInsets.all(10.w),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF8FAFC),
                                  borderRadius: BorderRadius.circular(10.r),
                                  border: Border.all(color: const Color(0xFFE2E8F0)),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '${b.sportName} • ${b.courtName}',
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize: 12.5.sp,
                                              fontWeight: FontWeight.w700,
                                              color: const Color(0xFF0F172A),
                                            ),
                                          ),
                                          SizedBox(height: 2.h),
                                          Text(
                                            '${b.dateText} | ${b.timeWindow}',
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize: 11.sp,
                                              color: const Color(0xFF64748B),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(width: 8.w),
                                    Text(
                                      '₹${b.totalAmount.toInt()}',
                                      style: TextStyle(
                                        fontSize: 12.5.sp,
                                        fontWeight: FontWeight.w800,
                                        color: const Color(0xFF0F172A),
                                      ),
                                    ),
                                  ],
                                ),
                              )),
                          const Divider(height: 20),
                          _ticketMeta('FACILITY', pass.venueName),
                        ] else ...[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(pass.sportName.toUpperCase(),
                                        style: TextStyle(
                                            fontSize: 10.sp,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.primary,
                                            letterSpacing: 1.2)),
                                    SizedBox(height: 2.h),
                                    Text(pass.courtName, style: AppTypography.cardTitle),
                                  ],
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFECFDF5),
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                                child: Text(
                                  pass.status,
                                  style: const TextStyle(
                                      fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF059669)),
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 28),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(child: _ticketMeta('DATE', pass.dateText)),
                              Expanded(child: _ticketMeta('TIME WINDOW', pass.timeWindow)),
                            ],
                          ),
                          SizedBox(height: 14.h),
                          _ticketMeta('FACILITY', pass.venueName),
                        ],
                      ],
                    ),
                  ),

                  // Perforated Line with Notches
                  Row(
                    children: [
                      Container(
                        width: 14.w,
                        height: 28.h,
                        decoration: const BoxDecoration(
                          color: Color(0xFF0F172A),
                          borderRadius: BorderRadius.horizontal(right: Radius.circular(14)),
                        ),
                      ),
                      Expanded(
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            return Flex(
                              direction: Axis.horizontal,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: List.generate(
                                (constraints.constrainWidth() / 10).floor(),
                                (_) => SizedBox(
                                  width: 5,
                                  height: 1,
                                  child: DecoratedBox(
                                    decoration: BoxDecoration(color: Colors.grey.shade300),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      Container(
                        width: 14.w,
                        height: 28.h,
                        decoration: const BoxDecoration(
                          color: Color(0xFF0F172A),
                          borderRadius: BorderRadius.horizontal(left: Radius.circular(14)),
                        ),
                      ),
                    ],
                  ),

                  // Lower Ticket Part: 6-Digit PIN & QR
                  Padding(
                    padding: EdgeInsets.all(20.w),
                    child: Column(
                      children: [
                        Text(
                          'SMART DOOR ACCESS PIN',
                          style: TextStyle(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textSecondary,
                              letterSpacing: 1.2),
                        ),
                        SizedBox(height: 8.h),

                        // 6-Digit PIN Box
                        GestureDetector(
                          onTap: () {
                            Clipboard.setData(ClipboardData(text: pass.accessPin));
                            Get.snackbar(
                              'PIN Copied',
                              'Access PIN ${pass.accessPin} copied to clipboard',
                              snackPosition: SnackPosition.BOTTOM,
                              backgroundColor: Colors.white,
                              duration: const Duration(seconds: 2),
                            );
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(14.r),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  pass.accessPin,
                                  style: TextStyle(
                                    fontSize: 28.sp,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 6,
                                    fontFamily: 'monospace',
                                    color: AppColors.primary,
                                  ),
                                ),
                                SizedBox(width: 12.w),
                                const Icon(Icons.copy_rounded, size: 18, color: AppColors.textSecondary),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 16.h),

                        // QR Code image
                        Container(
                          width: 140.w,
                          height: 140.w,
                          padding: EdgeInsets.all(8.w),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade200),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: (pass.qrPassUrl.isNotEmpty && pass.qrPassUrl.startsWith('http'))
                              ? Image.network(
                                  pass.qrPassUrl,
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) =>
                                      const Icon(Icons.qr_code_2_rounded, size: 100),
                                )
                              : const Icon(Icons.qr_code_2_rounded, size: 100),
                        ),


                        SizedBox(height: 12.h),
                        Text(
                          'Scan QR code at venue turnstile or enter PIN on keypad\n(Valid ±15 minutes around slot start)',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 10.sp, color: AppColors.textSecondary, height: 1.4),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24.h),

            // Return to Home & View Receipt Row
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      side: const BorderSide(color: Color(0xFFD4AF37)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                    ),
                    icon: Icon(Icons.receipt_long_rounded, color: const Color(0xFFD4AF37), size: 18.sp),
                    label: Text(
                      'RECEIPT',
                      style: TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 12.5.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    onPressed: () => PaymentReceiptDialog.showBooking(context, pass: pass),
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                    ),
                    onPressed: () {
                      if (Get.isRegistered<MainNavController>()) {
                        Get.find<MainNavController>().changeTab(1); // Bookings tab
                      }
                      Get.until((route) => route.isFirst);
                    },
                    child: Text(
                      'MY BOOKINGS',
                      style: TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 12.5.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _ticketMeta(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
        SizedBox(height: 2.h),
        Text(value, style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
      ],
    );
  }
}
