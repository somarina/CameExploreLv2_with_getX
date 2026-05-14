import 'package:frontend/app/routes/app_pages.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class SplashScreenController extends GetxController {
  final box = GetStorage();

  @override
  void onReady() {
    super.onReady();

    Future.delayed(const Duration(seconds: 4), () {
      final seenOnboarding = box.read('seenOnboarding') ?? false;

      if (seenOnboarding == true) {
        Get.offAllNamed(Routes.AUTH_SCREEN);
      } else {
        Get.offAllNamed(Routes.ONBOARDING_SCREEN);
      }
    });
  }
}
