import 'package:frontend/app/routes/app_pages.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class SplashScreenController extends GetxController {
  final box = GetStorage();

  @override
  void onReady() {
    super.onReady();

    Future.delayed(const Duration(seconds: 2), () {
      final seenOnboarding = box.read('seenOnboarding') ?? false;
      final isLogin = box.read('isLogin') ?? false;
      final userMode = box.read('userMode') ?? '';

      if (isLogin || userMode == 'guest') {
        // Already logged in → skip login, go home
        Get.offAllNamed(Routes.BUTTON_NAVBAR);
      } else if (seenOnboarding) {
        // Seen onboarding but not logged in → go to login
        Get.offAllNamed(Routes.LOGIN_SCREEN);
      } else {
        // First time ever → show onboarding
        Get.offAllNamed(Routes.ONBOARDING_SCREEN);
      }
    });
  }
}
