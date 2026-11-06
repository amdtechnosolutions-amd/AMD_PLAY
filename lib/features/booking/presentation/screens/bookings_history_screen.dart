import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../data/models/booking_pass_model.dart';
import '../../data/services/booking_service.dart';
import 'digital_pass_screen.dart';
import 'court_booking_screen.dart';

class BookingsHistoryScreen extends StatefulWidget {
  const BookingsHistoryScreen({super.key});

  @override
  State<BookingsHistoryScreen> createState() => _BookingsHistoryScreenState();
}

class _BookingsHistoryScreenState extends State<BookingsHistoryScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final BookingService _bookingService = BookingService();
  List<BookingPassModel> _passes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadBookings();
  }

  Future<void> _loadBookings() async {
    setState(() => _isLoading = true);
    final list = await _bookingService.getMyBookings();
    setState(() {
      _passes = list;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('My Bookings & Passes', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0.5,
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          indicatorWeight: 3,
          tabs: const [
            Tab(text: 'Active Passes'),
            Tab(text: 'Past Bookings'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : TabBarView(
              controller: _tabController,
              children: [
                _buildPassList(_passes.where((p) => p.status.toUpperCase() == 'CONFIRMED' || p.status.toUpperCase() == 'CHECKED_IN').toList(), isActive: true),
                _buildPassList(_passes.where((p) => p.status.toUpperCase() != 'CONFIRMED' && p.status.toUpperCase() != 'CHECKED_IN').toList(), isActive: false),
              ],
            ),
    );
  }

  Widget _buildPassList(List<BookingPassModel> items, {required bool isActive}) {
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.confirmation_number_outlined, size: 56, color: Colors.grey.shade400),
            SizedBox(height: 12.h),
            Text(
              isActive ? 'No active court passes' : 'No past bookings found',
              style: AppTypography.cardTitle.copyWith(color: AppColors.textSecondary),
            ),
            SizedBox(height: 16.h),
            ElevatedButton(
              onPressed: () => Get.to(() => const CourtBookingScreen()),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('BOOK A COURT NOW', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(16.w),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final pass = items[index];
        return Container(
          margin: EdgeInsets.only(bottom: 16.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight,
                            borderRadius: BorderRadius.circular(6.r),
                          ),
                          child: Text(
                            pass.sportName.toUpperCase(),
                            style: TextStyle(
                              fontSize: 10.sp,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                        Text(
                          'Ref: ${pass.bookingReference}',
                          style: TextStyle(fontSize: 11.sp, color: AppColors.textSecondary, fontFamily: 'monospace'),
                        ),
                      ],
                    ),
                    SizedBox(height: 10.h),
                    Text(pass.courtName, style: AppTypography.cardTitle),
                    SizedBox(height: 8.h),
                      Row(
                        children: [
                          const Icon(Icons.calendar_today_rounded, size: 14, color: AppColors.textSecondary),
                          SizedBox(width: 6.w),
                          Expanded(
                            child: Text('${pass.dateText} • ${pass.timeWindow}',
                                style: TextStyle(fontSize: 12.sp, color: AppColors.textSecondary)),
                          ),
                        ],
                      ),

                    if (isActive) ...[
                      SizedBox(height: 14.h),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(10.r),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'DOOR ACCESS PIN:',
                              style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
                            ),
                            Text(
                              pass.accessPin,
                              style: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.w900,
                                fontFamily: 'monospace',
                                letterSpacing: 4,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.vertical(bottom: Radius.circular(16.r)),
                  border: Border(top: BorderSide(color: Colors.grey.shade200)),
                ),
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Paid: ₹${pass.totalAmount.toInt()}',
                      style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                    ),
                    TextButton.icon(
                      icon: const Icon(Icons.qr_code_rounded, size: 16),
                      label: const Text('VIEW ACCESS PASS'),
                      style: TextButton.styleFrom(foregroundColor: AppColors.primary),
                      onPressed: () => Get.to(() => DigitalPassScreen(pass: pass)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
