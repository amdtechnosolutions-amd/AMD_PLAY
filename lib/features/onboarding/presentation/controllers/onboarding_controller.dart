import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/storage/storage_service.dart';

class OnboardingItem {
  final String headline;
  final String subtitle;
  final String sportBadge;
  final String assetPath;
  final IconData sportIcon;

  const OnboardingItem({
    required this.headline,
    required this.subtitle,
    required this.sportBadge,
    required this.assetPath,
    required this.sportIcon,
  });
}

class OnboardingController extends GetxController {
  final StorageService _storage = Get.find<StorageService>();
  final PageController pageController = PageController();
  final RxInt currentPage = 0.obs;

  final List<OnboardingItem> items = const [
    OnboardingItem(
      headline: 'PLAY YOUR GAME',
      subtitle: 'Book world-class badminton courts in seconds with instant slot confirmation.',
      sportBadge: '🏸 Badminton Arena',
      assetPath: 'assets/images/1.jpeg',
      sportIcon: Icons.sports_tennis_rounded,
    ),
    OnboardingItem(
      headline: 'TRAIN. IMPROVE. WIN.',
      subtitle: 'Experience FIFA-grade turf grounds, elite training and live game sessions.',
      sportBadge: '⚽ Premium Sports Turf',
      assetPath: 'assets/images/2.webp',
      sportIcon: Icons.sports_soccer_rounded,
    ),
    OnboardingItem(
      headline: 'ONE APP. EVERY SPORT.',
      subtitle: 'Fast-paced Pickleball, Turf, Badminton, Cricket, Gym and more under one roof.',
      sportBadge: '🏓 Pro Pickleball Court',
      assetPath: 'assets/images/picleball.webp',
      sportIcon: Icons.sports_baseball_rounded,
    ),
  ];

  void onPageChanged(int index) {
    currentPage.value = index;
  }

  void next() {
    if (currentPage.value < items.length - 1) {
      pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOutCubic,
      );
    } else {
      finishOnboarding();
    }
  }

  void finishOnboarding() async {
    await _storage.setHasSeenOnboarding(true);
    Get.offAllNamed(AppRoutes.userSelection);
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }
}
