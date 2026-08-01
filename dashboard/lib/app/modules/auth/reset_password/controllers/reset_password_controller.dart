import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../controllers/theme_controller.dart';
import '../../../../core/api/services/dashboard_auth_service.dart';

class ResetPasswordController extends GetxController {
  final ThemeController themeController = Get.find<ThemeController>();
  final DashboardAuthService authService = DashboardAuthService();

  late final String email;
  late final String otp;

  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  final RxBool isLoading = false.obs;
  final RxBool obscureNewPassword = true.obs;
  final RxBool obscureConfirmPassword = true.obs;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    email = (args is Map && args['email'] != null) ? args['email'] as String : '';
    otp = (args is Map && args['otp'] != null) ? args['otp'] as String : '';
  }

  @override
  void onClose() {
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }

  void toggleNewPasswordVisibility() =>
      obscureNewPassword.value = !obscureNewPassword.value;

  void toggleConfirmPasswordVisibility() =>
      obscureConfirmPassword.value = !obscureConfirmPassword.value;

  Future<void> resetPassword() async {
    final newPassword = newPasswordController.text;
    final confirmPassword = confirmPasswordController.text;

    // Backend requires new_password/confirm_password to be 8-72 chars.
    if (newPassword.length < 8) {
      Get.snackbar(
        'error'.tr,
        'password_too_short'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (newPassword != confirmPassword) {
      Get.snackbar(
        'error'.tr,
        'passwords_do_not_match'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    isLoading.value = true;
    try {
      final response = await authService.resetPasswordService(
        email: email,
        otp: otp,
        newPassword: newPassword,
        confirmPassword: confirmPassword,
      );
      final success = response is Map && response['result'] == true;
      final message = (response is Map ? response['message'] as String? : null) ??
          'Something went wrong';

      if (!success) {
        Get.snackbar('error'.tr, message, snackPosition: SnackPosition.BOTTOM);
        return;
      }

      Get.snackbar('success'.tr, message, snackPosition: SnackPosition.BOTTOM);

      // TODO: replace with your actual login route, e.g. Get.offAllNamed('/login').
      Get.until((route) => route.isFirst);
    } finally {
      isLoading.value = false;
    }
  }
}
