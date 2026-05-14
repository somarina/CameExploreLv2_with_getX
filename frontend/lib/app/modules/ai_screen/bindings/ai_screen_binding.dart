import 'package:get/get.dart';

import '../controllers/ai_screen_controller.dart';

class AiScreenBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AiScreenController>(
      () => AiScreenController(),
    );
  }
}
