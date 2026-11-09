import 'package:get/get.dart';
import '../presentation/controllers/student_evaluation_controller.dart';

class StudentEvaluationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<StudentEvaluationController>(() => StudentEvaluationController());
  }
}
