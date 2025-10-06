import 'package:get/get.dart';

import '../controllers/play_multi_controller.dart';

class PlayMultiBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PlayMultiController>(
      () => PlayMultiController(),
    );
  }
}
