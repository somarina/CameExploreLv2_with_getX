// ignore_for_file: deprecated_member_use

import 'dart:ui';

import 'package:bounce/bounce.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../routes/app_pages.dart';
import '../controllers/login_screen_controller.dart';

class LoginScreenView extends GetView<LoginScreenController> {
  const LoginScreenView({super.key});
  static const primaryColor = Color(0xFF00C17C);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isDark = controller.themeController.isDarkMode.value;

      final Color pageBg = isDark
          ? Color(0xFF031024)
          : Color(0xFFF8FAFC);
      final Color fieldFill = isDark
          ? Colors.white.withOpacity(.08)
          : Colors.white.withOpacity(.85);
      final Color fieldBorder = isDark
          ? Colors.white.withOpacity(.18)
          : Colors.black.withOpacity(.08);
      final Color fieldText = isDark ? Colors.white : Colors.black87;
      final Color fieldLabel = isDark ? Colors.white60 : Colors.black54;
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
                  constraints: BoxConstraints(
                    maxWidth: 720,
                    maxHeight: 560,
                  ),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final isMobile = constraints.maxWidth < 700;
                      return ClipRRect(
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
                            child: isMobile
                                ? Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      _formPanel(
                                        isDark: isDark,
                                        isMobile: isMobile,
                                        fieldFill: fieldFill,
                                        fieldBorder: fieldBorder,
                                        fieldText: fieldText,
                                        fieldLabel: fieldLabel,
                                        titleColor: titleColor,
                                        subtitleColor: subtitleColor,
                                      ),
                                    ],
                                  )
                                : IntrinsicHeight(
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        Expanded(
                                          child: _formPanel(
                                            isDark: isDark,
                                            isMobile: isMobile,
                                            fieldFill: fieldFill,
                                            fieldBorder: fieldBorder,
                                            fieldText: fieldText,
                                            fieldLabel: fieldLabel,
                                            titleColor: titleColor,
                                            subtitleColor: subtitleColor,
                                          ),
                                        ),
                                        SizedBox(
                                          width: 320,
                                          child: _imageSidePanel(),
                                        ),
                                      ],
                                    ),
                                  ),
                          ),
                        ),
                      );
                    },
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

  Widget _formPanel({
    required bool isDark,
    required bool isMobile,
    required Color fieldFill,
    required Color fieldBorder,
    required Color fieldText,
    required Color fieldLabel,
    required Color titleColor,
    required Color subtitleColor,
  }) {
    return Padding(
      padding: EdgeInsets.all(isMobile ? 20 : 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Image.asset('assets/icons/logo.png',width: 90,height: 90,fit: BoxFit.cover,),
                ],
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
                    icon: isDark ? Icons.light_mode : Icons.dark_mode,
                    isDark: isDark,
                    onTap: controller.themeController.toggleTheme,
                  ),
                ],
              ),
            ],
          ),

          SizedBox(height: isMobile ? 14 : 18),

          Text(
            "welcome_back".tr,
            style: _font(
              "welcome_back".tr,
              color: titleColor,
              fontSize: isMobile ? 22 : 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 3),
          Row(
            children: [
              Text(
                "sign_in_to_continue".tr,
                style: _font(
                  "sign_in_to_continue".tr,
                  color: subtitleColor,
                  fontSize: 13,
                ),
              ),
              SizedBox(width: 5),
              Bounce(
                onTap: () {
                  Get.toNamed(Routes.REGISTER_SCREEM);
                },
                child: Text(
                  "register".tr,
                  style: _font(
                    "register".tr,
                    color: primaryColor,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: isMobile ? 16 : 20),
          _input(
            label: "email".tr,
            controller: controller.emailController,
            fieldFill: fieldFill,
            fieldBorder: fieldBorder,
            fieldText: fieldText,
            fieldLabel: fieldLabel,
          ),
          SizedBox(height: 12),
          Obx(
            () => TextField(
              controller: controller.passwordController,
              obscureText: !controller.isPasswordVisible.value,
              style: _font("password".tr, color: fieldText, fontSize: 14),
              cursorColor: primaryColor,
              decoration: InputDecoration(
                labelText: "password".tr,
                labelStyle: _font("password".tr, color: fieldLabel),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                filled: true,
                fillColor: fieldFill,
                suffixIcon: IconButton(
                  onPressed: controller.togglePassword,
                  icon: Icon(
                    controller.isPasswordVisible.value
                        ? Icons.visibility
                        : Icons.visibility_off,
                    color: fieldLabel,
                    size: 19,
                  ),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: fieldBorder),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: fieldBorder),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: primaryColor, width: 1.4),
                ),
              ),
            ),
          ),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Obx(
                    () => Transform.scale(
                      scale: 0.9,
                      child: Checkbox(
                        value: controller.rememberMe.value,
                        activeColor: primaryColor,
                        onChanged: controller.toggleRemember,
                      ),
                    ),
                  ),

                  Text(
                    "remember_me".tr,
                    style: _font(
                      "remember_me".tr,
                      color: subtitleColor,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
              TextButton(
                onPressed: () {
                  Get.toNamed(Routes.FORGET_PASSWORD);
                },
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                ),
                child: Text(
                  "forgot_password".tr,
                  style: _font(
                    "forgot_password".tr,
                    color: primaryColor,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 6),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: Obx(
              () => ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: controller.isLoading.value ? null : controller.login,
              child: controller.isLoading.value
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.4,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                "sign_in".tr,
                style: _font(
                  "sign_in".tr,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ),
            ),
            ),

          SizedBox(height: 14),
        ],
      ),
    );
  }

  Widget _socialCircleButton({
    required String imagePath,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(26),
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isDark ? Colors.white.withOpacity(.08) : Colors.white,
          border: Border.all(
            color: isDark ? Colors.white12 : Colors.grey.shade300,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.06),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        padding: const EdgeInsets.all(10),
        child: Image.asset(imagePath, fit: BoxFit.contain),
      ),
    );
  } 

  Widget _imageSidePanel() {
    return Padding(
      padding: const EdgeInsets.all(2),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Image.asset("assets/images/angkor_wat.png", fit: BoxFit.cover),
      ),
    );
  }

  Widget _input({
    required String label,
    required TextEditingController controller,
    required Color fieldFill,
    required Color fieldBorder,
    required Color fieldText,
    required Color fieldLabel,
  }) {
    return TextField(
      controller: controller,
      style: _font(label, color: fieldText, fontSize: 14),
      cursorColor: primaryColor,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: _font(label, color: fieldLabel),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        filled: true,
        fillColor: fieldFill,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: fieldBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: fieldBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: primaryColor, width: 1.4),
        ),
      ),
    );
  }
}