import 'package:get/get.dart';
import '../controllers/favorite_quiz_controller.dart';

class FavoriteQuizBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<FavoriteQuizController>(
      () => FavoriteQuizController(),
    );
  }
}

