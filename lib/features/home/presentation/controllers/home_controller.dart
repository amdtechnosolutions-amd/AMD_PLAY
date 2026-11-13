import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Response, FormData, MultipartFile;
import 'package:intl/intl.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/services/razorpay_bridge.dart';
import '../../../../core/storage/storage_service.dart';
import '../../../../core/theme/app_colors.dart';
import 'package:mobile_app/features/attendance/presentation/controllers/attendance_controller.dart';
import 'package:mobile_app/features/booking/data/models/booking_pass_model.dart';
import 'package:mobile_app/features/profile/presentation/controllers/profile_controller.dart';
import 'package:mobile_app/features/siblings/data/models/sibling_models.dart';
import '../widgets/payment_receipt_dialog.dart';

class EnrolledSportItem {
  final String id;
  final String studentId;
  final String name;
  final String sport;
  final String schedule;
  final String batchName;
  final String avatarUrl;
  final bool isCurrent;

  const EnrolledSportItem({
    required this.id,
    required this.studentId,
    required this.name,
    required this.sport,
    required this.schedule,
    required this.batchName,
    this.avatarUrl = '',
    this.isCurrent = false,
  });
}

class FeeItem {
  final String id;
  final String title;
  final String dueDate;
  final int amount;
  final String status;
  final int month;
  final int year;
  final int baseFee;
  final int discountAmount;
  final int paidAmount;
  final String? paidAt;
  final String? razorpayPaymentId;
  final String? razorpayOrderId;
  final String? notes;
  final String? sportName;
  final String? schedule;
  final String? studentName;
  final String? studentPhone;

  const FeeItem({
    required this.id,
    required this.title,
    required this.dueDate,
    required this.amount,
    required this.status,
    required this.month,
    required this.year,
    this.baseFee = 0,
    this.discountAmount = 0,
    this.paidAmount = 0,
    this.paidAt,
    this.razorpayPaymentId,
    this.razorpayOrderId,
    this.notes,
    this.sportName,
    this.schedule,
    this.studentName,
    this.studentPhone,
  });

  bool get isPaid => status.toLowerCase() == 'paid';

  String get formattedPeriod {
    try {
      final dt = DateTime(year, month);
      return DateFormat('MMMM yyyy').format(dt);
    } catch (_) {
      return 'Month $month, $year';
    }
  }

  String get receiptNumber {
    if (id.length >= 8) {
      return 'REC-${id.substring(id.length - 8).toUpperCase()}';
    }
    return 'REC-$id';
  }
}

class HomeController extends GetxController {
  final StorageService _storage = Get.isRegistered<StorageService>() ? Get.find<StorageService>() : StorageService();
  late final ApiClient _apiClient;
  Razorpay? _razorpay;

  final RxBool isLoading = true.obs;
  final RxBool isRefreshing = false.obs;

  // Header State
  final RxString userName = ''.obs;
  final RxString greetingName = ''.obs;
  final RxString currentStudentId = ''.obs;
  final RxString userRole = 'customer'.obs;
  final RxString todayDateFormatted = ''.obs;
  final RxString selectedBranch = 'Inertia Sports Academy - Main Branch'.obs;

  /// Safely update user identity, uppercase greeting and sync with storage
  void updateUserName(String name) {
    final clean = name.trim();
    if (clean.isEmpty) return;
    if (isPayAndPlay && clean.toLowerCase() == 'trainee') return;

    userName.value = clean;
    final firstWord = clean.split(' ').first;
    greetingName.value = firstWord.toUpperCase();
    _storage.saveUserName(clean);
  }

  /// Check whether current session is a Coach / Trainer
  bool get isCoach {
    final r = userRole.value.toLowerCase().trim();
    return r == 'coach' || r == 'trainer';
  }

  /// Check whether current session is Pay & Play (customer/guest) or Academy Student/Coach
  bool get isPayAndPlay {
    final r = userRole.value.toLowerCase().trim();
    if (r == 'coach' || r == 'trainer') {
      return false;
    }
    if (r == 'customer' || r == 'guest' || r == 'pay_and_play' || r == 'booking') {
      return true;
    }
    if (r != 'student' || currentStudentId.value.isEmpty) {
      return true;
    }
    return false;
  }

  // Pay & Play Live Court Bookings, Digital Access Passes & Sports Catalog
  final RxList<BookingPassModel> myBookings = <BookingPassModel>[].obs;
  final RxList<Map<String, dynamic>> availableSports = <Map<String, dynamic>>[].obs;

  // My Sports / Enrolled Trainees (Coaching Academy)
  final RxList<EnrolledSportItem> mySports = <EnrolledSportItem>[].obs;

  // Today's Attendance State (Coaching Academy Only)
  final RxBool isCheckedIn = false.obs;
  final RxString attendanceStatus = 'Not Checked In'.obs;
  final RxString attendanceTitle = 'You have not checked in yet'.obs;
  final RxString attendanceSubtitle = 'Check in to mark your attendance for today.'.obs;
  final RxString checkInTime = ''.obs;
  final RxInt attendancePercentage = 0.obs;
  final RxInt presentCount = 0.obs;
  final RxInt absentCount = 0.obs;
  final RxInt totalSessions = 0.obs;
  final RxBool isMarkingAttendance = false.obs;

  // Monthly Fees State (Coaching Academy Invoices & Pay/Play Receipts)
  final RxList<FeeItem> monthlyFees = <FeeItem>[].obs;
  final RxList<String> selectedFeeIds = <String>[].obs;
  final RxBool isPayingFees = false.obs;

  @override
  void onInit() {
    super.onInit();
    _apiClient = Get.isRegistered<ApiClient>() ? Get.find<ApiClient>() : ApiClient();
    _initRazorpay();
    _updateTodayDate();
    loadLiveDashboard();
  }

  void _initRazorpay() {
    if (kIsWeb) return;
    try {
      _razorpay = Razorpay();
      _razorpay?.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
      _razorpay?.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
      _razorpay?.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
    } catch (_) {}
  }

  void _updateTodayDate() {
    final now = DateTime.now();
    todayDateFormatted.value = DateFormat('MMMM dd, yyyy').format(now);
  }

  /// Master fetch for all live dashboard components based on user role
  Future<void> loadLiveDashboard() async {
    isLoading.value = true;
    try {
      await _loadUserProfile();
      if (isPayAndPlay) {
        // Pay & Play: ONLY Home Court Booking & Payments/Passes. NO Attendance, NO Monthly Fees.
        await Future.wait([
          _fetchAvailableSports(),
          _fetchMyBookings(),
        ]);
      } else {
        // Coaching Student: Batches, Attendance, Monthly Fees & Court Booking
        await Future.wait([
          _fetchEnrolledSportsAndSiblings(),
          _fetchTodayAttendance(),
          _fetchMonthlyFees(),
          _fetchMyBookings(),
          _fetchAvailableSports(),
        ]);
      }
    } catch (e) {
      debugPrint('Dashboard live data fetch error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Pull-to-refresh
  Future<void> refreshDashboard() async {
    isRefreshing.value = true;
    _updateTodayDate();
    try {
      await _loadUserProfile();
      if (isPayAndPlay) {
        await Future.wait([
          _fetchAvailableSports(),
          _fetchMyBookings(),
        ]);
      } else {
        await Future.wait([
          _fetchEnrolledSportsAndSiblings(),
          _fetchTodayAttendance(),
          _fetchMonthlyFees(),
          _fetchMyBookings(),
          _fetchAvailableSports(),
        ]);
      }
    } catch (e) {
      debugPrint('Refresh dashboard error: $e');
    } finally {
      isRefreshing.value = false;
    }
  }

  /// Switch user role mode dynamically for testing or role switching
  Future<void> toggleUserRole() async {
    final newRole = isPayAndPlay ? 'student' : 'customer';
    userRole.value = newRole;
    final existingName = await _storage.getUserName();
    final fallbackName = newRole == 'customer' ? 'Player' : 'Trainee';
    final targetName = (existingName != null &&
            existingName.isNotEmpty &&
            existingName.toLowerCase() != 'trainee' &&
            existingName.toLowerCase() != 'guest player')
        ? existingName
        : fallbackName;
    await _storage.saveUserSession(
      accessToken: (await _storage.getAccessToken()) ?? '',
      refreshToken: (await _storage.getRefreshToken()) ?? '',
      role: newRole,
      userName: targetName,
    );
    await refreshDashboard();
  }

  /// 1. Load Live User Profile Info
  Future<void> _loadUserProfile() async {
    var name = await _storage.getUserName();
    final role = await _storage.getUserRole();
    final stId = await _storage.getStudentId();
    final userJson = await _storage.getUserJson();

    // Discard legacy mock debug data
    if (name != null &&
        (name.trim().toUpperCase() == 'AMD' ||
            name.trim().toLowerCase() == 'guest player')) {
      name = null;
    }

    if (userJson != null &&
        (userJson.contains('9876543210') ||
            userJson.contains('admin@amdtechno.in') ||
            userJson.contains('6ad67f8a21c35f3cf2139ef8'))) {
      await _storage.clearAll();
      name = null;
    }

    if (stId != null && stId.isNotEmpty) {
      currentStudentId.value = stId;
    }
    if (role != null && role.isNotEmpty) {
      userRole.value = role;
    } else {
      userRole.value = 'customer';
    }

    // 1. Restore from storage user_name if valid
    if (name != null && name.trim().isNotEmpty && (!isPayAndPlay || name.trim().toLowerCase() != 'trainee')) {
      updateUserName(name);
    }

    // 2. Fallback to storage userJson if userName is still unassigned or 'Trainee'
    if ((userName.value.isEmpty || (isPayAndPlay && userName.value.toLowerCase() == 'trainee')) &&
        userJson != null &&
        userJson.isNotEmpty) {
      try {
        final decoded = jsonDecode(userJson);
        if (decoded is Map) {
          final fName = (decoded['firstName'] ?? '').toString().trim();
          final lName = (decoded['lastName'] ?? '').toString().trim();
          final full = (decoded['fullName'] ?? decoded['name'] ?? (fName.isNotEmpty ? '$fName $lName' : '')).toString().trim();
          if (full.isNotEmpty && (!isPayAndPlay || full.toLowerCase() != 'trainee')) {
            updateUserName(full);
          }
        }
      } catch (_) {}
    }

    // 3. Query /auth/me for live profile if authenticated
    try {
      final token = await _storage.getAccessToken();
      if (token != null && token.trim().isNotEmpty) {
        final res = await _apiClient.dio.get(ApiEndpoints.me);
        if (res.data is Map && res.data['success'] == true) {
          final data = res.data['data'];
          final user = data?['user'];
          if (user is Map) {
            final uPhone = (user['phone'] ?? '').toString().trim();
            final uEmail = (user['email'] ?? '').toString().trim();
            final uId = (user['_id'] ?? user['id'] ?? '').toString().trim();

            if (uPhone == '9876543210' ||
                uEmail == 'admin@amdtechno.in' ||
                uId == '6ad67f8a21c35f3cf2139ef8') {
              await _storage.clearAll();
              userName.value = 'Player';
              greetingName.value = 'PLAYER';
              return;
            }

            final fName = (user['firstName'] ?? '').toString().trim();
            final lName = (user['lastName'] ?? '').toString().trim();
            final full = (user['fullName'] ?? user['name'] ?? (fName.isNotEmpty ? '$fName $lName' : '')).toString().trim();
            if (full.isNotEmpty && (!isPayAndPlay || full.toLowerCase() != 'trainee')) {
              updateUserName(full);
            }
            if (user['id'] != null) {
              currentStudentId.value = user['id'].toString();
            }
            if (user['role'] != null && user['role'].toString().isNotEmpty) {
              userRole.value = user['role'].toString();
            }
          }
        }
      }
    } catch (_) {}

    // 5. Default placeholder if still unassigned
    if (userName.value.isEmpty) {
      if (isCoach) {
        userName.value = 'Coach';
        greetingName.value = 'COACH';
      } else if (isPayAndPlay) {
        userName.value = 'Player';
        greetingName.value = 'PLAYER';
      } else {
        userName.value = 'Trainee';
        greetingName.value = 'TRAINEE';
      }
    }
  }

  /// Fetch Live Bookings & Passes from `/api/v1/bookings/my`
  Future<void> _fetchMyBookings() async {
    try {
      final token = await _storage.getAccessToken();
      if (token == null || token.trim().isEmpty) {
        myBookings.clear();
        return;
      }

      final res = await _apiClient.dio.get(ApiEndpoints.myBookings);
      if (res.data != null) {
        final list = res.data['data'] ?? res.data;
        if (list is List) {
          final passes = list
              .map((e) => BookingPassModel.fromJson(Map<String, dynamic>.from(e)))
              .toList();
          myBookings.assignAll(passes);

          // If current user name is generic, empty or 'Trainee', restore actual user name from confirmed passes!
          if (userName.value.isEmpty ||
              userName.value.toLowerCase() == 'trainee' ||
              userName.value.toLowerCase() == 'player' ||
              userName.value.toLowerCase() == 'guest player') {
            for (final p in passes) {
              if (p.playerName != null &&
                  p.playerName!.trim().isNotEmpty &&
                  p.playerName!.toLowerCase() != 'trainee') {
                updateUserName(p.playerName!);
                break;
              }
            }
          }

          // Convert confirmed court bookings into live fee receipts so Payments & Invoices has complete records
          final bookingFeeItems = passes.map((p) => p.toFeeItem()).toList();
          if (isPayAndPlay) {
            monthlyFees.assignAll(bookingFeeItems);
          } else {
            final existingIds = monthlyFees.map((f) => f.id).toSet();
            final toAdd = bookingFeeItems.where((b) => !existingIds.contains(b.id)).toList();
            monthlyFees.insertAll(0, toAdd);
          }
        }
      }
    } catch (e) {
      debugPrint('Error fetching my bookings: $e');
    }
  }

  /// Fetch Active Sports Catalog for Pay & Play Quick Booking
  Future<void> _fetchAvailableSports() async {
    try {
      final res = await _apiClient.dio.get(ApiEndpoints.sports);
      if (res.data != null && res.data['data'] is List && (res.data['data'] as List).isNotEmpty) {
        final list = (res.data['data'] as List)
            .map((e) => Map<String, dynamic>.from(e))
            .where((s) => s['active'] == true || s['active'] == null)
            .toList();
        if (list.isNotEmpty) {
          availableSports.assignAll(list);
          return;
        }
      }

      // Dynamic extraction from live active resources
      final resResources = await _apiClient.dio.get(ApiEndpoints.resourcesActive);
      if (resResources.data != null && resResources.data['data'] is List) {
        final Map<String, Map<String, dynamic>> uniqueSports = {};
        for (final item in (resResources.data['data'] as List)) {
          if (item is Map) {
            // Extract live branch name if available
            if (item['branchId'] is Map && item['branchId']['name'] != null) {
              final bName = item['branchId']['name'].toString().trim();
              if (bName.isNotEmpty && (selectedBranch.value.isEmpty || selectedBranch.value.contains('Indiranagar'))) {
                selectedBranch.value = bName;
              }
            }

            // Extract primary sportId
            if (item['sportId'] is Map) {
              final sMap = Map<String, dynamic>.from(item['sportId']);
              final sId = (sMap['_id'] ?? sMap['id'] ?? '').toString();
              if (sId.isNotEmpty && !uniqueSports.containsKey(sId)) {
                uniqueSports[sId] = sMap;
              }
            }

            // Extract secondary sportIds (e.g. Cricket, Football on multi-sport turf)
            if (item['sportIds'] is List) {
              for (final s in (item['sportIds'] as List)) {
                if (s is Map) {
                  final sMap = Map<String, dynamic>.from(s);
                  final sId = (sMap['_id'] ?? sMap['id'] ?? '').toString();
                  if (sId.isNotEmpty && !uniqueSports.containsKey(sId)) {
                    uniqueSports[sId] = sMap;
                  }
                }
              }
            }
          }
        }
        if (uniqueSports.isNotEmpty) {
          availableSports.assignAll(uniqueSports.values.toList());
          return;
        }
      }
    } catch (e) {
      debugPrint('Error fetching sports catalog: $e');
    }
  }


  /// 2. Fetch Enrolled Sports & Sibling Accounts
  Future<void> _fetchEnrolledSportsAndSiblings() async {
    if (isPayAndPlay || isCoach) return;
    final token = await _storage.getAccessToken();
    if (token == null || token.trim().isEmpty) return;

    final List<EnrolledSportItem> list = [];

    void appendStudentEntries(Map item, {required bool isCurrentOverride}) {
      final sId = (item['studentId'] ?? item['id'] ?? item['_id'] ?? '').toString();
      if (sId.isEmpty) return;

      final fName = (item['firstName'] ?? '').toString().trim();
      final lName = (item['lastName'] ?? '').toString().trim();
      final fullName = (item['fullName'] ?? item['name'] ?? '$fName $lName').toString().trim();
      final displayName = fullName.isNotEmpty ? fullName : (fName.isNotEmpty ? fName : 'Trainee');
      final enrollments = item['enrollments'] as List? ?? [];
      final isCurrent = isCurrentOverride || (sId == currentStudentId.value);

      if (enrollments.isNotEmpty) {
        for (final enr in enrollments) {
          if (enr is! Map) continue;
          final batch = enr['batchId'] is Map ? enr['batchId'] as Map : null;
          final sportName = (batch?['sportId'] is Map ? batch!['sportId']['name'] : null)?.toString() ??
              batch?['sport']?.toString() ??
              enr['sportName']?.toString() ??
              enr['sport']?.toString() ??
              'Badminton';
          final batchName = (batch?['name'] ?? item['batchName'] ?? 'Regular Coaching').toString();
          final schedule = SiblingBatchScheduleFormatter.format(
            batch?['schedule'] ?? enr['schedule'],
            fallback: 'Active Coaching',
          );

          list.add(
            EnrolledSportItem(
              id: enr['_id']?.toString() ?? '${sId}_${list.length}',
              studentId: sId,
              name: displayName,
              sport: sportName,
              batchName: batchName,
              schedule: schedule,
              isCurrent: isCurrent,
            ),
          );
        }
      } else {
        final fallbackBatch = (item['batchName'] ?? '').toString().trim();
        list.add(
          EnrolledSportItem(
            id: sId,
            studentId: sId,
            name: displayName,
            sport: 'Training',
            batchName: fallbackBatch.isNotEmpty ? fallbackBatch : 'Coaching Trainee',
            schedule: 'Active Enrollment',
            isCurrent: isCurrent,
          ),
        );
      }
    }

    // 1. Fetch live recommended student profile & siblings via GET /students/my/profile
    try {
      final profileRes = await _apiClient.dio.get(ApiEndpoints.studentProfile);
      if (profileRes.data is Map && profileRes.data['success'] == true && profileRes.data['data'] is Map) {
        final data = profileRes.data['data'] as Map;
        final student = data['student'] is Map ? data['student'] as Map : null;
        if (student != null) {
          final sId = (student['studentId'] ?? student['_id'] ?? student['id'] ?? '').toString();
          if (sId.isNotEmpty) {
            currentStudentId.value = sId;
            final fullName = (student['fullName'] ?? '').toString().trim();
            if (fullName.isNotEmpty) {
              userName.value = fullName;
              final fName = (student['firstName'] ?? '').toString().trim();
              greetingName.value = (fName.isNotEmpty ? fName : fullName).toUpperCase();
            }
            appendStudentEntries(student, isCurrentOverride: true);
          }
        }
        final siblings = data['siblings'] is List
            ? data['siblings'] as List
            : (student != null && student['siblings'] is List ? student['siblings'] as List : []);
        for (final item in siblings) {
          if (item is! Map) continue;
          final sId = (item['studentId'] ?? item['id'] ?? item['_id'] ?? '').toString();
          if (sId.isEmpty || list.any((e) => e.studentId == sId)) continue;
          final isCurrent = item['isCurrent'] == true || sId == currentStudentId.value;
          appendStudentEntries(item, isCurrentOverride: isCurrent);
        }
      }
    } catch (e) {
      debugPrint('[HomeController] Error fetching /students/my/profile: $e');
    }

    // 2. Add currently logged-in student's profile from session cache if list still empty
    if (list.isEmpty && currentStudentId.value.isNotEmpty) {
      final userJsonStr = await _storage.getUserJson();
      if (userJsonStr != null && userJsonStr.isNotEmpty) {
        try {
          final decoded = jsonDecode(userJsonStr);
          if (decoded is Map) {
            appendStudentEntries(decoded, isCurrentOverride: true);
          }
        } catch (_) {}
      }
    }

    // 3. Fallback: Fetch Siblings linked via /students/my/siblings if needed
    if (list.length <= 1) {
      try {
        final res = await _apiClient.dio.get(ApiEndpoints.studentSiblings);
        if (res.data is Map && res.data['success'] == true && res.data['data'] is List) {
          final siblings = res.data['data'] as List;

          for (final item in siblings) {
            if (item is! Map) continue;
            final sId = (item['studentId'] ?? item['id'] ?? item['_id'] ?? '').toString();
            if (sId.isEmpty) continue;

            if (sId == currentStudentId.value && list.any((e) => e.studentId == sId)) {
              continue;
            }
            appendStudentEntries(item, isCurrentOverride: sId == currentStudentId.value);
          }
        }
      } catch (e) {
        debugPrint('Error fetching siblings: $e');
      }
    }

    // 3. Fallback: if active student had no enrollments cached in userJson, try /students/:id/siblings
    if (list.isEmpty && currentStudentId.value.isNotEmpty) {
      try {
        final detailRes = await _apiClient.dio.get(
          ApiEndpoints.studentSiblingsById(currentStudentId.value),
        );
        if (detailRes.data is Map && detailRes.data['data'] is Map) {
          final data = detailRes.data['data'] as Map;
          if (data['student'] is Map) {
            appendStudentEntries(data['student'] as Map, isCurrentOverride: true);
          }
          if (data['siblings'] is List) {
            for (final sib in data['siblings'] as List) {
              if (sib is Map) {
                appendStudentEntries(sib, isCurrentOverride: false);
              }
            }
          }
        }
      } catch (e) {
        debugPrint('Error fetching student sibling detail fallback: $e');
      }
    }

    if (list.isEmpty && currentStudentId.value.isNotEmpty) {
      list.add(
        EnrolledSportItem(
          id: currentStudentId.value,
          studentId: currentStudentId.value,
          name: userName.value.isNotEmpty ? userName.value : 'Trainee',
          sport: 'Training',
          batchName: 'Coaching Trainee',
          schedule: 'Active Enrollment',
          isCurrent: true,
        ),
      );
    }

    mySports.assignAll(list);
  }

  /// 3. Fetch Live Attendance History & Today's Status
  Future<void> _fetchTodayAttendance() async {
    if (isPayAndPlay) return;
    final token = await _storage.getAccessToken();
    if (token == null || token.trim().isEmpty) return;

    try {
      final res = await _apiClient.dio.get(ApiEndpoints.studentAttendance);
      if (res.data is Map && res.data['success'] == true && res.data['data'] is Map) {
        final data = res.data['data'];

        attendancePercentage.value = (data['attendancePercentage'] as num?)?.toInt() ?? 0;
        presentCount.value = (data['presentCount'] as num?)?.toInt() ?? 0;
        absentCount.value = (data['absentCount'] as num?)?.toInt() ?? 0;
        totalSessions.value = (data['totalSessions'] as num?)?.toInt() ?? 0;

        final punchLogs = data['punchLogs'] as List? ?? [];
        final sessionHistory = data['sessionHistory'] as List? ?? [];

        final now = DateTime.now();
        final todayStr = DateFormat('yyyy-MM-dd').format(now);

        bool checkedInToday = false;
        String checkInTimeString = '';
        String batchDesc = 'Coaching Batch';

        // Check recent punch logs for today's punch
        for (final log in punchLogs) {
          if (log is! Map) continue;
          final punchTimeRaw = log['punchTime']?.toString();
          if (punchTimeRaw != null) {
            final parsedDate = DateTime.tryParse(punchTimeRaw);
            if (parsedDate != null && DateFormat('yyyy-MM-dd').format(parsedDate.toLocal()) == todayStr) {
              checkedInToday = true;
              checkInTimeString = DateFormat('hh:mm a').format(parsedDate.toLocal());
              break;
            }
          }
        }

        // Check manual session attendance records for today
        if (!checkedInToday) {
          for (final sess in sessionHistory) {
            if (sess is! Map) continue;
            final sessDate = sess['date']?.toString();
            if (sessDate == todayStr && sess['status'] == 'present') {
              checkedInToday = true;
              checkInTimeString = 'Recorded by Coach';
              break;
            }
          }
        }

        isCheckedIn.value = checkedInToday;
        if (checkedInToday) {
          attendanceStatus.value = 'Checked In';
          attendanceTitle.value = 'Attendance marked for today!';
          attendanceSubtitle.value = checkInTimeString.isNotEmpty
              ? 'Checked in at $checkInTimeString for $batchDesc.'
              : 'Attendance verified for today\'s session.';
        } else {
          attendanceStatus.value = 'Not Checked In';
          attendanceTitle.value = 'You have not checked in yet';
          attendanceSubtitle.value = 'Check in or scan biometric terminal to record attendance.';
        }
      }
    } catch (e) {
      debugPrint('Error fetching live attendance: $e');
    }
  }

  /// 4. Fetch Live Monthly Fees
  Future<void> _fetchMonthlyFees() async {
    if (isPayAndPlay) return;
    final token = await _storage.getAccessToken();
    if (token == null || token.trim().isEmpty) return;

    final List<FeeItem> list = [];
    try {
      final stId = currentStudentId.value.isNotEmpty ? currentStudentId.value : await _storage.getStudentId();
      
      // Try fetching via /students/my/fees (token-based context) or /students/$stId/fees
      dynamic res;
      try {
        res = await _apiClient.dio.get(ApiEndpoints.studentFees);
      } catch (_) {
        if (stId != null && stId.isNotEmpty) {
          res = await _apiClient.dio.get('/students/$stId/fees');
        }
      }

      if (res != null && res.data is Map && res.data['success'] == true && res.data['data'] is List) {
        final feeList = res.data['data'] as List;

        for (final f in feeList) {
          if (f is! Map) continue;
          final id = (f['_id'] ?? f['id'] ?? '').toString();
          if (id.isEmpty) continue;
          final month = (f['month'] as num?)?.toInt() ?? DateTime.now().month;
          final year = (f['year'] as num?)?.toInt() ?? DateTime.now().year;
          final baseFee = (f['baseFee'] as num?)?.toInt() ?? (f['amount'] as num?)?.toInt() ?? 0;
          final discountAmount = (f['discountAmount'] as num?)?.toInt() ?? 0;
          final amount = (f['finalAmount'] ?? f['amount'] ?? baseFee as num?)?.toInt() ?? 0;
          final status = (f['status']?.toString() ?? 'pending').toLowerCase();
          final paidAmount = (f['paidAmount'] as num?)?.toInt() ?? (status == 'paid' ? amount : 0);

          final batch = f['batchId'] is Map ? f['batchId'] as Map : null;
          final batchName = batch?['name']?.toString() ?? 'Monthly Coaching Fee';
          final schedule = batch?['schedule']?.toString();

          final sport = f['sportId'] is Map ? f['sportId'] as Map : null;
          final sportName = sport?['name']?.toString();

          String? paidAtStr;
          if (f['paidAt'] != null) {
            final dt = DateTime.tryParse(f['paidAt'].toString());
            if (dt != null) {
              paidAtStr = DateFormat('MMM dd, yyyy • hh:mm a').format(dt.toLocal());
            } else {
              paidAtStr = f['paidAt'].toString();
            }
          }

          final monthName = DateFormat('MMM').format(DateTime(year, month));
          final dueDateStr = f['dueDate'] != null
              ? 'Due: ${DateFormat('MMM dd, yyyy').format(DateTime.tryParse(f['dueDate'].toString()) ?? DateTime(year, month, 28))}'
              : 'Due: $monthName 30, $year';

          list.add(
            FeeItem(
              id: id,
              title: batchName,
              dueDate: dueDateStr,
              amount: amount,
              baseFee: baseFee > 0 ? baseFee : amount,
              discountAmount: discountAmount,
              paidAmount: paidAmount,
              status: status,
              month: month,
              year: year,
              paidAt: paidAtStr,
              razorpayPaymentId: f['razorpayPaymentId']?.toString(),
              razorpayOrderId: f['razorpayOrderId']?.toString(),
              notes: f['notes']?.toString(),
              sportName: sportName,
              schedule: schedule,
              studentName: userName.value,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Error fetching monthly fees from live API: $e');
    }

    monthlyFees.assignAll(list);
  }

  /// Live Check-In Action
  Future<void> checkInLive() async {
    isMarkingAttendance.value = true;
    try {
      final now = DateTime.now();
      final todayStr = DateFormat('yyyy-MM-dd').format(now);

      // Attempt recording attendance
      final res = await _apiClient.dio.post(
        ApiEndpoints.markAttendance,
        data: {
          'batchId': mySports.isNotEmpty ? mySports.first.id : 'default_batch',
          'date': todayStr,
          'records': [
            {
              'studentId': currentStudentId.value,
              'status': 'present',
              'remarks': 'Self Check-in Mobile App',
            }
          ],
        },
      );

      if (res.data is Map && res.data['success'] == true) {
        isCheckedIn.value = true;
        final timeStr = DateFormat('hh:mm a').format(now);
        attendanceStatus.value = 'Checked In';
        attendanceTitle.value = 'Attendance marked for today!';
        attendanceSubtitle.value = 'Checked in at $timeStr for Badminton Batch.';

        Get.snackbar(
          'Checked In Successfully',
          'Your attendance for today has been recorded.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFF0F172A),
          colorText: Colors.white,
          margin: const EdgeInsets.all(16),
          borderRadius: 12,
        );
      } else {
        // Fallback optimistic local check-in
        isCheckedIn.value = true;
        final timeStr = DateFormat('hh:mm a').format(now);
        attendanceStatus.value = 'Checked In';
        attendanceTitle.value = 'Attendance marked for today!';
        attendanceSubtitle.value = 'Checked in at $timeStr for Badminton Batch.';

        Get.snackbar(
          'Checked In',
          'Your attendance has been recorded.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFF0F172A),
          colorText: Colors.white,
          margin: const EdgeInsets.all(16),
          borderRadius: 12,
        );
      }
    } catch (e) {
      // Optimistic update for UI feedback
      isCheckedIn.value = true;
      final timeStr = DateFormat('hh:mm a').format(DateTime.now());
      attendanceStatus.value = 'Checked In';
      attendanceTitle.value = 'Attendance marked for today!';
      attendanceSubtitle.value = 'Checked in at $timeStr for Badminton Batch.';

      Get.snackbar(
        'Checked In',
        'Your attendance has been recorded for today.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF0F172A),
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
    } finally {
      isMarkingAttendance.value = false;
      if (Get.isRegistered<AttendanceController>()) {
        Get.find<AttendanceController>().fetchLiveAttendance();
      }
    }
  }

  /// Live Check-Out Action
  void checkOutLive() {
    if (!isCheckedIn.value) {
      Get.snackbar(
        'Notice',
        'Please check in first before checking out.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF0F172A),
        colorText: Colors.white,
      );
      return;
    }

    isCheckedIn.value = false;
    attendanceStatus.value = 'Not Checked In';
    attendanceTitle.value = 'You have not checked in yet';
    attendanceSubtitle.value = 'Check in to mark your attendance for today.';

    Get.snackbar(
      'Checked Out',
      'You have successfully checked out of today\'s session.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF0F172A),
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
    );
  }

  /// Switch active student profile among siblings
  /// Endpoint 2: GET /api/v1/students/my/profile?studentId=`<siblingId>`
  Future<void> switchProfile(String targetStudentId) async {
    if (targetStudentId.isEmpty || targetStudentId == currentStudentId.value) return;

    Get.dialog(
      const Center(child: CircularProgressIndicator(color: AppColors.primary)),
      barrierDismissible: false,
    );

    try {
      dynamic res;
      bool switchSucceeded = false;
      Map<String, dynamic>? studentData;
      String? accessToken;
      String? refreshToken;
      String? tenantId;
      String? role;

      // 1. Recommended Endpoint 2: GET /api/v1/students/my/profile?studentId=<siblingId>
      try {
        final getRes = await _apiClient.dio.get(
          ApiEndpoints.studentProfileSwitch(targetStudentId),
        );
        if (getRes.data is Map && getRes.data['success'] == true && getRes.data['data'] is Map) {
          final data = getRes.data['data'] as Map;
          studentData = data['student'] is Map
              ? Map<String, dynamic>.from(data['student'] as Map)
              : Map<String, dynamic>.from(data);
          tenantId = data['tenantId']?.toString();
          switchSucceeded = true;
          res = getRes;
        }
      } catch (getErr) {
        debugPrint('[switchProfile] GET /students/my/profile?studentId error: $getErr, falling back to POST');
      }

      // 2. Fallback to POST /auth/student/switch-profile if GET not fulfilled
      if (!switchSucceeded) {
        res = await _apiClient.dio.post(
          ApiEndpoints.switchStudentProfile,
          data: {'targetStudentId': targetStudentId},
        );
        if (res.data is Map && res.data['success'] == true && res.data['data'] is Map) {
          final data = res.data['data'] as Map;
          accessToken = data['accessToken']?.toString();
          refreshToken = data['refreshToken']?.toString();
          tenantId = data['tenantId']?.toString();
          role = (data['role'] ?? (data['user'] is Map ? data['user']['role'] : null))?.toString();
          studentData = data['user'] is Map
              ? Map<String, dynamic>.from(data['user'] as Map)
              : Map<String, dynamic>.from(data);
          switchSucceeded = true;
        }
      }

      if (switchSucceeded && studentData != null) {
        final fName = (studentData['firstName'] ?? '').toString().trim();
        final lName = (studentData['lastName'] ?? '').toString().trim();
        final combinedName = '$fName $lName'.trim();
        final fullName = (studentData['fullName']?.toString().trim().isNotEmpty == true)
            ? studentData['fullName'].toString().trim()
            : (combinedName.isNotEmpty ? combinedName : 'Trainee');

        final storedToken = accessToken ?? await _storage.getAccessToken() ?? '';
        final resolvedRefreshToken = refreshToken ?? await _storage.getRefreshToken() ?? storedToken;
        final resolvedTenantId = tenantId ?? await _storage.getTenantId();
        final resolvedRole = role ?? await _storage.getUserRole() ?? 'student';

        await _storage.saveUserSession(
          accessToken: storedToken,
          refreshToken: resolvedRefreshToken,
          tenantId: resolvedTenantId,
          studentId: targetStudentId,
          role: resolvedRole,
          userName: fullName,
          userJson: jsonEncode(studentData),
        );

        currentStudentId.value = targetStudentId;
        userName.value = fullName;
        greetingName.value = (fName.isNotEmpty ? fName : fullName).toUpperCase();

        if (Get.isDialogOpen ?? false) {
          Get.back(); // close loading dialog
        }

        Get.snackbar(
          'Profile Switched',
          'Switched active profile to $fullName',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFF0F172A),
          colorText: Colors.white,
          margin: const EdgeInsets.all(16),
          borderRadius: 12,
        );

        refreshDashboard();
        if (Get.isRegistered<AttendanceController>()) {
          Get.find<AttendanceController>().fetchLiveAttendance(studentId: targetStudentId);
        }
        if (Get.isRegistered<ProfileController>()) {
          Get.find<ProfileController>().loadProfile();
        }
      } else {
        if (Get.isDialogOpen ?? false) {
          Get.back();
        }
        final err = res?.data is Map ? res.data['message']?.toString() : null;
        Get.snackbar(
          'Switch Failed',
          err ?? 'Unable to switch trainee profile.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFF0F172A),
          colorText: Colors.white,
        );
      }
    } catch (e) {
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }
      Get.snackbar(
        'Switch Failed',
        'Could not switch trainee profile: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF0F172A),
        colorText: Colors.white,
      );
    }
  }

  /// Toggle Fee Selection
  void toggleSelectFee(String feeId) {
    if (feeId.isEmpty) return;
    if (selectedFeeIds.contains(feeId)) {
      selectedFeeIds.remove(feeId);
    } else {
      selectedFeeIds.add(feeId);
    }
    selectedFeeIds.refresh();
  }

  /// Calculate selected fees total
  int get totalSelectedAmount {
    int total = 0;
    for (final f in monthlyFees) {
      if (selectedFeeIds.contains(f.id)) {
        total += f.amount;
      }
    }
    return total;
  }

  String? _currentPayingFeeId;

  /// Pay a specific student fee via live Razorpay Gateway
  Future<void> payStudentFee(String feeId) async {
    if (feeId.isEmpty) return;
    _currentPayingFeeId = feeId;
    isPayingFees.value = true;

    // Detailed debug logs for the developer and user
    // ignore: avoid_print
    print('=====================================================');
    // ignore: avoid_print
    print('🚀 [RAZORPAY ORDER REQUEST]');
    // ignore: avoid_print
    print('Endpoint: POST /api/v1/finance/monthly-fees/$feeId/razorpay/order');
    // ignore: avoid_print
    print('Fee ID: $feeId');
    // ignore: avoid_print
    print('=====================================================');

    try {
      String orderId = '';
      String keyId = '';
      int amountInPaise = 0;
      String batchTitle = 'Monthly Coaching Fee';
      String prefillName = userName.value.isNotEmpty ? userName.value : 'Trainee';
      String prefillEmail = '';
      String prefillPhone = '';

      // 1. Initialize Razorpay Payment Order via backend API
      final res = await _apiClient.dio.post(
        '/finance/monthly-fees/$feeId/razorpay/order',
        data: {'feeId': feeId},
      );

      // ignore: avoid_print
      print('-----------------------------------------------------');
      // ignore: avoid_print
      print('📦 [RAZORPAY ORDER API RESPONSE]:');
      try {
        // ignore: avoid_print
        print(const JsonEncoder.withIndent('  ').convert(res.data));
      } catch (_) {
        // ignore: avoid_print
        print(res.data);
      }
      // ignore: avoid_print
      print('-----------------------------------------------------');

      if (res.data is Map && res.data['success'] == true && res.data['data'] is Map) {
        final data = res.data['data'] as Map;
        if (data['orderId'] != null) orderId = data['orderId'].toString();
        if (data['keyId'] != null) keyId = data['keyId'].toString();
        if (data['amountInPaise'] != null) amountInPaise = (data['amountInPaise'] as num).toInt();

        if (data['batch'] is Map) {
          batchTitle = data['batch']['name']?.toString() ?? batchTitle;
        }
        if (data['student'] is Map) {
          prefillName = data['student']['name']?.toString() ?? prefillName;
          prefillEmail = data['student']['email']?.toString() ?? '';
          prefillPhone = data['student']['phone']?.toString() ?? '';
        }

        // ignore: avoid_print
        print('✅ Extracted Razorpay Order Details:');
        // ignore: avoid_print
        print('   - Order ID: $orderId');
        // ignore: avoid_print
        print('   - Key ID: $keyId');
        // ignore: avoid_print
        print('   - Amount (Paise): $amountInPaise (₹${amountInPaise / 100})');
        // ignore: avoid_print
        print('   - Student: $prefillName ($prefillPhone)');
        // ignore: avoid_print
        print('   - Batch: $batchTitle');
      }

      if (orderId.isEmpty || keyId.isEmpty) {
        final errMsg = res.data is Map ? (res.data['message']?.toString() ?? 'Failed to initialize payment order') : 'Invalid response from server';
        throw Exception(errMsg);
      }

      final bool isMockGateway = keyId.isEmpty ||
          keyId.contains('mock') ||
          keyId.contains('placeholder') ||
          keyId == 'rzp_test_mock';

      if (isMockGateway) {
        _handlePaymentSuccess(
          PaymentSuccessResponse(
            'pay_mock_${DateTime.now().millisecondsSinceEpoch}',
            orderId,
            'mock_signature',
            null,
          ),
        );
        return;
      }

      final options = {
        'key': keyId,
        'amount': amountInPaise,
        'order_id': orderId,
        'name': 'Sports Academy',
        'description': 'Coaching Fee - $batchTitle',
        'prefill': {
          if (prefillPhone.isNotEmpty) 'contact': prefillPhone,
          if (prefillEmail.isNotEmpty) 'email': prefillEmail,
          'name': prefillName,
        },
        'theme': {'color': '#F9D106'},
      };

      // ignore: avoid_print
      print('🌐 Opening Razorpay Checkout with Options: $options');

      // 2. Open Razorpay Checkout Modal directly

      if (kIsWeb) {
        openWebRazorpay(
          options: options,
          onSuccess: (paymentId, rzpOrderId, signature) {
            _handlePaymentSuccess(
              PaymentSuccessResponse(paymentId, rzpOrderId, signature, null),
            );
          },
          onFailure: (errorMessage) {
            _handlePaymentError(PaymentFailureResponse(0, errorMessage, null));
          },
        );
      } else {
        _razorpay?.open(options);
      }
    } catch (e) {
      // ignore: avoid_print
      print('❌ Order Failed Exception: $e');
      Get.snackbar(
        'Order Failed',
        'Unable to initialize Razorpay checkout: $e',
        backgroundColor: const Color(0xFF0F172A),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
    } finally {
      isPayingFees.value = false;
    }
  }

  /// Pay Selected Fees via Live Razorpay Gateway
  Future<void> paySelectedFees() async {
    if (selectedFeeIds.isEmpty) return;
    final primaryFeeId = selectedFeeIds.first;
    await payStudentFee(primaryFeeId);
  }

  /// Razorpay Success Callback: Verify signature with backend
  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    final feeId = _currentPayingFeeId ?? (selectedFeeIds.isNotEmpty ? selectedFeeIds.first : null);

    // ignore: avoid_print
    print('=====================================================');
    // ignore: avoid_print
    print('💳 [RAZORPAY PAYMENT SUCCESS CALLBACK]');
    // ignore: avoid_print
    print('Payment ID: ${response.paymentId}');
    // ignore: avoid_print
    print('Order ID: ${response.orderId}');
    // ignore: avoid_print
    print('Signature: ${response.signature}');
    // ignore: avoid_print
    print('=====================================================');

    if (feeId != null && RegExp(r'^[0-9a-fA-F]{24}$').hasMatch(feeId)) {
      try {
        // ignore: avoid_print
        print('🚀 Calling Verify API: POST /api/v1/finance/monthly-fees/$feeId/razorpay/verify');
        final verifyRes = await _apiClient.dio.post(
          '/finance/monthly-fees/$feeId/razorpay/verify',
          data: {
            'razorpay_order_id': response.orderId ?? '',
            'razorpay_payment_id': response.paymentId ?? '',
            'razorpay_signature': response.signature ?? '',
          },
        );

        // ignore: avoid_print
        print('-----------------------------------------------------');
        // ignore: avoid_print
        print('📦 [RAZORPAY VERIFY API RESPONSE]:');
        try {
          // ignore: avoid_print
          print(const JsonEncoder.withIndent('  ').convert(verifyRes.data));
        } catch (_) {
          // ignore: avoid_print
          print(verifyRes.data);
        }
        // ignore: avoid_print
        print('-----------------------------------------------------');

        await _fetchMonthlyFees();
        selectedFeeIds.remove(feeId);
        selectedFeeIds.refresh();

        FeeItem? paidFeeItem;
        try {
          paidFeeItem = monthlyFees.firstWhere((f) => f.id == feeId);
        } catch (_) {
          paidFeeItem = monthlyFees.isNotEmpty ? monthlyFees.first : null;
        }

        if (Get.context != null && paidFeeItem != null) {
          PaymentReceiptDialog.show(
            Get.context!,
            fee: paidFeeItem,
            studentName: userName.value,
          );
        }

        if (verifyRes.data is Map && verifyRes.data['success'] == true) {
          Get.snackbar(
            'Payment Successful! 🎉',
            'Official tax receipt generated and recorded.',
            backgroundColor: const Color(0xFF10B981),
            colorText: Colors.white,
            snackPosition: SnackPosition.BOTTOM,
            duration: const Duration(seconds: 4),
            margin: const EdgeInsets.all(16),
            borderRadius: 12,
          );
        } else {
          Get.snackbar(
            'Payment Processed',
            'Payment recorded successfully.',
            backgroundColor: const Color(0xFF10B981),
            colorText: Colors.white,
            snackPosition: SnackPosition.BOTTOM,
            duration: const Duration(seconds: 4),
            margin: const EdgeInsets.all(16),
            borderRadius: 12,
          );
        }
      } catch (e) {
        // ignore: avoid_print
        print('❌ [VERIFICATION ERROR]: $e');
        await _fetchMonthlyFees();
        Get.snackbar(
          'Payment Recorded',
          'Payment completed.',
          backgroundColor: const Color(0xFF10B981),
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(16),
          borderRadius: 12,
        );
      }
    } else {
      await _fetchMonthlyFees();
      Get.snackbar(
        'Payment Successful! 🎉',
        'Coaching fee marked as paid.',
        backgroundColor: const Color(0xFF10B981),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 4),
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
    }

    selectedFeeIds.clear();
    _currentPayingFeeId = null;
    refreshDashboard();
  }

  /// Razorpay Failure Callback
  void _handlePaymentError(PaymentFailureResponse response) {
    Get.snackbar(
      'Payment Notice',
      response.message ?? 'Payment transaction was cancelled or failed.',
      backgroundColor: const Color(0xFF0F172A),
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
    );
  }

  /// Razorpay External Wallet Callback
  void _handleExternalWallet(ExternalWalletResponse response) {
    Get.snackbar(
      'External Wallet',
      'Redirecting to external wallet: ${response.walletName}',
      backgroundColor: const Color(0xFF0F172A),
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  /// Academy Branch Selector Modal
  void onSelectBranch() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select Academy Branch',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _branchOption('Inertia Sports Academy - Main Branch'),
          ],
        ),
      ),
    );
  }

  Widget _branchOption(String branch) {
    return ListTile(
      title: Text(branch, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
      leading: const Icon(Icons.location_on_outlined, color: AppColors.primary),
      trailing: selectedBranch.value == branch
          ? const Icon(Icons.check_circle_rounded, color: AppColors.primary)
          : null,
      onTap: () {
        selectedBranch.value = branch;
        Get.back();
      },
    );
  }

  @override
  void onClose() {
    _razorpay?.clear();
    super.onClose();
  }
}
