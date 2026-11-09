import 'dart:io';
import 'package:flutter/foundation.dart';

/// Centralized API endpoint constants matching backend routing spec /api/v1/...
class ApiEndpoints {
  ApiEndpoints._();

  // Set to true for live server, or toggle to false for local development
  static const bool isProduction = true;
  static const String liveBaseUrl = 'https://www.amdplayapi.amdtechno.in/api/v1';
  static const String localWebBaseUrl = 'http://localhost:5005/api/v1';
  static const String localAndroidBaseUrl = 'http://10.0.2.2:5005/api/v1';

  // Tenant identifiers for cloud live vs local dev
  static const String liveTenantId = '6ad6bd7fd33a91a36c41ff44';
  static const String localTenantId = '6acaad5a7006e925024a4102';

  static String get defaultTenantId => isProduction ? liveTenantId : localTenantId;

  static String get baseUrl {
    if (isProduction) {
      return liveBaseUrl;
    }
    if (kIsWeb) {
      return localWebBaseUrl;
    }
    try {
      if (Platform.isAndroid) {
        return localAndroidBaseUrl;
      }
    } catch (_) {}
    return localWebBaseUrl;
  }



  // Auth
  static const String studentLogin = '/auth/student/login';
  static const String switchStudentProfile = '/auth/student/switch-profile';
  static const String memberLogin = '/auth/member/login';
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String guestRegister = '/auth/guest-register';
  static const String sendOtp = '/auth/send-otp';
  static const String verifyOtp = '/auth/verify-otp';
  static const String refreshToken = '/auth/refresh';
  static const String me = '/auth/me';

  // Students & Trainees
  static const String studentAttendance = '/students/my/attendance';
  static const String studentSiblings = '/students/my/siblings';
  static const String studentFees = '/students/my/fees';
  static const String markAttendance = '/students/attendance/mark';
  static const String studentEvaluations = '/students/my/evaluations';
  static const String studentLatestEvaluation = '/students/my/evaluations/latest';

  // Sports & Facilities
  static const String sports = '/sports';
  static const String resources = '/resources';
  static const String resourcesActive = '/resources/active';
  static const String facilities = '/facilities';
  static const String facilityDetails = '/facilities/';
  static const String slots = '/slots';
  static const String holdSlot = '/slots/hold';
  static const String multiHoldSlot = '/slots/multi-hold';
  static const String releaseSlot = '/slots/release';
  static const String multiReleaseSlot = '/slots/multi-release';
  static const String calculatePrice = '/slots/calculate-price';

  // Bookings & Access
  static const String bookings = '/bookings';
  static const String bookingsMulti = '/bookings/multi';
  static const String myBookings = '/bookings/my';
  static const String bookingGroup = '/bookings/group';
  static const String razorpayBookingOrder = '/bookings/razorpay/order';
  static const String razorpayBookingVerify = '/bookings/razorpay/verify';
  static const String registerAndBook = '/auth/register-and-book';
  static const String qrPass = '/access/qr';
  static const String pinAccess = '/access/pin';

  // Payments
  static const String createPaymentOrder = '/payments/order';
  static const String verifyPayment = '/payments/verify';

  // Coaching & Membership
  static const String coachingBatches = '/coaching/batches';
  static const String memberships = '/memberships/packages';
  static const String attendance = '/attendance';
  static const String userProfile = '/users/profile';
}
