import 'package:get/get.dart';

import '../controllers/play_event_controller.dart';

class PlayEventBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PlayEventController>(
      () => PlayEventController(),
    );
  }
}
