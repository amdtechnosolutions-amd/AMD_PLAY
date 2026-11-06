import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/storage/storage_service.dart';

class OnboardingItem {
  final String headline;
  final String subtitle;
  final String imageUrl;
  final IconData sportIcon;

  const OnboardingItem({
    required this.headline,
    required this.subtitle,
    required this.imageUrl,
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
      subtitle: 'Book courts, turfs and sports facilities in seconds with instant confirmation.',
      imageUrl: 'https://images.unsplash.com/photo-1626224583764-f87db24ac4ea?auto=format&fit=crop&w=800&q=80',
      sportIcon: Icons.sports_tennis_rounded,
    ),
    OnboardingItem(
      headline: 'TRAIN. IMPROVE. WIN.',
      subtitle: 'Join top coaching programs, track attendance and manage your sports journey.',
      imageUrl: 'https://images.unsplash.com/photo-1574629810360-7efbbe195018?auto=format&fit=crop&w=800&q=80',
      sportIcon: Icons.fitness_center_rounded,
    ),
    OnboardingItem(
      headline: 'ONE APP. EVERY SPORT.',
      subtitle: 'Badminton, Football, Pickleball, Cricket, Tennis, Swimming, Gym and more.',
      imageUrl: 'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?auto=format&fit=crop&w=800&q=80',
      sportIcon: Icons.sports_soccer_rounded,
    ),
  ];

  void onPageChanged(int index) {
    currentPage.value = index;
  }

  void next() {
    if (currentPage.value < items.length - 1) {
      pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
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
