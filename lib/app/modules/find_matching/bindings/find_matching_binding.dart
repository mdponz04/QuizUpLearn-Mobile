import 'package:get/get.dart';

import '../controllers/find_matching_controller.dart';

class FindMatchingBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<FindMatchingController>(
      () => FindMatchingController(),
    );
  }
}
