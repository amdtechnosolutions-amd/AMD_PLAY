import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/storage/storage_service.dart';
import '../../data/models/sibling_attendance_model.dart';

/// Model representing a single session's attendance record
class AttendanceSession {
  final String date; // YYYY-MM-DD
  final String batchId;
  final String batchName;
  final String sport;
  final String time;
  final String status; // 'Present', 'Absent', 'Excused'
  final String remarks;
  final String? checkInTime;
  final String verificationMode;

  const AttendanceSession({
    required this.date,
    required this.batchId,
    required this.batchName,
    required this.sport,
    required this.time,
    required this.status,
    this.remarks = '',
    this.checkInTime,
    this.verificationMode = 'manual',
  });

  bool get isPresent => status.toLowerCase() == 'present';
  bool get isAbsent => status.toLowerCase() == 'absent';
  bool get isExcused => status.toLowerCase() == 'excused';

  DateTime? get dateTime => DateTime.tryParse(date);

  String get formattedDate {
    try {
      final dt = DateTime.parse(date);
      return DateFormat('MMM dd, yyyy').format(dt);
    } catch (_) {
      return date;
    }
  }
}

class AttendanceController extends GetxController {
  final StorageService _storage =
      Get.isRegistered<StorageService>() ? Get.find<StorageService>() : StorageService();
  late final ApiClient _apiClient;

  final RxBool isLoading = true.obs;
  final RxBool isRefreshing = false.obs;
  final RxBool isCalendarView = true.obs;

  // Selected Month State
  final Rx<DateTime> currentMonth = DateTime.now().obs;

  // Live Metric Counts
  final RxInt overallPercentage = 0.obs;
  final RxInt presentCount = 0.obs;
  final RxInt absentCount = 0.obs;
  final RxInt totalSessions = 0.obs;

  // Sibling Switcher State
  final RxList<SiblingAttendanceItem> siblings = <SiblingAttendanceItem>[].obs;
  final RxString selectedSiblingId = ''.obs;
  final RxString selectedStudentName = ''.obs;
  final RxString selectedRegNo = ''.obs;
  final RxString selectedBatchName = ''.obs;
  final RxString selectedSportName = ''.obs;
  final RxBool hasSiblings = false.obs;
  final RxString familyPhone = ''.obs;

  // Monthly Filtered Counts
  final RxInt monthPresentCount = 0.obs;
  final RxInt monthAbsentCount = 0.obs;
  final RxInt monthOverallPercentage = 0.obs;

  // Session Collections
  final RxList<AttendanceSession> allSessions = <AttendanceSession>[].obs;
  final RxList<AttendanceSession> filteredSessions = <AttendanceSession>[].obs;

  // Set of dates (YYYY-MM-DD) for fast lookup
  final RxSet<String> presentDates = <String>{}.obs;
  final RxSet<String> absentDates = <String>{}.obs;
  final RxSet<String> excusedDates = <String>{}.obs;

  // Map of date string -> session for modal details
  final RxMap<String, AttendanceSession> sessionMap = <String, AttendanceSession>{}.obs;

  @override
  void onInit() {
    super.onInit();
    _apiClient = Get.isRegistered<ApiClient>() ? Get.find<ApiClient>() : ApiClient();
    final now = DateTime.now();
    currentMonth.value = DateTime(now.year, now.month, 1);
    fetchLiveAttendance();
  }

  /// Toggle between Calendar and List view
  void setCalendarView(bool value) {
    isCalendarView.value = value;
  }

  /// Navigate to previous month
  void previousMonth() {
    final cur = currentMonth.value;
    currentMonth.value = DateTime(cur.year, cur.month - 1, 1);
    _filterSessionsForMonth();
  }

  /// Navigate to next month
  void nextMonth() {
    final cur = currentMonth.value;
    currentMonth.value = DateTime(cur.year, cur.month + 1, 1);
    _filterSessionsForMonth();
  }

  /// Jump to specific month
  void setMonth(DateTime month) {
    currentMonth.value = DateTime(month.year, month.month, 1);
    _filterSessionsForMonth();
  }

  String get formattedMonthHeader {
    return DateFormat('MMMM yyyy').format(currentMonth.value);
  }

  /// Master fetch from live backend API (supports sibling query parameters)
  Future<void> fetchLiveAttendance({String? studentId}) async {
    final role = (await _storage.getUserRole())?.toLowerCase().trim();
    final isPayAndPlay = role == 'customer' || role == 'guest' || role == 'pay_and_play' || role == 'booking';
    final token = await _storage.getAccessToken();

    // Skip student attendance if user is Pay & Play or unauthenticated
    if (isPayAndPlay || token == null || token.trim().isEmpty) {
      isLoading.value = false;
      return;
    }

    if (studentId != null && studentId.isNotEmpty) {
      selectedSiblingId.value = studentId;
    }

    isLoading.value = true;
    try {
      final storedId = await _storage.getStudentId();
      final targetId = (studentId != null && studentId.isNotEmpty)
          ? studentId
          : (selectedSiblingId.value.isNotEmpty ? selectedSiblingId.value : (storedId ?? ''));

      final queryParams = <String, dynamic>{
        'groupBy': 'sibling',
      };
      if (targetId.isNotEmpty) {
        queryParams['studentId'] = targetId;
      }

      dynamic response;
      try {
        response = await _apiClient.dio.get(
          ApiEndpoints.studentAttendance,
          queryParameters: queryParams,
        );
      } catch (dioErr) {
        debugPrint('GET ${ApiEndpoints.studentAttendance} error: $dioErr');
        if (targetId.isNotEmpty) {
          try {
            response = await _apiClient.dio.get(
              '/students/$targetId/attendance',
              queryParameters: {'groupBy': 'sibling'},
            );
          } catch (_) {}
        }
      }

      if (response != null && response.data is Map && response.data['success'] == true) {
        final data = response.data['data'];
        if (data is Map) {
          _parseAttendanceData(data);
        }
      } else {
        _populateFallbackFromLocalContext();
      }
    } catch (e) {
      debugPrint('Error loading live attendance: $e');
      _populateFallbackFromLocalContext();
    } finally {
      _filterSessionsForMonth();
      isLoading.value = false;
    }
  }

  /// Select a specific sibling without switching authentication token
  Future<void> selectSiblingAttendance(String studentId) async {
    if (selectedSiblingId.value == studentId && !isLoading.value) return;
    selectedSiblingId.value = studentId;
    await fetchLiveAttendance(studentId: studentId);
  }

  /// Pull to refresh
  Future<void> refreshAttendance() async {
    isRefreshing.value = true;
    try {
      await fetchLiveAttendance(studentId: selectedSiblingId.value);
    } finally {
      isRefreshing.value = false;
    }
  }

  @visibleForTesting
  void parseAttendanceDataForTest(Map data) => _parseAttendanceData(data);

  void _parseAttendanceData(Map data) {
    final parsed = StudentAttendanceResponse.fromJson(Map<String, dynamic>.from(data));

    // Update student identifiers and family metadata
    if (parsed.studentId.isNotEmpty) {
      selectedSiblingId.value = parsed.studentId;
    }
    selectedStudentName.value = parsed.studentName;
    selectedRegNo.value = parsed.regNo;
    selectedBatchName.value = parsed.batchName;
    selectedSportName.value = parsed.sportName;
    familyPhone.value = parsed.familyPhone;
    hasSiblings.value = parsed.hasSiblings || parsed.siblings.length > 1;

    // Update siblings collection
    if (parsed.siblings.isNotEmpty) {
      siblings.assignAll(parsed.siblings);
      if (selectedSiblingId.value.isEmpty) {
        final activeSib = parsed.siblings.firstWhere(
          (s) => s.isSelected,
          orElse: () => parsed.siblings.first,
        );
        selectedSiblingId.value = activeSib.studentId;
        if (selectedStudentName.value.isEmpty) {
          selectedStudentName.value = activeSib.fullName;
        }
      }
    }

    totalSessions.value = parsed.totalSessions;
    presentCount.value = parsed.presentCount;
    absentCount.value = parsed.absentCount;

    final rawPercentage = parsed.attendancePercentage;
    // Guard against backend bug returning 100% when there are 0 total sessions
    if (totalSessions.value == 0 || (presentCount.value == 0 && absentCount.value == 0)) {
      overallPercentage.value = 0;
    } else {
      overallPercentage.value = rawPercentage;
    }

    final sessionHistory = parsed.sessionHistory;
    final punchLogs = parsed.punchLogs;

    final List<AttendanceSession> list = [];
    final Set<String> pDates = {};
    final Set<String> aDates = {};
    final Set<String> eDates = {};
    final Map<String, AttendanceSession> sMap = {};

    for (final item in sessionHistory) {
      if (item is! Map) continue;
      final dateStr = item['date']?.toString() ?? '';
      if (dateStr.isEmpty) continue;

      final batch = item['batchId'] is Map ? item['batchId'] as Map : null;
      final batchName = item['batchName']?.toString() ?? batch?['name']?.toString() ?? 'Coaching Batch';
      final sport = item['sport']?.toString() ?? batch?['sport']?.toString() ?? 'Badminton';
      final time = item['time']?.toString() ?? batch?['schedule']?.toString() ?? '06:00 PM - 07:00 PM';
      final rawStatus = (item['status']?.toString() ?? 'Present').trim();
      final status = rawStatus.toLowerCase() == 'absent'
          ? 'Absent'
          : (rawStatus.toLowerCase() == 'excused' ? 'Excused' : 'Present');
      final remarks = item['remarks']?.toString() ?? '';
      final checkInTime = item['checkInTime']?.toString();
      final verificationMode = item['verificationMode']?.toString() ?? 'manual';

      final session = AttendanceSession(
        date: dateStr,
        batchId: item['batchId']?.toString() ?? '',
        batchName: batchName,
        sport: sport,
        time: time,
        status: status,
        remarks: remarks,
        checkInTime: checkInTime,
        verificationMode: verificationMode,
      );

      list.add(session);
      sMap[dateStr] = session;

      if (status == 'Present') {
        pDates.add(dateStr);
      } else if (status == 'Absent') {
        aDates.add(dateStr);
      } else {
        eDates.add(dateStr);
      }
    }

    // Merge punch logs into sessions if not already added
    for (final punch in punchLogs) {
      if (punch is! Map) continue;
      final punchTimeStr = punch['punchTime']?.toString();
      if (punchTimeStr == null) continue;

      final dt = DateTime.tryParse(punchTimeStr);
      if (dt == null) continue;
      final dateKey = DateFormat('yyyy-MM-dd').format(dt.toLocal());
      final timeStr = DateFormat('hh:mm a').format(dt.toLocal());

      if (!sMap.containsKey(dateKey)) {
        final session = AttendanceSession(
          date: dateKey,
          batchId: punch['batchId']?.toString() ?? '',
          batchName: punch['batchName']?.toString() ?? 'Biometric Punch',
          sport: 'Academy Session',
          time: timeStr,
          status: 'Present',
          remarks: punch['notes']?.toString() ?? 'Biometric Terminal Check-in',
          checkInTime: punchTimeStr,
          verificationMode: punch['verificationMode']?.toString() ?? 'face',
        );

        list.add(session);
        sMap[dateKey] = session;
        pDates.add(dateKey);
      }
    }

    // Sort descending by date
    list.sort((a, b) => b.date.compareTo(a.date));

    allSessions.assignAll(list);
    presentDates.assignAll(pDates);
    absentDates.assignAll(aDates);
    excusedDates.assignAll(eDates);
    sessionMap.assignAll(sMap);

    // Calculate overall percentage if not provided or 0 with active sessions
    if (list.isEmpty) {
      totalSessions.value = 0;
      presentCount.value = 0;
      absentCount.value = 0;
      overallPercentage.value = 0;
    } else if (totalSessions.value == 0) {
      totalSessions.value = list.length;
      presentCount.value = pDates.length;
      absentCount.value = aDates.length;
      overallPercentage.value = totalSessions.value > 0
          ? ((presentCount.value / totalSessions.value) * 100).round()
          : 0;
    }
  }

  void _populateFallbackFromLocalContext() {
    if (allSessions.isEmpty) {
      totalSessions.value = 0;
      presentCount.value = 0;
      absentCount.value = 0;
      overallPercentage.value = 0;
    }
  }

  /// Recalculate month specific sessions and metrics
  void _filterSessionsForMonth() {
    final y = currentMonth.value.year;
    final m = currentMonth.value.month;

    final monthSessions = allSessions.where((s) {
      final dt = s.dateTime;
      if (dt == null) return false;
      return dt.year == y && dt.month == m;
    }).toList();

    filteredSessions.assignAll(monthSessions);

    int p = 0;
    int a = 0;
    for (final s in monthSessions) {
      if (s.isPresent) p++;
      if (s.isAbsent) a++;
    }

    monthPresentCount.value = p;
    monthAbsentCount.value = a;
    final total = p + a;
    monthOverallPercentage.value = total > 0 ? ((p / total) * 100).round() : 0;
  }

  /// Return session status for a specific day in the currently viewed month
  String? getStatusForDay(int day) {
    final y = currentMonth.value.year;
    final m = currentMonth.value.month;
    final dateKey = '$y-${m.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';

    if (presentDates.contains(dateKey)) return 'Present';
    if (absentDates.contains(dateKey)) return 'Absent';
    if (excusedDates.contains(dateKey)) return 'Excused';
    return null;
  }

  AttendanceSession? getSessionForDay(int day) {
    final y = currentMonth.value.year;
    final m = currentMonth.value.month;
    final dateKey = '$y-${m.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';
    return sessionMap[dateKey];
  }
}
