// ignore_for_file: unused_local_variable, deprecated_member_use, unused_element

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/forget_password_controller.dart';

class ForgetPasswordView extends GetView<ForgetPasswordController> {
  const ForgetPasswordView({super.key});
  static const primaryColor = Color(0xFF00C17C);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isDark = controller.themeController.isDarkMode.value;

      final Color pageBg = isDark ? Color(0xFF031024) : Color(0xFFF8FAFC);
      final Color titleColor = isDark ? Colors.white : Colors.black87;
      final Color subtitleColor = isDark ? Colors.white70 : Colors.black54;
      final Color dotInactive =
          isDark ? Colors.white.withOpacity(.3) : Colors.black.withOpacity(.2);

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
                                        icon: Icons.arrow_back,
                                        isDark: isDark,
                                        onTap: () => Get.back(),
                                      ),
                                      SizedBox(width: 8),
                                      _circleIconButton(
                                        icon: isDark
                                            ? Icons.light_mode
                                            : Icons.dark_mode,
                                        isDark: isDark,
                                        onTap: controller.themeController.toggleTheme,
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
                                    color: isDark
                                        ? Colors.white.withOpacity(.10)
                                        : Colors.black.withOpacity(.06),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Icon(
                                    Icons.mail_outline,
                                    size: 30,
                                    color: isDark ? Colors.white70 : Colors.black54,
                                  ),
                                ),
                              ),
                              SizedBox(height: 16),
                              Center(
                                child: Text(
                                  "forget_password_title".tr,
                                  style: _font(
                                    "forget_password_title".tr,
                                    color: titleColor,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              SizedBox(height: 6),
                              Center(
                                child: Text(
                                  "forget_password_subtitlee".tr,
                                  textAlign: TextAlign.center,
                                  style: _font(
                                    "forget_password_subtitlee".tr,
                                    color: subtitleColor,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                              SizedBox(height: 18),
                              Text(
                                "email_address".tr,
                                style: _font(
                                  "email_address".tr,
                                  color: titleColor,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(height: 8),
                              TextField(
                                controller: controller.emailController,
                                keyboardType: TextInputType.emailAddress,
                                style: _font(
                                  "email_address".tr,
                                  color: titleColor,
                                  fontSize: 14,
                                ),
                                decoration: InputDecoration(
                                  hintText: "enter_your_email".tr,
                                  hintStyle: _font(
                                    "enter_your_email".tr,
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
                                ),
                              ),
                              SizedBox(height: 18),
                              Obx(
                                () => ElevatedButton(
                                  onPressed: controller.isLoading.value
                                      ? null
                                      : controller.sendOtpCode,
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
                                            Icon(Icons.mail_outline, size: 18),
                                            SizedBox(width: 8),
                                            Text(
                                              'send_otp_code'.tr,
                                              style: _font(
                                                'send_otp_code'.tr,
                                                color: Colors.white,
                                                fontSize: 15,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                ),
                              ),
                              SizedBox(height: 14),
                              
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
