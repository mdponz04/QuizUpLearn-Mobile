import 'package:get/get.dart';
import 'package:quizkahoot/app/modules/single-mode/controllers/single_mode_controller.dart';

class SingleModeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SingleModeController>(
      () => SingleModeController(),
    );
  }
}
