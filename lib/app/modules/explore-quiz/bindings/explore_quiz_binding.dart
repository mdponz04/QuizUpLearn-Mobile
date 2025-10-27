import 'package:get/get.dart';
import 'package:quizkahoot/app/modules/explore-quiz/controllers/explore_quiz_controller.dart';
import 'package:quizkahoot/app/modules/single-mode/controllers/single_mode_controller.dart';

class ExploreQuizBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ExploreQuizController>(
      () => ExploreQuizController(),
    );
    Get.lazyPut<SingleModeController>(
      () => SingleModeController(),
    );
  }
}
