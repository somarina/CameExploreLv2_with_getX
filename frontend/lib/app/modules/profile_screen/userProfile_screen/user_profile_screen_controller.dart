part of 'user_profile_screen_view.dart';

class UserProfileScreenViewController extends GetxController {
  /// check login status
  final RxBool isLogin = true.obs;
  var isLoading = false.obs;

  // mock user data
  // var userName = "vouchly".obs;
  // var email = "vouchly@gmail.com".obs;
  var isdark = true.obs;
  //
  var box = GetStorage();

  var authService = AuthServices();

  late UserModel user;
  ImageProvider? getAvatar() {
    final u = user;

    final avatar = u.avatar;

    if (avatar.isEmpty) {
      return null;
    }

    // network image
    if (avatar.startsWith("http")) {
      return NetworkImage(avatar);
    }

    // // local file image (image_picker)
    // if (avatar.startsWith("file") || avatar.contains("/")) {
    //   return FileImage(File(avatar));
    // }

    return null;
  }

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();

    getProfile();
  }

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
  // bool isActive = true;
  void updateLocale(String value) async {
    await box.write("language", value);
    if (value == "kmKH") {
      Get.updateLocale(Locale("kmKH"));
      // fonts
      // Get.changeTheme(
      //   ThemeData(textTheme: GoogleFonts.googleSansCodeTextTheme()),
      // );
    } else {
      Get.updateLocale(Locale("enUS"));
    }
  }
  // var selectedLang = 'km'.obs;

  // // late String avatar;

  // void changeLanguage(String value) {
  //   selectedLang.value = value;
  //   updateLocale(value);
  // }

  // void updateLocale(String value) {
  //   if (value == 'km') {
  //     Get.updateLocale(const Locale('km', 'KH'));
  //   } else {
  //     Get.updateLocale(const Locale('en', 'US'));
  //   }
  // }

  Future<void> getProfile() async {
    isLoading.value = true;
    var response = await authService.fetchProfile();
    user = UserModel.fromMap(response['data']);
    isLoading.value = false;
  }
}
