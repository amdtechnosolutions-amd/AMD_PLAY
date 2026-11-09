import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../core/services/pdf_receipt_service.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../booking/data/models/booking_pass_model.dart';
import '../../../booking/data/services/booking_service.dart';
import '../../../home/presentation/controllers/home_controller.dart';
import '../../../home/presentation/widgets/payment_receipt_dialog.dart';

/// Screen listing all Invoices & Official Payment Receipts across:
/// 1. Court Booking Payments
/// 2. Student Monthly Coaching Fees
/// 3. Membership Passes & Subscriptions
class InvoicesReceiptsScreen extends StatefulWidget {
  const InvoicesReceiptsScreen({super.key});

  @override
  State<InvoicesReceiptsScreen> createState() => _InvoicesReceiptsScreenState();
}

class _InvoicesReceiptsScreenState extends State<InvoicesReceiptsScreen> {
  static const Color goldAccent = Color(0xFFD4AF37);
  static const Color darkText = Color(0xFF0F172A);
  static const Color slateText = Color(0xFF64748B);

  final BookingService _bookingService = BookingService();

  String _selectedCategory = 'ALL'; // 'ALL', 'BOOKINGS', 'FEES', 'MEMBERSHIPS'
  bool _isLoading = true;
  List<BookingPassModel> _bookingReceipts = [];
  List<FeeItem> _feeReceipts = [];

  @override
  void initState() {
    super.initState();
    _loadAllReceipts();
  }

  Future<void> _loadAllReceipts() async {
    setState(() => _isLoading = true);

    try {
      // 1. Fetch live booking payments
      final bookings = await _bookingService.getMyBookings();
      _bookingReceipts = bookings;

      // 2. Fetch live fee items from HomeController
      if (Get.isRegistered<HomeController>()) {
        final homeCtrl = Get.find<HomeController>();
        await homeCtrl.refreshDashboard();
        _feeReceipts = homeCtrl.monthlyFees;
      }
    } catch (_) {}

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Collect all unified receipt items
    final List<_UnifiedReceiptItem> allItems = [];

    // Add paid bookings
    for (final b in _bookingReceipts) {
      allItems.add(_UnifiedReceiptItem(
        id: b.id,
        receiptNumber: 'RCP-${b.bookingReference.replaceAll('-', '').toUpperCase()}',
        type: 'Booking',
        title: '${b.sportName} - ${b.courtName}',
        subtitle: '${b.dateText} • ${b.timeWindow}',
        amount: b.totalAmount.round(),
        dateText: b.dateText,
        status: b.status.toUpperCase() == 'CONFIRMED' ? 'PAID' : b.status.toUpperCase(),
        paymentId: b.razorpayPaymentId ?? 'pay_live_settled',
        bookingPass: b,
      ));
    }

    // Add paid coaching fees
    for (final f in _feeReceipts) {
      allItems.add(_UnifiedReceiptItem(
        id: f.id,
        receiptNumber: f.receiptNumber,
        type: 'Fee',
        title: f.title,
        subtitle: '${f.sportName ?? "Badminton Academy"} • ${f.formattedPeriod}',
        amount: f.paidAmount > 0 ? f.paidAmount : f.amount,
        dateText: f.paidAt ?? f.dueDate,
        status: f.status.toUpperCase(),
        paymentId: f.razorpayPaymentId ?? 'pay_live_settled',
        feeItem: f,
      ));
    }

    // Filter items by category
    final filtered = allItems.where((item) {
      if (_selectedCategory == 'ALL') return true;
      if (_selectedCategory == 'BOOKINGS') return item.type == 'Booking';
      if (_selectedCategory == 'FEES') return item.type == 'Fee';
      if (_selectedCategory == 'MEMBERSHIPS') return item.type == 'Membership';
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Invoices & Receipts',
          style: TextStyle(
            fontFamily: 'Nunito',
            fontSize: 18.sp,
            fontWeight: FontWeight.w800,
            color: darkText,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: darkText),
          onPressed: () => Get.back(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: goldAccent),
            tooltip: 'Refresh Invoices',
            onPressed: _loadAllReceipts,
          ),
        ],
      ),
      body: Column(
        children: [
          // Category Filter Tabs
          _buildCategoryFilter(),

          // Receipts List Content
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2.6,
                      color: goldAccent,
                    ),
                  )
                : filtered.isEmpty
                    ? SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 60.h),
                        child: EmptyState(
                          title: 'No Receipts Found',
                          message: 'No settlement records or invoices found for the selected category.',
                          icon: Icons.receipt_long_outlined,
                          buttonText: 'REFRESH',
                          onButtonPressed: _loadAllReceipts,
                        ),
                      )
                    : RefreshIndicator(
                        color: goldAccent,
                        backgroundColor: Colors.white,
                        onRefresh: _loadAllReceipts,
                        child: ListView.builder(
                          padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 40.h),
                          itemCount: filtered.length,
                          itemBuilder: (context, index) {
                            return _buildReceiptCard(filtered[index]);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilter() {
    final categories = [
      {'key': 'ALL', 'label': 'All Receipts'},
      {'key': 'BOOKINGS', 'label': 'Court Bookings'},
      {'key': 'FEES', 'label': 'Coaching Fees'},
      {'key': 'MEMBERSHIPS', 'label': 'Memberships'},
    ];

    return Container(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Row(
          children: categories.map((cat) {
            final isSelected = _selectedCategory == cat['key'];
            return Padding(
              padding: EdgeInsets.only(right: 8.w),
              child: GestureDetector(
                onTap: () => setState(() => _selectedCategory = cat['key']!),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 7.h),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFFFFFDF5) : Colors.white,
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(
                      color: isSelected ? goldAccent : const Color(0xFFE2E8F0),
                      width: isSelected ? 1.4 : 1.0,
                    ),
                    boxShadow: isSelected
                        ? const [
                            BoxShadow(
                              color: Color(0x20D4AF37),
                              blurRadius: 8,
                              offset: Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Text(
                    cat['label']!,
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 12.sp,
                      fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                      color: isSelected ? const Color(0xFF9E7B1A) : slateText,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildReceiptCard(_UnifiedReceiptItem item) {
    Color typeColor = const Color(0xFF10B981);
    IconData typeIcon = Icons.school_rounded;
    String typeLabel = 'COACHING FEE';

    if (item.type == 'Booking') {
      typeColor = const Color(0xFFD4AF37);
      typeIcon = Icons.sports_tennis_rounded;
      typeLabel = 'COURT BOOKING';
    } else if (item.type == 'Membership') {
      typeColor = const Color(0xFF8B5CF6);
      typeIcon = Icons.card_membership_rounded;
      typeLabel = 'MEMBERSHIP';
    }

    return Container(
      margin: EdgeInsets.only(bottom: 14.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: const Color(0x60D4AF37), width: 1.2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x18D4AF37),
            blurRadius: 14,
            offset: Offset(0, 4),
          ),
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Category Pill & Receipt Number
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 10.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(5.w),
                      decoration: BoxDecoration(
                        color: typeColor.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(typeIcon, size: 14.sp, color: typeColor),
                    ),
                    SizedBox(width: 8.w),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFFDF5),
                        borderRadius: BorderRadius.circular(8.r),
                        border: Border.all(color: const Color(0x60D4AF37), width: 0.9),
                      ),
                      child: Text(
                        typeLabel,
                        style: TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 9.5.sp,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF9E7B1A),
                          letterSpacing: 0.4,
                        ),
                      ),
                    ),
                  ],
                ),
                Text(
                  item.receiptNumber,
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 11.5.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),

          // Title & Description
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w800,
                    color: darkText,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  item.subtitle,
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 12.sp,
                    color: slateText,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 12.h),

          // Total Paid & Status Banner
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
            decoration: const BoxDecoration(
              color: Color(0xFFF8FAFC),
              border: Border.symmetric(
                horizontal: BorderSide(color: Color(0xFFE2E8F0)),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'TOTAL SETTLED',
                      style: TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 9.5.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF94A3B8),
                        letterSpacing: 0.5,
                      ),
                    ),
                    Text(
                      '₹${item.amount}',
                      style: TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 16.5.sp,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF10B981),
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFFECFDF5),
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(color: const Color(0xFFA7F3D0)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle_rounded, size: 13, color: Color(0xFF059669)),
                      SizedBox(width: 4.w),
                      Text(
                        item.status,
                        style: TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF059669),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Action Buttons: View Receipt & Download PDF
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 12.h),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: darkText,
                      side: const BorderSide(color: Color(0xFFD4AF37), width: 1.1),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                      padding: EdgeInsets.symmetric(vertical: 8.h),
                    ),
                    icon: Icon(Icons.receipt_long_rounded, size: 16.sp, color: const Color(0xFF9E7B1A)),
                    label: Text(
                      'VIEW RECEIPT',
                      style: TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 11.5.sp,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.3,
                      ),
                    ),
                    onPressed: () {
                      if (item.type == 'Booking' && item.bookingPass != null) {
                        PaymentReceiptDialog.showBooking(
                          context,
                          pass: item.bookingPass!,
                        );
                      } else if (item.type == 'Fee' && item.feeItem != null) {
                        PaymentReceiptDialog.show(
                          context,
                          fee: item.feeItem!,
                        );
                      } else {
                        PaymentReceiptDialog.showMembership(
                          context,
                          receiptNumber: item.receiptNumber,
                          title: item.title,
                          customerName: 'Academy Member',
                          dateText: item.dateText,
                          totalAmount: item.amount,
                          baseAmount: item.amount,
                          razorpayPaymentId: item.paymentId,
                        );
                      }
                    },
                  ),
                ),
                SizedBox(width: 10.w),
                IconButton(
                  icon: Icon(Icons.download_rounded, color: const Color(0xFF9E7B1A), size: 22.sp),
                  tooltip: 'Download Invoice PDF',
                  onPressed: () async {
                    try {
                      if (item.type == 'Booking' && item.bookingPass != null) {
                        final p = item.bookingPass!;
                        final ref = p.bookingReference.isNotEmpty ? p.bookingReference : p.id;
                        final rcpNo = 'RCP-${ref.replaceAll('-', '').toUpperCase()}';
                        await PdfReceiptService.downloadOrShareReceipt(
                          receiptNumber: rcpNo,
                          receiptType: 'Booking',
                          title: '${p.sportName} - ${p.courtName}',
                          sportName: p.sportName,
                          schedule: '${p.dateText} • ${p.timeWindow}',
                          customerName: (p.playerName != null && p.playerName!.isNotEmpty) ? p.playerName! : 'Academy Player',
                          dateText: p.dateText,
                          totalAmount: p.totalAmount.round(),
                          baseAmount: p.amount.round(),
                          taxAmount: p.taxAmount.round(),
                          status: p.status.toUpperCase() == 'CONFIRMED' ? 'PAID' : p.status.toUpperCase(),
                          razorpayPaymentId: p.razorpayPaymentId ?? 'pay_rzp_${ref.replaceAll('-', '_')}',
                          razorpayOrderId: p.razorpayOrderId,
                          notes: 'Court Reservation PIN: ${p.accessPin}',
                        );
                      } else if (item.type == 'Fee' && item.feeItem != null) {
                        final f = item.feeItem!;
                        await PdfReceiptService.downloadOrShareReceipt(
                          receiptNumber: f.receiptNumber,
                          receiptType: 'Fee',
                          title: f.title,
                          sportName: f.sportName ?? 'Badminton',
                          schedule: f.formattedPeriod,
                          customerName: f.studentName ?? 'Academy Trainee',
                          customerPhone: f.studentPhone ?? '',
                          dateText: f.paidAt ?? f.dueDate,
                          totalAmount: f.paidAmount > 0 ? f.paidAmount : f.amount,
                          baseAmount: f.baseFee > 0 ? f.baseFee : f.amount,
                          discountAmount: f.discountAmount,
                          status: f.status.toUpperCase(),
                          razorpayPaymentId: f.razorpayPaymentId ?? 'pay_live_settled',
                          razorpayOrderId: f.razorpayOrderId,
                          notes: f.notes ?? 'Monthly Coaching Academy Subscription',
                        );
                      } else {
                        await PdfReceiptService.downloadOrShareReceipt(
                          receiptNumber: item.receiptNumber,
                          receiptType: 'Membership',
                          title: item.title,
                          sportName: 'All Sports Access',
                          schedule: item.subtitle,
                          customerName: 'Academy Member',
                          dateText: item.dateText,
                          totalAmount: item.amount,
                          baseAmount: item.amount,
                          status: item.status,
                          razorpayPaymentId: item.paymentId,
                          notes: 'VIP Academy Facility Pass',
                        );
                      }

                      Get.snackbar(
                        'Invoice Saved & Shared',
                        'Tax invoice ${item.receiptNumber} generated successfully.',
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: Colors.white,
                        colorText: darkText,
                        borderColor: const Color(0xFF10B981),
                        borderWidth: 1.2,
                        margin: const EdgeInsets.all(16),
                        borderRadius: 14,
                        icon: const Icon(Icons.check_circle_rounded, color: Color(0xFF10B981)),
                      );
                    } catch (e) {
                      Get.snackbar(
                        'Download Error',
                        'Failed to generate invoice PDF: $e',
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: Colors.white,
                        colorText: const Color(0xFFEF4444),
                        borderColor: const Color(0xFFEF4444),
                        borderWidth: 1.2,
                        margin: const EdgeInsets.all(16),
                        borderRadius: 14,
                        icon: const Icon(Icons.error_outline_rounded, color: Color(0xFFEF4444)),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _UnifiedReceiptItem {
  final String id;
  final String receiptNumber;
  final String type; // 'Booking', 'Fee', 'Membership'
  final String title;
  final String subtitle;
  final int amount;
  final String dateText;
  final String status;
  final String paymentId;
  final BookingPassModel? bookingPass;
  final FeeItem? feeItem;

  const _UnifiedReceiptItem({
    required this.id,
    required this.receiptNumber,
    required this.type,
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.dateText,
    required this.status,
    required this.paymentId,
    this.bookingPass,
    this.feeItem,
  });
}

