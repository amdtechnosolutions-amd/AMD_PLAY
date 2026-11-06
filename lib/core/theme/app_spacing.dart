import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Standard 8-pt base spacing scale adapted for screen responsiveness.
class AppSpacing {
  AppSpacing._();

  static double get xs => 4.w;
  static double get sm => 8.w;
  static double get md => 12.w;
  static double get lg => 16.w;
  static double get xl => 20.w;
  static double get xxl => 24.w;
  static double get xxxl => 32.w;
  static double get huge => 48.w;

  // Vertical specific helpers
  static double get vXs => 4.h;
  static double get vSm => 8.h;
  static double get vMd => 12.h;
  static double get vLg => 16.h;
  static double get vXl => 20.h;
  static double get vXxl => 24.h;
  static double get vXxxl => 32.h;
  static double get vHuge => 48.h;
}
