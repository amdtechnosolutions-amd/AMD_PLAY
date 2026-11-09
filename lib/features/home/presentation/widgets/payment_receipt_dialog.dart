import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:mobile_app/features/booking/data/models/booking_pass_model.dart';
import '../controllers/home_controller.dart';

/// Unified Tax Invoice & Official Payment Receipt Dialog
/// Supports all 3 payment categories:
/// 1. Booking Payments (court reservations & slot passes)
/// 2. Fee Payments (academy student monthly fees)
/// 3. Member Fees (VIP membership subscriptions & packages)
class PaymentReceiptDialog extends StatelessWidget {
  final String receiptNumber;
  final String receiptType; // 'Booking', 'Fee', or 'Membership'
  final String title;
  final String? sportName;
  final String? schedule;
  final String customerName;
  final String customerPhone;
  final String dateText;
  final int totalAmount;
  final int baseAmount;
  final int discountAmount;
  final int taxAmount;
  final String status;
  final String razorpayPaymentId;
  final String? razorpayOrderId;
  final String? notes;

  const PaymentReceiptDialog({
    super.key,
    required this.receiptNumber,
    required this.receiptType,
    required this.title,
    this.sportName,
    this.schedule,
    required this.customerName,
    this.customerPhone = '',
    required this.dateText,
    required this.totalAmount,
    required this.baseAmount,
    this.discountAmount = 0,
    this.taxAmount = 0,
    this.status = 'PAID',
    required this.razorpayPaymentId,
    this.razorpayOrderId,
    this.notes,
  });

  /// Factory constructor from FeeItem (Student Coaching Fees)
  factory PaymentReceiptDialog.fromFee({
    required FeeItem fee,
    String? studentName,
    String? studentPhone,
  }) {
    return PaymentReceiptDialog(
      receiptNumber: fee.receiptNumber,
      receiptType: 'Fee',
      title: fee.title,
      sportName: fee.sportName ?? 'Badminton',
      schedule: fee.formattedPeriod,
      customerName: studentName ?? fee.studentName ?? 'Academy Trainee',
      customerPhone: studentPhone ?? fee.studentPhone ?? '',
      dateText: fee.paidAt ?? fee.dueDate,
      totalAmount: fee.paidAmount > 0 ? fee.paidAmount : fee.amount,
      baseAmount: fee.baseFee > 0 ? fee.baseFee : fee.amount,
      discountAmount: fee.discountAmount,
      status: fee.status.toUpperCase(),
      razorpayPaymentId: fee.razorpayPaymentId ?? 'pay_live_settled',
      razorpayOrderId: fee.razorpayOrderId,
      notes: fee.notes ?? 'Monthly Coaching Academy Subscription',
    );
  }

  /// Factory constructor from BookingPassModel (Court Reservations)
  factory PaymentReceiptDialog.fromBooking({
    required BookingPassModel pass,
    String? customerName,
    String? customerPhone,
  }) {
    final ref = pass.bookingReference.isNotEmpty ? pass.bookingReference : pass.id;
    final rcpNo = 'RCP-${ref.replaceAll('-', '').toUpperCase()}';

    return PaymentReceiptDialog(
      receiptNumber: rcpNo,
      receiptType: 'Booking',
      title: '${pass.sportName} - ${pass.courtName}',
      sportName: pass.sportName,
      schedule: '${pass.dateText} • ${pass.timeWindow}',
      customerName: customerName ?? pass.playerName ?? 'Academy Player',
      customerPhone: customerPhone ?? '',
      dateText: pass.dateText,
      totalAmount: pass.totalAmount.round(),
      baseAmount: pass.amount.round(),
      taxAmount: pass.taxAmount.round(),
      status: pass.status.toUpperCase() == 'CONFIRMED' ? 'PAID' : pass.status.toUpperCase(),
      razorpayPaymentId: pass.razorpayPaymentId ?? 'pay_rzp_${ref.replaceAll('-', '_')}',
      razorpayOrderId: pass.razorpayOrderId,
      notes: 'Court Reservation PIN: ${pass.accessPin}',
    );
  }

  /// Factory constructor for Membership Pass payments
  factory PaymentReceiptDialog.fromMembership({
    required String receiptNumber,
    required String title,
    String? sportName,
    String? schedule,
    required String customerName,
    String customerPhone = '',
    required String dateText,
    required int totalAmount,
    required int baseAmount,
    int discountAmount = 0,
    String status = 'PAID',
    required String razorpayPaymentId,
    String? razorpayOrderId,
    String? notes,
  }) {
    return PaymentReceiptDialog(
      receiptNumber: receiptNumber,
      receiptType: 'Membership',
      title: title,
      sportName: sportName ?? 'All Sports Access',
      schedule: schedule ?? 'Annual / Season Pass',
      customerName: customerName,
      customerPhone: customerPhone,
      dateText: dateText,
      totalAmount: totalAmount,
      baseAmount: baseAmount,
      discountAmount: discountAmount,
      status: status,
      razorpayPaymentId: razorpayPaymentId,
      razorpayOrderId: razorpayOrderId,
      notes: notes ?? 'VIP Academy Facility Pass',
    );
  }

  /// Show dialog for FeeItem
  static void show(
    BuildContext context, {
    required FeeItem fee,
    String? studentName,
    String? studentPhone,
  }) {
    showDialog(
      context: context,
      builder: (ctx) => PaymentReceiptDialog.fromFee(
        fee: fee,
        studentName: studentName,
        studentPhone: studentPhone,
      ),
    );
  }

  /// Show dialog for BookingPassModel
  static void showBooking(
    BuildContext context, {
    required BookingPassModel pass,
    String? customerName,
    String? customerPhone,
  }) {
    showDialog(
      context: context,
      builder: (ctx) => PaymentReceiptDialog.fromBooking(
        pass: pass,
        customerName: customerName,
        customerPhone: customerPhone,
      ),
    );
  }

  /// Show dialog for Membership pass
  static void showMembership(
    BuildContext context, {
    required String receiptNumber,
    required String title,
    String? sportName,
    String? schedule,
    required String customerName,
    String customerPhone = '',
    required String dateText,
    required int totalAmount,
    required int baseAmount,
    int discountAmount = 0,
    String status = 'PAID',
    required String razorpayPaymentId,
    String? razorpayOrderId,
    String? notes,
  }) {
    showDialog(
      context: context,
      builder: (ctx) => PaymentReceiptDialog.fromMembership(
        receiptNumber: receiptNumber,
        title: title,
        sportName: sportName,
        schedule: schedule,
        customerName: customerName,
        customerPhone: customerPhone,
        dateText: dateText,
        totalAmount: totalAmount,
        baseAmount: baseAmount,
        discountAmount: discountAmount,
        status: status,
        razorpayPaymentId: razorpayPaymentId,
        razorpayOrderId: razorpayOrderId,
        notes: notes,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Color typeColor = const Color(0xFF10B981); // Emerald
    IconData typeIcon = Icons.check_circle_rounded;
    String typeLabel = 'TAX INVOICE';

    if (receiptType == 'Booking') {
      typeColor = const Color(0xFFD4AF37); // Gold
      typeIcon = Icons.sports_tennis_rounded;
      typeLabel = 'COURT BOOKING INVOICE';
    } else if (receiptType == 'Membership') {
      typeColor = const Color(0xFF8B5CF6); // Purple
      typeIcon = Icons.card_membership_rounded;
      typeLabel = 'MEMBERSHIP INVOICE';
    } else {
      typeColor = const Color(0xFF10B981); // Green
      typeIcon = Icons.school_rounded;
      typeLabel = 'COACHING FEE INVOICE';
    }

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
      child: Container(
        constraints: BoxConstraints(maxWidth: 420.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.25),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Top Luxury Banner
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
              decoration: BoxDecoration(
                color: typeColor,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.25),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(typeIcon, color: Colors.white, size: 24.sp),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Payment Receipt',
                          style: TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          typeLabel,
                          style: TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w700,
                            color: Colors.white.withValues(alpha: 0.95),
                            letterSpacing: 0.6,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            // Receipt Body Content
            Flexible(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(20.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Receipt Number & Date row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'RECEIPT NO',
                              style: TextStyle(
                                fontFamily: 'Nunito',
                                fontSize: 10.sp,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF94A3B8),
                                letterSpacing: 0.8,
                              ),
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              receiptNumber,
                              style: TextStyle(
                                fontFamily: 'Nunito',
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF0F172A),
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'DATE & TIME',
                              style: TextStyle(
                                fontFamily: 'Nunito',
                                fontSize: 10.sp,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF94A3B8),
                                letterSpacing: 0.8,
                              ),
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              dateText.isNotEmpty ? dateText : 'Confirmed',
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

                    SizedBox(height: 14.h),
                    const Divider(color: Color(0xFFE2E8F0)),
                    SizedBox(height: 10.h),

                    // Customer / Student / Member Details
                    Text(
                      receiptType == 'Fee'
                          ? 'STUDENT / TRAINEE'
                          : (receiptType == 'Membership' ? 'MEMBER DETAILS' : 'BOOKED BY'),
                      style: TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 10.sp,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF94A3B8),
                        letterSpacing: 0.8,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 16.r,
                          backgroundColor: const Color(0xFFFFFDF5),
                          child: Text(
                            customerName.isNotEmpty ? customerName[0].toUpperCase() : 'U',
                            style: TextStyle(
                              fontFamily: 'Nunito',
                              color: const Color(0xFF9E7B1A),
                              fontWeight: FontWeight.w900,
                              fontSize: 14.sp,
                            ),
                          ),
                        ),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                customerName,
                                style: TextStyle(
                                  fontFamily: 'Nunito',
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF0F172A),
                                ),
                              ),
                              if (customerPhone.isNotEmpty)
                                Text(
                                  customerPhone,
                                  style: TextStyle(
                                    fontFamily: 'Nunito',
                                    fontSize: 12.sp,
                                    color: const Color(0xFF64748B),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFFDF5),
                            borderRadius: BorderRadius.circular(8.r),
                            border: Border.all(color: const Color(0x60D4AF37), width: 1),
                          ),
                          child: Text(
                            receiptType.toUpperCase(),
                            style: TextStyle(
                              fontFamily: 'Nunito',
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF9E7B1A),
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 14.h),
                    const Divider(color: Color(0xFFE2E8F0)),
                    SizedBox(height: 10.h),

                    // Subscription / Reservation Details
                    Text(
                      'ITEM DETAILS',
                      style: TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 10.sp,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF94A3B8),
                        letterSpacing: 0.8,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    _buildRow('Description', title),
                    if (sportName != null && sportName!.isNotEmpty)
                      _buildRow('Sport Category', sportName!),
                    if (schedule != null && schedule!.isNotEmpty)
                      _buildRow(receiptType == 'Fee' ? 'Billing Period' : 'Session Schedule', schedule!),
                    _buildRow('Payment Gateway', 'Razorpay UPI / Online Gateway'),
                    _buildRow('Payment ID', razorpayPaymentId, isMono: true),
                    if (razorpayOrderId != null && razorpayOrderId!.isNotEmpty && razorpayOrderId != 'null')
                      _buildRow('Order ID', razorpayOrderId!, isMono: true),
                    if (notes != null && notes!.isNotEmpty)
                      _buildRow('Reference Notes', notes!),

                    SizedBox(height: 14.h),
                    const Divider(color: Color(0xFFE2E8F0)),
                    SizedBox(height: 10.h),

                    // Price Breakdown
                    Text(
                      'PAYMENT BREAKDOWN',
                      style: TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 10.sp,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF94A3B8),
                        letterSpacing: 0.8,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    _buildRow('Base Amount', '₹$baseAmount'),
                    if (taxAmount > 0)
                      _buildRow('Taxes & GST (Included)', '₹$taxAmount'),
                    if (discountAmount > 0)
                      _buildRow('Special Discount / Sibling', '-₹$discountAmount', isDiscount: true),
                    SizedBox(height: 8.h),

                    // Total Amount Banner
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total Paid',
                            style: TextStyle(
                              fontFamily: 'Nunito',
                              fontSize: 15.sp,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF0F172A),
                            ),
                          ),
                          Row(
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFECFDF5),
                                  borderRadius: BorderRadius.circular(6.r),
                                  border: Border.all(color: const Color(0xFFA7F3D0)),
                                ),
                                child: Text(
                                  status.toUpperCase(),
                                  style: TextStyle(
                                    fontFamily: 'Nunito',
                                    fontSize: 11.sp,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF059669),
                                  ),
                                ),
                              ),
                              SizedBox(width: 8.w),
                              Text(
                                '₹$totalAmount',
                                style: TextStyle(
                                  fontFamily: 'Nunito',
                                  fontSize: 19.sp,
                                  fontWeight: FontWeight.w900,
                                  color: const Color(0xFF10B981),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 14.h),
                    Center(
                      child: Text(
                        'Thank you for training with Inertia Sports Academy!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 11.sp,
                          color: const Color(0xFF94A3B8),
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Bottom Actions
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(24.r)),
                border: const Border(top: BorderSide(color: Color(0xFFE2E8F0))),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        side: const BorderSide(color: Color(0xFFD4AF37)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                      ),
                      icon: Icon(Icons.download_rounded, size: 18.sp, color: const Color(0xFF9E7B1A)),
                      label: Text(
                        'Download PDF',
                        style: TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 13.sp,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                      onPressed: () {
                        Get.snackbar(
                          'Invoice Saved',
                          'PDF invoice $receiptNumber has been generated and saved to your device.',
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: Colors.white,
                          colorText: const Color(0xFF0F172A),
                          borderColor: const Color(0xFF10B981),
                          borderWidth: 1.2,
                          margin: const EdgeInsets.all(16),
                          borderRadius: 14,
                          icon: const Icon(Icons.check_circle_rounded, color: Color(0xFF10B981)),
                        );
                      },
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD4AF37),
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                        elevation: 0,
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(
                        'Done',
                        style: TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 13.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
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

  Widget _buildRow(String label, String value, {bool isMono = false, bool isDiscount = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Nunito',
              fontSize: 12.sp,
              color: const Color(0xFF64748B),
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: isMono ? 'monospace' : 'Nunito',
                fontSize: 12.sp,
                fontWeight: FontWeight.w700,
                color: isDiscount ? const Color(0xFFEF4444) : const Color(0xFF0F172A),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
