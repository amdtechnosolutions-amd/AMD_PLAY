import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'core/network/api_client.dart';
import 'core/network/network_service.dart';
import 'core/routes/app_pages.dart';
import 'core/storage/storage_service.dart';
import 'core/theme/app_theme.dart';
import 'features/splash/bindings/splash_binding.dart';
import 'features/splash/presentation/screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set preferred orientation to portrait
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  // Initialize core services
  await Get.putAsync<StorageService>(() => StorageService().init());
  await Get.putAsync<NetworkService>(() => NetworkService().init());
  Get.put<ApiClient>(ApiClient(), permanent: true);

  runApp(const SportsAcademyApp());
}

class SportsAcademyApp extends StatelessWidget {
  const SportsAcademyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(390, 844),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return GetMaterialApp(
          title: 'Inertia Sports Academy',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          initialRoute: AppPages.initial,
          getPages: AppPages.routes,
          unknownRoute: GetPage(
            name: '/not-found',
            page: () => const SplashScreen(),
            binding: SplashBinding(),
          ),
          defaultTransition: Transition.fade,
        );
      },
    );
  }
}
