import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../controllers/theme_controller.dart';
import '../../../../routes/app_pages.dart';


class RegisterScreenController extends GetxController {
  final ThemeController themeController = Get.find<ThemeController>();

  // Carousel state for the top image card.
  final PageController pageController = PageController();
  final currentPage = 0.obs;

  final List<String> carouselImages = [
    "assets/images/angkor_wat.png",
    "assets/images/angkor_wat.png",
    "assets/images/angkor_wat.png",
    "assets/images/angkor_wat.png",
  ];

  void onPageChanged(int index) {
    currentPage.value = index;
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }

  void registerAsIndividual() {
    // TODO: navigate to the individual registration form
    Get.toNamed(Routes.PERSONAL_REGISTER_SCREEN);
                                    
  }

  void registerAsTravelAgency() {
    // TODO: navigate to the travel agency / group registration form4
    Get.toNamed(Routes.COMPANY_REGISTER_SCREEN);

  }
}