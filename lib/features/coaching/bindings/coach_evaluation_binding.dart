import 'package:get/get.dart';
import '../presentation/controllers/coach_evaluation_controller.dart';
import '../presentation/controllers/student_evaluation_controller.dart';

class CoachEvaluationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CoachEvaluationController>(() => CoachEvaluationController());
    Get.lazyPut<StudentEvaluationController>(() => StudentEvaluationController());
  }
}

