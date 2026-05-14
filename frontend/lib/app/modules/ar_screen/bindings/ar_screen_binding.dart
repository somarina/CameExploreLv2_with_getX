import 'package:get/get.dart';

import '../controllers/ar_screen_controller.dart';

class ArScreenBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ArScreenController>(
      () => ArScreenController(),
    );
  }
}
