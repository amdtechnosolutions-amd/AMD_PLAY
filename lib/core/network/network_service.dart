import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

/// Centralized service monitoring real-time network connectivity across the app.
class NetworkService extends GetxService {
  static NetworkService get to => Get.find<NetworkService>();

  final InternetConnection _internetConnection = InternetConnection();
  StreamSubscription<InternetStatus>? _subscription;

  final RxBool isConnected = true.obs;
  final Rx<InternetStatus> connectionStatus = InternetStatus.connected.obs;

  bool _initialCheckDone = false;

  Future<NetworkService> init() async {
    try {
      final initialStatus = await _internetConnection.internetStatus;
      connectionStatus.value = initialStatus;
      isConnected.value = initialStatus == InternetStatus.connected;
    } catch (_) {
      isConnected.value = true;
    }
    _initialCheckDone = true;

    _subscription = _internetConnection.onStatusChange.listen((status) {
      final wasConnected = isConnected.value;
      connectionStatus.value = status;
      final connected = status == InternetStatus.connected;
      isConnected.value = connected;

      // Only notify user after initial startup check to avoid flashing alerts on launch
      if (_initialCheckDone && wasConnected != connected) {
        _notifyStatusChange(connected);
      }
    });

    return this;
  }

  void _notifyStatusChange(bool online) {
    if (Get.context == null) return;

    if (Get.isSnackbarOpen) {
      Get.closeCurrentSnackbar();
    }

    Get.rawSnackbar(
      snackPosition: SnackPosition.TOP,
      backgroundColor: online ? const Color(0xFF10B981) : const Color(0xFFEF4444),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      borderRadius: 12,
      duration: Duration(seconds: online ? 3 : 5),
      messageText: Row(
        children: [
          Icon(
            online ? Icons.wifi_rounded : Icons.wifi_off_rounded,
            color: Colors.white,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              online
                  ? 'Internet connection restored'
                  : 'No internet connection. Please check your network.',
              style: const TextStyle(
                fontFamily: 'Nunito',
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Manually trigger a fresh internet connectivity check
  Future<bool> checkConnection() async {
    try {
      final hasInternet = await _internetConnection.hasInternetAccess;
      isConnected.value = hasInternet;
      return hasInternet;
    } catch (_) {
      return isConnected.value;
    }
  }

  @override
  void onClose() {
    _subscription?.cancel();
    super.onClose();
  }
}

