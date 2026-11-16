import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_cashfree_pg_sdk/api/cfsession/cfsession.dart';
import 'package:flutter_cashfree_pg_sdk/api/cfpaymentgateway/cfpaymentgatewayservice.dart';
import 'package:flutter_cashfree_pg_sdk/api/cfpayment/cfwebcheckoutpayment.dart';
import 'package:flutter_cashfree_pg_sdk/utils/cfenums.dart';
import 'package:flutter_cashfree_pg_sdk/api/cferrorresponse/cferrorresponse.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../network/api_endpoints.dart';
import 'razorpay_bridge.dart';

/// Universal Multi-Tenant Payment Service (Cashfree + Razorpay)
/// Dynamically routes to the tenant academy's configured active gateway.
class UnifiedPaymentService {
  final CFPaymentGatewayService _cfService = CFPaymentGatewayService();
  Razorpay? _razorpay;

  final String apiBaseUrl;

  // State holders for active payment session
  Map<String, dynamic>? _activeBookingData;
  String? _userToken;
  String? _tenantId;
  Function(Map<String, dynamic> booking)? _onSuccess;
  Function(String error)? _onError;

  UnifiedPaymentService({String? customBaseUrl})
      : apiBaseUrl = customBaseUrl ?? ApiEndpoints.baseUrl {
    _initRazorpay();
  }

  void _initRazorpay() {
    try {
      _razorpay = Razorpay();
      _razorpay?.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handleRazorpaySuccess);
      _razorpay?.on(Razorpay.EVENT_PAYMENT_ERROR, _handleRazorpayError);
      _razorpay?.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleRazorpayExternalWallet);
    } catch (_) {}
  }

  void dispose() {
    _razorpay?.clear();
  }

  /// Master Payment Dispatcher
  Future<void> initiateBookingPayment({
    required BuildContext context,
    required Map<String, dynamic> bookingData,
    String? token,
    String? tenantId,
    required Function(Map<String, dynamic> booking) onSuccess,
    required Function(String error) onError,
  }) async {
    _activeBookingData = bookingData;
    _userToken = token;
    _tenantId = tenantId;
    _onSuccess = onSuccess;
    _onError = onError;

    try {
      final Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
      if (tenantId != null && tenantId.isNotEmpty) {
        headers['X-Tenant-ID'] = tenantId;
      } else {
        headers['X-Tenant-ID'] = ApiEndpoints.defaultTenantId;
      }

      // 1. Initialize Order from Backend
      final url = Uri.parse('$apiBaseUrl/bookings/payment/order');
      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(bookingData),
      );

      final Map<String, dynamic> result = jsonDecode(response.body);
      if (result['success'] != true) {
        onError(result['message'] ?? 'Failed to initialize payment');
        return;
      }

      final orderData = result['data'] is Map ? Map<String, dynamic>.from(result['data']) : <String, dynamic>{};
      final String gateway = (orderData['gateway'] ?? 'razorpay').toString().toLowerCase();

      // -------------------------------------------------------------
      // 2A. Tenant uses CASHFREE
      // -------------------------------------------------------------
      if (gateway == 'cashfree') {
        _launchCashfreePayment(orderData);
      }
      // -------------------------------------------------------------
      // 2B. Tenant uses RAZORPAY
      // -------------------------------------------------------------
      else {
        _launchRazorpayPayment(orderData);
      }
    } catch (e) {
      onError('Payment error: $e');
    }
  }

  // --- Cashfree Mobile Flow ---
  void _launchCashfreePayment(Map<String, dynamic> orderData) {
    _cfService.setCallback(
      // Cashfree success callback
      (String orderId) async {
        await _verifyPayment({
          'gateway': 'cashfree',
          'orderId': orderId,
          ...?_activeBookingData,
        });
      },
      // Cashfree error callback
      (CFErrorResponse error, String orderId) {
        if (_onError != null) {
          _onError!(error.getMessage() ?? 'Cashfree payment cancelled or failed');
        }
      },
    );

    final String rawEnv = (orderData['environment'] ??
        orderData['cfEnvironment'] ??
        orderData['mode'] ??
        '').toString().toUpperCase().trim();
    final bool isProd = orderData['isProduction'] == true ||
        rawEnv == 'PRODUCTION' ||
        rawEnv == 'PROD' ||
        rawEnv == 'LIVE' ||
        (rawEnv.isEmpty && ApiEndpoints.isProduction);

    final String orderId = (orderData['orderId'] ??
        orderData['order_id'] ??
        orderData['cfOrderId'] ??
        orderData['cf_order_id'] ??
        '').toString().trim();

    final String paymentSessionId = (orderData['paymentSessionId'] ??
        orderData['payment_session_id'] ??
        orderData['paymentSessionToken'] ??
        orderData['payment_session_token'] ??
        orderData['session_id'] ??
        orderData['sessionId'] ??
        orderData['token'] ??
        '').toString().trim();

    // Handle mock gateway if present
    if (paymentSessionId.contains('mock') || orderId.contains('mock')) {
      debugPrint('🧪 [MOCK CASHFREE] Completing test payment directly...');
      _verifyPayment({
        'gateway': 'cashfree',
        'orderId': orderId,
        ...?_activeBookingData,
      });
      return;
    }

    if (paymentSessionId.isEmpty) {
      if (_onError != null) {
        _onError!('Payment session token is missing from Cashfree server response');
      }
      return;
    }

    debugPrint('🚀 [CASHFREE CHECKOUT] session: $paymentSessionId, orderId: $orderId, env: ${isProd ? "PRODUCTION" : "SANDBOX"}');

    if (kIsWeb) {
      openWebCashfree(
        paymentSessionId: paymentSessionId,
        orderId: orderId,
        isProd: isProd,
        onSuccess: (cfOrderId) async {
          await _verifyPayment({
            'gateway': 'cashfree',
            'orderId': cfOrderId.isNotEmpty ? cfOrderId : orderId,
            ...?_activeBookingData,
          });
        },
        onFailure: (errorMessage) {
          if (_onError != null) {
            _onError!(errorMessage);
          }
        },
      );
      return;
    }

    final CFSession session = CFSessionBuilder()
        .setEnvironment(isProd ? CFEnvironment.PRODUCTION : CFEnvironment.SANDBOX)
        .setOrderId(orderId)
        .setPaymentSessionId(paymentSessionId)
        .build();

    final CFWebCheckoutPayment cfPayment = CFWebCheckoutPaymentBuilder()
        .setSession(session)
        .build();

    _cfService.doPayment(cfPayment);
  }

  // --- Razorpay Mobile Flow ---
  void _launchRazorpayPayment(Map<String, dynamic> orderData) {
    final String orderId = orderData['orderId']?.toString() ?? '';
    final String keyId = orderData['keyId']?.toString() ?? '';
    final int amountInPaise = orderData['amountInPaise'] != null
        ? (orderData['amountInPaise'] as num).toInt()
        : ((orderData['amount'] as num? ?? 0) * 100).toInt();

    // Check mock
    final bool isMock = keyId.isEmpty || keyId.contains('mock') || keyId == 'rzp_test_mock';
    if (isMock) {
      debugPrint('🧪 [MOCK RAZORPAY] Completing test payment directly...');
      _verifyPayment({
        'gateway': 'razorpay',
        'razorpay_order_id': orderId,
        'razorpay_payment_id': 'pay_mock_${DateTime.now().millisecondsSinceEpoch}',
        'razorpay_signature': 'mock_signature',
        ...?_activeBookingData,
      });
      return;
    }

    final Map<String, dynamic> options = {
      'key': keyId,
      'amount': amountInPaise,
      'name': 'Sports Academy',
      'order_id': orderId,
      'prefill': {
        'contact': _activeBookingData?['customer']?['phone'] ?? _activeBookingData?['phone'] ?? '',
        'email': _activeBookingData?['customer']?['email'] ?? _activeBookingData?['email'] ?? '',
        'name': _activeBookingData?['customer']?['name'] ?? _activeBookingData?['name'] ?? 'Player',
      },
      'theme': {'color': '#F9D106'},
    };

    _razorpay?.open(options);
  }

  void _handleRazorpaySuccess(PaymentSuccessResponse response) async {
    await _verifyPayment({
      'gateway': 'razorpay',
      'razorpay_order_id': response.orderId ?? '',
      'razorpay_payment_id': response.paymentId ?? '',
      'razorpay_signature': response.signature ?? '',
      ...?_activeBookingData,
    });
  }

  void _handleRazorpayError(PaymentFailureResponse response) {
    if (_onError != null) {
      _onError!('Payment cancelled or failed (${response.code}): ${response.message}');
    }
  }

  void _handleRazorpayExternalWallet(ExternalWalletResponse response) {
    debugPrint('Razorpay external wallet selected: ${response.walletName}');
  }

  // --- Unified Backend Verification Call ---
  Future<void> _verifyPayment(Map<String, dynamic> verifyPayload) async {
    try {
      final Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };
      if (_userToken != null && _userToken!.isNotEmpty) {
        headers['Authorization'] = 'Bearer $_userToken';
      }
      if (_tenantId != null && _tenantId!.isNotEmpty) {
        headers['X-Tenant-ID'] = _tenantId!;
      } else {
        headers['X-Tenant-ID'] = ApiEndpoints.defaultTenantId;
      }

      final response = await http.post(
        Uri.parse('$apiBaseUrl/bookings/payment/verify'),
        headers: headers,
        body: jsonEncode(verifyPayload),
      );

      final Map<String, dynamic> verifyResult = jsonDecode(response.body);
      if (verifyResult['success'] == true && verifyResult['data'] != null) {
        if (_onSuccess != null) {
          _onSuccess!(Map<String, dynamic>.from(verifyResult['data']));
        }
      } else {
        if (_onError != null) {
          _onError!(verifyResult['message'] ?? 'Payment verification failed');
        }
      }
    } catch (e) {
      if (_onError != null) {
        _onError!('Verification connection error: $e');
      }
    }
  }
}
