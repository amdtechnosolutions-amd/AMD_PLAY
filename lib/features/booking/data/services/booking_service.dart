import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/storage/storage_service.dart';
import '../models/court_slot_model.dart';
import '../models/booking_pass_model.dart';

/// Centralized service handling live sport discovery, court slots, 5-minute atomic holds, and booking passes.
class BookingService {
  final ApiClient? _customApiClient;
  BookingService({ApiClient? apiClient}) : _customApiClient = apiClient;

  ApiClient get _apiClient {
    if (_customApiClient != null) return _customApiClient;
    if (Get.isRegistered<ApiClient>()) {
      return Get.find<ApiClient>();
    }
    return ApiClient();
  }

  /// 1. Fetch Sports Catalog from `/api/v1/sports` with automatic fallback to `/api/v1/resources/active`
  Future<List<SportItem>> getSports() async {

    try {
      final res = await _apiClient.dio.get(ApiEndpoints.sports);
      if (res.statusCode == 200 && res.data != null) {
        final rawData = res.data['data'] ?? res.data;
        if (rawData is List && rawData.isNotEmpty) {
          final sports = rawData
              .map((e) => SportItem.fromJson(Map<String, dynamic>.from(e)))
              .where((s) => s.active)
              .toList();
          if (sports.isNotEmpty) {
            return sports;
          }
        }
      }
    } catch (_) {
      // Continue to fallback
    }

    // Dynamic discovery fallback: extract active sports from active courts/resources
    try {
      final resResources = await _apiClient.dio.get(ApiEndpoints.resourcesActive);
      if (resResources.statusCode == 200 && resResources.data != null) {
        final rawData = resResources.data['data'] ?? resResources.data;
        if (rawData is List && rawData.isNotEmpty) {
          final Map<String, SportItem> uniqueSports = {};
          for (final item in rawData) {
            if (item is Map) {
              final sportObj = item['sportId'];
              if (sportObj is Map) {
                final sport = SportItem.fromJson(Map<String, dynamic>.from(sportObj));
                if (sport.id.isNotEmpty && !uniqueSports.containsKey(sport.id)) {
                  uniqueSports[sport.id] = sport;
                }
              }

              // Extract secondary sportIds (e.g. Cricket, Football on multi-sport turf)
              final secondarySports = item['sportIds'];
              if (secondarySports is List) {
                for (final s in secondarySports) {
                  if (s is Map) {
                    final sport = SportItem.fromJson(Map<String, dynamic>.from(s));
                    if (sport.id.isNotEmpty && !uniqueSports.containsKey(sport.id)) {
                      uniqueSports[sport.id] = sport;
                    }
                  }
                }
              }
            }
          }
          if (uniqueSports.isNotEmpty) {
            return uniqueSports.values.toList();
          }
        }
      }
    } catch (_) {
      // Fall through to empty return
    }

    return const [];
  }

  /// 2. Fetch Active Courts / Resources from `/api/v1/resources/active` or `/api/v1/resources`
  Future<List<CourtModel>> getCourts({String? sportId, String? sportCode}) async {
    try {
      final Map<String, dynamic> queryParams = {};
      if (sportId != null && sportId.isNotEmpty) {
        queryParams['sportId'] = sportId;
      }

      final res = await _apiClient.dio.get(
        ApiEndpoints.resourcesActive,
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      if (res.statusCode == 200 && res.data != null) {
        final rawData = res.data['data'] ?? res.data;
        if (rawData is List) {
          final list = rawData
              .map((e) => CourtModel.fromJson(Map<String, dynamic>.from(e)))
              .where((c) {
                if (sportId != null && sportId.isNotEmpty && c.sportId.isNotEmpty) {
                  return c.sportId == sportId;
                }
                if (sportCode != null && sportCode.isNotEmpty && sportCode != 'all') {
                  return c.sportCode.toLowerCase() == sportCode.toLowerCase() ||
                      c.sport.toLowerCase().contains(sportCode.toLowerCase());
                }
                return true;
              })
              .toList();

          return list;
        }
      }
    } catch (_) {
      // Return empty list on failure - no mock data
    }
    return <CourtModel>[];
  }

  /// 3. Fetch Live Slots for a Court and Date from `/api/v1/slots`
  Future<List<SlotModel>> getSlotsForCourt(
    CourtModel court, {
    required String date,
  }) async {
    try {
      final res = await _apiClient.dio.get(
        ApiEndpoints.slots,
        queryParameters: {
          'resourceId': court.id,
          'date': date,
        },
      );

      if (res.statusCode == 200 && res.data != null) {
        final data = res.data['data'] ?? res.data;
        if (data is Map && data['slots'] is List) {
          final rawSlots = data['slots'] as List;
          return rawSlots
              .map((e) => SlotModel.fromJson(Map<String, dynamic>.from(e), courtId: court.id))
              .toList();
        }
      }
    } catch (_) {
      // Return empty list on failure - no mock data
    }
    return <SlotModel>[];
  }

  /// 4. Request a 5-minute atomic distributed hold lock on multiple slots
  Future<MultiSlotHoldResult?> acquireMultiSlotHold({
    required List<SelectedSlot> slots,
  }) async {
    try {
      final res = await _apiClient.dio.post(ApiEndpoints.holdSlot, data: {
        'slots': slots.map((s) => s.toJson()).toList(),
      });
      if (res.statusCode == 200 && res.data != null) {
        final body = res.data['data'] ?? res.data;
        if (body is Map<String, dynamic>) {
          return MultiSlotHoldResult.fromJson(body);
        }
      }
    } catch (_) {}
    return null;
  }

  /// 4b. Single-slot hold backward compatibility
  Future<bool> acquireSlotHold({
    required String courtId,
    required String date,
    required String startTime,
    required String endTime,
  }) async {
    try {
      final res = await _apiClient.dio.post(ApiEndpoints.holdSlot, data: {
        'resourceId': courtId,
        'date': date,
        'startTime': startTime,
        'endTime': endTime,
      });
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  /// 5. Release active multi-slot hold
  Future<bool> releaseMultiSlotHold({
    String? holdId,
    required List<SelectedSlot> slots,
  }) async {
    try {
      final res = await _apiClient.dio.post(ApiEndpoints.releaseSlot, data: {
        if (holdId != null && holdId.isNotEmpty) 'holdId': holdId,
        'slots': slots.map((s) => s.toJson()).toList(),
      });
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  /// 5b. Single-slot release backward compatibility
  Future<bool> releaseSlotHold({
    required String courtId,
    required String date,
    required String startTime,
  }) async {
    try {
      final res = await _apiClient.dio.post(ApiEndpoints.releaseSlot, data: {
        'resourceId': courtId,
        'date': date,
        'startTime': startTime,
      });
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  /// 6. Calculate Price & Taxes for multiple slots via POST /api/v1/slots/calculate-price
  Future<MultiSlotPricingQuote?> calculateMultiSlotPrice({
    required List<SelectedSlot> slots,
  }) async {
    try {
      final res = await _apiClient.dio.post(ApiEndpoints.calculatePrice, data: {
        'slots': slots.map((s) => s.toJson()).toList(),
      });

      if (res.statusCode == 200 && res.data != null) {
        final data = res.data['data'] ?? res.data;
        if (data is Map) {
          return MultiSlotPricingQuote.fromJson(Map<String, dynamic>.from(data));
        }
      }
    } catch (_) {}
    return null;
  }

  /// 6b. Single-slot calculatePrice backward compatibility
  Future<Map<String, dynamic>?> calculatePrice({
    required String courtId,
    required String date,
    required String startTime,
    required String endTime,
  }) async {
    try {
      final res = await _apiClient.dio.post(ApiEndpoints.calculatePrice, data: {
        'resourceId': courtId,
        'date': date,
        'startTime': startTime,
        'endTime': endTime,
      });

      if (res.statusCode == 200 && res.data != null) {
        final data = res.data['data'] ?? res.data;
        if (data is Map) {
          return Map<String, dynamic>.from(data);
        }
      }
    } catch (_) {}
    return null;
  }

  /// 7. Confirm Direct / Wallet / UPI / Cash Multi-Slot Booking via POST /api/v1/bookings
  Future<BookingPassModel> confirmMultiSlotCheckout({
    required List<SelectedSlot> slots,
    String? holdId,
    required String paymentMethod,
    String notes = 'Direct mobile booking',
  }) async {
    try {
      final res = await _apiClient.dio.post(ApiEndpoints.bookings, data: {
        'paymentMethod': paymentMethod,
        if (holdId != null && holdId.isNotEmpty) 'holdId': holdId,
        'slots': slots.map((s) => s.toJson()).toList(),
        'notes': notes,
      });

      if (res.statusCode == 200 || res.statusCode == 201) {
        final bkgData = res.data['data'] ?? res.data;
        if (bkgData is Map) {
          return BookingPassModel.fromJson(Map<String, dynamic>.from(bkgData));
        }
      }

      throw Exception(res.data?['message'] ?? 'Failed to confirm booking');
    } on DioException catch (dioErr) {
      final msg = dioErr.response?.data is Map
          ? (dioErr.response?.data['message'] ?? dioErr.response?.data['error'] ?? 'Booking request failed')
          : 'Unable to connect to booking server';
      throw Exception(msg);
    }
  }

  /// 7b. Single-slot confirmCheckout backward compatibility
  Future<BookingPassModel> confirmCheckout({
    required CourtModel court,
    required SlotModel slot,
    required String date,
    required String paymentMethod,
    String notes = 'Direct mobile booking',
  }) async {
    return confirmMultiSlotCheckout(
      slots: [
        SelectedSlot(
          resourceId: court.id,
          courtName: court.name,
          sportName: court.sport,
          date: date,
          startTime: slot.startTime,
          endTime: slot.endTime,
          timeText: slot.timeText,
          price: slot.price,
        ),
      ],
      paymentMethod: paymentMethod,
      notes: notes,
    );
  }

  /// 8. Create Razorpay Booking Order for Multiple Slots
  Future<Map<String, dynamic>?> createMultiSlotRazorpayOrder({
    required List<SelectedSlot> slots,
    String? holdId,
  }) async {
    try {
      final res = await _apiClient.dio.post(ApiEndpoints.razorpayBookingOrder, data: {
        if (holdId != null && holdId.isNotEmpty) 'holdId': holdId,
        'slots': slots.map((s) => s.toJson()).toList(),
      });

      if ((res.statusCode == 200 || res.statusCode == 201) && res.data != null) {
        final data = res.data['data'] ?? res.data;
        if (data is Map) {
          return Map<String, dynamic>.from(data);
        }
      }
    } catch (_) {}
    return null;
  }

  /// 8b. Single-slot createRazorpayOrder backward compatibility
  Future<Map<String, dynamic>?> createRazorpayOrder({
    required String courtId,
    required String date,
    required String startTime,
    required String endTime,
  }) async {
    return createMultiSlotRazorpayOrder(
      slots: [
        SelectedSlot(
          resourceId: courtId,
          courtName: '',
          date: date,
          startTime: startTime,
          endTime: endTime,
        ),
      ],
    );
  }

  /// 9. Verify Razorpay Payment & Confirm Bookings for Multiple Slots
  Future<BookingPassModel?> verifyMultiSlotRazorpayPayment({
    required List<SelectedSlot> slots,
    String? holdId,
    required String razorpayOrderId,
    required String razorpayPaymentId,
    required String razorpaySignature,
    String notes = '',
  }) async {
    try {
      final res = await _apiClient.dio.post(ApiEndpoints.razorpayBookingVerify, data: {
        'razorpayOrderId': razorpayOrderId,
        'razorpay_order_id': razorpayOrderId,
        'razorpayPaymentId': razorpayPaymentId,
        'razorpay_payment_id': razorpayPaymentId,
        'razorpaySignature': razorpaySignature,
        'razorpay_signature': razorpaySignature,
        if (holdId != null && holdId.isNotEmpty) 'holdId': holdId,
        'slots': slots.map((s) => s.toJson()).toList(),
        if (notes.isNotEmpty) 'notes': notes,
      });

      if ((res.statusCode == 200 || res.statusCode == 201) && res.data != null) {
        final bkgData = res.data['data'] ?? res.data;
        if (bkgData is Map) {
          return BookingPassModel.fromJson(Map<String, dynamic>.from(bkgData));
        }
      }
    } catch (e) {
      // ignore: avoid_print
      print('❌ [VERIFY PAYMENT ERROR]: $e');
    }
    return null;
  }

  /// 9b. Single-slot verifyRazorpayPayment backward compatibility
  Future<BookingPassModel?> verifyRazorpayPayment({
    required CourtModel court,
    required SlotModel slot,
    required String date,
    required String razorpayOrderId,
    required String razorpayPaymentId,
    required String razorpaySignature,
  }) async {
    return verifyMultiSlotRazorpayPayment(
      slots: [
        SelectedSlot(
          resourceId: court.id,
          courtName: court.name,
          sportName: court.sport,
          date: date,
          startTime: slot.startTime,
          endTime: slot.endTime,
          timeText: slot.timeText,
          price: slot.price,
        ),
      ],
      razorpayOrderId: razorpayOrderId,
      razorpayPaymentId: razorpayPaymentId,
      razorpaySignature: razorpaySignature,
    );
  }

  /// 10. Fetch Group Sessions via GET /api/v1/bookings/group/:groupId
  Future<Map<String, dynamic>?> getGroupBookings(String groupId) async {
    try {
      final res = await _apiClient.dio.get('${ApiEndpoints.bookingGroup}/$groupId');
      if (res.statusCode == 200 && res.data != null) {
        final body = res.data['data'] ?? res.data;
        if (body is Map<String, dynamic>) return body;
      }
    } catch (_) {}
    return null;
  }

  /// 11. Fetch Consolidated Group Invoice via GET /api/v1/bookings/group/:groupId/invoice
  Future<Map<String, dynamic>?> getGroupInvoice(String groupId) async {
    try {
      final res = await _apiClient.dio.get('${ApiEndpoints.bookingGroup}/$groupId/invoice');
      if (res.statusCode == 200 && res.data != null) {
        final body = res.data['data'] ?? res.data;
        if (body is Map<String, dynamic>) return body;
      }
    } catch (_) {}
    return null;
  }

  /// Step 1: Quick Customer Registration & Smart Auto-Match by Phone via `/api/v1/auth/guest-register`
  Future<Map<String, dynamic>?> guestRegister({
    required String phone,
    required String name,
    String? email,
  }) async {
    try {
      final res = await _apiClient.dio.post(
        ApiEndpoints.guestRegister,
        data: {
          'phone': phone.trim(),
          'name': name.trim(),
          if (email != null && email.trim().isNotEmpty) 'email': email.trim(),
        },
      );

      if ((res.statusCode == 200 || res.statusCode == 201) && res.data != null) {
        final body = res.data['data'] ?? res.data;
        if (body is Map<String, dynamic>) {
          final token = body['accessToken']?.toString() ?? '';
          final user = body['user'] is Map ? body['user'] as Map<String, dynamic> : null;

          if (Get.isRegistered<StorageService>() && token.isNotEmpty) {
            final storage = Get.find<StorageService>();
            await storage.saveUserSession(
              accessToken: token,
              refreshToken: token,
              tenantId: user?['tenantId']?.toString() ?? ApiEndpoints.defaultTenantId,
              branchId: user?['branchId']?.toString(),
              studentId: user?['_id']?.toString() ?? '',
              role: 'customer',
              userName: name.trim(),
              userJson: jsonEncode(user ?? {}),
            );
          }
          return body;
        }
      }
    } on DioException catch (dioErr) {
      final msg = dioErr.response?.data is Map
          ? (dioErr.response?.data['message'] ?? dioErr.response?.data['error'] ?? 'Registration failed')
          : 'Unable to connect to registration server';
      throw Exception(msg);
    } catch (e) {
      throw Exception('Guest registration failed: $e');
    }
    return null;
  }

  /// Bonus: 1-Step Guest Instant Registration & Booking
  Future<BookingPassModel?> registerAndBook({
    required CourtModel court,
    required SlotModel slot,
    required String date,
    required String firstName,
    required String phone,
    String? email,
    String paymentMethod = 'upi',
    String notes = 'First time mobile player',
  }) async {
    try {
      final res = await _apiClient.dio.post(ApiEndpoints.registerAndBook, data: {
        'firstName': firstName,
        'phone': phone,
        'email': email,
        'resourceId': court.id,
        'date': date,
        'startTime': slot.startTime,
        'endTime': slot.endTime,
        'paymentMethod': paymentMethod,
        'notes': notes,
      });

      if ((res.statusCode == 200 || res.statusCode == 201) && res.data != null) {
        final body = res.data['data'] ?? res.data;
        final bkgData = body['booking'] ?? body;
        if (bkgData is Map<String, dynamic>) {
          final pricing = bkgData['pricing'] is Map ? bkgData['pricing'] as Map<String, dynamic> : null;
          final pin = bkgData['accessCode'] ?? bkgData['accessPin'] ?? bkgData['pin'] ?? '741920';
          final bNum = bkgData['bookingNumber'] ?? bkgData['bookingReference'] ?? 'BK-$pin';
          final qrUrl = bkgData['qrCodeUrl'] ?? bkgData['qrPassUrl'] ?? bkgData['qrCode'] ??
              'https://api.qrserver.com/v1/create-qr-code/?size=350x350&data=PIN%3A$pin%3BBK%3A$bNum';

          return BookingPassModel(
            id: bkgData['_id'] ?? bkgData['id'] ?? '',
            bookingReference: bNum,
            courtName: court.name,
            sportName: court.sport,
            dateText: date,
            timeWindow: slot.timeText,
            accessPin: pin,
            qrPassUrl: qrUrl,
            amount: (pricing?['basePrice'] ?? bkgData['basePrice'] ?? slot.price).toDouble(),
            taxAmount: (pricing?['taxAmount'] ?? bkgData['taxAmount'] ?? (slot.price * 0.18).roundToDouble()).toDouble(),
            totalAmount: (pricing?['totalAmount'] ?? bkgData['totalAmount'] ?? (slot.price * 1.18).roundToDouble()).toDouble(),
            status: bkgData['status'] ?? 'CONFIRMED',
          );
        }
      }
    } catch (_) {}
    return null;
  }

  /// 8. Fetch My Bookings from `/api/v1/bookings/my`
  Future<List<BookingPassModel>> getMyBookings() async {
    try {
      final res = await _apiClient.dio.get(ApiEndpoints.myBookings);
      if (res.statusCode == 200 && res.data != null) {
        final list = res.data['data'] ?? res.data;
        if (list is List && list.isNotEmpty) {
          return list.map((e) => BookingPassModel.fromJson(Map<String, dynamic>.from(e))).toList();
        }
      }
    } catch (_) {}
    return <BookingPassModel>[];
  }
}
