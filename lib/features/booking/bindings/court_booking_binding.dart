import 'package:get/get.dart';
import '../data/services/booking_service.dart';
import '../presentation/controllers/court_booking_controller.dart';

class CourtBookingBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<BookingService>(() => BookingService());
    Get.lazyPut<CourtBookingController>(
      () => CourtBookingController(bookingService: Get.find<BookingService>()),
    );
  }
}
