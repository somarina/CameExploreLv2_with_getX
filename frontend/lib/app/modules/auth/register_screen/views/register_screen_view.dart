import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';

import '../../../../core/constants/app_colors/app_colors.dart';
import '../controllers/register_screen_controller.dart';

class RegisterScreenView extends GetView<RegisterScreenController> {
  const RegisterScreenView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackgroundColor,
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Obx(
              () => Form(
                key: controller.formKey,
                autovalidateMode: controller.submitted.value
                    ? AutovalidateMode.onUserInteraction
                    : AutovalidateMode.disabled,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Image ──────────────────────────────────────────
                      Center(
                        // child: Image.asset(
                        //   'assets/images/signup_screen/singup_screen.png',
                        //   height: 220,
                        //   fit: BoxFit.contain,
                        // ),
                        child: Lottie.asset(
                          // 'assets/images/register.json',
                          'assets/images/register2.json', 
                          height: 220,
                          fit: BoxFit.contain,
                        ),
                      ),
                      SizedBox(height: 8),

                      // ── Title ──────────────────────────────────────────
                      Center(
                        child: Text(
                          'ចុះឈ្មោះ',
                          style: GoogleFonts.kantumruyPro(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // ── First Name ─────────────────────────────────────
                      _buildInput(
                        controller: controller.firstNameController,
                        hintText: 'នាមត្រកូល',
                        validator: controller.validateFirstName,
                      ),
                      const SizedBox(height: 10),

                      // ── Last Name ──────────────────────────────────────
                      _buildInput(
                        controller: controller.lastNameController,
                        hintText: 'នាមខ្លួន',
                        validator: controller.validateLastName,
                      ),
                      const SizedBox(height: 10),

                      // ── Gender ─────────────────────────────────────────
                      Text(
                        'ភេទ',
                        style: GoogleFonts.kantumruyPro(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 10),
                      _buildGender(),
                      const SizedBox(height: 10),

                      // ── Email ──────────────────────────────────────────
                      _buildInput(
                        controller: controller.emailController,
                        hintText: 'អ៊ីម៉ែល',
                        keyboardType: TextInputType.emailAddress,
                        validator: controller.validateEmail,
                      ),
                      const SizedBox(height: 10),

                      // ── Phone ──────────────────────────────────────────
                      _buildInput(
                        controller: controller.phoneController,
                        hintText: 'លេខទូរស័ព្ទ',
                        keyboardType: TextInputType.phone,
                        validator: controller.validatePhone,
                      ),
                      const SizedBox(height: 10),

                      // ── Password ───────────────────────────────────────
                      Obx(
                        () => _buildPassword(
                          controller: controller.passwordController,
                          hintText: 'ពាក្យសម្ងាត់',
                          hide: controller.hidePassword.value,
                          toggle: controller.togglePassword,
                          validator: controller.validatePassword,
                        ),
                      ),
                      const SizedBox(height: 10),

                      // ── Confirm Password ───────────────────────────────
                      Obx(
                        () => _buildPassword(
                          controller: controller.confirmPasswordController,
                          hintText: 'បញ្ជាក់ពាក្យសម្ងាត់',
                          hide: controller.hideConfirmPassword.value,
                          toggle: controller.toggleConfirmPassword,
                          validator: controller.validateConfirmPassword,
                        ),
                      ),
                      const SizedBox(height: 14),

                      // ── Checkbox ───────────────────────────────────────
                      Obx(
                        () => Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Checkbox(
                              value: controller.isChecked.value,
                              onChanged: controller.toggleCheckbox,
                              activeColor: AppColors.lightPrimaryColor,
                              side: const BorderSide(
                                width: 2,
                                color: Colors.black,
                              ),
                            ),
                            Expanded(
                              child: Wrap(
                                spacing: 4,
                                runSpacing: 2,
                                children: [
                                  Text(
                                    'ខ្ញុំបានអាន',
                                    style: GoogleFonts.kantumruyPro(
                                      fontSize: 14,
                                    ),
                                  ),
                                  Text(
                                    'យល់ព្រម​ & ចូលរួម',
                                    style: GoogleFonts.kantumruyPro(
                                      fontSize: 14,
                                      color: AppColors.lightPrimaryColor,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    'ហើយខ្ញុំទទួលយក',
                                    style: GoogleFonts.kantumruyPro(
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),

                      // ── Buttons Row ────────────────────────────────────
                      Row(
                        children: [
                          Expanded(child: _buildSignupButton()),
                          const SizedBox(width: 12),
                          Expanded(child: _buildGuestButton()),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // ── Divider ────────────────────────────────────────
                      Container(
                        width: double.infinity,
                        height: 1,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 10),

                      // ── Already have account ───────────────────────────
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'មានគណនីរួចហើយ?',
                            style: GoogleFonts.kantumruyPro(fontSize: 14),
                          ),
                          const SizedBox(width: 10),
                          GestureDetector(
                            onTap: controller.goToLogin,
                            child: Text(
                              'ចូលគណនី',
                              style: GoogleFonts.kantumruyPro(
                                fontSize: 14,
                                color: AppColors.lightPrimaryColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Gender Widget ──────────────────────────────────────────────────────────

  Widget _buildGender() {
    return Obx(
      () => Row(
        children: [
          _buildGenderItem('ប្រុស'),
          const SizedBox(width: 10),
          _buildGenderItem('ស្រី'),
        ],
      ),
    );
  }

  Widget _buildGenderItem(String value) {
    final isSelected = controller.gender.value == value;
    return Expanded(
      child: InkWell(
        onTap: () => controller.selectGender(value),
        child: Container(
          height: 45,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: isSelected ? Colors.black : Colors.grey),
          ),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 20),
                child: Text(
                  value,
                  style: GoogleFonts.kantumruyPro(
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                  ),
                ),
              ),
              const Spacer(),
              Icon(
                isSelected
                    ? Icons.radio_button_checked
                    : Icons.radio_button_off,
                color: isSelected ? AppColors.lightPrimaryColor : Colors.grey,
              ),
              const SizedBox(width: 20),
            ],
          ),
        ),
      ),
    );
  }

  // ── Signup Button ──────────────────────────────────────────────────────────

  Widget _buildSignupButton() {
    return Obx(
      () => GestureDetector(
        onTapDown: (_) => controller.downSignup.value = true,
        onTapCancel: () => controller.downSignup.value = false,
        onTapUp: (_) => controller.downSignup.value = false,
        child: AnimatedScale(
          scale: controller.downSignup.value ? 0.98 : 1,
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOut,
          child: ElevatedButton(
            onPressed: controller.isLoading.value ? null : controller.register,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.lightPrimaryColor,
              minimumSize: const Size(double.infinity, 52),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(26),
              ),
              elevation: 0,
            ),
            child: controller.isLoading.value
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.5,
                    ),
                  )
                : Text(
                    'ចុះឈ្មោះ',
                    style: GoogleFonts.kantumruyPro(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  // ── Guest Button ───────────────────────────────────────────────────────────

  Widget _buildGuestButton() {
    return Obx(
      () => GestureDetector(
        onTapDown: (_) => controller.downGuest.value = true,
        onTapCancel: () => controller.downGuest.value = false,
        onTapUp: (_) => controller.downGuest.value = false,
        child: AnimatedScale(
          scale: controller.downGuest.value ? 0.98 : 1,
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOut,
          child: ElevatedButton(
            onPressed: controller.continueAsGuest,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6D6D6D),
              minimumSize: const Size(double.infinity, 52),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(26),
              ),
              elevation: 0,
            ),
            child: Text(
              'បន្តជាភ្ញៀវ',
              style: GoogleFonts.kantumruyPro(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Input Field ────────────────────────────────────────────────────────────

  Widget _buildInput({
    required TextEditingController controller,
    required String hintText,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      decoration: _inputDecoration(hintText: hintText),
    );
  }

  Widget _buildPassword({
    required TextEditingController controller,
    required String hintText,
    required bool hide,
    required VoidCallback toggle,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: hide,
      validator: validator,
      decoration: _inputDecoration(
        hintText: hintText,
        suffixIcon: IconButton(
          icon: Icon(hide ? Icons.visibility_off : Icons.visibility),
          onPressed: toggle,
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String hintText,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: GoogleFonts.kantumruyPro(color: Colors.grey),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
      errorStyle: GoogleFonts.kantumruyPro(
        color: Colors.red,
        fontSize: 12.5,
        fontWeight: FontWeight.w500,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE6E6E6), width: 1.4),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.lightPrimaryColor, width: 1.6),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red, width: 1.4),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red, width: 1.6),
      ),
    );
  }
}
