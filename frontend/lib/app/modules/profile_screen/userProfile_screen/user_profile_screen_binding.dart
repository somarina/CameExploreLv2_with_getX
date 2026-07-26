part of 'user_profile_screen_view.dart';

class UserProfileScreenViewBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => UserProfileScreenViewController());
    Get.put(() => ThemeModeViewController(), permanent: true);
  }
}
