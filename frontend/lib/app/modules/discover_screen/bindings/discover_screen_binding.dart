import 'package:get/get.dart';

import '../controllers/discover_screen_controller.dart';

class DiscoverScreenBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DiscoverScreenController>(
      () => DiscoverScreenController(),
    );
  }
}
