import 'dart:async';

import 'package:flutter/material.dart';
import 'package:frontend/app/core/api/services/auth_services.dart';
import 'package:get/get.dart';

class ForgetPasswordController extends GetxController {
  final AuthServices _authServices = AuthServices();

  // Step: 1=forgot, 2=otp, 3=confirm, 4=reset
  final currentStep = 1.obs;

  // Step 1
  final emailOrPhoneController = TextEditingController();
  final step1FormKey = GlobalKey<FormState>();

  // Step 2 – OTP
  final List<TextEditingController> otpControllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> otpFocusNodes = List.generate(6, (_) => FocusNode());
  final resendSeconds = 30.obs;
  Timer? _resendTimer;

  // Step 4 – reset
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final step4FormKey = GlobalKey<FormState>();
  final showPassword = false.obs;
  final showConfirmPassword = false.obs;

  final isLoading = false.obs;

  String get emailOrPhone => emailOrPhoneController.text.trim();
  String get otp => otpControllers.map((c) => c.text).join();

  final showValidation = false.obs;

  @override
  void onClose() {
    emailOrPhoneController.dispose();
    for (var c in otpControllers) c.dispose();
    for (var f in otpFocusNodes) f.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    _resendTimer?.cancel();
    super.onClose();
  }

  // ── Step 1: Request OTP ──────────────────────────────────────────────────
  Future<void> requestOtp() async {
    if (!step1FormKey.currentState!.validate()) return;
    isLoading.value = true;
    try {
      final res = await _authServices.forgotPasswordService(
        email: emailOrPhone,
      );
      // ✅ Fixed: check 'result' not 'success'
      if (res != null && res['result'] == true) {
        currentStep.value = 2;
        _startResendTimer();
        Future.delayed(
          const Duration(milliseconds: 300),
          () => otpFocusNodes[0].requestFocus(),
        );
      } else {
        Get.snackbar(
          'កំហុស',
          res?['message'] ?? 'សូមព្យាយាមម្ដងទៀត',
          backgroundColor: Colors.red[100],
          colorText: Colors.red[900],
          snackPosition: SnackPosition.TOP,
        );
      }
    } catch (e) {
      Get.snackbar(
        'កំហុស',
        'មិនអាចភ្ជាប់ម៉ាស៊ីនមេបាន',
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void _startResendTimer() {
    resendSeconds.value = 30;
    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (resendSeconds.value <= 0) {
        t.cancel();
      } else {
        resendSeconds.value--;
      }
    });
  }

  Future<void> resendOtp() async {
    if (resendSeconds.value > 0) return;
    for (var c in otpControllers) c.clear();
    otpFocusNodes[0].requestFocus();
    await requestOtp();
  }

  // ── Step 2: Verify OTP ───────────────────────────────────────────────────
  Future<void> verifyOtp() async {
    if (otp.length < 6) {
      Get.snackbar(
        'កំហុស',
        'សូមបំពេញ OTP ចំនួន 6 ខ្ទង់',
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
        snackPosition: SnackPosition.TOP,
      );
      return;
    }
    isLoading.value = true;
    try {
      final res = await _authServices.verifyOtpService(
        email: emailOrPhone,
        otp: otp,
      );
      // ✅ Fixed: check 'result' not 'success'
      if (res != null && res['result'] == true) {
        currentStep.value = 3;
      } else {
        Get.snackbar(
          'កំហុស',
          res?['message'] ?? 'OTP មិនត្រឹមត្រូវ',
          backgroundColor: Colors.red[100],
          colorText: Colors.red[900],
          snackPosition: SnackPosition.TOP,
        );
      }
    } catch (e) {
      Get.snackbar(
        'កំហុស',
        'មិនអាចភ្ជាប់ម៉ាស៊ីនមេបាន',
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // ── Step 4: Reset Password ───────────────────────────────────────────────
  Future<void> resetPassword() async {
    if (!step4FormKey.currentState!.validate()) return;
    isLoading.value = true;
    try {
      final res = await _authServices.resetPasswordService(
        email: emailOrPhone,
        otp: otp,
        newPassword: passwordController.text,
        confirmPassword: confirmPasswordController.text,
      );
      // ✅ Fixed: check 'result' not 'success'
      if (res != null && res['result'] == true) {
        Get.back();
        Get.snackbar(
          'ជោគជ័យ',
          'ពាក្យសម្ងាត់ត្រូវបានផ្លាស់ប្ដូររួចរាល់',
          backgroundColor: Colors.green[100],
          colorText: Colors.green[900],
          snackPosition: SnackPosition.TOP,
        );
      } else {
        Get.snackbar(
          'កំហុស',
          res?['message'] ?? 'សូមព្យាយាមម្ដងទៀត',
          backgroundColor: Colors.red[100],
          colorText: Colors.red[900],
          snackPosition: SnackPosition.TOP,
        );
      }
    } catch (e) {
      Get.snackbar(
        'កំហុស',
        'មិនអាចភ្ជាប់ម៉ាស៊ីនមេបាន',
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void handleOtpInput(int index, String value) {
    if (value.length == 1 && index < 5) {
      otpFocusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      otpFocusNodes[index - 1].requestFocus();
    }
  }

  void goBack() {
    if (currentStep.value > 1) {
      currentStep.value--;
    } else {
      Get.back();
    }
  }
}
