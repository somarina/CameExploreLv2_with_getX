part of 'user_profile_screen_view.dart';

class UserProfileScreenViewController extends GetxController {

  /// check login status
  final RxBool isLogin = true.obs;

  // mock user data
  var userName = "somarinak".obs;
  var email = "somarinak@gmail.com".obs;
  
  void login() {
    isLogin.value = true;
  }

  void logout() {
    isLogin.value = false;
  }
}