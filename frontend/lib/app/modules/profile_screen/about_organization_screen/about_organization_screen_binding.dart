import 'package:frontend/app/modules/profile_screen/about_organization_screen/about_organization_screen_controller.dart';
import 'package:get/get.dart';

class AboutOrganizationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AboutOrganizationController>(
      () => AboutOrganizationController(),
    );
  }
}
