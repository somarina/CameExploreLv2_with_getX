import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';

import '../controllers/forget_password_controller.dart';
import 'confirm_screen.dart';
import 'otp_screen.dart';
import 'reset_password_screen.dart';

class ForgetPasswordView extends GetView<ForgetPasswordController> {
  const ForgetPasswordView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Colors.white,
      backgroundColor: Get.theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Obx(() {
          switch (controller.currentStep.value) {
            case 1:
              return _EmailStep(controller: controller);
            case 2:
              return const OtpScreen();
            case 3:
              return const ConfirmScreen();
            case 4:
              return const ResetPasswordScreen();
            default:
              return _EmailStep(controller: controller);
          }
        }),
      ),
    );
  }
}

class _EmailStep extends StatelessWidget {
  final ForgetPasswordController controller;

  const _EmailStep({required this.controller});

  @override
  Widget build(BuildContext context) {
    final isEnglish = Get.locale?.languageCode == "enUS";
    final keyboard = MediaQuery.of(context).viewInsets.bottom;
    final keyboardOpen = keyboard > 0;
    final topPad = keyboardOpen ? 8.0 : 0.0;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: AnimatedPadding(
        duration: Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: EdgeInsets.only(top: topPad),
        child: Form(
          key: controller.step1FormKey,
          child: SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            padding: EdgeInsets.fromLTRB(24, 12, 24, keyboard + 16),
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
                    SizedBox(width: 12),
                    Expanded(
                      child: Center(
                        child: Text(
                          "find_account".tr,
                          style: isEnglish
                              ? GoogleFonts.spaceGrotesk(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Get.theme.colorScheme.onSurface,
                                )
                              : GoogleFonts.kantumruyPro(
                                  fontSize: 19,
                                  fontWeight: .bold,
                                  color: Get.theme.colorScheme.onSurface,
                                ),
                        ),
                      ),
                    ),
                    SizedBox(width: 42), // same width as back button
                  ],
                ),

                Center(child: _buildTopImage(context, keyboardOpen)),

                SizedBox(height: 20),

                AnimatedBuilder(
                  animation: controller.shakeController,
                  builder: (context, _) {
                    final t = controller.shakeController.value;

                    final offset =
                        (10 * (1 - t)) * ((t * 10).floor().isEven ? 1 : -1);

                    return Transform.translate(
                      offset: Offset(offset, 0),
                      child: TextFormField(
                        controller: controller.emailOrPhoneController,

                        autovalidateMode: controller.showValidation.value
                            ? AutovalidateMode.always
                            : AutovalidateMode.disabled,

                        style: isEnglish
                            ? GoogleFonts.spaceGrotesk(fontSize: 15)
                            : GoogleFonts.googleSans(fontSize: 15),

                        decoration: InputDecoration(
                          hintText: "enter_email".tr,

                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 16,
                          ),

                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(
                              color: Colors.black54,
                              width: 1.2,
                            ),
                          ),

                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(
                              color: Colors.grey,
                              width: 1.2,
                            ),
                          ),

                          errorStyle: isEnglish
                              ? GoogleFonts.spaceGrotesk(
                                  color: Color(0xFFD32F2F),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  height: 1.4,
                                )
                              : GoogleFonts.googleSans(
                                  color: Color(0xFFD32F2F),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  height: 1.4,
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
                            borderSide: const BorderSide(
                              color: Colors.red,
                              width: 1.8,
                            ),
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
                          final v = (value ?? '').trim();

                          if (v.isEmpty) {
                            return "email_required".tr;
                          }

                          if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(v)) {
                            return "invalid_email".tr;
                          }

                          return null;
                        },
                      ),
                    );
                  },
                ),

                SizedBox(height: 24),

                Center(
                  child: SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: Obx(
                      () => ElevatedButton(
                        onPressed: controller.isLoading.value
                            ? null
                            : controller.requestOtp,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xff009A3F),
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
                                "continue".tr,
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
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Widget _buildTopImage(BuildContext context, bool keyboardOpen) {
  return AnimatedContainer(
    duration: Duration(milliseconds: 200),
    curve: Curves.easeInOut,
    height: keyboardOpen
        ? MediaQuery.of(context).size.height * 0.18
        : MediaQuery.of(context).size.height * 0.32,
    child: Lottie.asset(
      // 'assets/images/forget_password.json',
      'assets/images/animation_forget_password.json',
      fit: BoxFit.contain,
    ),
  );
}
