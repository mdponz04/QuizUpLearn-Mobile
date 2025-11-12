import 'package:get/get.dart';
import 'package:quizkahoot/app/modules/placement-tests/controllers/placement_tests_controller.dart';
import 'package:quizkahoot/app/modules/single-mode/controllers/single_mode_controller.dart';

class PlacementTestsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PlacementTestsController>(
      () => PlacementTestsController(),
    );
    Get.lazyPut<SingleModeController>(
      () => SingleModeController(),
    );
  }
}

