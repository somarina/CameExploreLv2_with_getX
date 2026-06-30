import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../controllers/theme_controller.dart';

class LoginScreenController extends GetxController {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final isPasswordVisible = false.obs;
  final rememberMe = true.obs;

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
    Get.snackbar(
      "Login",
      "Login button clicked",
      snackPosition: SnackPosition.BOTTOM,
    );
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