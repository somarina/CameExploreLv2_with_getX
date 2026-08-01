import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../controllers/theme_controller.dart';
import '../../../../core/api/services/dashboard_auth_service.dart';
import '../../reset_password/views/reset_password_view.dart';
import '../../reset_password/bindings/reset_password_binding.dart';

class OtpVerificationController extends GetxController {
  final ThemeController themeController = Get.find<ThemeController>();
  final DashboardAuthService authService = DashboardAuthService();

  late final String email;

  final int codeLength = 6;
  late final List<TextEditingController> otpControllers;
  late final List<FocusNode> focusNodes;

  final RxBool isLoading = false.obs;
  final RxInt secondsRemaining = 30.obs;
  Timer? _timer;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    email = (args is Map && args['email'] != null) ? args['email'] as String : '';

    otpControllers = List.generate(codeLength, (_) => TextEditingController());
    focusNodes = List.generate(codeLength, (_) => FocusNode());

    _startTimer();
  }

  @override
  void onClose() {
    _timer?.cancel();
    for (final c in otpControllers) {
      c.dispose();
    }
    for (final f in focusNodes) {
      f.dispose();
    }
    super.onClose();
  }

  void _startTimer() {
    secondsRemaining.value = 30;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (secondsRemaining.value <= 1) {
        secondsRemaining.value = 0;
        timer.cancel();
      } else {
        secondsRemaining.value--;
      }
    });
  }

  bool get canResend => secondsRemaining.value == 0;

  String get maskedEmail {
    if (!email.contains('@')) return email;
    final parts = email.split('@');
    final name = parts[0];
    final visible = name.length > 2 ? name.substring(0, 2) : name;
    return '$visible***@${parts[1]}';
  }

  void onDigitChanged(String value, int index) {
    if (value.isNotEmpty && index < codeLength - 1) {
      focusNodes[index + 1].requestFocus();
    }
    if (value.isEmpty && index > 0) {
      focusNodes[index - 1].requestFocus();
    }
  }

  String get _code => otpControllers.map((c) => c.text).join();

  Future<void> resendCode() async {
    if (!canResend) return;

    final response = await authService.forgotPasswordService(email: email);
    final success = response is Map && response['result'] == true;
    final message = (response is Map ? response['message'] as String? : null) ??
        'Something went wrong';

    Get.snackbar(
      success ? 'success'.tr : 'error'.tr,
      message,
      snackPosition: SnackPosition.BOTTOM,
    );

    if (success) {
      for (final c in otpControllers) {
        c.clear();
      }
      focusNodes.first.requestFocus();
      _startTimer();
    }
  }

  Future<void> verifyCode() async {
    if (_code.length < codeLength) {
      Get.snackbar(
        'error'.tr,
        'please_enter_full_code'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    isLoading.value = true;
    try {
      final code = _code;
      final response = await authService.verifyOtpService(email: email, otp: code);
      final success = response is Map && response['result'] == true;
      final message = (response is Map ? response['message'] as String? : null) ??
          'Something went wrong';

      if (!success) {
        Get.snackbar('error'.tr, message, snackPosition: SnackPosition.BOTTOM);
        return;
      }

      Get.off(
        () => const ResetPasswordView(),
        binding: ResetPasswordBinding(),
        arguments: {'email': email, 'otp': code},
      );
    } finally {
      isLoading.value = false;
    }
  }
}
