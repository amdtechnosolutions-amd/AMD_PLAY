import 'package:get/get.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/storage/storage_service.dart';

/// Controller handling splash screen lifecycle, session checks, and initial routing.
class SplashController extends GetxController {
  final StorageService _storageService = Get.find<StorageService>();

  @override
  void onInit() {
    super.onInit();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // 1000ms delay for clean, subtle animation
    await Future.delayed(const Duration(milliseconds: 3100));

    final hasSeenOnboarding = await _storageService.hasSeenOnboarding();
    final accessToken = await _storageService.getAccessToken();

    if (!hasSeenOnboarding) {
      Get.offAllNamed(AppRoutes.onboarding);
    } else if (accessToken != null && accessToken.isNotEmpty) {
      Get.offAllNamed(AppRoutes.mainNav);
    } else {
      Get.offAllNamed(AppRoutes.userSelection);
    }
  }
}
