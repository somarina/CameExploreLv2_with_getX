import 'package:frontend/app/modules/profile_screen/change_pwd_screen/change_pwd_screen_controller.dart';
import 'package:get/get.dart';

class ChangePasswordBinding extends Bindings {
  @override
  void dependencies() {
    // Get.put(ChangePasswordController());
    Get.lazyPut(()=>ChangePasswordController());
  }
}