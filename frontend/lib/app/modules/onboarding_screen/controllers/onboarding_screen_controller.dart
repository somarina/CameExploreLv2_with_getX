import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../../../routes/app_pages.dart';

class OnboardingScreenController extends GetxController {
  final PageController pageController = PageController();
  final RxInt currentPage = 0.obs;
  final box = GetStorage();

  Timer? autoTimer;

  @override
  void onInit() {
    super.onInit();
    _startAutoSlide();
  }

  void _startAutoSlide() {
    autoTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (currentPage.value < 2) {
        nextPage();
      } else {
        autoTimer?.cancel();
      }
    });
  }

  void onPageChanged(int index) {
    currentPage.value = index;
  }

  void nextPage() {
    pageController.nextPage(
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeInOut,
    );
  }

  void skip() {
    finishOnboarding();
  }

  void finishOnboarding() {
    box.write('seenOnboarding', true);
    Get.offAllNamed(Routes.AUTH_SCREEN);
  }

  @override
  void onClose() {
    autoTimer?.cancel();
    pageController.dispose();
    super.onClose();
  }
}
