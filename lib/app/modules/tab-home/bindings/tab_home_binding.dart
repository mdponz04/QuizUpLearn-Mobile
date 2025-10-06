import 'package:get/get.dart';

import '../controllers/tab_home_controller.dart';

class TabHomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TabHomeController>(
      () => TabHomeController(),
    );
  }
}
