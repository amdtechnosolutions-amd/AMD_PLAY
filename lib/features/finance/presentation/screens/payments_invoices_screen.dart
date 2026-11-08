import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../home/presentation/controllers/home_controller.dart';
import '../../../home/presentation/widgets/payment_receipt_dialog.dart';
import 'package:mobile_app/features/booking/data/models/booking_pass_model.dart';
import 'package:mobile_app/features/booking/presentation/screens/digital_pass_screen.dart';
import 'package:mobile_app/features/booking/presentation/screens/court_booking_screen.dart';
import 'package:mobile_app/features/main_nav/presentation/controllers/main_nav_controller.dart';

/// Screen displaying 100% Live Invoices, Pending Coaching Fees, and Settled Payment Receipts.
class PaymentsInvoicesScreen extends StatefulWidget {
  const PaymentsInvoicesScreen({super.key});

  @override
  State<PaymentsInvoicesScreen> createState() => _PaymentsInvoicesScreenState();
}

class _PaymentsInvoicesScreenState extends State<PaymentsInvoicesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final HomeController _homeController = Get.isRegistered<HomeController>() ? Get.find<HomeController>() : Get.put(HomeController());

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Obx(() => Text(
              _homeController.isPayAndPlay ? 'Payments & Receipts' : 'Coaching Fees & Invoices',
              style: TextStyle(
                fontFamily: 'Nunito',
                fontWeight: FontWeight.w800,
                fontSize: 18.sp,
                color: const Color(0xFF0F172A),
              ),
            )),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh_rounded, color: const Color(0xFF0F172A), size: 22.sp),
            tooltip: 'Refresh Invoices',
            onPressed: () => _homeController.refreshDashboard(),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(48.h),
          child: Container(
            color: Colors.white,
            child: Obx(() => TabBar(
                  controller: _tabController,
                  labelColor: const Color(0xFF0F172A),
                  unselectedLabelColor: const Color(0xFF64748B),
                  indicatorColor: const Color(0xFFD4AF37),
                  indicatorWeight: 3,
                  dividerColor: const Color(0x30D4AF37),
                  labelStyle: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w800,
                  ),
                  unselectedLabelStyle: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                  ),
                  tabs: _homeController.isPayAndPlay
                      ? const [
                          Tab(text: 'All Receipts'),
                          Tab(text: 'Active Passes'),
                          Tab(text: 'Paid Bookings'),
                        ]
                      : const [
                          Tab(text: 'All Invoices'),
                          Tab(text: 'Pending Dues'),
                          Tab(text: 'Paid Receipts'),
                        ],
                )),
          ),
        ),
      ),
      body: Obx(() {
        if (_homeController.isLoading.value && _homeController.monthlyFees.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }

        final isPayAndPlay = _homeController.isPayAndPlay;
        final allFees = _homeController.monthlyFees;
        final pendingFees = allFees.where((f) => !f.isPaid).toList();
        final paidFees = allFees.where((f) => f.isPaid).toList();
        final passes = _homeController.myBookings;

        if (isPayAndPlay) {
          return TabBarView(
            controller: _tabController,
            children: [
              _buildFeeListView(
                allFees,
                emptyMessage: 'No court booking receipts or payments yet.',
                isReceiptTab: true,
              ),
              _buildPassesListView(passes),
              _buildFeeListView(
                paidFees,
                emptyMessage: 'No settled payment receipts yet.',
                isReceiptTab: true,
              ),
            ],
          );
        }

        return TabBarView(
          controller: _tabController,
          children: [
            _buildFeeListView(allFees, emptyMessage: 'No fee records or invoices found.'),
            _buildFeeListView(pendingFees, emptyMessage: 'All caught up! No pending fee dues.'),
            _buildFeeListView(paidFees, emptyMessage: 'No settled payment receipts yet.', isReceiptTab: true),
          ],
        );
      }),
    );
  }

  Widget _buildFeeListView(List<FeeItem> items, {required String emptyMessage, bool isReceiptTab = false}) {
    if (items.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(32.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(20.w),
                decoration: BoxDecoration(
                  color: isReceiptTab ? const Color(0xFFECFDF5) : const Color(0xFFFEF3C7),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isReceiptTab ? Icons.receipt_long_outlined : Icons.check_circle_outline_rounded,
                  size: 48.sp,
                  color: isReceiptTab ? const Color(0xFF10B981) : const Color(0xFFD97706),
                ),
              ),
              SizedBox(height: 16.h),
              Text(
                emptyMessage,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF475569),
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                'Fee invoices generated by academy admin will appear here in real-time.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12.sp, color: const Color(0xFF94A3B8)),
              ),
              SizedBox(height: 20.h),
              OutlinedButton.icon(
                onPressed: () => _homeController.refreshDashboard(),
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('Refresh from API'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF0F172A),
                  side: const BorderSide(color: Color(0xFFCBD5E1)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => _homeController.refreshDashboard(),
      color: AppColors.primary,
      child: ListView.separated(
        padding: EdgeInsets.all(16.w),
        itemCount: items.length + 1,
        separatorBuilder: (context, index) => SizedBox(height: 12.h),
        itemBuilder: (context, index) {
          if (index == 0) {
            return _buildSummaryCard(items);
          }
          final fee = items[index - 1];
          return _buildFeeCard(fee);
        },
      ),
    );
  }

  Widget _buildSummaryCard(List<FeeItem> items) {
    final isPayAndPlay = _homeController.isPayAndPlay;
    int totalPending = 0;
    int totalPaid = 0;
    for (final f in _homeController.monthlyFees) {
      if (f.isPaid) {
        totalPaid += f.paidAmount > 0 ? f.paidAmount : f.amount;
      } else {
        totalPending += f.amount;
      }
    }

    if (isPayAndPlay) {
      return Container(
        padding: EdgeInsets.all(16.w),
        margin: EdgeInsets.only(bottom: 8.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18.r),
          border: Border.all(
            color: const Color(0x60D4AF37),
            width: 1.2,
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x24D4AF37),
              blurRadius: 16,
              spreadRadius: 0,
              offset: Offset(0, 5),
            ),
            BoxShadow(
              color: Color(0x0A000000),
              blurRadius: 4,
              offset: Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'PAYMENT GATEWAY',
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF64748B),
                      letterSpacing: 0.8,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Row(
                    children: [
                      const Icon(Icons.verified_rounded, color: Color(0xFF10B981), size: 18),
                      SizedBox(width: 6.w),
                      Text(
                        'Razorpay Live',
                        style: TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              height: 36.h,
              width: 1,
              color: const Color(0x30D4AF37),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'SETTLED BOOKINGS',
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF64748B),
                      letterSpacing: 0.8,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    '₹$totalPaid',
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF059669),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: EdgeInsets.all(16.w),
      margin: EdgeInsets.only(bottom: 8.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(
          color: const Color(0x60D4AF37),
          width: 1.2,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x24D4AF37),
            blurRadius: 16,
            spreadRadius: 0,
            offset: Offset(0, 5),
          ),
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 4,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'PENDING DUES',
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF64748B),
                    letterSpacing: 0.8,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  '₹$totalPending',
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w900,
                    color: totalPending > 0 ? const Color(0xFFD97706) : const Color(0xFF059669),
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: 36.h,
            width: 1,
            color: const Color(0x30D4AF37),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'SETTLED RECEIPTS',
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF64748B),
                    letterSpacing: 0.8,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  '₹$totalPaid',
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF059669),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPassesListView(List<BookingPassModel> passes) {
    if (passes.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(32.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(20.w),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFDF5),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0x60D4AF37), width: 1.2),
                ),
                child: Icon(Icons.confirmation_number_outlined, size: 48.sp, color: const Color(0xFFD4AF37)),
              ),
              SizedBox(height: 16.h),
              Text(
                'No active court passes right now',
                textAlign: TextAlign.center,
                style: TextStyle(fontFamily: 'Nunito', fontSize: 15.sp, fontWeight: FontWeight.w800, color: const Color(0xFF334155)),
              ),
              SizedBox(height: 8.h),
              Text(
                'Book a court slot to receive your turnstile QR pass & 6-digit access PIN.',
                textAlign: TextAlign.center,
                style: TextStyle(fontFamily: 'Nunito', fontSize: 12.sp, color: const Color(0xFF64748B)),
              ),
              SizedBox(height: 20.h),
              ElevatedButton(
                onPressed: () {
                  if (Get.isRegistered<MainNavController>()) {
                    Get.find<MainNavController>().changeTab(1);
                  } else {
                    Get.to(() => const CourtBookingScreen());
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF0F172A),
                  elevation: 0,
                  side: const BorderSide(color: Color(0xFFD4AF37), width: 1.4),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                  padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
                ),
                child: const Text('BOOK A COURT NOW', style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => _homeController.refreshDashboard(),
      color: const Color(0xFFD4AF37),
      child: ListView.separated(
        padding: EdgeInsets.all(16.w),
        itemCount: passes.length,
        separatorBuilder: (_, _) => SizedBox(height: 14.h),
        itemBuilder: (context, index) {
          final pass = passes[index];
          return Container(
            padding: EdgeInsets.all(16.w),
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFFDF5),
                        borderRadius: BorderRadius.circular(8.r),
                        border: Border.all(
                          color: const Color(0x60D4AF37),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        pass.sportName.toUpperCase(),
                        style: TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 10.5.sp,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF9E7B1A),
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6.r),
                        border: Border.all(
                          color: const Color(0xFF10B981).withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        pass.status,
                        style: TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF059669),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10.h),
                Text(
                  pass.courtName,
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 17.sp,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                SizedBox(height: 4.h),
                Row(
                  children: [
                    Icon(Icons.calendar_today_rounded, size: 13.sp, color: const Color(0xFFD4AF37)),
                    SizedBox(width: 5.w),
                    Text(
                      '${pass.dateText} • ${pass.timeWindow}',
                      style: TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 12.sp,
                        color: const Color(0xFF64748B),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 14.h),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14.r),
                    border: Border.all(
                      color: const Color(0x60D4AF37),
                      width: 1.2,
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x14D4AF37),
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'GATE ACCESS PIN',
                            style: TextStyle(
                              fontFamily: 'Nunito',
                              fontSize: 9.5.sp,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF64748B),
                              letterSpacing: 0.5,
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            pass.accessPin,
                            style: TextStyle(
                              fontFamily: 'Nunito',
                              fontSize: 19.sp,
                              fontWeight: FontWeight.w900,
                              color: const Color(0xFF0F172A),
                              letterSpacing: 4.0,
                            ),
                          ),
                        ],
                      ),
                      ElevatedButton.icon(
                        onPressed: () => Get.to(() => DigitalPassScreen(pass: pass)),
                        icon: const Icon(Icons.qr_code_rounded, size: 16, color: Color(0xFF0F172A)),
                        label: Text(
                          'View Pass',
                          style: TextStyle(
                            fontFamily: 'Nunito',
                            fontWeight: FontWeight.w800,
                            fontSize: 12.5.sp,
                            color: const Color(0xFF0F172A),
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF0F172A),
                          elevation: 0,
                          side: const BorderSide(color: Color(0xFFD4AF37), width: 1.4),
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
        },
      ),
    );
  }

  Widget _buildFeeCard(FeeItem fee) {
    final isPaid = fee.isPaid;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(
          color: const Color(0x60D4AF37),
          width: 1.2,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x22D4AF37),
            blurRadius: 16,
            spreadRadius: 0,
            offset: Offset(0, 5),
          ),
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 4,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Bar
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFDF7),
              borderRadius: BorderRadius.vertical(top: Radius.circular(17.r)),
              border: const Border(
                bottom: BorderSide(
                  color: Color(0x40D4AF37),
                  width: 1,
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      isPaid ? Icons.receipt_long_rounded : Icons.pending_actions_rounded,
                      size: 18.sp,
                      color: const Color(0xFFD4AF37),
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      fee.formattedPeriod,
                      style: TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 13.5.sp,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 3.h),
                  decoration: BoxDecoration(
                    color: isPaid
                        ? const Color(0xFF10B981).withValues(alpha: 0.15)
                        : const Color(0xFFF59E0B).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6.r),
                    border: Border.all(
                      color: isPaid
                          ? const Color(0xFF10B981).withValues(alpha: 0.3)
                          : const Color(0xFFF59E0B).withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    isPaid ? 'PAID' : fee.status.toUpperCase(),
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 10.5.sp,
                      fontWeight: FontWeight.w800,
                      color: isPaid ? const Color(0xFF059669) : const Color(0xFFB45309),
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Body Content
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fee.title,
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 15.5.sp,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                if (fee.schedule != null && fee.schedule!.isNotEmpty) ...[
                  SizedBox(height: 3.h),
                  Text(
                    fee.schedule!,
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 12.sp,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                ],
                SizedBox(height: 10.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isPaid
                              ? (fee.paidAt != null ? 'Paid on: ${fee.paidAt}' : fee.dueDate)
                              : fee.dueDate,
                          style: TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: 12.sp,
                            color: isPaid ? const Color(0xFF64748B) : const Color(0xFFEF4444),
                            fontWeight: isPaid ? FontWeight.normal : FontWeight.w700,
                          ),
                        ),
                        if (isPaid && fee.razorpayPaymentId != null && fee.razorpayPaymentId!.isNotEmpty)
                          Padding(
                            padding: EdgeInsets.only(top: 2.h),
                            child: Text(
                              'Txn: ${fee.razorpayPaymentId}',
                              style: TextStyle(
                                fontSize: 11.sp,
                                fontFamily: 'monospace',
                                color: const Color(0xFF94A3B8),
                              ),
                            ),
                          ),
                      ],
                    ),
                    Text(
                      '₹${fee.amount}',
                      style: TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w900,
                        color: isPaid ? const Color(0xFF059669) : const Color(0xFF0F172A),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 14.h),
                const Divider(height: 1, color: Color(0x30D4AF37)),
                SizedBox(height: 12.h),

                // Action Button: Fully white with app color border only!
                if (isPaid)
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF0F172A),
                        padding: EdgeInsets.symmetric(vertical: 11.h),
                        side: const BorderSide(color: Color(0xFFD4AF37), width: 1.4),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                        elevation: 0,
                      ),
                      icon: const Icon(Icons.receipt_rounded, size: 18, color: Color(0xFF0F172A)),
                      label: const Text(
                        'View Live Receipt',
                        style: TextStyle(
                          fontFamily: 'Nunito',
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      onPressed: () {
                        PaymentReceiptDialog.show(
                          context,
                          fee: fee,
                          studentName: _homeController.userName.value,
                        );
                      },
                    ),
                  )
                else
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF0F172A),
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        side: const BorderSide(color: Color(0xFFD4AF37), width: 1.4),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                        elevation: 0,
                      ),
                      icon: const Icon(Icons.payment_rounded, size: 18, color: Color(0xFF0F172A)),
                      label: const Text(
                        'Pay with Razorpay',
                        style: TextStyle(
                          fontFamily: 'Nunito',
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      onPressed: () => _homeController.payStudentFee(fee.id),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
