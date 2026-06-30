import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../controllers/forget_password_controller.dart';

class ResetPasswordScreen extends GetView<ForgetPasswordController> {
  const ResetPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isEnglish = Get.locale?.languageCode == "enUS";

    return Scaffold(
      backgroundColor: Get.theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Form(
              key: controller.step4FormKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      InkWell(
                        onTap: controller.goBack,
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: const Color(0xff009A3F),
                              width: 1.2,
                            ),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(
                            Icons.arrow_back_ios_new,
                            size: 16,
                            color: Color(0xff009A3F),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Center(
                          child: Text(
                            "reset_password_title".tr,
                            style: isEnglish
                                ? GoogleFonts.spaceGrotesk(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  )
                                : GoogleFonts.googleSans(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 42, height: 42),
                    ],
                  ),

                  SizedBox(height: 32),
                  Text(
                    'Reset New Password',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 18,
                      fontWeight: .bold,
                      color: Get.theme.colorScheme.onSurface,
                    ),
                  ),
                  SizedBox(height: 3),
                  Text(
                    'Create a new password. Make sure it is different from previous passwords for security.',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 14,
                      color: Get.theme.colorScheme.onSurface,
                    ),
                  ),
                  SizedBox(height: 35),

                  Text(
                    "new_password_label".tr,
                    style: isEnglish
                        ? GoogleFonts.spaceGrotesk(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          )
                        : GoogleFonts.googleSans(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                  ),
                  const SizedBox(height: 8),

                  // New Password field
                  Obx(
                    () => TextFormField(
                      controller: controller.passwordController,
                      obscureText: !controller.showPassword.value,
                      style: isEnglish
                          ? GoogleFonts.spaceGrotesk(fontSize: 15)
                          : GoogleFonts.googleSans(fontSize: 15),
                      decoration: InputDecoration(
                        hintText: "new_password_hint".tr,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 16,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            controller.showPassword.value
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: Colors.grey,
                          ),
                          onPressed: () => controller.showPassword.toggle(),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(color: Colors.grey),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(
                            color: Color(0xff009A3F),
                            width: 1.8,
                          ),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(color: Colors.red),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(
                            color: Colors.red,
                            width: 1.8,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if ((value ?? '').isEmpty)
                          return "password_required".tr;
                        if (value!.length < 8) return "password_too_short".tr;
                        return null;
                      },
                    ),
                  ),

                  const SizedBox(height: 20),

                  Text(
                    "confirm_password_label".tr,
                    style: isEnglish
                        ? GoogleFonts.spaceGrotesk(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          )
                        : GoogleFonts.googleSans(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                  ),
                  const SizedBox(height: 8),

                  // Confirm Password field
                  Obx(
                    () => TextFormField(
                      controller: controller.confirmPasswordController,
                      obscureText: !controller.showConfirmPassword.value,
                      style: isEnglish
                          ? GoogleFonts.spaceGrotesk(fontSize: 15)
                          : GoogleFonts.googleSans(fontSize: 15),
                      decoration: InputDecoration(
                        hintText: "confirm_password_hint".tr,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 16,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            controller.showConfirmPassword.value
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: Colors.grey,
                          ),
                          onPressed: () =>
                              controller.showConfirmPassword.toggle(),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(color: Colors.grey),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(
                            color: Color(0xff009A3F),
                            width: 1.8,
                          ),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(color: Colors.red),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(
                            color: Colors.red,
                            width: 1.8,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if ((value ?? '').isEmpty)
                          return "password_required".tr;
                        if (value != controller.passwordController.text) {
                          return "password_mismatch".tr;
                        }
                        return null;
                      },
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Submit button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: Obx(
                      () => ElevatedButton(
                        onPressed: controller.isLoading.value
                            ? null
                            : controller.resetPassword,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xff009A3F),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: controller.isLoading.value
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                "reset_password_btn".tr,
                                style: isEnglish
                                    ? GoogleFonts.spaceGrotesk(
                                        fontSize: 17,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      )
                                    : GoogleFonts.googleSans(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
