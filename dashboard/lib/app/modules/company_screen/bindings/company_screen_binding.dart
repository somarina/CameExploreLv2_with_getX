import 'package:get/get.dart';

import '../controllers/company_screen_controller.dart';

class CompanyScreenBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CompanyScreenController>(
      () => CompanyScreenController(),
    );
  }
}
