import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/forget_password_controller.dart';

class OtpScreen extends GetView<ForgetPasswordController> {
  const OtpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: Get.back,
                    icon: const Icon(Icons.arrow_back_ios),
                  ),
                ],
              ),

              SizedBox(height: 30),

              Text(
                "ផ្ទៀងផ្ទាត់កូដសម្ងាត់",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),

              SizedBox(height: 30),

              Text(
                "បញ្ចូល OTP ដែលផ្ញើទៅអ៊ីមែល ឬលេខទូរស័ព្ទរបស់អ្នក",
                textAlign: TextAlign.center,
              ),

              SizedBox(height: 40),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(
                  6,
                  (index) => SizedBox(
                    width: 45,
                    child: TextField(
                      controller: controller.otpControllers[index],
                      focusNode: controller.otpFocusNodes[index],
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      maxLength: 1,
                      decoration: const InputDecoration(
                        counterText: "",
                      ),
                      onChanged: (value) {
                        controller.handleOtpInput(index, value);
                      },
                    ),
                  ),
                ),
              ),

              SizedBox(height: 20),

              Obx(
                () => Text(
                  controller.resendSeconds.value > 0
                      ? "Resend code in 00:${controller.resendSeconds.value.toString().padLeft(2, '0')}"
                      : "You can resend now",
                ),
              ),

              SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: controller.verifyOtp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff009A3F),
                  ),
                  child: Text(
                    "បន្ត",
                    style: TextStyle(
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