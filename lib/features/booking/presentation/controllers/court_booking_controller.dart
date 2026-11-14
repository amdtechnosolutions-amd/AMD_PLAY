import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../../../../core/services/razorpay_bridge.dart';
import '../../../../core/storage/storage_service.dart';
import '../../../home/presentation/controllers/home_controller.dart';
import '../../../siblings/data/models/sibling_models.dart';
import '../../../siblings/data/services/sibling_service.dart';
import '../../data/models/court_slot_model.dart';
import '../../data/models/booking_pass_model.dart';
import '../../data/services/booking_service.dart';
import '../screens/digital_pass_screen.dart';

class CourtBookingController extends GetxController {
  final BookingService _bookingService;

  CourtBookingController({BookingService? bookingService})
      : _bookingService = bookingService ?? BookingService();

  // Sports catalog
  final RxList<SportItem> sports = <SportItem>[].obs;
  final Rx<SportItem?> selectedSport = Rx<SportItem?>(null);

  // Courts / Resources
  final RxList<CourtModel> courts = <CourtModel>[].obs;
  final Rx<CourtModel?> selectedCourt = Rx<CourtModel?>(null);

  // Dynamic booking dates (14 rolling days from today)
  final RxList<DateTime> availableDates = <DateTime>[].obs;
  final Rx<DateTime> selectedDate = DateTime.now().obs;

  // Live Slots & Multi-Slot Selection
  final RxList<SlotModel> availableSlots = <SlotModel>[].obs;
  final RxList<SelectedSlot> selectedSlots = <SelectedSlot>[].obs;
  final Rx<SlotModel?> selectedSlot = Rx<SlotModel?>(null);

  // Dynamic Price & Tax Quote (Quote Engine)
  final Rx<MultiSlotPricingQuote?> pricingQuote = Rx<MultiSlotPricingQuote?>(null);
  final RxBool isLoadingQuote = false.obs;

  // Loading States
  final RxBool isLoadingSports = false.obs;
  final RxBool isLoadingCourts = false.obs;
  final RxBool isLoadingSlots = false.obs;
  final RxBool isSubmitting = false.obs;

  // 5-Minute Slot Hold Lock Engine
  Timer? _holdTimer;
  final RxString activeHoldId = ''.obs;
  final RxInt holdSecondsRemaining = 0.obs;
  final RxBool isHoldingSlot = false.obs;

  Razorpay? _razorpay;
  final StorageService _storage = Get.isRegistered<StorageService>() ? Get.find<StorageService>() : StorageService();
  Map<String, dynamic>? _pendingOrder;
  Completer<BookingPassModel?>? _pendingBookingCompleter;

  // Guest Customer Registration State (Step 1)
  final RxString customerPhone = ''.obs;
  final RxString customerName = ''.obs;
  final RxString customerEmail = ''.obs;
  final RxBool isGuestRegistered = false.obs;
  final RxBool isExistingCustomer = false.obs;
  final RxBool isRegisteringGuest = false.obs;
  final RxString userRole = ''.obs;

  bool get isStudent => userRole.value.toLowerCase().trim() == 'student';
  bool get isCoach =>
      userRole.value.toLowerCase().trim() == 'coach' ||
      userRole.value.toLowerCase().trim() == 'trainer';
  bool get isStudentOrCoach => isStudent || isCoach;

  // Student Personal Booking State (Contract: JWT extracted, optional sibling selection, 'upi')
  final RxList<SiblingStudentModel> familySiblings = <SiblingStudentModel>[].obs;
  final Rx<SiblingStudentModel?> selectedSibling = Rx<SiblingStudentModel?>(null);
  final RxString selectedPaymentMethod = 'upi'.obs;
  final RxString bookingNotes = 'Personal training practice'.obs;

  String get holdTimeFormatted {
    final mins = (holdSecondsRemaining.value ~/ 60).toString().padLeft(2, '0');
    final secs = (holdSecondsRemaining.value % 60).toString().padLeft(2, '0');
    return '$mins:$secs';
  }

  int get totalSelectedCount => selectedSlots.length;
  bool get hasSelectedSlots => selectedSlots.isNotEmpty;

  double get grandBaseAmount {
    if (pricingQuote.value != null && pricingQuote.value!.basePrice > 0) {
      return pricingQuote.value!.basePrice;
    }
    return selectedSlots.fold<double>(0, (sum, s) => sum + s.price);
  }

  double get grandTaxAmount {
    if (pricingQuote.value != null && pricingQuote.value!.taxAmount > 0) {
      return pricingQuote.value!.taxAmount;
    }
    return (grandBaseAmount * 0.18).roundToDouble();
  }

  double get grandTotalAmount {
    if (pricingQuote.value != null && pricingQuote.value!.totalAmount > 0) {
      return pricingQuote.value!.totalAmount;
    }
    return grandBaseAmount + grandTaxAmount;
  }

  bool isSlotSelected(SlotModel slot) {
    final courtId = selectedCourt.value?.id ?? slot.courtId;
    final dateStr = DateFormat('yyyy-MM-dd').format(selectedDate.value);
    return selectedSlots.any((s) =>
        s.resourceId == courtId &&
        s.date == dateStr &&
        s.startTime == slot.startTime &&
        s.endTime == slot.endTime);
  }

  @override
  void onInit() {
    super.onInit();
    _initRazorpay();
    checkCustomerSession();
    _initRollingDates();
    loadSports();
  }

  Future<void> checkCustomerSession() async {
    try {
      final token = await _storage.getAccessToken();
      final role = await _storage.getUserRole();
      final name = await _storage.getUserName();
      final userJson = await _storage.getUserJson();

      if (role != null && role.isNotEmpty) {
        userRole.value = role;
      }

      if (token != null && token.isNotEmpty) {
        // Any authenticated user (student, coach, or customer) has an active identity
        isGuestRegistered.value = true;

        if (name != null &&
            name.isNotEmpty &&
            name != 'Pay & Play Guest' &&
            name != 'Trainee' &&
            name != 'Player') {
          customerName.value = name;
        }

        if (userJson != null && userJson.isNotEmpty) {
          try {
            final decoded = jsonDecode(userJson);
            if (decoded is Map) {
              final phone = (decoded['phone'] ??
                      decoded['parentPhone'] ??
                      decoded['mobile'] ??
                      '')
                  .toString()
                  .trim();
              if (phone.isNotEmpty && customerPhone.value.isEmpty) {
                customerPhone.value = phone;
              }

              final email = (decoded['email'] ?? '').toString().trim();
              if (email.isNotEmpty && customerEmail.value.isEmpty) {
                customerEmail.value = email;
              }

              final fName = (decoded['firstName'] ?? '').toString().trim();
              final lName = (decoded['lastName'] ?? '').toString().trim();
              final fullName = (decoded['fullName'] ??
                      decoded['name'] ??
                      (fName.isNotEmpty ? '$fName $lName' : ''))
                  .toString()
                  .trim();
              if (fullName.isNotEmpty && customerName.value.isEmpty) {
                customerName.value = fullName;
              }
            }
          } catch (_) {}
        }

        // Cross-sync with live HomeController if available
        if (Get.isRegistered<HomeController>()) {
          final homeCtrl = Get.find<HomeController>();
          if (customerName.value.isEmpty &&
              homeCtrl.userName.value.isNotEmpty &&
              homeCtrl.userName.value != 'Trainee' &&
              homeCtrl.userName.value != 'Player') {
            customerName.value = homeCtrl.userName.value;
          }
          if (homeCtrl.userRole.value.isNotEmpty) {
            userRole.value = homeCtrl.userRole.value;
          }
        }

        if (isStudent) {
          loadFamilySiblings();
        }
      }
    } catch (_) {}
  }

  /// Load linked family siblings for student booking assignment
  Future<void> loadFamilySiblings() async {
    try {
      final service = SiblingService();
      final profile = await service.getMyProfile();
      if (profile.hasSiblings && profile.siblings.isNotEmpty) {
        familySiblings.assignAll(profile.siblings);
        final currentId = await _storage.getStudentId();
        final match = profile.siblings.firstWhereOrNull(
          (s) => s.studentId == currentId || s.isCurrent,
        );
        selectedSibling.value = match ?? profile.siblings.first;
      }
    } catch (_) {}
  }

  void _initRazorpay() {
    if (kIsWeb) return;
    try {
      _razorpay = Razorpay();
      _razorpay?.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handleNativePaymentSuccess);
      _razorpay?.on(Razorpay.EVENT_PAYMENT_ERROR, _handleNativePaymentError);
      _razorpay?.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleNativeExternalWallet);
    } catch (_) {}
  }

  void _initRollingDates() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    selectedDate.value = today;

    final dates = List.generate(14, (i) => today.add(Duration(days: i)));
    availableDates.assignAll(dates);
  }

  /// 1. Load Sports Catalog from `/api/v1/sports`
  Future<void> loadSports() async {
    isLoadingSports.value = true;
    try {
      final list = await _bookingService.getSports();
      sports.assignAll(list);
      if (sports.isNotEmpty) {
        if (selectedSport.value == null || !sports.any((s) => s.id == selectedSport.value?.id)) {
          selectedSport.value = sports.first;
        }
        await loadCourts();
      }
    } finally {
      isLoadingSports.value = false;
    }
  }

  /// 2. Load Active Courts for Selected Sport from `/api/v1/resources/active`
  Future<void> loadCourts() async {
    isLoadingCourts.value = true;
    try {
      final sport = selectedSport.value;
      final list = await _bookingService.getCourts(
        sportId: sport?.id,
        sportCode: sport?.slug,
      );
      courts.assignAll(list);
      if (courts.isNotEmpty) {
        selectCourt(courts.first);
      } else {
        selectedCourt.value = null;
        availableSlots.clear();
      }
    } finally {
      isLoadingCourts.value = false;
    }
  }

  /// Change active sport tab
  void changeSport(SportItem sport) {
    if (selectedSport.value?.id == sport.id) return;
    selectedSport.value = sport;
    loadCourts();
  }

  /// Change active booking date
  void changeDate(DateTime date) {
    selectedDate.value = date;
    final dateStr = DateFormat('yyyy-MM-dd').format(date);
    selectedSlots.removeWhere((s) => s.date != dateStr);
    if (selectedCourt.value != null) {
      loadSlotsForCourt(selectedCourt.value!);
    }
  }

  /// Returns true if currently selected date is today
  bool get isTodaySelected {
    final now = DateTime.now();
    return selectedDate.value.year == now.year &&
        selectedDate.value.month == now.month &&
        selectedDate.value.day == now.day;
  }

  /// Select court
  void selectCourt(CourtModel court) {
    selectedCourt.value = court;
    loadSlotsForCourt(court);
  }

  /// 3. Load Live Slots for Court and Date from `/api/v1/slots`
  Future<void> loadSlotsForCourt(CourtModel court) async {
    isLoadingSlots.value = true;
    try {
      final dateStr = DateFormat('yyyy-MM-dd').format(selectedDate.value);
      final rawSlots = await _bookingService.getSlotsForCourt(court, date: dateStr);
      final now = DateTime.now();
      // Filter out slots that have already elapsed for today
      final filteredSlots = rawSlots.where((slot) => !slot.isPast(selectedDate.value, now)).toList();
      availableSlots.assignAll(filteredSlots);
    } finally {
      isLoadingSlots.value = false;
    }
  }

  /// Tapping an available slot toggles selection in multi-slot cart and manages atomic hold
  Future<void> onSlotTapped(SlotModel slot) async {
    if (slot.isPast(selectedDate.value)) {
      Get.snackbar(
        'Slot Expired',
        'This slot has already passed and cannot be booked.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (!slot.isAvailable) {

      if (slot.isHold) {
        Get.snackbar(
          'Slot Locked',
          'Another customer is checking out this slot (5 min hold).',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.amber.shade50,
          colorText: Colors.amber.shade900,
        );
      } else if (slot.isBooked) {
        Get.snackbar(
          'Slot Booked',
          'This slot is already reserved.',
          snackPosition: SnackPosition.BOTTOM,
        );
      } else if (slot.isBatchConflict) {
        Get.snackbar(
          'Coaching Batch Active',
          slot.reason ?? 'This slot is reserved for academy coaching.',
          snackPosition: SnackPosition.BOTTOM,
        );
      } else if (slot.isMaintenance) {
        Get.snackbar(
          'Under Maintenance',
          slot.reason ?? 'This court is currently under scheduled maintenance.',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
      return;
    }

    final court = selectedCourt.value;
    final dateStr = DateFormat('yyyy-MM-dd').format(selectedDate.value);
    final target = SelectedSlot(
      resourceId: court?.id ?? slot.courtId,
      courtName: court?.name ?? 'Court',
      sportName: court?.sport ?? 'Sports',
      date: dateStr,
      startTime: slot.startTime,
      endTime: slot.endTime,
      timeText: slot.timeText,
      price: slot.price,
    );

    final existingIndex = selectedSlots.indexWhere((s) => s == target);

    if (existingIndex >= 0) {
      // 3. Cancel / Deselect: Release locked slot
      final removed = selectedSlots.removeAt(existingIndex);
      if (selectedSlots.isEmpty) {
        releaseActiveHold();
        return;
      } else {
        selectedSlot.value = SlotModel(
          courtId: selectedSlots.first.resourceId,
          timeText: selectedSlots.first.timeText,
          startTime: selectedSlots.first.startTime,
          endTime: selectedSlots.first.endTime,
          price: selectedSlots.first.price,
          status: SlotStatus.available,
        );
        _bookingService.releaseMultiSlotHold(
          holdId: activeHoldId.value,
          slots: [removed],
        );
        await fetchPriceQuote();
      }
    } else {
      // 1. Cart / Selection: Add to slots
      selectedSlots.add(target);
      selectedSlot.value = slot;

      // 2. Temporary Lock: Hold slots for 5 mins
      await acquireHoldForSelectedSlots();
      await fetchPriceQuote();
    }
  }

  /// Request multi-slot hold lock from backend
  Future<bool> acquireHoldForSelectedSlots() async {
    if (selectedSlots.isEmpty) return false;

    final holdRes = await _bookingService.acquireMultiSlotHold(slots: selectedSlots);
    if (holdRes != null && holdRes.holdId.isNotEmpty) {
      activeHoldId.value = holdRes.holdId;
      holdSecondsRemaining.value = holdRes.expiresInSeconds > 0 ? holdRes.expiresInSeconds : 300;
      isHoldingSlot.value = true;
      _startHoldTimer();
      return true;
    } else {
      // Fallback: If single slot and acquireMultiSlotHold had issues
      if (selectedSlots.length == 1) {
        final s = selectedSlots.first;
        final ok = await _bookingService.acquireSlotHold(
          courtId: s.resourceId,
          date: s.date,
          startTime: s.startTime,
          endTime: s.endTime,
        );
        if (ok) {
          activeHoldId.value = 'hold_${DateTime.now().millisecondsSinceEpoch}';
          holdSecondsRemaining.value = 300;
          isHoldingSlot.value = true;
          _startHoldTimer();
          return true;
        }
      }
    }
    return false;
  }

  void _startHoldTimer() {
    _holdTimer?.cancel();
    _holdTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (holdSecondsRemaining.value > 0) {
        holdSecondsRemaining.value--;
      } else {
        timer.cancel();
        releaseActiveHold();
        Get.snackbar(
          'Hold Expired',
          'Your 5-minute checkout hold has expired. The slots have been released back to the arena grid.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade50,
          colorText: Colors.red.shade900,
          duration: const Duration(seconds: 4),
        );
      }
    });
  }

  /// 1. Calculate Grand Total & Taxes via POST /api/v1/slots/calculate-price
  Future<void> fetchPriceQuote() async {
    if (selectedSlots.isEmpty) {
      pricingQuote.value = null;
      return;
    }
    isLoadingQuote.value = true;
    try {
      final quote = await _bookingService.calculateMultiSlotPrice(slots: selectedSlots);
      if (quote != null) {
        pricingQuote.value = quote;
      }
    } finally {
      isLoadingQuote.value = false;
    }
  }

  /// 3. Deselect / Release active slot hold
  void releaseActiveHold() {
    if (selectedSlots.isNotEmpty) {
      _bookingService.releaseMultiSlotHold(
        holdId: activeHoldId.value,
        slots: List.from(selectedSlots),
      );
    } else if (selectedSlot.value != null && selectedCourt.value != null) {
      final dateStr = DateFormat('yyyy-MM-dd').format(selectedDate.value);
      _bookingService.releaseSlotHold(
        courtId: selectedCourt.value!.id,
        date: dateStr,
        startTime: selectedSlot.value!.startTime,
      );
    }

    _holdTimer?.cancel();
    _holdTimer = null;
    isHoldingSlot.value = false;
    holdSecondsRemaining.value = 0;
    activeHoldId.value = '';
    selectedSlots.clear();
    selectedSlot.value = null;
    pricingQuote.value = null;
  }

  /// Primary: Initialize Razorpay Gateway Order for multi-slot checkout
  Future<BookingPassModel?> payWithRazorpay() async {
    if (selectedSlots.isEmpty) {
      if (selectedCourt.value != null && selectedSlot.value != null) {
        final court = selectedCourt.value!;
        final slot = selectedSlot.value!;
        final dateStr = DateFormat('yyyy-MM-dd').format(selectedDate.value);
        selectedSlots.add(SelectedSlot(
          resourceId: court.id,
          courtName: court.name,
          sportName: court.sport,
          date: dateStr,
          startTime: slot.startTime,
          endTime: slot.endTime,
          timeText: slot.timeText,
          price: slot.price,
        ));
      } else {
        return null;
      }
    }

    isSubmitting.value = true;
    _pendingBookingCompleter = Completer<BookingPassModel?>();

    try {
      // Ensure hold lock is active
      if (activeHoldId.value.isEmpty || !isHoldingSlot.value) {
        await acquireHoldForSelectedSlots();
      }

      // 4a. Razorpay Order: Create unified checkout order via POST /api/v1/bookings/razorpay/order
      final orderData = await _bookingService.createMultiSlotRazorpayOrder(
        slots: selectedSlots,
        holdId: activeHoldId.value,
      );

      if (orderData == null || orderData['orderId'] == null) {
        throw Exception('Failed to generate Razorpay booking order from server');
      }

      final String orderId = orderData['orderId'].toString();
      final String keyId = (orderData['keyId'] ?? '').toString();
      final int amountInPaise = orderData['amountInPaise'] != null
          ? (orderData['amountInPaise'] as num).toInt()
          : (grandTotalAmount * 100).round();

      String prefillName = 'Arena Player';
      String prefillEmail = customerEmail.value;
      String prefillPhone = customerPhone.value;

      try {
        final savedName = await _storage.getUserName();
        if (savedName != null && savedName.isNotEmpty) prefillName = savedName;
      } catch (_) {}

      _pendingOrder = {
        'orderId': orderId,
        'holdId': activeHoldId.value,
        'slots': List<SelectedSlot>.from(selectedSlots),
      };

      final firstSlot = selectedSlots.first;
      final slotDesc = selectedSlots.length == 1
          ? '${firstSlot.courtName} - ${firstSlot.timeText}'
          : '${selectedSlots.length} Slots (${firstSlot.courtName}...)';

      // If the backend has mock credentials (rzp_test_mock), the public Razorpay CDN checkout
      // will fail with 'Something went wrong / Payment Failed' because it's not a real key.
      // In mock mode, complete the verification directly with the backend.
      final bool isMockGateway = keyId.isEmpty ||
          keyId.contains('mock') ||
          keyId.contains('placeholder') ||
          keyId == 'rzp_test_mock';

      if (isMockGateway) {
        debugPrint('🧪 [MOCK GATEWAY] Backend returned test key ($keyId). Completing test checkout directly...');
        final pass = await _verifyAndFinalizeBooking(
          razorpayOrderId: orderId,
          razorpayPaymentId: 'pay_mock_${DateTime.now().millisecondsSinceEpoch}',
          razorpaySignature: 'mock_signature',
        );
        isSubmitting.value = false;
        return pass;
      }

      final options = {
        'key': keyId,
        'amount': amountInPaise,
        'order_id': orderId,
        'name': 'Sports Academy',
        'description': slotDesc,
        'prefill': {
          if (prefillPhone.isNotEmpty) 'contact': prefillPhone,
          if (prefillEmail.isNotEmpty) 'email': prefillEmail,
          'name': prefillName,
        },
        'theme': {'color': '#F9D106'},
      };

      debugPrint('💳 [RAZORPAY GATEWAY CHECKOUT] Launching options: $options');

      // 2. Open Razorpay Checkout Modal

      if (kIsWeb) {
        openWebRazorpay(
          options: options,
          onSuccess: (paymentId, rzpOrderId, signature) async {
            final pass = await _verifyAndFinalizeBooking(
              razorpayOrderId: rzpOrderId.isNotEmpty ? rzpOrderId : orderId,
              razorpayPaymentId: paymentId,
              razorpaySignature: signature,
            );
            if (_pendingBookingCompleter != null && !_pendingBookingCompleter!.isCompleted) {
              _pendingBookingCompleter!.complete(pass);
            }
          },
          onFailure: (errorMessage) {
            isSubmitting.value = false;
            Get.snackbar(
              'Payment Notice',
              errorMessage,
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: const Color(0xFFFEF2F2),
              colorText: const Color(0xFF991B1B),
            );
            if (_pendingBookingCompleter != null && !_pendingBookingCompleter!.isCompleted) {
              _pendingBookingCompleter!.complete(null);
            }
          },
        );
      } else {
        _razorpay?.open(options);
      }

      return await _pendingBookingCompleter!.future;
    } catch (e) {
      isSubmitting.value = false;
      Get.snackbar(
        'Payment Gateway Notice',
        e.toString().replaceAll('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFFEF3F2),
        colorText: const Color(0xFFD92D20),
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
      return null;
    }
  }

  /// 4b. Verification & Settlement Callback via POST /api/v1/bookings/razorpay/verify
  Future<BookingPassModel?> _verifyAndFinalizeBooking({
    required String razorpayOrderId,
    required String razorpayPaymentId,
    required String razorpaySignature,
  }) async {
    final pending = _pendingOrder;
    if (pending == null) return null;

    final List<SelectedSlot> slots = (pending['slots'] as List<SelectedSlot>?) ?? List.from(selectedSlots);
    final String holdId = (pending['holdId'] as String?) ?? activeHoldId.value;

    try {
      debugPrint('🚀 [RAZORPAY VERIFY] order: $razorpayOrderId, payId: $razorpayPaymentId, slots: ${slots.length}');
      final pass = await _bookingService.verifyMultiSlotRazorpayPayment(
        slots: slots,
        holdId: holdId,
        razorpayOrderId: razorpayOrderId,
        razorpayPaymentId: razorpayPaymentId,
        razorpaySignature: razorpaySignature,
      );

      _holdTimer?.cancel();
      isHoldingSlot.value = false;
      activeHoldId.value = '';
      selectedSlots.clear();
      selectedSlot.value = null;
      pricingQuote.value = null;
      _pendingOrder = null;
      isSubmitting.value = false;

      // Refresh slot grid
      if (selectedCourt.value != null) {
        loadSlotsForCourt(selectedCourt.value!);
      }
      return pass;
    } catch (e) {
      isSubmitting.value = false;
      Get.snackbar(
        'Verification Notice',
        'Could not verify Razorpay signature: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade50,
        colorText: Colors.red.shade900,
      );
      return null;
    }
  }

  void _handleNativePaymentSuccess(PaymentSuccessResponse response) async {
    final pass = await _verifyAndFinalizeBooking(
      razorpayOrderId: response.orderId ?? (_pendingOrder?['orderId'] ?? ''),
      razorpayPaymentId: response.paymentId ?? '',
      razorpaySignature: response.signature ?? '',
    );
    if (_pendingBookingCompleter != null && !_pendingBookingCompleter!.isCompleted) {
      _pendingBookingCompleter!.complete(pass);
    }
    if (pass != null) {
      Get.off(() => DigitalPassScreen(pass: pass));
    }
  }

  void _handleNativePaymentError(PaymentFailureResponse response) {
    isSubmitting.value = false;
    Get.snackbar(
      'Payment Notice',
      response.message ?? 'Payment transaction was cancelled or declined.',
      snackPosition: SnackPosition.BOTTOM,
    );
    if (_pendingBookingCompleter != null && !_pendingBookingCompleter!.isCompleted) {
      _pendingBookingCompleter!.complete(null);
    }
  }

  void _handleNativeExternalWallet(ExternalWalletResponse response) {
    isSubmitting.value = false;
    Get.snackbar(
      'External Wallet',
      'Redirecting to external wallet: ${response.walletName}',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  /// Step 1: Quick Customer Registration & Smart Auto-Match by Phone
  Future<bool> registerGuestCustomer({
    required String phone,
    required String name,
    String? email,
  }) async {
    // If currently authenticated as a student or coach, NEVER register as guest customer or overwrite session
    final currentRole = await _storage.getUserRole();
    if (currentRole == 'student' ||
        currentRole == 'coach' ||
        currentRole == 'trainer' ||
        isStudentOrCoach) {
      debugPrint('ℹ️ [BOOKING] Authenticated $currentRole session active. Skipping guest registration.');
      customerPhone.value = phone.trim();
      customerName.value = name.trim();
      if (email != null && email.trim().isNotEmpty) customerEmail.value = email.trim();
      isGuestRegistered.value = true;
      return true;
    }

    if (phone.trim().length < 10) {
      Get.snackbar(
        'Invalid Mobile',
        'Please enter a valid 10-digit mobile number',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }
    if (name.trim().isEmpty) {
      Get.snackbar(
        'Name Required',
        'Please enter your full name',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }

    isRegisteringGuest.value = true;
    try {
      final res = await _bookingService.guestRegister(
        phone: phone.trim(),
        name: name.trim(),
        email: email?.trim(),
      );

      if (res != null && res['accessToken'] != null) {
        customerPhone.value = phone.trim();
        customerName.value = name.trim();
        customerEmail.value = (email ?? '').trim();
        isGuestRegistered.value = true;
        isExistingCustomer.value = res['isExistingCustomer'] == true;
        await _storage.saveUserName(name.trim());

        final isExisting = res['isExistingCustomer'] == true;
        Get.snackbar(
          isExisting ? 'Welcome Back!' : 'Profile Created!',
          isExisting
              ? 'Returning customer profile matched seamlessly.'
              : 'Guest player session initialized successfully.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFF0F172A),
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
        return true;
      }
      return false;
    } catch (e) {
      Get.snackbar(
        'Registration Notice',
        e.toString().replaceAll('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade50,
        colorText: Colors.red.shade900,
      );
      return false;
    } finally {
      isRegisteringGuest.value = false;
    }
  }

  /// 4c. Direct Booking via POST /api/v1/bookings (or /bookings/multi)
  Future<BookingPassModel?> proceedBooking({
    String paymentMethod = 'WALLET',
    String notes = 'Direct mobile booking',
  }) async {
    if (selectedSlots.isEmpty && selectedCourt.value != null && selectedSlot.value != null) {
      final court = selectedCourt.value!;
      final slot = selectedSlot.value!;
      final dateStr = DateFormat('yyyy-MM-dd').format(selectedDate.value);
      selectedSlots.add(SelectedSlot(
        resourceId: court.id,
        courtName: court.name,
        sportName: court.sport,
        date: dateStr,
        startTime: slot.startTime,
        endTime: slot.endTime,
        timeText: slot.timeText,
        price: slot.price,
      ));
    }
    if (selectedSlots.isEmpty) return null;

    isSubmitting.value = true;
    try {
      final pass = await _bookingService.confirmMultiSlotCheckout(
        slots: selectedSlots,
        holdId: activeHoldId.value,
        paymentMethod: paymentMethod,
        notes: notes,
      );

      _holdTimer?.cancel();
      isHoldingSlot.value = false;
      activeHoldId.value = '';
      selectedSlots.clear();
      selectedSlot.value = null;
      pricingQuote.value = null;

      if (selectedCourt.value != null) {
        loadSlotsForCourt(selectedCourt.value!);
      }
      return pass;
    } catch (e) {
      Get.snackbar(
        'Booking Notice',
        e.toString().replaceAll('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFFEF3F2),
        colorText: const Color(0xFFD92D20),
      );
      return null;
    } finally {
      isSubmitting.value = false;
    }
  }

  /// Direct Student Personal Booking via POST /api/v1/bookings or /api/v1/bookings/multi
  /// Follows exact backend contract: JWT authentication, clean body, optional sibling assignment
  Future<BookingPassModel?> confirmStudentBooking({
    String? paymentMethod,
    String? notes,
  }) async {
    if (selectedSlots.isEmpty && (selectedCourt.value == null || selectedSlot.value == null)) {
      return null;
    }

    if (selectedSlots.isEmpty && selectedCourt.value != null && selectedSlot.value != null) {
      final court = selectedCourt.value!;
      final slot = selectedSlot.value!;
      final dateStr = DateFormat('yyyy-MM-dd').format(selectedDate.value);
      selectedSlots.add(SelectedSlot(
        resourceId: court.id,
        courtName: court.name,
        sportName: court.sport,
        date: dateStr,
        startTime: slot.startTime,
        endTime: slot.endTime,
        timeText: slot.timeText,
        price: slot.price,
      ));
    }

    isSubmitting.value = true;
    try {
      // Sibling assignment check
      String? siblingId;
      final currentPrimaryId = await _storage.getStudentId();
      if (selectedSibling.value != null &&
          selectedSibling.value!.studentId.isNotEmpty &&
          selectedSibling.value!.studentId != currentPrimaryId) {
        siblingId = selectedSibling.value!.studentId;
      }

      final pass = await _bookingService.confirmStudentBooking(
        slots: selectedSlots,
        holdId: activeHoldId.value,
        paymentMethod: paymentMethod ?? selectedPaymentMethod.value,
        notes: (notes != null && notes.isNotEmpty) ? notes : bookingNotes.value,
        siblingStudentId: siblingId,
      );

      _holdTimer?.cancel();
      isHoldingSlot.value = false;
      activeHoldId.value = '';
      selectedSlots.clear();
      selectedSlot.value = null;
      pricingQuote.value = null;

      if (selectedCourt.value != null) {
        loadSlotsForCourt(selectedCourt.value!);
      }

      return pass;
    } catch (e) {
      Get.snackbar(
        'Booking Notice',
        e.toString().replaceAll('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFFEF2F2),
        colorText: const Color(0xFF991B1B),
      );
      return null;
    } finally {
      isSubmitting.value = false;
    }
  }

  /// Backward-compatible alias directing straight to Razorpay
  Future<BookingPassModel?> confirmBooking({String? paymentMethod}) async {
    return payWithRazorpay();
  }

  @override
  void onClose() {
    _holdTimer?.cancel();
    if (!kIsWeb) {
      _razorpay?.clear();
    }
    super.onClose();
  }
}
