import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:lottie/lottie.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/api/services/auth_services.dart';
import '../../../../routes/app_pages.dart';

class RegisterScreenController extends GetxController
    with GetTickerProviderStateMixin {
  final box = GetStorage();
  final authServices = AuthServices();

  final formKey = GlobalKey<FormState>();

  final isEnglish = Get.locale?.languageCode == "enUS";

  // ── Text Controllers ──────────────────────────────────────────────────────
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  // ── Observable variables ──────────────────────────────────────────────────
  final gender = 'ប្រុស'.obs;
  final hidePassword = true.obs;
  final hideConfirmPassword = true.obs;
  final isChecked = false.obs;
  final isLoading = false.obs;
  final submitted = false.obs;
  final downSignup = false.obs;
  final downGuest = false.obs;

  // ── Shake Controllers ─────────────────────────────────────────────────────
  late final AnimationController firstNameShakeCtrl;
  late final AnimationController lastNameShakeCtrl;
  late final AnimationController emailShakeCtrl;
  late final AnimationController phoneShakeCtrl;
  late final AnimationController passwordShakeCtrl;
  late final AnimationController confirmPasswordShakeCtrl;

  late final Animation<double> firstNameShake;
  late final Animation<double> lastNameShake;
  late final Animation<double> emailShake;
  late final Animation<double> phoneShake;
  late final Animation<double> passwordShake;
  late final Animation<double> confirmPasswordShake;

  static const int shakeDurationMs = 180;
  static const double shakeDistance = 10;

  @override
  void onInit() {
    super.onInit();
    firstNameShakeCtrl = _makeCtrl();
    lastNameShakeCtrl = _makeCtrl();
    emailShakeCtrl = _makeCtrl();
    phoneShakeCtrl = _makeCtrl();
    passwordShakeCtrl = _makeCtrl();
    confirmPasswordShakeCtrl = _makeCtrl();

    firstNameShake = _makeAnim(firstNameShakeCtrl);
    lastNameShake = _makeAnim(lastNameShakeCtrl);
    emailShake = _makeAnim(emailShakeCtrl);
    phoneShake = _makeAnim(phoneShakeCtrl);
    passwordShake = _makeAnim(passwordShakeCtrl);
    confirmPasswordShake = _makeAnim(confirmPasswordShakeCtrl);
  }

  AnimationController _makeCtrl() => AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: shakeDurationMs),
  );

  Animation<double> _makeAnim(AnimationController ctrl) {
    final items = <TweenSequenceItem<double>>[];
    const int count = 7;
    const double d = shakeDistance;
    for (int i = 0; i < count; i++) {
      items.add(
        TweenSequenceItem<double>(
          tween: Tween<double>(
            begin: i.isEven ? 0 : -d,
            end: i.isEven ? d : -d,
          ),
          weight: 1,
        ),
      );
    }
    items.add(
      TweenSequenceItem<double>(
        tween: Tween<double>(begin: -d, end: 0),
        weight: 1,
      ),
    );
    return TweenSequence(
      items,
    ).animate(CurvedAnimation(parent: ctrl, curve: Curves.easeInOut));
  }

  // ── Helpers ───────────────────────────────────────────────────────────────
  void selectGender(String value) => gender.value = value;
  void togglePassword() => hidePassword.value = !hidePassword.value;
  void toggleConfirmPassword() =>
      hideConfirmPassword.value = !hideConfirmPassword.value;
  void toggleCheckbox(bool? value) => isChecked.value = value ?? false;

  // ── Validators ────────────────────────────────────────────────────────────
  String? validateFirstName(String? value) {
    if (!submitted.value) return null;
    if (value == null || value.trim().isEmpty) return 'សូមបញ្ចូលនាមត្រកូល';
    return null;
  }

  String? validateLastName(String? value) {
    if (!submitted.value) return null;
    if (value == null || value.trim().isEmpty) return 'សូមបញ្ចូលនាមខ្លួន';
    return null;
  }

  String? validateEmail(String? value) {
    if (!submitted.value) return null;
    final v = (value ?? '').trim();
    if (v.isEmpty) return 'សូមបញ្ចូលអ៊ីម៉ែល';
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(v))
      return 'អ៊ីម៉ែលមិនត្រឹមត្រូវ';
    return null;
  }

  String? validatePhone(String? value) {
    if (!submitted.value) return null;
    final v = (value ?? '').trim();
    if (v.isEmpty) return 'សូមបញ្ចូលលេខទូរស័ព្ទ';
    if (!RegExp(r'^(?:\+855|855|0)(?:\d{8,9})$').hasMatch(v)) {
      return 'លេខទូរស័ព្ទមិនត្រឹមត្រូវ';
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (!submitted.value) return null;
    final v = (value ?? '').trim();
    if (v.isEmpty) return 'សូមបញ្ចូលពាក្យសម្ងាត់';
    if (v.length < 8) return 'ពាក្យសម្ងាត់ត្រូវមានយ៉ាងតិច 8 តួអក្សរ';
    if (!RegExp(r'[A-Za-z]').hasMatch(v)) return 'ត្រូវមានអក្សរយ៉ាងហោចណាស់ 1';
    if (!RegExp(r'\d').hasMatch(v)) return 'ត្រូវមានលេខយ៉ាងហោចណាស់ 1';
    return null;
  }

  String? validateConfirmPassword(String? value) {
    if (!submitted.value) return null;
    final v = (value ?? '').trim();
    if (v.isEmpty) return 'សូមបញ្ជាក់ពាក្យសម្ងាត់';
    if (v != passwordController.text.trim()) return 'ពាក្យសម្ងាត់មិនដូចគ្នា';
    return null;
  }

  // ── Save user to storage ──────────────────────────────────────────────────
  void _saveUser(dynamic data) {
    box.write('token', data['token'] ?? '');
    box.write('userId', data['id'] ?? '');
    box.write('userName', data['name'] ?? '');
    box.write('userEmail', data['email'] ?? '');
    box.write('userAvatar', data['avatar'] ?? '');
    box.write('userRole', data['role'] ?? 'user');
    box.write('isLogin', true);
    box.write('userMode', 'user');
  }

  // ── Register ──────────────────────────────────────────────────────────────
  Future<void> register() async {
    if (isLoading.value) return;

    FocusManager.instance.primaryFocus?.unfocus();
    submitted.value = true;

    final isValid = formKey.currentState!.validate();

    // Shake invalid fields
    if (firstNameController.text.trim().isEmpty) {
      firstNameShakeCtrl.forward(from: 0);
    }
    if (lastNameController.text.trim().isEmpty) {
      lastNameShakeCtrl.forward(from: 0);
    }
    if (emailController.text.trim().isEmpty ||
        !RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(emailController.text.trim())) {
      emailShakeCtrl.forward(from: 0);
    }
    if (phoneController.text.trim().isEmpty ||
        !RegExp(
          r'^(?:\+855|855|0)(?:\d{8,9})$',
        ).hasMatch(phoneController.text.trim())) {
      phoneShakeCtrl.forward(from: 0);
    }
    if (passwordController.text.trim().isEmpty ||
        passwordController.text.trim().length < 8) {
      passwordShakeCtrl.forward(from: 0);
    }
    if (confirmPasswordController.text.trim().isEmpty ||
        confirmPasswordController.text.trim() !=
            passwordController.text.trim()) {
      confirmPasswordShakeCtrl.forward(from: 0);
    }

    if (!isValid) return;

    if (!isChecked.value) {
      Get.snackbar(
        'ចុះឈ្មោះ',
        'សូមយល់ព្រមលក្ខខណ្ឌជាមុនសិន',
        snackPosition: SnackPosition.TOP,
        colorText: Colors.white,
      );
      return;
    }

    try {
      isLoading.value = true;

      final name =
          '${firstNameController.text.trim()} ${lastNameController.text.trim()}';

      var response = await authServices.registerService(
        name: name,
        gender: gender.value,
        email: emailController.text.trim(),
        phone: phoneController.text.trim(),
        password: passwordController.text.trim(),
        confirmPassword: confirmPasswordController.text.trim(),
      );

      if (response != null && response['result'] == true) {
        // ← Save user data first
        _saveUser(response['data']);
        _showSuccessDialog();
      } else {
        Get.snackbar(
          'ចុះឈ្មោះបរាជ័យ',
          response?['message'] ?? 'ចុះឈ្មោះបរាជ័យ',
          snackPosition: SnackPosition.TOP,
          // colorText: Colors.white,
        );
      }
    } on DioException catch (e) {
      // ← Extract real error message from backend
      String message = 'ចុះឈ្មោះបរាជ័យ';
      if (e.response?.data != null) {
        message = e.response?.data['message'] ?? message;
      }
      Get.snackbar(
        'ចុះឈ្មោះបរាជ័យ',
        message,
        snackPosition: SnackPosition.TOP,
        // colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'ចុះឈ្មោះបរាជ័យ',
        e.toString(),
        snackPosition: SnackPosition.TOP,
        // colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // ── Google Login ──────────────────────────────────────────────────────────
  Future<void> loginWithGoogle() async {
    if (isLoading.value) return;
    try {
      isLoading.value = true;
      await GoogleSignIn.instance.signOut();
      final googleUser = await GoogleSignIn.instance.authenticate();

      var response = await authServices.googleLoginService(
        googleId: googleUser.id,
        email: googleUser.email,
        name: googleUser.displayName ?? '',
        profileImage: googleUser.photoUrl ?? '',
      );

      if (response != null && response['result'] == true) {
        _saveUser(response['data']);
        Get.offAllNamed('/button-navigation'); // ← fixed route
      } else {
        Get.snackbar(
          'Google Login Failed',
          response?['message'] ?? 'Something went wrong',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } on DioException catch (e) {
      String message = 'Google Login Failed';
      if (e.response?.data != null) {
        message = e.response?.data['message'] ?? message;
      }
      Get.snackbar(
        'Google Login Failed',
        message,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Google Login Failed',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 5),
      );
    } finally {
      isLoading.value = false;
    }
  }

  // ── Telegram Login ────────────────────────────────────────────────────────
  Future<void> loginWithTelegram() async {
    if (isLoading.value) return;

    try {
      isLoading.value = true;

      const botId = '8720092780';
      const origin = 'https://staleness-antirust-shrapnel.ngrok-free.dev';

      final url = Uri.parse(
        'https://oauth.telegram.org/auth'
        '?bot_id=$botId'
        '&origin=$origin'
        '&return_to=camexplore://telegram-login'
        '&request_access=write',
      );

      print('Telegram URL: $url');

      await launchUrl(url, mode: LaunchMode.externalApplication);
    } catch (e) {
      print('TELEGRAM ERROR: $e');

      Get.snackbar(
        'Telegram Login Failed',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // ── Success Dialog ────────────────────────────────────────────────────────
  void _showSuccessDialog() {
    Get.dialog(
      barrierDismissible: false,
      Dialog(
        backgroundColor: const Color.fromARGB(220, 17, 17, 17),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Lottie.asset(
                'assets/images/Done.json',
                width: 130,
                height: 130,
              ),
              SizedBox(height: 16),
              Text(
                'គណនីរបស់អ្នកត្រូវបានបង្កើតឡើងជោគជ័យ',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    Get.back();
                    Get.offAllNamed(Routes.LOGIN_SCREEN);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF009A3F),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text(
                    'យល់ព្រម',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
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

  // ── Guest ─────────────────────────────────────────────────────────────────
  void continueAsGuest() {
    box.write('userMode', 'guest');
    Get.offAllNamed(Routes.BUTTON_NAVBAR);
  }

  // ── Navigation ────────────────────────────────────────────────────────────
  void goToLogin() => Get.back();

  // ── Dispose ───────────────────────────────────────────────────────────────
  @override
  void onClose() {
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    firstNameShakeCtrl.dispose();
    lastNameShakeCtrl.dispose();
    emailShakeCtrl.dispose();
    phoneShakeCtrl.dispose();
    passwordShakeCtrl.dispose();
    confirmPasswordShakeCtrl.dispose();
    super.onClose();
  }
}
