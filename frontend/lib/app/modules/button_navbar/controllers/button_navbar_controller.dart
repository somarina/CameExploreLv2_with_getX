import 'package:frontend/app/modules/profile_screen/theme_mode/theme_mode_view.dart';
import 'package:get/get.dart';

class ButtonNavbarController extends GetxController {
    var themeCtrl = Get.find<ThemeModeViewController>();
  var currentIndex = 0.obs;

  void changePage(int index) {
    currentIndex.value = index;
  }
}
