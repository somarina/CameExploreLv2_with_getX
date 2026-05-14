import 'package:get/get.dart';

import '../controllers/button_navbar_controller.dart';

class ButtonNavbarBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ButtonNavbarController>(
      () => ButtonNavbarController(),
    );
  }
}
