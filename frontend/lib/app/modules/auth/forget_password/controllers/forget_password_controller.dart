// ignore_for_file: avoid_print

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:frontend/app/core/api/services/auth_services.dart';
import 'package:get/get.dart';

import '../../../../routes/app_pages.dart';

class ForgetPasswordController extends GetxController
    with GetSingleTickerProviderStateMixin {
  final AuthServices _authServices = AuthServices();

  final currentStep = 1.obs;

  final emailOrPhoneController = TextEditingController();
  final step1FormKey = GlobalKey<FormState>();

  late AnimationController shakeController;

  final List<TextEditingController> otpControllers = List.generate(
    6,
        (_) => TextEditingController(),
  );
  final List<FocusNode> otpFocusNodes = List.generate(6, (_) => FocusNode());
  final resendSeconds = 180.obs;
  Timer? _resendTimer;

  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final step4FormKey = GlobalKey<FormState>();
  final showPassword = false.obs;
  final showConfirmPassword = false.obs;

  final isLoading = false.obs;
  final showValidation = false.obs;

  String get emailOrPhone => emailOrPhoneController.text.trim();
  String get otp => otpControllers.map((c) => c.text).join();

  String get resendTimerLabel {
    final total = resendSeconds.value;
    final minutes = total ~/ 60;
    final seconds = total % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  void onInit() {
    super.onInit();
    shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
  }

  void triggerShake() {
    shakeController.forward(from: 0);
  }

  @override
  void onClose() {
    emailOrPhoneController.dispose();
    for (var c in otpControllers) {
      c.dispose();
    }
    for (var f in otpFocusNodes) {
      f.dispose();
    }
    passwordController.dispose();
    confirmPasswordController.dispose();
    _resendTimer?.cancel();
    shakeController.dispose();
    super.onClose();
  }

  // ── Step 1: Request OTP ─────────────────────────────────────────────
  Future<void> requestOtp() async {
    showValidation.value = true;
    await Future.delayed(Duration.zero);
    final isValid = step1FormKey.currentState!.validate();
    if (!isValid) {
      triggerShake();
      return;
    }

    isLoading.value = true;
    try {
      final res = await _authServices.forgotPasswordService(
        email: emailOrPhone,
      );

      if (res != null && res['result'] == true) {
        currentStep.value = 2;
        _startResendTimer();

        for (var c in otpControllers) {
          c.clear();
        }

        Future.delayed(
          const Duration(milliseconds: 300),
              () => otpFocusNodes[0].requestFocus(),
        );
      } else {
        Get.snackbar(
          'otp_invalid'.tr,
          res?['message'] ?? 'try_again'.tr,
          backgroundColor: Colors.red[100],
          colorText: Colors.red[900],
        );
      }
    } catch (e) {
      Get.snackbar(
        'otp_invalid'.tr,
        'connection_error'.tr,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
      );
    } finally {
      isLoading.value = false;
    }
  }

  void _startResendTimer() {
    resendSeconds.value = 180;
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
    await requestOtp();
  }

  void onResendTap() {
    if (resendSeconds.value > 0) return;
    resendOtp();
  }

  // ── Step 2: Verify OTP ─────────────────────────────────────────────
  Future<void> verifyOtp() async {
    if (otp.length < otpControllers.length) {
      Get.snackbar(
        'otp_invalid'.tr,
        'otp_incomplete'.trParams({'count': otpControllers.length.toString()}),
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
        snackPosition: SnackPosition.TOP,
      );
      triggerShake();
      return;
    }

    isLoading.value = true;
    try {
      final res = await _authServices.verifyOtpService(
        email: emailOrPhone,
        otp: otp,
      );

      if (res != null && res['result'] == true) {
        currentStep.value = 3; // ← goes to ConfirmScreen
      } else {
        triggerShake();
        for (var c in otpControllers) {
          c.clear();
        }
        otpFocusNodes[0].requestFocus();

        Get.snackbar(
          'otp_invalid'.tr,
          res?['message'] ?? 'otp_invalid'.tr,
          backgroundColor: Colors.red[100],
          colorText: Colors.red[900],
          snackPosition: SnackPosition.TOP,
        );
      }
    } catch (e) {
      Get.snackbar(
        'otp_invalid'.tr,
        'connection_error'.tr,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // ── Step 4: Reset Password ─────────────────────────────────────────
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

      if (res != null && res['result'] == true) {
        Get.back();
        Get.offAllNamed(Routes.LOGIN_SCREEN);
        Get.snackbar(
          'reset_success'.tr,
          'reset_success'.tr,
          backgroundColor: Colors.green[100],
          colorText: Colors.green[900],
          snackPosition: SnackPosition.TOP,
        );
        
      } else {
        Get.snackbar(
          'otp_invalid'.tr,
          res?['message'] ?? 'try_again'.tr,
          backgroundColor: Colors.red[100],
          colorText: Colors.red[900],
          snackPosition: SnackPosition.TOP,
        );
      }
    } catch (e) {
      Get.snackbar(
        'otp_invalid'.tr,
        'connection_error'.tr,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // ── OTP input behavior ───────────────────────────────────────────────
  void handleOtpInput(int index, String value) {
    if (value.length > 1) {
      final digits = value.replaceAll(RegExp(r'[^0-9]'), '');
      for (var i = 0; i < otpControllers.length; i++) {
        otpControllers[i].text = i < digits.length ? digits[i] : '';
      }
      if (digits.length >= otpControllers.length) {
        FocusManager.instance.primaryFocus?.unfocus();
        verifyOtp();
      } else if (digits.isNotEmpty) {
        otpFocusNodes[digits.length].requestFocus();
      }
      return;
    }

    if (value.length == 1 && index < otpControllers.length - 1) {
      otpFocusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      otpFocusNodes[index - 1].requestFocus();
    }

    if (index == otpControllers.length - 1 && value.isNotEmpty) {
      FocusManager.instance.primaryFocus?.unfocus();
      if (otp.length == otpControllers.length) {
        verifyOtp();
      }
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