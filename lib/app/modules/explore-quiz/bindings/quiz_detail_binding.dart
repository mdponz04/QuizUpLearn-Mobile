import 'package:get/get.dart';
import '../controllers/quiz_detail_controller.dart';
import 'package:quizkahoot/app/modules/single-mode/controllers/single_mode_controller.dart';

class QuizDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<QuizDetailController>(() => QuizDetailController());
    Get.lazyPut<SingleModeController>(() => SingleModeController());
  }
}

