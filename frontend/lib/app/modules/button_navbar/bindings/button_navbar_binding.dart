import 'package:get/get.dart';

import '../../profile_screen/userProfile_screen/user_profile_screen_view.dart';
import '../controllers/button_navbar_controller.dart';

class ButtonNavbarBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ButtonNavbarController>(
      () => ButtonNavbarController(),
    );
    Get.lazyPut<UserProfileScreenViewController>(
      () => UserProfileScreenViewController(),
    );
  }
}
