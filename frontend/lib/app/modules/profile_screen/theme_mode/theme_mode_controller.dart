part of 'theme_mode_view.dart';

class ThemeModeViewController extends GetxController {
  var isDark = Get.isDarkMode.obs;
  var box = GetStorage();

  void changeTheme(bool dark) async {
    selectMode.value = dark ? 1 : 0;

    await box.write("isdark", dark);

    Get.changeThemeMode(dark ? .dark : .light);
  }

  var selectMode = 0.obs;
  //0 is light, 1 is dark

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    // selectMode.value = Get.isDarkMode ? 1 : 0;
    if (box.hasData("isdark")) {
      bool isDarkSaved = box.read("isdark");
      selectMode.value = isDarkSaved ? 1 : 0;
    } else {
      // 2. Fallback to system status if no preference is saved yet
      selectMode.value = Get.isDarkMode ? 1 : 0;
    }

    
  }


  // var isdark = true.obs;
  // var box = GetStorage();
  // void changeTheme(ThemeMode mode) async {
  //   await box.write("isdark", mode == ThemeMode.dark ? true : false);
  //   Get.changeThemeMode(mode);
  // }
}
