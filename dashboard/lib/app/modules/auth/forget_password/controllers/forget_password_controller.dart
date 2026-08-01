import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../controllers/theme_controller.dart';
import '../../../../core/api/services/dashboard_auth_service.dart';
import '../../otp_verification/bindings/otp_verification_binding.dart';
import '../../otp_verification/views/otp_verification_view.dart';

class ForgetPasswordController extends GetxController {
  final ThemeController themeController = Get.find<ThemeController>();
  final DashboardAuthService authService = DashboardAuthService();

  final TextEditingController emailController = TextEditingController();
  final RxBool isLoading = false.obs;

  @override
  void onClose() {
    emailController.dispose();
    super.onClose();
  }

  Future<void> sendOtpCode() async {
    final email = emailController.text.trim();
    if (email.isEmpty || !GetUtils.isEmail(email)) {
      Get.snackbar(
        'error'.tr,
        'please_enter_valid_email'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    isLoading.value = true;
    try {
      final response = await authService.forgotPasswordService(email: email);
      final success = response is Map && response['result'] == true;
      final message = (response is Map ? response['message'] as String? : null) ??
          'Something went wrong';

      if (!success) {
        Get.snackbar('error'.tr, message, snackPosition: SnackPosition.BOTTOM);
        return;
      }

      Get.snackbar('success'.tr, message, snackPosition: SnackPosition.BOTTOM);

      Get.to(
        () => OtpVerificationView(),
        binding: OtpVerificationBinding(),
        arguments: {'email': email},
      );
    } finally {
      isLoading.value = false;
    }
  }
}
