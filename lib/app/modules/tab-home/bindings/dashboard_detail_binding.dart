import 'package:get/get.dart';
import '../controllers/dashboard_detail_controller.dart';

class DashboardDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DashboardDetailController>(() => DashboardDetailController());
  }
}

