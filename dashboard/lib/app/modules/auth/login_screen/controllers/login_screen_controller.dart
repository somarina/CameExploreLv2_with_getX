import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../../../../controllers/theme_controller.dart';
import '../../../../core/api/services/dashboard_auth_service.dart';
import '../../../../routes/app_pages.dart';

class LoginScreenController extends GetxController {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final isPasswordVisible = false.obs;
  final rememberMe = true.obs;
  final isLoading = false.obs;

  final DashboardAuthService _authService = DashboardAuthService();

  // Shared app-wide theme state — same instance Register and every
  // other screen reads from, so toggling here stays in sync everywhere.
  final ThemeController themeController = Get.find<ThemeController>();

  void togglePassword() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  void toggleRemember(bool? value) {
    rememberMe.value = value ?? false;
  }

  Future<void> login() async {
    final emailOrPhone = emailController.text.trim();
    final password = passwordController.text;

    if (emailOrPhone.isEmpty || password.isEmpty) {
      Get.snackbar(
        "Login",
        "Please enter your email/phone and password",
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    isLoading.value = true;
    final response = await _authService.loginService(
      emailOrPhone: emailOrPhone,
      password: password,
    );
    isLoading.value = false;

    if (response == null) {
      Get.snackbar(
        "Login",
        "Could not reach the server",
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final bool result = response["result"] == true;
    final String message = response["message"] ?? "Something went wrong";

    if (!result) {
      Get.snackbar("Login failed", message, snackPosition: SnackPosition.BOTTOM);
      return;
    }

    final data = response["data"] as Map<String, dynamic>? ?? {};
    final box = GetStorage();
    box.write("dashboard_token", data["token"] ?? "");
    box.write("dashboard_admin_name", data["name"] ?? "");
    box.write("dashboard_active_role", data["active_role"] ?? "");
    box.write("dashboard_email", data["email"] ?? "");

    Get.offAllNamed(Routes.ADMIN_SCREEN);
  }

  void continueWithGoogle() {
    // TODO: wire up real Google sign-in (e.g. google_sign_in package
    // or Firebase Auth GoogleAuthProvider) here.
    Get.snackbar(
      "Google",
      "Continue with Google tapped",
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void continueWithTelegram() {
    // TODO: wire up Telegram Login Widget here. Telegram's web login
    // flow normally embeds https://oauth.telegram.org/auth?bot_id=...
    // (or the widget script from telegram.org/js/telegram-widget.js)
    // inside a webview/iframe — this needs your bot's id + domain
    // registered with @BotFather first.
    Get.snackbar(
      "Telegram",
      "Continue with Telegram tapped",
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}