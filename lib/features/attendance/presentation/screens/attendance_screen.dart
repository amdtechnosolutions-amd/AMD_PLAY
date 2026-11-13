import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/storage/storage_service.dart';
import '../controllers/attendance_controller.dart';

/// Pixel-perfect Attendance History Screen connected to live backend APIs.
class AttendanceScreen extends StatelessWidget {
  const AttendanceScreen({super.key});

  static const Color goldAccent = Color(0xFFD4AF37);
  static const Color presentColor = Color(0xFF10B981);
  static const Color presentLight = Color(0xFFECFDF5);
  static const Color absentColor = Color(0xFFF87171);
  static const Color absentLight = Color(0xFFFEE2E2);
  static const Color excusedColor = Color(0xFFF59E0B);
  static const Color excusedLight = Color(0xFFFEF3C7);
  static const Color darkSlate = Color(0xFF0F172A);

  @override
  Widget build(BuildContext context) {
    final controller = Get.isRegistered<AttendanceController>()
        ? Get.find<AttendanceController>()
        : Get.put(AttendanceController());

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: Text(
          'Attendance History',
          style: TextStyle(
            fontFamily: 'Nunito',
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
            tooltip: 'Refresh Live Attendance',
            onPressed: () => controller.refreshAttendance(),
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
                middleText: 'Are you sure you want to exit to Login?',
                textConfirm: 'Logout',
                textCancel: 'Cancel',
                confirmTextColor: Colors.white,
                buttonColor: goldAccent,
                onConfirm: () async {
                  if (Get.isRegistered<StorageService>()) {
                    await Get.find<StorageService>().clearAll();
                  }
                  Get.offAllNamed(AppRoutes.userSelection);
                },
              );
            },
          ),
          SizedBox(width: 4.w),
        ],
      ),
      body: Obx(() {
        final hasSiblings = controller.siblings.length > 1;

        if (controller.isLoading.value && controller.allSessions.isEmpty) {
          return Column(
            children: [
              if (hasSiblings) _buildSiblingSwitcherBar(controller),
              const Expanded(
                child: Center(
                  child: CircularProgressIndicator(color: goldAccent),
                ),
              ),
            ],
          );
        }

        return Column(
          children: [
            if (hasSiblings) _buildSiblingSwitcherBar(controller),
            Expanded(
              child: RefreshIndicator(
                color: goldAccent,
                onRefresh: () => controller.refreshAttendance(),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 90.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Active student header banner if siblings exist
                      if (hasSiblings || controller.selectedStudentName.value.isNotEmpty) ...[
                        _buildActiveStudentCard(controller),
                        SizedBox(height: 16.h),
                      ],

                      // 1. Top 3 Metric Summary Cards (Overall, Present, Absent)
                      _buildMetricCards(controller),
                      SizedBox(height: 22.h),

                      // 2. Filter by Month Header Row
                      _buildFilterByMonthHeader(context, controller),
                      SizedBox(height: 16.h),

                      // 3. View Mode Toggle: [Calendar View] | [List View]
                      _buildViewToggle(controller),
                      SizedBox(height: 18.h),

                      // 4. Content based on active view mode
                      if (controller.isCalendarView.value)
                        _buildCalendarCard(context, controller)
                      else
                        _buildListView(controller),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  // ===========================================================================
  // SIBLING SWITCHER & ACTIVE STUDENT HEADER
  // ===========================================================================

  Widget _buildSiblingSwitcherBar(AttendanceController controller) {
    final activeId = controller.selectedSiblingId.value;
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 10.h),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Color(0x18D4AF37), width: 1),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          children: controller.siblings.map((sib) {
            final isSelected = sib.studentId == activeId ||
                (activeId.isEmpty && sib.isSelected);
            final initial = sib.fullName.isNotEmpty
                ? sib.fullName[0].toUpperCase()
                : 'S';
            final label = sib.regNo.isNotEmpty
                ? '${sib.fullName} (${sib.regNo})'
                : sib.fullName;

            return GestureDetector(
              onTap: () => controller.selectSiblingAttendance(sib.studentId),
              child: Container(
                margin: EdgeInsets.only(right: 8.w),
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 7.h),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFFFFFDF5)
                      : const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(14.r),
                  border: Border.all(
                    color: isSelected ? goldAccent : const Color(0xFFE2E8F0),
                    width: isSelected ? 1.5 : 1.0,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 22.r,
                      height: 22.r,
                      decoration: BoxDecoration(
                        color: isSelected ? goldAccent : const Color(0xFFCBD5E1),
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        initial,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      label,
                      style: TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 12.5.sp,
                        fontWeight:
                            isSelected ? FontWeight.w700 : FontWeight.w600,
                        color: isSelected ? darkSlate : const Color(0xFF64748B),
                      ),
                    ),
                    if (sib.attendancePercentage > 0) ...[
                      SizedBox(width: 6.w),
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 5.w, vertical: 1.5.h),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0x2010B981)
                              : const Color(0xFFE2E8F0),
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        child: Text(
                          '${sib.attendancePercentage}%',
                          style: TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w700,
                            color: isSelected
                                ? const Color(0xFF059669)
                                : const Color(0xFF64748B),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildActiveStudentCard(AttendanceController controller) {
    final name = controller.selectedStudentName.value.isNotEmpty
        ? controller.selectedStudentName.value
        : 'Student Profile';
    final initial = name.isNotEmpty ? name[0].toUpperCase() : 'S';
    final regNo = controller.selectedRegNo.value;
    final batch = controller.selectedBatchName.value;
    final sport = controller.selectedSportName.value;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0x40D4AF37), width: 1.2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0C000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 42.r,
            height: 42.r,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFFFFDF5),
              border: Border.all(color: goldAccent, width: 2),
            ),
            alignment: Alignment.center,
            child: Text(
              initial,
              style: TextStyle(
                fontFamily: 'Nunito',
                fontSize: 18.sp,
                fontWeight: FontWeight.w800,
                color: goldAccent,
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name.toUpperCase(),
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w800,
                    color: darkSlate,
                    letterSpacing: 0.3,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4.h),
                Wrap(
                  spacing: 6.w,
                  runSpacing: 4.h,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    if (sport.isNotEmpty)
                      Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF9E6),
                          borderRadius: BorderRadius.circular(6.r),
                          border: Border.all(
                              color: const Color(0x80D4AF37), width: 0.8),
                        ),
                        child: Text(
                          sport.toUpperCase(),
                          style: TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFFB45309),
                          ),
                        ),
                      ),
                    if (batch.isNotEmpty)
                      Text(
                        batch,
                        style: TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 11.5.sp,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                    if (regNo.isNotEmpty)
                      Text(
                        '• $regNo',
                        style: TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 11.5.sp,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF94A3B8),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(width: 8.w),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: const Color(0xFFECFDF5),
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(color: const Color(0xFF10B981), width: 1),
            ),
            child: Column(
              children: [
                Text(
                  '${controller.overallPercentage.value}%',
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF059669),
                  ),
                ),
                Text(
                  'Attendance',
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 9.sp,
                    fontWeight: FontWeight.w600,
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

  // ===========================================================================
  // TOP METRIC CARDS: Overall %, Present Count, Absent Count
  // ===========================================================================

  Widget _buildMetricCards(AttendanceController controller) {
    return Row(
      children: [
        // Card 1: Overall %
        Expanded(
          child: _buildMetricCard(
            icon: Icons.donut_large_rounded,
            iconColor: goldAccent,
            value: '${controller.overallPercentage.value}%',
            valueColor: goldAccent,
            label: 'Overall',
          ),
        ),
        SizedBox(width: 12.w),

        // Card 2: Present Count
        Expanded(
          child: _buildMetricCard(
            icon: Icons.check_circle_rounded,
            iconColor: presentColor,
            value: '${controller.presentCount.value}',
            valueColor: presentColor,
            label: 'Present',
          ),
        ),
        SizedBox(width: 12.w),

        // Card 3: Absent Count
        Expanded(
          child: _buildMetricCard(
            icon: Icons.cancel_rounded,
            iconColor: absentColor,
            value: '${controller.absentCount.value}',
            valueColor: absentColor,
            label: 'Absent',
          ),
        ),
      ],
    );
  }

  Widget _buildMetricCard({
    required IconData icon,
    required Color iconColor,
    required String value,
    required Color valueColor,
    required String label,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 18.h, horizontal: 8.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
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
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 28.sp, color: iconColor),
          SizedBox(height: 10.h),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'Nunito',
              fontSize: 20.sp,
              fontWeight: FontWeight.w800,
              color: valueColor,
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Nunito',
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // FILTER BY MONTH HEADER
  // ===========================================================================

  Widget _buildFilterByMonthHeader(
    BuildContext context,
    AttendanceController controller,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Filter by Month',
          style: TextStyle(
            fontFamily: 'Nunito',
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
            color: darkSlate,
          ),
        ),
        GestureDetector(
          onTap: () => _showMonthPicker(context, controller),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 7.h),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFDF5),
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(color: const Color(0x60D4AF37), width: 1.2),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x10D4AF37),
                  blurRadius: 6,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  size: 15.sp,
                  color: goldAccent,
                ),
                SizedBox(width: 6.w),
                Text(
                  controller.formattedMonthHeader,
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 13.5.sp,
                    fontWeight: FontWeight.w700,
                    color: darkSlate,
                  ),
                ),
                SizedBox(width: 4.w),
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 16.sp,
                  color: goldAccent,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ===========================================================================
  // VIEW MODE TOGGLE PILLS: Calendar View vs List View
  // ===========================================================================

  Widget _buildViewToggle(AttendanceController controller) {
    final isCal = controller.isCalendarView.value;

    return Row(
      children: [
        // Calendar View Pill
        Expanded(
          child: GestureDetector(
            onTap: () => controller.setCalendarView(true),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: 44.h,
              decoration: BoxDecoration(
                color: isCal ? goldAccent : Colors.white,
                borderRadius: BorderRadius.circular(22.r),
                border: Border.all(
                  color: isCal ? goldAccent : const Color(0xFFE2E8F0),
                  width: 1.2,
                ),
                boxShadow: isCal
                    ? const [
                        BoxShadow(
                          color: Color(0x25D4AF37),
                          blurRadius: 8,
                          offset: Offset(0, 3),
                        ),
                      ]
                    : null,
              ),
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.calendar_month_rounded,
                      size: 16.sp,
                      color: isCal ? Colors.white : const Color(0xFF64748B),
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      'Calendar View',
                      style: TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 13.5.sp,
                        fontWeight: FontWeight.w700,
                        color: isCal ? Colors.white : const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        SizedBox(width: 12.w),

        // List View Pill
        Expanded(
          child: GestureDetector(
            onTap: () => controller.setCalendarView(false),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: 44.h,
              decoration: BoxDecoration(
                color: !isCal ? goldAccent : Colors.white,
                borderRadius: BorderRadius.circular(22.r),
                border: Border.all(
                  color: !isCal ? goldAccent : const Color(0xFFE2E8F0),
                  width: 1.2,
                ),
                boxShadow: !isCal
                    ? const [
                        BoxShadow(
                          color: Color(0x25D4AF37),
                          blurRadius: 8,
                          offset: Offset(0, 3),
                        ),
                      ]
                    : null,
              ),
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.format_list_bulleted_rounded,
                      size: 16.sp,
                      color: !isCal ? Colors.white : const Color(0xFF64748B),
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      'List View',
                      style: TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 13.5.sp,
                        fontWeight: FontWeight.w700,
                        color: !isCal ? Colors.white : const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ===========================================================================
  // DYNAMIC CALENDAR CARD WITH ACCURATE MONTH LAYOUT & LIVE ATTENDANCE BADGES
  // ===========================================================================

  Widget _buildCalendarCard(
    BuildContext context,
    AttendanceController controller,
  ) {
    final weekdays = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 18.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: const Color(0xFFF1F5F9), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Month navigation header: < [Month Year] >
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: Icon(
                  Icons.arrow_back_ios_rounded,
                  size: 16.sp,
                  color: const Color(0xFF0F172A),
                ),
                onPressed: () => controller.previousMonth(),
              ),
              Text(
                controller.formattedMonthHeader,
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF0F172A),
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16.sp,
                  color: const Color(0xFF0F172A),
                ),
                onPressed: () => controller.nextMonth(),
              ),
            ],
          ),
          SizedBox(height: 12.h),

          // Weekdays header row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: weekdays.map((day) {
              return SizedBox(
                width: 38.w,
                child: Center(
                  child: Text(
                    day,
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          SizedBox(height: 12.h),

          // Calendar Grid (Accurate for any month & year)
          _buildDynamicCalendarDaysGrid(context, controller),

          SizedBox(height: 14.h),
          const Divider(color: Color(0xFFF1F5F9)),
          SizedBox(height: 8.h),

          // Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegendItem(presentColor, 'Present'),
              SizedBox(width: 18.w),
              _buildLegendItem(absentColor, 'Absent'),
              SizedBox(width: 18.w),
              _buildLegendItem(excusedColor, 'Excused'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10.w,
          height: 10.w,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        SizedBox(width: 6.w),
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Nunito',
            fontSize: 11.5.sp,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF64748B),
          ),
        ),
      ],
    );
  }

  Widget _buildDynamicCalendarDaysGrid(
    BuildContext context,
    AttendanceController controller,
  ) {
    final cur = controller.currentMonth.value;
    final year = cur.year;
    final month = cur.month;

    // First day of month (DateTime weekday: 1 = Mon, ..., 7 = Sun)
    // For Sunday start calendar (0 = Sun, 1 = Mon, ..., 6 = Sat):
    final firstDayWeekday = DateTime(year, month, 1).weekday % 7;
    final daysInMonth = DateTime(year, month + 1, 0).day;
    final daysInPrevMonth = DateTime(year, month, 0).day;

    final List<Map<String, dynamic>> gridCells = [];

    // 1. Previous month trailing days
    for (int i = firstDayWeekday - 1; i >= 0; i--) {
      gridCells.add({'day': daysInPrevMonth - i, 'isCurrentMonth': false});
    }

    // 2. Current month days
    for (int d = 1; d <= daysInMonth; d++) {
      gridCells.add({'day': d, 'isCurrentMonth': true});
    }

    // 3. Next month leading days to complete full rows (multiple of 7)
    final remainder = gridCells.length % 7;
    if (remainder != 0) {
      final daysToAdd = 7 - remainder;
      for (int i = 1; i <= daysToAdd; i++) {
        gridCells.add({'day': i, 'isCurrentMonth': false});
      }
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: gridCells.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: 1.05,
      ),
      itemBuilder: (context, index) {
        final item = gridCells[index];
        final dayNum = item['day'] as int;
        final isCurrentMonth = item['isCurrentMonth'] as bool;

        String? status;
        AttendanceSession? session;
        if (isCurrentMonth) {
          status = controller.getStatusForDay(dayNum);
          session = controller.getSessionForDay(dayNum);
        }

        final isPresent = status == 'Present';
        final isAbsent = status == 'Absent';
        final isExcused = status == 'Excused';

        Color bgColor = Colors.transparent;
        Color textColor = const Color(0xFFCBD5E1);

        if (isCurrentMonth) {
          if (isPresent) {
            bgColor = presentColor;
            textColor = Colors.white;
          } else if (isAbsent) {
            bgColor = absentColor;
            textColor = Colors.white;
          } else if (isExcused) {
            bgColor = excusedColor;
            textColor = Colors.white;
          } else {
            textColor = darkSlate;
          }
        }

        return Center(
          child: GestureDetector(
            onTap: () {
              if (isCurrentMonth) {
                _showDayDetailsBottomSheet(
                  context,
                  controller,
                  dayNum,
                  status,
                  session,
                );
              }
            },
            child: Container(
              width: 36.h,
              height: 36.h,
              decoration: BoxDecoration(shape: BoxShape.circle, color: bgColor),
              child: Center(
                child: Text(
                  '$dayNum',
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 14.sp,
                    fontWeight: (isPresent || isAbsent || isExcused)
                        ? FontWeight.w700
                        : FontWeight.w500,
                    color: textColor,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showDayDetailsBottomSheet(
    BuildContext context,
    AttendanceController controller,
    int day,
    String? status,
    AttendanceSession? session,
  ) {
    final cur = controller.currentMonth.value;
    final dateStr = DateFormat('MMMM dd, yyyy')
        .format(DateTime(cur.year, cur.month, day));

    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
            SizedBox(height: 16.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      dateStr,
                      style: TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      session?.batchName ?? 'Academy Coaching Session',
                      style: TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 12.5.sp,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 6.h,
                  ),
                  decoration: BoxDecoration(
                    color: status == 'Present'
                        ? presentLight
                        : (status == 'Absent'
                              ? absentLight
                              : (status == 'Excused'
                                    ? excusedLight
                                    : const Color(0xFFF1F5F9))),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(
                    status ?? 'No Session',
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w700,
                      color: status == 'Present'
                          ? presentColor
                          : (status == 'Absent'
                                ? const Color(0xFFEF4444)
                                : (status == 'Excused'
                                      ? const Color(0xFFD97706)
                                      : const Color(0xFF64748B))),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            const Divider(color: Color(0xFFF1F5F9)),
            SizedBox(height: 12.h),
            if (session != null) ...[
              _buildDetailRow(
                Icons.sports_tennis_rounded,
                'Sport',
                session.sport,
              ),
              SizedBox(height: 10.h),
              _buildDetailRow(
                Icons.schedule_rounded,
                'Batch Timing',
                session.time,
              ),
              SizedBox(height: 10.h),
              _buildDetailRow(
                Icons.verified_user_rounded,
                'Verification Mode',
                session.verificationMode.toUpperCase(),
              ),
              if (session.checkInTime != null) ...[
                SizedBox(height: 10.h),
                _buildDetailRow(
                  Icons.alarm_on_rounded,
                  'Punch Timestamp',
                  session.checkInTime!,
                ),
              ],
              if (session.remarks.isNotEmpty) ...[
                SizedBox(height: 10.h),
                _buildDetailRow(
                  Icons.notes_rounded,
                  'Remarks',
                  session.remarks,
                ),
              ],
            ] else ...[
              Padding(
                padding: EdgeInsets.symmetric(vertical: 8.h),
                child: Text(
                  'No training session or scheduled attendance punch recorded for this day.',
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 13.sp,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ),
            ],
            SizedBox(height: 20.h),
            SizedBox(
              width: double.infinity,
              height: 44.h,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: goldAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  elevation: 0,
                ),
                onPressed: () => Get.back(),
                child: Text(
                  'Close',
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            SizedBox(height: 8.h),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16.sp, color: goldAccent),
        SizedBox(width: 8.w),
        Text(
          '$label: ',
          style: TextStyle(
            fontFamily: 'Nunito',
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF0F172A),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontFamily: 'Nunito',
              fontSize: 13.sp,
              color: const Color(0xFF64748B),
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  // ===========================================================================
  // LIST VIEW: Batch Attendance History Details
  // ===========================================================================

  Widget _buildListView(AttendanceController controller) {
    final list = controller.filteredSessions.isNotEmpty
        ? controller.filteredSessions
        : controller.allSessions;

    if (list.isEmpty) {
      return Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 40.h, horizontal: 20.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: const Color(0xFFF1F5F9)),
        ),
        child: Column(
          children: [
            Icon(
              Icons.event_busy_rounded,
              size: 48.sp,
              color: const Color(0xFF94A3B8),
            ),
            SizedBox(height: 12.h),
            Text(
              'No Attendance Records Found',
              style: TextStyle(
                fontFamily: 'Nunito',
                fontSize: 15.sp,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF0F172A),
              ),
            ),
            SizedBox(height: 6.h),
            Text(
              'No session logs recorded for ${controller.formattedMonthHeader}.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Nunito',
                fontSize: 12.5.sp,
                color: const Color(0xFF64748B),
              ),
            ),
            SizedBox(height: 16.h),
            TextButton.icon(
              onPressed: () => controller.refreshAttendance(),
              icon: Icon(Icons.refresh_rounded, size: 16.sp, color: goldAccent),
              label: Text(
                'Refresh',
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w700,
                  color: goldAccent,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: list.map((record) {
        final isAbsent = record.isAbsent;
        final isPresent = record.isPresent;

        return Container(
          margin: EdgeInsets.only(bottom: 12.h),
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: const Color(0xFFF1F5F9)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 42.h,
                      height: 42.h,
                      decoration: BoxDecoration(
                        color: isAbsent
                            ? absentLight
                            : (isPresent ? presentLight : excusedLight),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Icon(
                        isAbsent
                            ? Icons.cancel_outlined
                            : (isPresent
                                  ? Icons.sports_tennis_rounded
                                  : Icons.info_outline_rounded),
                        color: isAbsent
                            ? const Color(0xFFEF4444)
                            : (isPresent
                                  ? presentColor
                                  : const Color(0xFFD97706)),
                        size: 22.sp,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            record.formattedDate,
                            style: TextStyle(
                              fontFamily: 'Nunito',
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF0F172A),
                            ),
                          ),
                          SizedBox(height: 3.h),
                          Text(
                            '${record.sport} • ${record.time}',
                            style: TextStyle(
                              fontFamily: 'Nunito',
                              fontSize: 11.5.sp,
                              color: const Color(0xFF64748B),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (record.remarks.isNotEmpty) ...[
                            SizedBox(height: 2.h),
                            Text(
                              record.remarks,
                              style: TextStyle(
                                fontFamily: 'Nunito',
                                fontSize: 10.5.sp,
                                fontStyle: FontStyle.italic,
                                color: const Color(0xFF94A3B8),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.only(left: 8.w),
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: isAbsent
                      ? absentLight
                      : (isPresent ? presentLight : excusedLight),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Text(
                  record.status,
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w700,
                    color: isAbsent
                        ? const Color(0xFFEF4444)
                        : (isPresent ? presentColor : const Color(0xFFD97706)),
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  // ===========================================================================
  // MONTH PICKER MODAL
  // ===========================================================================

  void _showMonthPicker(BuildContext context, AttendanceController controller) {
    final current = controller.currentMonth.value;
    final months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Padding(
          padding: EdgeInsets.all(20.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Select Month (${current.year})',
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF0F172A),
                ),
              ),
              SizedBox(height: 16.h),
              Wrap(
                spacing: 8.w,
                runSpacing: 8.h,
                children: List.generate(12, (index) {
                  final mNum = index + 1;
                  final isSelected = current.month == mNum;

                  return GestureDetector(
                    onTap: () {
                      controller.setMonth(DateTime(current.year, mNum, 1));
                      Get.back();
                    },
                    child: Container(
                      width: 75.w,
                      padding: EdgeInsets.symmetric(vertical: 10.h),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? goldAccent
                            : const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(10.r),
                        border: Border.all(
                          color: isSelected
                              ? goldAccent
                              : const Color(0xFFE2E8F0),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          months[index].substring(0, 3),
                          style: TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: 13.sp,
                            fontWeight: isSelected
                                ? FontWeight.w700
                                : FontWeight.w500,
                            color: isSelected
                                ? Colors.white
                                : const Color(0xFF0F172A),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
              SizedBox(height: 18.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () {
                      final now = DateTime.now();
                      controller.setMonth(now);
                      Get.back();
                    },
                    child: Text(
                      'Current Month',
                      style: TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                        color: goldAccent,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () => Get.back(),
                    child: Text(
                      'Close',
                      style: TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
