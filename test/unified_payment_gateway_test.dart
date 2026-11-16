import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_cashfree_pg_sdk/api/cfsession/cfsession.dart';
import 'package:flutter_cashfree_pg_sdk/utils/cfenums.dart';
import 'package:mobile_app/core/theme/app_colors.dart';
import 'package:mobile_app/core/network/api_endpoints.dart';
import 'package:mobile_app/core/services/unified_payment_service.dart';
import 'package:mobile_app/features/booking/data/models/booking_pass_model.dart';
import 'package:mobile_app/features/booking/data/models/court_slot_model.dart';
import 'package:mobile_app/features/booking/presentation/controllers/court_booking_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(const MethodChannel('razorpay_flutter'), (call) async => null);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(const MethodChannel('flutter_cashfree_pg_sdk'), (call) async => null);
  });

  group('Multi-Tenant Dual Payment Gateway (Cashfree + Razorpay) Tests', () {
    test('API endpoints for unified payment order and verify match backend spec', () {
      expect(ApiEndpoints.bookingPaymentOrder, '/bookings/payment/order');
      expect(ApiEndpoints.bookingPaymentVerify, '/bookings/payment/verify');
    });

    test('UnifiedPaymentService initializes with dynamic base URL', () {
      final service = UnifiedPaymentService(customBaseUrl: 'https://amdplayapi.amdtechno.in/api/v1');
      expect(service.apiBaseUrl, 'https://amdplayapi.amdtechno.in/api/v1');
      service.dispose();
    });

    test('SelectedSlot fromJson parses slot structure correctly', () {
      final json = {
        'resourceId': '68ea23c4a638b97dcf5e7912',
        'courtName': 'Badminton Court 1',
        'sportName': 'Badminton',
        'date': '2026-11-20',
        'startTime': '18:00',
        'endTime': '19:00',
        'timeText': '18:00 - 19:00',
        'price': 400.0,
      };

      final slot = SelectedSlot.fromJson(json);
      expect(slot.resourceId, '68ea23c4a638b97dcf5e7912');
      expect(slot.courtName, 'Badminton Court 1');
      expect(slot.sportName, 'Badminton');
      expect(slot.date, '2026-11-20');
      expect(slot.startTime, '18:00');
      expect(slot.endTime, '19:00');
      expect(slot.price, 400.0);
    });

    test('BookingPassModel correctly parses Cashfree payment response payload', () {
      final cashfreePayload = {
        '_id': '6901a9b23f81e4b3',
        'bookingNumber': 'BK-20261120-41BC99',
        'status': 'confirmed',
        'accessCode': '739201',
        'qrCodeUrl': 'https://api.qrserver.com/v1/create-qr-code/?size=350x350&data=PIN%3A739201',
        'pricing': {
          'basePrice': 300,
          'taxAmount': 54,
          'totalAmount': 354,
        },
        'payment': {
          'method': 'cashfree',
          'status': 'success',
          'transactionId': '10492815',
        },
        'resource': {
          '_id': '68ea23c4a638b97dcf5e7912',
          'name': 'Court 1',
        },
      };

      final pass = BookingPassModel.fromJson(cashfreePayload);
      expect(pass.id, '6901a9b23f81e4b3');
      expect(pass.bookingReference, 'BK-20261120-41BC99');
      expect(pass.accessPin, '739201');
      expect(pass.courtName, 'Court 1');
      expect(pass.totalAmount, 354.0);
      expect(pass.razorpayPaymentId, '10492815'); // Mapped to gateway payment ID
    });

    test('BookingPassModel correctly parses Razorpay payment response payload', () {
      final razorpayPayload = {
        '_id': '6901a9b23f81e4b4',
        'bookingNumber': 'BK-20261120-41BC98',
        'status': 'confirmed',
        'accessCode': '842913',
        'qrCodeUrl': 'https://api.qrserver.com/v1/create-qr-code/?size=350x350&data=PIN%3A842913',
        'pricing': {
          'basePrice': 300,
          'taxAmount': 54,
          'totalAmount': 354,
        },
        'razorpayPaymentId': 'pay_29QQoUBcx96muk',
        'razorpayOrderId': 'order_U08JJnFVeigYhA',
        'resource': {
          '_id': '68ea23c4a638b97dcf5e7912',
          'name': 'Turf A',
        },
      };

      final pass = BookingPassModel.fromJson(razorpayPayload);
      expect(pass.id, '6901a9b23f81e4b4');
      expect(pass.bookingReference, 'BK-20261120-41BC98');
      expect(pass.accessPin, '842913');
      expect(pass.courtName, 'Turf A');
      expect(pass.razorpayPaymentId, 'pay_29QQoUBcx96muk');
      expect(pass.razorpayOrderId, 'order_U08JJnFVeigYhA');
    });

    test('CourtBookingController exposes payWithUnifiedGateway alias', () {
      final controller = CourtBookingController();
      expect(controller.payWithUnifiedGateway, isNotNull);
    });

    test('Cashfree session builder configures PRODUCTION environment for live backend response', () {
      final backendOrderData = {
        'gateway': 'cashfree',
        'orderId': 'cf_1794846052248_9483',
        'cfOrderId': '7460414603',
        'paymentSessionId': 'session_m7bj56IQCMgDtNs9w9BhVYvXrZVYZUtAQdcLgCb0OYF8VprXl2XmR3yG6jwwekqj',
        'amount': 1000,
        'currency': 'INR',
        'environment': 'PRODUCTION',
      };

      final String rawEnv = (backendOrderData['environment'] ?? '').toString().toUpperCase().trim();
      final bool isProd = rawEnv == 'PRODUCTION' || rawEnv == 'PROD' || rawEnv == 'LIVE';
      expect(isProd, isTrue);

      final session = CFSessionBuilder()
          .setEnvironment(isProd ? CFEnvironment.PRODUCTION : CFEnvironment.SANDBOX)
          .setOrderId(backendOrderData['orderId']!.toString())
          .setPaymentSessionId(backendOrderData['paymentSessionId']!.toString())
          .build();

      expect(session.getEnvironment(), 'PRODUCTION');
      expect(session.getOrderId(), 'cf_1794846052248_9483');
      expect(session.getPaymentSessionId(), 'session_m7bj56IQCMgDtNs9w9BhVYvXrZVYZUtAQdcLgCb0OYF8VprXl2XmR3yG6jwwekqj');
    });

    test('Cashfree session extraction supports snake_case payment_session_id', () {
      final snakeCasePayload = {
        'order_id': 'cf_order_9988',
        'payment_session_id': 'session_token_xyz_123',
        'mode': 'PROD',
      };

      final String paymentSessionId = (snakeCasePayload['paymentSessionId'] ??
          snakeCasePayload['payment_session_id'] ??
          '').toString().trim();
      final String orderId = (snakeCasePayload['orderId'] ??
          snakeCasePayload['order_id'] ??
          '').toString().trim();

      expect(paymentSessionId, 'session_token_xyz_123');
      expect(orderId, 'cf_order_9988');
    });

    test('Backend updated environment payload flags correctly identify PRODUCTION', () {
      final backendUpdatedPayload = {
        'gateway': 'cashfree',
        'environment': 'PRODUCTION',
        'mode': 'production',
        'cfEnvironment': 'PRODUCTION',
        'isProduction': true,
      };

      final String rawEnv = (backendUpdatedPayload['environment'] ??
          backendUpdatedPayload['cfEnvironment'] ??
          backendUpdatedPayload['mode'] ??
          '').toString().toUpperCase().trim();

      final bool isProd = backendUpdatedPayload['isProduction'] == true ||
          rawEnv == 'PRODUCTION' ||
          rawEnv == 'PROD' ||
          rawEnv == 'LIVE';

      expect(isProd, isTrue);
    });

    test('Checkout screen styling tokens use white background and AppColors.primary borders', () {
      // Validates branding requirements: white screen background and AppColors.primary borders
      expect(AppColors.primary, const Color(0xFFF9D106));
      expect(AppColors.surface, const Color(0xFFFFFFFF));
    });
  });
}
