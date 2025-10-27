import 'package:get/get.dart';
import 'package:quizkahoot/app/modules/tab-home/controllers/tab_home_controller.dart';

import '../controllers/home_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeController>(
      () => HomeController(),
    );
     Get.lazyPut<TabHomeController>(
      () => TabHomeController(),
    );
  }
}
