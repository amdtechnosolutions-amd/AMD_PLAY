import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../core/theme/app_colors.dart';
import '../../data/models/court_slot_model.dart';
import '../controllers/court_booking_controller.dart';
import 'checkout_screen.dart';
import 'bookings_history_screen.dart';

/// Live "Book a Court" Screen driven directly by `/api/v1/sports`, `/api/v1/resources/active`, and `/api/v1/slots`.
class CourtBookingScreen extends StatelessWidget {
  const CourtBookingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final CourtBookingController controller = Get.isRegistered<CourtBookingController>()
        ? Get.find<CourtBookingController>()
        : Get.put(CourtBookingController());

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        centerTitle: true,
        automaticallyImplyLeading: false,
        leading: Navigator.of(context).canPop()
            ? IconButton(
                icon: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: const Color(0xFF0F172A),
                  size: 18.sp,
                ),
                tooltip: 'Back',
                onPressed: () => Get.back(),
              )
            : null,
        title: Text(
          'Book a Court',
          style: TextStyle(fontFamily: 'Nunito', 
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF0F172A),
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'My Passes',
            icon: Icon(
              Icons.confirmation_number_outlined,
              color: const Color(0xFF0F172A),
              size: 22.sp,
            ),
            onPressed: () => Get.to(() => const BookingsHistoryScreen()),
          ),
          SizedBox(width: 4.w),
        ],
      ),
      body: Obx(() {
        final hasSelectedSlots = controller.hasSelectedSlots || controller.selectedSlot.value != null;

        return Stack(
          children: [
            RefreshIndicator(
              color: const Color(0xFF0F172A),
              backgroundColor: AppColors.primary,
              onRefresh: () async {
                await controller.loadSports();
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.fromLTRB(
                  16.w,
                  16.h,
                  16.w,
                  hasSelectedSlots
                      ? (Navigator.of(context).canPop() ? 210.h : 280.h)
                      : (Navigator.of(context).canPop() ? 24.h : 90.h),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. SPORTS CATALOG FROM API
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Select a Sport',
                          style: TextStyle(fontFamily: 'Nunito', 
                            fontSize: 17.sp,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF0F172A),
                          ),
                        ),
                        if (controller.isLoadingSports.value)
                          SizedBox(
                            width: 16.w,
                            height: 16.w,
                            child: const CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF0F172A)),
                          ),
                      ],
                    ),
                    SizedBox(height: 12.h),
                    _buildSportsSection(controller),
                    SizedBox(height: 22.h),

                    // 2. COURTS / RESOURCES SELECTOR FROM API
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Select a Court / Turf',
                          style: TextStyle(fontFamily: 'Nunito', 
                            fontSize: 17.sp,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF0F172A),
                          ),
                        ),
                        if (controller.isLoadingCourts.value)
                          SizedBox(
                            width: 16.w,
                            height: 16.w,
                            child: const CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF0F172A)),
                          ),
                      ],
                    ),
                    SizedBox(height: 12.h),
                    _buildCourtsSection(controller),
                    SizedBox(height: 22.h),

                    // 3. DYNAMIC 14-DAY ROLLING CALENDAR DATES
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Select Date',
                          style: TextStyle(fontFamily: 'Nunito', 
                            fontSize: 17.sp,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF0F172A),
                          ),
                        ),
                        Text(
                          DateFormat('MMMM yyyy').format(controller.selectedDate.value),
                          style: TextStyle(fontFamily: 'Nunito', 
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF0F172A),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12.h),
                    _buildDatesList(controller),
                    SizedBox(height: 22.h),

                    // 4. LIVE SLOTS GRID FROM API
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            'Available Slots for ${DateFormat('d MMM').format(controller.selectedDate.value)}',
                            style: TextStyle(fontFamily: 'Nunito', 
                              fontSize: 17.sp,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF0F172A),
                            ),
                          ),
                        ),
                        if (controller.isLoadingSlots.value)
                          SizedBox(
                            width: 16.w,
                            height: 16.w,
                            child: const CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF0F172A)),
                          )
                        else if (controller.availableSlots.isNotEmpty)
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: Text(
                              '${controller.availableSlots.where((s) => s.isAvailable).length} Available',
                              style: TextStyle(fontFamily: 'Nunito', 
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF10B981),
                              ),
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: 14.h),
                    _buildSlotsGrid(controller),
                  ],
                ),
              ),
            ),

            // Elevated floating bottom sheet above Bottom Navigation Bar
            if (hasSelectedSlots)
              Positioned(
                left: 0,
                right: 0,
                bottom: Navigator.of(context).canPop() ? 0 : 72.h,
                child: _buildBookingBottomSheet(controller),
              ),
          ],
        );
      }),
    );
  }

  // ===========================================================================
  // 1. SPORTS SELECTOR
  // ===========================================================================

  Widget _buildSportsSection(CourtBookingController controller) {
    if (controller.isLoadingSports.value) {
      return _buildSportsShimmer();
    }

    if (controller.sports.isEmpty) {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.sports_rounded, size: 20.sp, color: const Color(0xFF94A3B8)),
            SizedBox(width: 10.w),
            Text(
              'No sports available right now.',
              style: TextStyle(fontFamily: 'Nunito', fontSize: 13.sp, color: const Color(0xFF64748B)),
            ),
            SizedBox(width: 10.w),
            TextButton(
              onPressed: () => controller.loadSports(),
              child: const Text('Retry', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      );
    }

    return SizedBox(
      height: 114.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: controller.sports.length,
        separatorBuilder: (_, index) => SizedBox(width: 12.w),
        itemBuilder: (context, index) {
          final sport = controller.sports[index];
          final isSelected = controller.selectedSport.value?.id == sport.id;

          return GestureDetector(
            onTap: () => controller.changeSport(sport),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 94.w,
              padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 6.w),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFFFFFDE7) : Colors.white,
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(
                  color: isSelected ? AppColors.primary : const Color(0xFFE2E8F0),
                  width: isSelected ? 2.0 : 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _getSportIcon(sport.slug, isSelected),
                  SizedBox(height: 6.h),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      sport.name,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      style: TextStyle(fontFamily: 'Nunito', 
                        fontSize: 11.5.sp,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        color: isSelected ? const Color(0xFF0F172A) : const Color(0xFF475569),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSportsShimmer() {
    return SizedBox(
      height: 114.h,
      child: Shimmer.fromColors(
        baseColor: const Color(0xFFE2E8F0),
        highlightColor: const Color(0xFFF8FAFC),
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 4,
          separatorBuilder: (_, index) => SizedBox(width: 12.w),
          itemBuilder: (context, index) {
            return Container(
              width: 94.w,
              padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 8.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 38.w,
                    height: 38.w,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(height: 10.h),
                  Container(
                    width: 60.w,
                    height: 12.h,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _getSportIcon(String slug, bool isSelected) {
    IconData iconData = Icons.sports_rounded;
    final s = slug.toLowerCase();

    if (s.contains('badminton')) {
      iconData = Icons.sports_tennis_rounded;
    } else if (s.contains('tennis') || s.contains('pickle') || s.contains('squash') || s.contains('table')) {
      iconData = Icons.sports_tennis_rounded;
    } else if (s.contains('foot') || s.contains('soccer') || s.contains('turf')) {
      iconData = Icons.sports_soccer_rounded;
    } else if (s.contains('cricket')) {
      iconData = Icons.sports_cricket_rounded;
    } else if (s.contains('basket')) {
      iconData = Icons.sports_basketball_rounded;
    } else if (s.contains('swim') || s.contains('pool')) {
      iconData = Icons.pool_rounded;
    } else if (s.contains('archer')) {
      iconData = Icons.track_changes_rounded;
    } else if (s.contains('gym') || s.contains('fit')) {
      iconData = Icons.fitness_center_rounded;
    }

    return Container(
      width: 38.w,
      height: 38.w,
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primary : const Color(0xFFF1F5F9),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Icon(
          iconData,
          size: 20.sp,
          color: isSelected ? const Color(0xFF0F172A) : const Color(0xFF64748B),
        ),
      ),
    );
  }

  // ===========================================================================
  // 2. COURTS SELECTOR
  // ===========================================================================

  Widget _buildCourtsSection(CourtBookingController controller) {
    if (controller.isLoadingCourts.value) {
      return _buildCourtsShimmer();
    }

    if (controller.courts.isEmpty) {
      return Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          children: [
            const Icon(Icons.info_outline_rounded, color: Color(0xFF94A3B8), size: 20),
            SizedBox(width: 10.w),
            Expanded(
              child: Text(
                'No courts available for ${controller.selectedSport.value?.name ?? 'this sport'}',
                style: TextStyle(fontFamily: 'Nunito', fontSize: 13.sp, color: const Color(0xFF64748B)),
              ),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: controller.courts.map((court) {
          final isSelected = controller.selectedCourt.value?.id == court.id;

          return Padding(
            padding: EdgeInsets.only(right: 10.w),
            child: GestureDetector(
              onTap: () => controller.selectCourt(court),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF0F172A) : Colors.white,
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(
                    color: isSelected ? const Color(0xFF0F172A) : const Color(0xFFCBD5E1),
                    width: 1.2,
                  ),
                  boxShadow: [
                    if (isSelected)
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.12),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      court.name,
                      style: TextStyle(fontFamily: 'Nunito', 
                        fontSize: 13.5.sp,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        color: isSelected ? Colors.white : const Color(0xFF0F172A),
                      ),
                    ),
                    if (court.surfaceType.isNotEmpty) ...[
                      SizedBox(width: 6.w),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.primary : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        child: Text(
                          court.surfaceType.toUpperCase(),
                          style: TextStyle(
                            fontSize: 9.sp,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF0F172A),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCourtsShimmer() {
    return SizedBox(
      height: 42.h,
      child: Shimmer.fromColors(
        baseColor: const Color(0xFFE2E8F0),
        highlightColor: const Color(0xFFF8FAFC),
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 3,
          separatorBuilder: (_, index) => SizedBox(width: 10.w),
          itemBuilder: (context, index) {
            return Container(
              width: 110.w,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20.r),
              ),
            );
          },
        ),
      ),
    );
  }

  // ===========================================================================
  // 3. DYNAMIC DATES LIST
  // ===========================================================================

  Widget _buildDatesList(CourtBookingController controller) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));

    return SizedBox(
      height: 82.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: controller.availableDates.length,
        separatorBuilder: (_, index) => SizedBox(width: 10.w),
        itemBuilder: (context, index) {
          final date = controller.availableDates[index];
          final isSelected = controller.selectedDate.value.year == date.year &&
              controller.selectedDate.value.month == date.month &&
              controller.selectedDate.value.day == date.day;

          String dayLabel = DateFormat('EEE').format(date).toUpperCase();
          if (date == today) {
            dayLabel = 'TODAY';
          } else if (date == tomorrow) {
            dayLabel = 'TOM';
          }

          return GestureDetector(
            onTap: () => controller.changeDate(date),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 58.w,
              padding: EdgeInsets.symmetric(vertical: 8.h),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFFFFFDE7) : Colors.white,
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(
                  color: isSelected ? AppColors.primary : const Color(0xFFE2E8F0),
                  width: isSelected ? 2.0 : 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isSelected
                        ? AppColors.primary.withValues(alpha: 0.15)
                        : Colors.black.withValues(alpha: 0.03),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    dayLabel,
                    style: TextStyle(fontFamily: 'Nunito', 
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w700,
                      color: isSelected ? const Color(0xFF0F172A) : const Color(0xFF64748B),
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    '${date.day}',
                    style: TextStyle(fontFamily: 'Nunito', 
                      fontSize: 17.sp,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ===========================================================================
  // 4. LIVE SLOTS GRID FROM API
  // ===========================================================================

  Widget _buildSlotsGrid(CourtBookingController controller) {
    if (controller.isLoadingSlots.value) {
      return _buildSlotsShimmer();
    }

    if (controller.availableSlots.isEmpty) {
      final isToday = controller.isTodaySelected;
      return Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 28.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(
          children: [
            Icon(Icons.event_busy_rounded, size: 44.sp, color: const Color(0xFF94A3B8)),
            SizedBox(height: 12.h),
            Text(
              isToday ? 'No More Slots Available Today' : 'No Slots Available',
              style: TextStyle(fontFamily: 'Nunito', fontSize: 15.sp, fontWeight: FontWeight.w700, color: const Color(0xFF0F172A)),
            ),
            SizedBox(height: 4.h),
            Text(
              isToday
                  ? 'All bookable hours for today have passed. Please select tomorrow to discover available slots.'
                  : 'Please select another court or date to discover bookable hours.',
              textAlign: TextAlign.center,
              style: TextStyle(fontFamily: 'Nunito', fontSize: 12.sp, color: const Color(0xFF64748B)),
            ),
            if (controller.selectedCourt.value != null) ...[
              SizedBox(height: 14.h),
              OutlinedButton.icon(
                onPressed: () => controller.loadSlotsForCourt(controller.selectedCourt.value!),
                icon: const Icon(Icons.refresh_rounded, size: 16),
                label: const Text('Refresh Slots'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF0F172A),
                  side: const BorderSide(color: Color(0xFFCBD5E1)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                ),
              ),
            ],
          ],
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 600 ? 3 : 2;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 10.w,
            mainAxisSpacing: 10.h,
            childAspectRatio: 2.2,
          ),
          itemCount: controller.availableSlots.length,
          itemBuilder: (context, index) {
            final slot = controller.availableSlots[index];
            final isSelected = controller.isSlotSelected(slot);

            Color bgColor = Colors.white;
            Color borderColor = const Color(0xFFE2E8F0);
            Color textColor = const Color(0xFF0F172A);
            String statusBadge = '₹${slot.price.toInt()}';
            Color badgeBg = const Color(0xFFECFDF5);
            Color badgeColor = const Color(0xFF059669);

            if (isSelected) {
              bgColor = AppColors.primary;
              borderColor = const Color(0xFF0F172A);
              textColor = const Color(0xFF0F172A);
              badgeBg = const Color(0xFF0F172A);
              badgeColor = Colors.white;
            } else if (slot.isHold) {
              bgColor = const Color(0xFFFFFBEB);
              borderColor = const Color(0xFFFDE68A);
              textColor = const Color(0xFF92400E);
              statusBadge = slot.heldByYou ? 'Your Hold' : 'Locked';
              badgeBg = const Color(0xFFFEF3C7);
              badgeColor = const Color(0xFFD97706);
            } else if (slot.isBooked) {
              bgColor = const Color(0xFFF1F5F9);
              borderColor = const Color(0xFFE2E8F0);
              textColor = const Color(0xFF94A3B8);
              statusBadge = 'Booked';
              badgeBg = const Color(0xFFE2E8F0);
              badgeColor = const Color(0xFF64748B);
            } else if (slot.isBatchConflict) {
              bgColor = const Color(0xFFEFF6FF);
              borderColor = const Color(0xFFBFDBFE);
              textColor = const Color(0xFF1E40AF);
              statusBadge = 'Coaching';
              badgeBg = const Color(0xFFDBEAFE);
              badgeColor = const Color(0xFF2563EB);
            } else if (slot.isMaintenance) {
              bgColor = const Color(0xFFFFF1F2);
              borderColor = const Color(0xFFFECDD3);
              textColor = const Color(0xFF9F1239);
              statusBadge = 'Maint.';
              badgeBg = const Color(0xFFFFE4E6);
              badgeColor = const Color(0xFFE11D48);
            }

            return GestureDetector(
              onTap: () => controller.onSlotTapped(slot),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(14.r),
                  border: Border.all(color: borderColor, width: isSelected ? 2.0 : 1.2),
                  boxShadow: [
                    if (isSelected)
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            slot.timeText,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontFamily: 'Nunito', 
                              fontSize: 12.sp,
                              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                              color: textColor,
                            ),
                          ),
                        ),
                        if (isSelected)
                          const Icon(Icons.check_circle_rounded, size: 16, color: Color(0xFF0F172A)),
                      ],
                    ),
                    SizedBox(height: 4.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 1.5.h),
                          decoration: BoxDecoration(
                            color: badgeBg,
                            borderRadius: BorderRadius.circular(6.r),
                          ),
                          child: Text(
                            statusBadge,
                            style: TextStyle(
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w800,
                              color: badgeColor,
                            ),
                          ),
                        ),
                        if (slot.isAvailable && !isSelected && slot.rateType == 'peak')
                          Text(
                            'PEAK',
                            style: TextStyle(
                              fontSize: 8.5.sp,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFFEA580C),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSlotsShimmer() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 600 ? 3 : 2;

        return Shimmer.fromColors(
          baseColor: const Color(0xFFE2E8F0),
          highlightColor: const Color(0xFFF8FAFC),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 10.w,
              mainAxisSpacing: 10.h,
              childAspectRatio: 2.2,
            ),
            itemCount: 6,
            itemBuilder: (context, index) {
              return Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14.r),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 100.w,
                      height: 12.h,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Container(
                      width: 45.w,
                      height: 16.h,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  // ===========================================================================
  // 5. BOTTOM BOOKING SUMMARY SHEET
  // ===========================================================================

  Widget _buildBookingBottomSheet(CourtBookingController controller) {
    final count = controller.totalSelectedCount > 0 ? controller.totalSelectedCount : 1;
    final grandTotal = controller.grandTotalAmount;
    final grandTax = controller.grandTaxAmount;
    final court = controller.selectedCourt.value;

    return Container(
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(22.r)),
        border: const Border(
          top: BorderSide(color: Color(0xFFE2E8F0), width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 18,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 1. 5-Minute Hold Timer Active Pill
            if (controller.isHoldingSlot.value) ...[
              Container(
                margin: EdgeInsets.only(bottom: 8.h),
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3F2),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: const Color(0xFFFECDCA)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.timer_outlined, size: 14, color: Color(0xFFD92D20)),
                    SizedBox(width: 6.w),
                    Text(
                      'Slots Held for ${controller.holdTimeFormatted}',
                      style: TextStyle(fontFamily: 'Nunito', 
                        fontSize: 11.5.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFFD92D20),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // 2. Selected Slots Horizontal Chip Strip
            if (controller.selectedSlots.isNotEmpty) ...[
              SizedBox(
                height: 32.h,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: controller.selectedSlots.length,
                  separatorBuilder: (_, index) => SizedBox(width: 8.w),
                  itemBuilder: (context, index) {
                    final item = controller.selectedSlots[index];
                    return Container(
                      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(8.r),
                        border: Border.all(color: const Color(0xFFCBD5E1)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${item.courtName} • ${item.timeText}',
                            style: TextStyle(fontFamily: 'Nunito', 
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF0F172A),
                            ),
                          ),
                          SizedBox(width: 6.w),
                          GestureDetector(
                            onTap: () {
                              controller.onSlotTapped(
                                SlotModel(
                                  courtId: item.resourceId,
                                  timeText: item.timeText,
                                  startTime: item.startTime,
                                  endTime: item.endTime,
                                  price: item.price,
                                  status: SlotStatus.available,
                                ),
                              );
                            },
                            child: Icon(Icons.close_rounded, size: 14.sp, color: const Color(0xFF64748B)),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: 10.h),
            ],

            // 3. Grand Total & Summary Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            '$count ${count == 1 ? "Slot" : "Slots"} Selected',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontFamily: 'Nunito', 
                              fontSize: 14.5.sp,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF0F172A),
                            ),
                          ),
                          if (controller.selectedSlots.isNotEmpty) ...[
                            SizedBox(width: 8.w),
                            GestureDetector(
                              onTap: () => controller.releaseActiveHold(),
                              child: Text(
                                'Clear',
                                style: TextStyle(fontFamily: 'Nunito', 
                                  fontSize: 11.5.sp,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFFEF4444),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        court != null ? '${court.sport} • ${court.name}' : 'Multi-Slot Cart',
                        style: TextStyle(fontFamily: 'Nunito', 
                          fontSize: 12.sp,
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
                      '₹${grandTotal.toInt()}',
                      style: TextStyle(fontFamily: 'Nunito', 
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    Text(
                      'Incl. GST (₹${grandTax.toInt()})',
                      style: TextStyle(fontFamily: 'Nunito', 
                        fontSize: 10.sp,
                        color: const Color(0xFF94A3B8),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 12.h),

            // 4. Proceed to Checkout Button
            ElevatedButton(
              onPressed: () {
                Get.to(() => CheckoutScreen(controller: controller));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: const Color(0xFF0F172A),
                elevation: 1.5,
                minimumSize: Size(double.infinity, 48.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14.r),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'PROCEED TO CHECKOUT • ₹${grandTotal.toInt()}',
                    style: TextStyle(fontFamily: 'Nunito', 
                      fontSize: 13.5.sp,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                  SizedBox(width: 6.w),
                  Icon(Icons.arrow_forward_rounded, size: 18.sp, color: const Color(0xFF0F172A)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
