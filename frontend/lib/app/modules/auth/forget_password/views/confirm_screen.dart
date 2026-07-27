import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../controllers/forget_password_controller.dart';

class ConfirmScreen extends GetView<ForgetPasswordController> {
  const ConfirmScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isEnglish = Get.locale?.languageCode == "enUS";

    return Scaffold(
      backgroundColor: Get.theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
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
                          color: Color(0xff009A3F),
                          width: 1.2,
                        ),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        Icons.arrow_back_ios_new,
                        size: 16,
                        color: Color(0xff009A3F),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        "confirm_title".tr,
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
                  SizedBox(width: 42, height: 42),
                ],
              ),

              SizedBox(height: 40),

              Text(
                "confirm_reset_title".tr,
                style: isEnglish
                    ? GoogleFonts.spaceGrotesk(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                )
                    : GoogleFonts.googleSans(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              SizedBox(height: 12),
 
              Text(
                "confirm_reset_subtitle".tr,
                style: isEnglish
                    ? GoogleFonts.spaceGrotesk(
                  fontSize: 14,
                  color: Colors.grey[700],
                )
                    : GoogleFonts.googleSans(
                  fontSize: 14,
                  color: Colors.grey[700],
                ),
              ),

              SizedBox(height: 40),

              // បញ្ជាក់ — Confirm → go to Reset Password
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () => controller.currentStep.value = 4,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff009A3F),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    "confirm_yes".tr,
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

              SizedBox(height: 12),

              // មិនព្រម — Cancel → go back to Email step
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () => controller.currentStep.value = 1,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    "confirm_no".tr,
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
            ],
          ),
        ),
      ),
    );
  }
}