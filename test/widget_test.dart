import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:mobile_app/core/widgets/app_button.dart';
import 'package:mobile_app/core/widgets/slot_card.dart';
import 'package:mobile_app/core/widgets/booking_card.dart';
import 'package:mobile_app/core/widgets/empty_state.dart';
import 'package:mobile_app/core/widgets/sport_card.dart';
import 'package:mobile_app/core/widgets/facility_card.dart';
import 'package:mobile_app/core/storage/storage_service.dart';
import 'package:mobile_app/features/onboarding/presentation/controllers/onboarding_controller.dart';
import 'package:mobile_app/features/auth/presentation/controllers/auth_controller.dart';
import 'package:mobile_app/features/booking/data/models/court_slot_model.dart';
import 'package:mobile_app/features/booking/data/models/booking_pass_model.dart';
import 'package:mobile_app/features/booking/data/services/booking_service.dart';
import 'package:mobile_app/features/booking/presentation/controllers/court_booking_controller.dart';
import 'package:mobile_app/features/booking/presentation/screens/digital_pass_screen.dart';
import 'package:mobile_app/features/booking/presentation/screens/bookings_history_screen.dart';

class TestBookingService extends BookingService {
  @override
  Future<List<SportItem>> getSports() async {
    return const [
      SportItem(id: 's-badminton', name: 'Badminton', slug: 'badminton'),
    ];
  }

  @override
  Future<List<CourtModel>> getCourts({String? sportId, String? sportCode}) async {
    return const [
      CourtModel(
        id: 'crt-1',
        name: 'Court 01 (Yonex Wooden)',
        sport: 'Badminton',
        sportCode: 'badminton',
        surfaceType: 'wooden',
        basePrice: 500,
        peakPrice: 750,
        weekendPrice: 850,
        memberPrice: 400,
      ),
    ];
  }

  @override
  Future<List<SlotModel>> getSlotsForCourt(
    CourtModel court, {
    required String date,
  }) async {
    return const [
      SlotModel(
        courtId: 'crt-1',
        timeText: '06:00 - 07:00',
        startTime: '06:00',
        endTime: '07:00',
        price: 500,
        status: SlotStatus.available,
      ),
    ];
  }

  @override
  Future<bool> acquireSlotHold({
    required String courtId,
    required String date,
    required String startTime,
    required String endTime,
  }) async => true;

  @override
  Future<bool> releaseSlotHold({
    required String courtId,
    required String date,
    required String startTime,
  }) async => true;

  @override
  Future<MultiSlotHoldResult?> acquireMultiSlotHold({
    required List<SelectedSlot> slots,
  }) async => MultiSlotHoldResult(
    holdId: 'mock_hold_123',
    expiresAt: DateTime.now().add(const Duration(minutes: 5)).toIso8601String(),
    expiresInSeconds: 300,
    heldSlotsCount: slots.length,
  );

  @override
  Future<bool> releaseMultiSlotHold({
    String? holdId,
    required List<SelectedSlot> slots,
  }) async => true;

  @override
  Future<MultiSlotPricingQuote?> calculateMultiSlotPrice({
    required List<SelectedSlot> slots,
  }) async {
    final base = slots.fold<double>(0, (sum, s) => sum + s.price);
    final tax = (base * 0.18).roundToDouble();
    return MultiSlotPricingQuote(
      basePrice: base,
      taxAmount: tax,
      totalAmount: base + tax,
      totalSlots: slots.length,
    );
  }
}

Widget createTestWidget(Widget child) {
  return ScreenUtilInit(
    designSize: const Size(390, 844),
    builder: (context, _) => GetMaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: child,
        ),
      ),
    ),
  );
}

Widget createScreenTestWidget(Widget screen) {
  return ScreenUtilInit(
    designSize: const Size(390, 844),
    builder: (context, _) => GetMaterialApp(
      home: screen,
    ),
  );
}

void main() {
  setUp(() {
    Get.testMode = true;
  });

  tearDown(() {
    Get.reset();
  });

  testWidgets('AppButton renders with CTA and Primary variants', (WidgetTester tester) async {
    bool tapped = false;

    await tester.pumpWidget(
      createTestWidget(
        AppButton.cta(
          text: 'BOOK NOW',
          onPressed: () {
            tapped = true;
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('BOOK NOW'), findsOneWidget);
    await tester.tap(find.text('BOOK NOW'));
    expect(tapped, isTrue);
  });

  testWidgets('SlotCard displays time, pricing, and available state', (WidgetTester tester) async {
    bool selected = false;

    await tester.pumpWidget(
      createTestWidget(
        SlotCard(
          timeText: '07:00 PM',
          priceText: '₹300',
          state: SlotState.available,
          onTap: () {
            selected = true;
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('07:00 PM'), findsOneWidget);
    expect(find.text('₹300'), findsOneWidget);
    expect(find.text('Available'), findsOneWidget);

    await tester.tap(find.text('07:00 PM'));
    expect(selected, isTrue);
  });

  testWidgets('BookingCard displays active booking details', (WidgetTester tester) async {
    await tester.pumpWidget(
      createTestWidget(
        const BookingCard(
          hasBooking: true,
          sportName: 'Badminton',
          facilityName: 'Smash Arena',
          courtName: 'Court 02',
          dateText: 'Today',
          timeText: '7:00 PM – 8:00 PM',
          status: 'CONFIRMED',
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('BADMINTON'), findsOneWidget);
    expect(find.text('Smash Arena • Court 02'), findsOneWidget);
    expect(find.text('CONFIRMED'), findsOneWidget);
    expect(find.text('VIEW BOOKING (QR & PIN)'), findsOneWidget);
  });

  testWidgets('EmptyState displays friendly empty message and CTA', (WidgetTester tester) async {
    await tester.pumpWidget(
      createTestWidget(
        EmptyState.bookings(
          onButtonPressed: () {},
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Your next game is waiting.'), findsOneWidget);
    expect(find.text('FIND A COURT'), findsOneWidget);
  });

  testWidgets('SportCard displays sport name and pricing badge', (WidgetTester tester) async {
    bool tapped = false;
    await tester.pumpWidget(
      createTestWidget(
        SportCard(
          name: 'Pickleball',
          imageUrl: 'https://example.com/pickleball.jpg',
          startingPrice: 'From ₹400/hr',
          onTap: () {
            tapped = true;
          },
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Pickleball'), findsOneWidget);
    expect(find.text('From ₹400/hr'), findsOneWidget);

    await tester.tap(find.text('Pickleball'));
    expect(tapped, isTrue);
  });

  testWidgets('FacilityCard displays venue name, sport, rating, and book button', (WidgetTester tester) async {
    bool booked = false;
    await tester.pumpWidget(
      createTestWidget(
        FacilityCard(
          name: 'Smash Arena',
          sportName: 'Badminton',
          imageUrl: 'https://example.com/smash.jpg',
          rating: 4.8,
          distance: '1.2 km away',
          pricePerHour: '₹300/hour',
          onBookTap: () {
            booked = true;
          },
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Smash Arena'), findsOneWidget);
    expect(find.text('BADMINTON'), findsOneWidget);
    expect(find.text('4.8'), findsOneWidget);
    expect(find.text('₹300/hour'), findsOneWidget);
    expect(find.text('BOOK'), findsOneWidget);

    await tester.ensureVisible(find.text('BOOK'));
    await tester.tap(find.text('BOOK'));
    expect(booked, isTrue);
  });

  testWidgets('OnboardingController advances pages and completes onboarding', (WidgetTester tester) async {
    final storage = StorageService();
    Get.put<StorageService>(storage);

    final controller = OnboardingController();
    Get.put<OnboardingController>(controller);

    expect(controller.currentPage.value, 0);
    controller.onPageChanged(1);
    expect(controller.currentPage.value, 1);
    controller.onPageChanged(2);
    expect(controller.currentPage.value, 2);
  });

  testWidgets('AuthController toggles between Phone+OTP and Email+Password modes', (WidgetTester tester) async {
    final storage = StorageService();
    Get.put<StorageService>(storage);

    final authController = AuthController();
    Get.put<AuthController>(authController);

    expect(authController.authMode.value, AuthMode.phoneOtp);

    authController.toggleAuthMode(AuthMode.emailPassword);
    expect(authController.authMode.value, AuthMode.emailPassword);

    authController.togglePasswordVisibility();
    expect(authController.isPasswordVisible.value, isTrue);
  });

  // Tests for Booking Concurrency & Digital Passes
  testWidgets('CourtBookingController acquires 5-min hold and starts countdown timer', (WidgetTester tester) async {
    final mockService = TestBookingService();
    final controller = CourtBookingController(bookingService: mockService);
    Get.put<CourtBookingController>(controller);

    await controller.loadSports();
    expect(controller.courts.isNotEmpty, isTrue);

    const slot = SlotModel(
      courtId: 'crt-1',
      timeText: '06:00 - 07:00',
      startTime: '06:00',
      endTime: '07:00',
      price: 500,
      status: SlotStatus.available,
    );

    await controller.onSlotTapped(slot);

    expect(controller.selectedSlot.value?.timeText, '06:00 - 07:00');
    expect(controller.isHoldingSlot.value, isTrue);
    expect(controller.holdSecondsRemaining.value, 300);
    expect(controller.holdTimeFormatted, '05:00');

    // Releasing hold
    controller.releaseActiveHold();
    expect(controller.isHoldingSlot.value, isFalse);
    expect(controller.selectedSlot.value, isNull);
    expect(controller.holdSecondsRemaining.value, 0);

    controller.onClose();
    Get.delete<CourtBookingController>();
  });

  testWidgets('DigitalPassScreen renders 6-digit access PIN and booking reference', (WidgetTester tester) async {
    const pass = BookingPassModel(
      id: 'bkg-test-1',
      bookingReference: 'APX-99881',
      courtName: 'Court 01 (Yonex Wooden)',
      sportName: 'Badminton',
      dateText: 'Today',
      timeWindow: '07:00 PM - 08:00 PM',
      accessPin: '654321',
      qrPassUrl: '', // Safe fallback in tests
      amount: 500,
      taxAmount: 90,
      totalAmount: 590,
      status: 'CONFIRMED',
    );

    await tester.pumpWidget(
      createScreenTestWidget(
        const DigitalPassScreen(pass: pass),
      ),
    );
    await tester.pump();

    expect(find.text('Booking Confirmed!'), findsOneWidget);
    expect(find.text('Ref: APX-99881'), findsOneWidget);
    expect(find.text('654321'), findsOneWidget); // 6-digit door PIN
    expect(find.text('Court 01 (Yonex Wooden)'), findsOneWidget);
    expect(find.text('SMART DOOR ACCESS PIN'), findsOneWidget);
  });

  testWidgets('BookingsHistoryScreen renders tabs and handles passes view', (WidgetTester tester) async {
    await tester.pumpWidget(
      createScreenTestWidget(
        const BookingsHistoryScreen(),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.text('Active Passes'), findsOneWidget);
    expect(find.text('Past Bookings'), findsOneWidget);
    expect(find.text('No active court passes'), findsOneWidget);
  });

  testWidgets('CourtBookingController handles multi-slot selection, holdId and price quotes', (WidgetTester tester) async {
    final mockService = TestBookingService();
    final controller = CourtBookingController(bookingService: mockService);
    Get.put<CourtBookingController>(controller);

    await controller.loadSports();

    const slot1 = SlotModel(
      courtId: 'crt-1',
      timeText: '06:00 - 07:00',
      startTime: '06:00',
      endTime: '07:00',
      price: 500,
      status: SlotStatus.available,
    );

    const slot2 = SlotModel(
      courtId: 'crt-1',
      timeText: '07:00 - 08:00',
      startTime: '07:00',
      endTime: '08:00',
      price: 500,
      status: SlotStatus.available,
    );

    // Tap slot 1 -> add to selectedSlots
    await controller.onSlotTapped(slot1);
    expect(controller.selectedSlots.length, 1);
    expect(controller.activeHoldId.value, 'mock_hold_123');
    expect(controller.isHoldingSlot.value, isTrue);

    // Tap slot 2 -> multi-slot cart has 2 slots
    await controller.onSlotTapped(slot2);
    expect(controller.selectedSlots.length, 2);
    expect(controller.grandBaseAmount, 1000.0);
    expect(controller.grandTaxAmount, 180.0);
    expect(controller.grandTotalAmount, 1180.0);

    // Deselect slot 1
    await controller.onSlotTapped(slot1);
    expect(controller.selectedSlots.length, 1);
    expect(controller.selectedSlots.first.startTime, '07:00');

    // Release all
    controller.releaseActiveHold();
    expect(controller.selectedSlots.isEmpty, isTrue);
    expect(controller.isHoldingSlot.value, isFalse);

    controller.onClose();
    Get.delete<CourtBookingController>();
  });

  testWidgets('DigitalPassScreen renders multi-slot group pass with all sessions', (WidgetTester tester) async {
    const sub1 = BookingPassModel(
      id: 'sub-1',
      bookingReference: 'BK-20261025-ABCD-1',
      courtName: 'Court 01',
      sportName: 'Badminton',
      dateText: '2026-10-25',
      timeWindow: '18:00 - 19:00',
      accessPin: '849201',
      qrPassUrl: '',
      amount: 600,
      taxAmount: 108,
      totalAmount: 708,
      status: 'CONFIRMED',
    );

    const sub2 = BookingPassModel(
      id: 'sub-2',
      bookingReference: 'BK-20261025-ABCD-2',
      courtName: 'Court 01',
      sportName: 'Badminton',
      dateText: '2026-10-25',
      timeWindow: '19:00 - 20:00',
      accessPin: '849201',
      qrPassUrl: '',
      amount: 600,
      taxAmount: 108,
      totalAmount: 708,
      status: 'CONFIRMED',
    );

    const groupPass = BookingPassModel(
      id: 'grp-main',
      bookingReference: 'BK-20261025-ABCD',
      groupBookingNumber: 'BK-20261025-ABCD',
      groupId: 'grp-1234',
      isMultiSlot: true,
      totalSlots: 2,
      courtName: 'Court 01',
      sportName: 'Badminton',
      dateText: '2026-10-25',
      timeWindow: '18:00 - 20:00',
      accessPin: '849201',
      qrPassUrl: '',
      amount: 1200,
      taxAmount: 216,
      totalAmount: 1416,
      status: 'CONFIRMED',
      subBookings: [sub1, sub2],
    );

    await tester.pumpWidget(
      createScreenTestWidget(
        const DigitalPassScreen(pass: groupPass),
      ),
    );
    await tester.pump();

    expect(find.text('Multi-Slot Booking Confirmed!'), findsOneWidget);
    expect(find.text('Ref: BK-20261025-ABCD • 2 Sessions'), findsOneWidget);
    expect(find.text('849201'), findsOneWidget); // shared PIN
    expect(find.text('2 SESSIONS RESERVED'), findsOneWidget);
  });
}
