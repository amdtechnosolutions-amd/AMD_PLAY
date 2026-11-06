import 'package:get/get.dart';
import '../../attendance/presentation/controllers/attendance_controller.dart';
import '../../booking/presentation/controllers/court_booking_controller.dart';
import '../../home/presentation/controllers/home_controller.dart';
import '../presentation/controllers/main_nav_controller.dart';

class MainNavBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<MainNavController>(MainNavController());
    Get.put<HomeController>(HomeController());
    Get.lazyPut<CourtBookingController>(() => CourtBookingController());
    Get.lazyPut<AttendanceController>(() => AttendanceController());
  }
}
