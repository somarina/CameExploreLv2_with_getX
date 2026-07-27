// ignore_for_file: unused_local_variable, deprecated_member_use, unused_element

import 'dart:ui';

import 'package:dashboard/app/modules/auth/register_screen/controllers/register_screen_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class PersonalRegisterScreenView extends GetView<RegisterScreenController> {
  const PersonalRegisterScreenView({super.key});

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
                          padding: const EdgeInsets.all(20),
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
