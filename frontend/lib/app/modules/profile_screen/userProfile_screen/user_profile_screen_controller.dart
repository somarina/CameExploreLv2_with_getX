part of 'user_profile_screen_view.dart';

class UserProfileScreenViewController extends GetxController {
  /// check login status
  final RxBool isLogin = true.obs;
  var isLoading = false.obs;

  var isdark = true.obs;
  //
  var box = GetStorage();

  var authService = AuthServices();

  late UserModel user;

  bool get isGuest => box.read('userMode') == 'guest';
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

    return null;
  }

  Future<void> getProfile() async {
    // Guests have no token — calling this hits a login-only endpoint,
    // which returns 401 and forces a "session expired" bounce to Login.
    if (isGuest) {
      user = UserModel(
        id: '',
        name: 'Guest',
        email: '',
        phone: '',
        avatar: '',
        gender: '',
      );
      isLogin.value = false;
      return;
    }
    isLoading.value = true;
    try {
      var response = await authService.fetchProfile();
      user = UserModel.fromMap(response['data']);
      isLogin.value = true;
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    selectedLanguage.value = box.read("language") ?? "kmKH";
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
      // await box.erase(); // optional: clear all stored data

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

  bool isActive = true;
  final RxString selectedLanguage = 'kmKH'.obs;
  void updateLocale(String value) async {
    selectedLanguage.value = value;

    await box.write("language", value);

    if (value == "kmKH") {
      Get.updateLocale(const Locale("kmKH"));
    } else {
      Get.updateLocale(const Locale("enUS"));
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
}
