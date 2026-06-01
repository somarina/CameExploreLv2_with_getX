import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../../../../core/api/services/auth_services.dart';

class RegisterScreenController extends GetxController {
  final box = GetStorage();
  final authServices = AuthServices();

  final formKey = GlobalKey<FormState>();

  // Controllers
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  // Observable variables
  final gender = 'ប្រុស'.obs;
  final hidePassword = true.obs;
  final hideConfirmPassword = true.obs;
  final isChecked = false.obs;
  final isLoading = false.obs;
  final submitted = false.obs;

  // Button press animation states
  final downSignup = false.obs;
  final downGuest = false.obs;

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
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(v)) return 'អ៊ីម៉ែលមិនត្រឹមត្រូវ';
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

  // ── Register ──────────────────────────────────────────────────────────────

  Future<void> register() async {
    if (isLoading.value) return;

    FocusManager.instance.primaryFocus?.unfocus();
    submitted.value = true;

    if (!formKey.currentState!.validate()) return;

    if (!isChecked.value) {
      Get.snackbar(
        'ចុះឈ្មោះ',
        'សូមយល់ព្រមលក្ខខណ្ឌជាមុនសិន',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.9),
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

      if (response['result'] == true) {
        _showSuccessDialog();
      } else {
        String msg = response['message'] ?? 'ចុះឈ្មោះបរាជ័យ';
        Get.snackbar(
          'ចុះឈ្មោះបរាជ័យ',
          msg,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withOpacity(0.9),
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'ចុះឈ្មោះបរាជ័យ',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.9),
        colorText: Colors.white,
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
              Image.asset(
                'assets/images/changePWD/change_pwd_success.gif',
                width: 130,
                height: 130,
              ),
              const SizedBox(height: 16),
              const Text(
                'គណនីរបស់អ្នកត្រូវបានបង្កើតឡើងជោគជ័យ',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    Get.back(); // close dialog
                    Get.offAllNamed('/button-navigation');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF009A3F),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
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
    Get.offAllNamed('/button-navigation');
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
    super.onClose();
  }
}