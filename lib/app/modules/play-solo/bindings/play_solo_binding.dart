import 'package:get/get.dart';

import '../controllers/play_solo_controller.dart';

class PlaySoloBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PlaySoloController>(
      () => PlaySoloController(),
    );
  }
}
