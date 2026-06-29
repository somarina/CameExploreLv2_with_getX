import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../controllers/forget_password_controller.dart';

class OtpScreen extends GetView<ForgetPasswordController> {
  const OtpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isEnglish = Get.locale?.languageCode == "enUS";

    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.otpFocusNodes[0].requestFocus();
    });

    return Scaffold(
      backgroundColor: Get.theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(left: 24, right: 24),
          child: Column(
            children: [
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
                        "otp_title".tr,
                        style: isEnglish
                            ? GoogleFonts.spaceGrotesk(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              )
                            : GoogleFonts.googleSans(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 42, height: 42),
                ],
              ),
              const SizedBox(height: 30),

              Column(
                children: [
                  Row(
                    children: [
                      Text("otp_subtitle".tr, textAlign: TextAlign.center,style: isEnglish? GoogleFonts.spaceGrotesk(): GoogleFonts.googleSans(fontSize: 16),),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 40),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(
                  6,
                  (index) => ValueListenableBuilder<TextEditingValue>(
                    valueListenable: controller.otpControllers[index],
                    builder: (context, value, child) {
                      final isFilled = value.text.isNotEmpty;
                      return Container(
                        width: 53,
                        height: 70,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(
                            color: isFilled
                                ? const Color(0xff009A3F)
                                : Colors.grey,
                            width: 1.5,
                          ),
                        ),
                        child: TextField(
                          controller: controller.otpControllers[index],
                          focusNode: controller.otpFocusNodes[index],
                          textAlign: TextAlign.center,
                          textAlignVertical: TextAlignVertical.center,
                          keyboardType: TextInputType.number,
                          maxLength: 2,
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 21,
                            fontWeight: FontWeight.w600,
                          ),
                          decoration: const InputDecoration(
                            counterText: "",
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                          ),
                          onChanged: (value) =>
                              controller.handleOtpInput(index, value),
                        ),
                      );
                    },
                  ),
                ),
              ),

              const SizedBox(height: 20),

              Obx(
                () => GestureDetector(
                  onTap: controller.onResendTap,
                  child: Text(
                    controller.resendSeconds.value > 0
                        ? "${'resend_in'.tr} ${controller.resendTimerLabel}"
                        : "resend_now".tr,
                    style: isEnglish
                        ? GoogleFonts.spaceGrotesk(
                            color: controller.resendSeconds.value > 0
                                ? Colors.grey
                                : Color(0xff009A3F),
                            fontSize: 13,
                          )
                        : GoogleFonts.googleSans(
                            color: controller.resendSeconds.value > 0
                                ? Colors.grey
                                : Color(0xff009A3F),
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            // decoration: controller.resendSeconds.value > 0
                            //     ? TextDecoration.none
                            //     : TextDecoration.underline,
                          ),
                  ),
                ),
              ),

              SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: Obx(
                  () => ElevatedButton(
                    onPressed: controller.isLoading.value
                        ? null
                        : controller.verifyOtp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xff009A3F),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: controller.isLoading.value
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            "continue".tr,
                            style: isEnglish
                                ? GoogleFonts.spaceGrotesk(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  )
                                : GoogleFonts.kantumruyPro(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                          ),
                  ),
                ),
              ),
              
              SizedBox(height: 10),

            ],
          ),
        ),
      ),
    );
  }
}
