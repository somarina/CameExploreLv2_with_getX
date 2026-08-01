// ignore_for_file: unused_local_variable, deprecated_member_use, unused_element

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/reset_password_controller.dart';

class ResetPasswordView extends GetView<ResetPasswordController> {
  const ResetPasswordView({super.key});
  static const primaryColor = Color(0xFF00C17C);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isDark = controller.themeController.isDarkMode.value;

      final Color pageBg = isDark ? Color(0xFF031024) : Color(0xFFF8FAFC);
      final Color titleColor = isDark ? Colors.white : Colors.black87;
      final Color subtitleColor = isDark ? Colors.white70 : Colors.black54;

      return Scaffold(
        backgroundColor: pageBg,
        body: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset("assets/images/angkor_wat.png", fit: BoxFit.cover),

            Container(color: Colors.black.withOpacity(isDark ? .35 : .15)),

            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  vertical: 32,
                  horizontal: 16,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 460),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                      child: Container(
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.white.withOpacity(.08)
                              : Colors.white.withOpacity(.75),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: isDark ? Colors.white24 : Colors.black12,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(.10),
                              blurRadius: 50,
                              spreadRadius: 2,
                              offset: const Offset(0, 20),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(20),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Image.asset(
                                    'assets/icons/logo.png',
                                    width: 70,
                                    height: 70,
                                    fit: BoxFit.cover,
                                  ),
                                  Row(
                                    children: [
                                      _circleIconButton(
                                        icon: isDark
                                            ? Icons.light_mode
                                            : Icons.dark_mode,
                                        isDark: isDark,
                                        onTap:
                                            controller.themeController.toggleTheme,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              SizedBox(height: 8),
                              Center(
                                child: Container(
                                  width: 64,
                                  height: 64,
                                  decoration: BoxDecoration(
                                    color: primaryColor.withOpacity(.12),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Icon(
                                    Icons.lock_reset_outlined,
                                    size: 30,
                                    color: primaryColor,
                                  ),
                                ),
                              ),
                              SizedBox(height: 16),
                              Center(
                                child: Text(
                                  "reset_password_title".tr,
                                  style: _font(
                                    "reset_password_title".tr,
                                    color: titleColor,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              SizedBox(height: 6),
                              Center(
                                child: Text(
                                  "reset_password_subtitle".tr,
                                  textAlign: TextAlign.center,
                                  style: _font(
                                    "reset_password_subtitle".tr,
                                    color: subtitleColor,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                              SizedBox(height: 22),
                              Text(
                                "new_password".tr,
                                style: _font(
                                  "new_password".tr,
                                  color: titleColor,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(height: 8),
                              Obx(
                                () => TextField(
                                  controller: controller.newPasswordController,
                                  obscureText: controller.obscureNewPassword.value,
                                  style: _font(
                                    "new_password".tr,
                                    color: titleColor,
                                    fontSize: 14,
                                  ),
                                  decoration: InputDecoration(
                                    hintText: "enter_new_password".tr,
                                    hintStyle: _font(
                                      "enter_new_password".tr,
                                      color: subtitleColor,
                                      fontSize: 14,
                                    ),
                                    filled: true,
                                    fillColor: isDark
                                        ? Colors.white.withOpacity(.06)
                                        : Colors.black.withOpacity(.04),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 14,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide.none,
                                    ),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        controller.obscureNewPassword.value
                                            ? Icons.visibility_off_outlined
                                            : Icons.visibility_outlined,
                                        color: subtitleColor,
                                        size: 20,
                                      ),
                                      onPressed:
                                          controller.toggleNewPasswordVisibility,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: 16),
                              Text(
                                "confirm_password".tr,
                                style: _font(
                                  "confirm_password".tr,
                                  color: titleColor,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(height: 8),
                              Obx(
                                () => TextField(
                                  controller:
                                      controller.confirmPasswordController,
                                  obscureText:
                                      controller.obscureConfirmPassword.value,
                                  style: _font(
                                    "confirm_password".tr,
                                    color: titleColor,
                                    fontSize: 14,
                                  ),
                                  decoration: InputDecoration(
                                    hintText: "re_enter_new_password".tr,
                                    hintStyle: _font(
                                      "re_enter_new_password".tr,
                                      color: subtitleColor,
                                      fontSize: 14,
                                    ),
                                    filled: true,
                                    fillColor: isDark
                                        ? Colors.white.withOpacity(.06)
                                        : Colors.black.withOpacity(.04),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 14,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide.none,
                                    ),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        controller.obscureConfirmPassword.value
                                            ? Icons.visibility_off_outlined
                                            : Icons.visibility_outlined,
                                        color: subtitleColor,
                                        size: 20,
                                      ),
                                      onPressed: controller
                                          .toggleConfirmPasswordVisibility,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: 6),
                              Text(
                                "password_hint".tr,
                                style: _font(
                                  "password_hint".tr,
                                  color: subtitleColor,
                                  fontSize: 11,
                                ),
                              ),
                              SizedBox(height: 18),
                              Obx(
                                () => ElevatedButton(
                                  onPressed: controller.isLoading.value
                                      ? null
                                      : controller.resetPassword,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: primaryColor,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    elevation: 0,
                                  ),
                                  child: controller.isLoading.value
                                      ? SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white,
                                          ),
                                        )
                                      : Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.lock_outline,
                                              size: 18,
                                            ),
                                            SizedBox(width: 8),
                                            Text(
                                              'reset_password_button'.tr,
                                              style: _font(
                                                'reset_password_button'.tr,
                                                color: Colors.white,
                                                fontSize: 15,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  bool _isKhmerText(String text) {
    return RegExp(r'[\u1780-\u17FF]').hasMatch(text);
  }

  TextStyle _font(
    String text, {
    required Color color,
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.normal,
  }) {
    return _isKhmerText(text)
        ? GoogleFonts.googleSans(
            color: color,
            fontSize: fontSize,
            fontWeight: fontWeight,
          )
        : GoogleFonts.spaceGrotesk(
            color: color,
            fontSize: fontSize,
            fontWeight: fontWeight,
          );
  }

  Widget _circleIconButton({
    required IconData icon,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: CircleAvatar(
        backgroundColor: isDark
            ? Colors.white.withOpacity(.10)
            : Colors.black.withOpacity(.06),
        radius: 16,
        child: Icon(
          icon,
          color: isDark ? Colors.white : Colors.black87,
          size: 16,
        ),
      ),
    );
  }
}
