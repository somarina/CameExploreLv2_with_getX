part of 'user_profile_screen_view.dart';

class UserProfileScreenViewController extends GetxController {
  /// check login status
  final RxBool isLogin = true.obs;
  var isLoading = false.obs;


  // mock user data
  var userName = "vouchly".obs;
  var email = "vouchly@gmail.com".obs;
  var isdark = true.obs;
  //
  var box = GetStorage();
  @override
  void onClose() {
    // TODO: implement onClose

    super.onClose();
  }

  void login() {
    isLogin.value = true;
  }

  // ------------------ logout -----------------------
  void logout() async {
    try {
      isLoading.value = true;
      // Clear token
      await box.remove("token");
      await box.erase(); // optional: clear all stored data

      isLoading.value = false;
      debugPrint("Success");
      Get.snackbar("Success", "Logout success");

      // Navigate to login screen & clear stack
      Get.offAllNamed(Routes.LOGIN_SCREEN);
    } catch (error) {
      isLoading.value = false;
      debugPrint("Failed");
      Get.snackbar("Failed", "Logout failed");
    }
  }

  // // ------------------ theme -----------------------
  // void changeTheme(ThemeMode mode) async {
  //   await box.write("isdark", mode == ThemeMode.dark ? true : false);
  //   Get.changeThemeMode(mode);
  // }

  // ------------------ Translate -----------------------
  // var isActive = "kmKH".obs;
  void updateLocale(String value) {
    if (value == "khmer") {
      
      Get.updateLocale(Locale("kmKH"),);
     
    } else {
      Get.updateLocale(Locale("enUS"));
     
    }
  }
}
