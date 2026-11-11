import 'package:get/get.dart';
import '../../features/auth/bindings/auth_binding.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/login_v2_screen.dart';
import '../../features/auth/presentation/screens/login_v3_screen.dart';
import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/auth/presentation/screens/user_selection_screen.dart';
import '../../features/home/bindings/home_binding.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/main_nav/bindings/main_nav_binding.dart';
import '../../features/main_nav/presentation/screens/main_nav_screen.dart';
import '../../features/onboarding/bindings/onboarding_binding.dart';
import '../../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../../features/splash/bindings/splash_binding.dart';
import '../../features/splash/presentation/screens/splash_screen.dart';
import '../../features/booking/bindings/court_booking_binding.dart';
import '../../features/booking/presentation/screens/court_booking_screen.dart';
import '../../features/booking/presentation/screens/bookings_history_screen.dart';
import '../../features/attendance/bindings/attendance_binding.dart';
import '../../features/attendance/presentation/screens/attendance_screen.dart';
import '../../features/membership/presentation/screens/membership_passes_screen.dart';
import '../../features/coaching/presentation/screens/coaching_batches_screen.dart';
import '../../features/coaching/presentation/screens/student_coaching_report_screen.dart';
import '../../features/coaching/presentation/screens/coach_evaluations_screen.dart';
import '../../features/coaching/presentation/screens/evaluate_student_screen.dart';
import '../../features/coaching/bindings/student_evaluation_binding.dart';
import '../../features/coaching/bindings/coach_evaluation_binding.dart';
import '../../features/siblings/presentation/screens/sibling_families_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/profile/presentation/screens/invoices_receipts_screen.dart';
import 'app_routes.dart';

/// Centralized GetX Page route map.
class AppPages {
  AppPages._();

  static const String initial = AppRoutes.root;

  static final List<GetPage> routes = [
    GetPage(
      name: AppRoutes.root,
      page: () => const SplashScreen(),
      binding: SplashBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashScreen(),
      binding: SplashBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.onboarding,
      page: () => const OnboardingScreen(),
      binding: OnboardingBinding(),
      transition: Transition.rightToLeftWithFade,
    ),
    GetPage(
      name: AppRoutes.userSelection,
      page: () => const UserSelectionScreen(),
      binding: AuthBinding(),
      transition: Transition.rightToLeftWithFade,
    ),
    GetPage(
      name: AppRoutes.roleSelection,
      page: () => const UserSelectionScreen(),
      binding: AuthBinding(),
      transition: Transition.rightToLeftWithFade,
    ),
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginScreen(),
      binding: AuthBinding(),
      transition: Transition.rightToLeftWithFade,
    ),
    GetPage(
      name: AppRoutes.loginV2,
      page: () => const LoginV2Screen(),
      binding: AuthBinding(),
      transition: Transition.rightToLeftWithFade,
    ),
    GetPage(
      name: AppRoutes.loginV3,
      page: () => const LoginV3Screen(),
      binding: AuthBinding(),
      transition: Transition.rightToLeftWithFade,
    ),
    GetPage(
      name: AppRoutes.forgotPassword,
      page: () => const ForgotPasswordScreen(),
      binding: AuthBinding(),
      transition: Transition.rightToLeftWithFade,
    ),
    GetPage(
      name: AppRoutes.attendance,
      page: () => const AttendanceScreen(),
      binding: AttendanceBinding(),
      transition: Transition.rightToLeftWithFade,
    ),
    GetPage(
      name: AppRoutes.mainNav,
      page: () => const MainNavScreen(),
      binding: MainNavBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.home,
      page: () => const HomeScreen(),
      binding: HomeBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.slotBooking,
      page: () => const CourtBookingScreen(),
      binding: CourtBookingBinding(),
      transition: Transition.rightToLeftWithFade,
    ),
    GetPage(
      name: AppRoutes.facilities,
      page: () => const CourtBookingScreen(),
      binding: CourtBookingBinding(),
      transition: Transition.rightToLeftWithFade,
    ),
    GetPage(
      name: AppRoutes.sports,
      page: () => const CourtBookingScreen(),
      binding: CourtBookingBinding(),
      transition: Transition.rightToLeftWithFade,
    ),
    GetPage(
      name: AppRoutes.myBookings,
      page: () => const BookingsHistoryScreen(),
      transition: Transition.rightToLeftWithFade,
    ),
    GetPage(
      name: AppRoutes.membership,
      page: () => const MembershipPassesScreen(),
      transition: Transition.rightToLeftWithFade,
    ),
    GetPage(
      name: AppRoutes.coaching,
      page: () => const CoachingBatchesScreen(),
      transition: Transition.rightToLeftWithFade,
    ),
    GetPage(
      name: AppRoutes.coachingReport,
      page: () => const StudentCoachingReportScreen(),
      binding: StudentEvaluationBinding(),
      transition: Transition.rightToLeftWithFade,
    ),
    GetPage(
      name: AppRoutes.coachEvaluations,
      page: () => const CoachEvaluationsScreen(),
      binding: CoachEvaluationBinding(),
      transition: Transition.rightToLeftWithFade,
    ),
    GetPage(
      name: AppRoutes.evaluateStudent,
      page: () => const EvaluateStudentScreen(),
      binding: CoachEvaluationBinding(),
      transition: Transition.rightToLeftWithFade,
    ),
    GetPage(
      name: AppRoutes.siblings,
      page: () => const SiblingFamiliesScreen(),
      transition: Transition.rightToLeftWithFade,
    ),
    GetPage(
      name: AppRoutes.profile,
      page: () => const ProfileScreen(),
      transition: Transition.rightToLeftWithFade,
    ),
    GetPage(
      name: AppRoutes.invoices,
      page: () => const InvoicesReceiptsScreen(),
      transition: Transition.rightToLeftWithFade,
    ),
  ];
}
