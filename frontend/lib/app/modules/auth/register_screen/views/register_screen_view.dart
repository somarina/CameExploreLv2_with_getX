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
    final keyboard = MediaQuery.of(context).viewInsets.bottom;
    final keyboardOpen = keyboard > 0;
    // ignore: unused_local_variable
    final topPad = keyboardOpen ? 8.0 : 0.0;

    return Scaffold(
      // backgroundColor: AppColors.lightBackgroundColor,
      backgroundColor: Get.theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22),
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
                      Center(
                        child: Lottie.asset(
                          'assets/icons/register_screen_animation.json',
                          height: keyboardOpen
                              ? MediaQuery.of(context).size.height * 0.18
                              : MediaQuery.of(context).size.height * 0.32,
                          fit: BoxFit.contain,
                        ),
                      ),
                      Center(
                        child: Text(
                          "Register".tr,
                          style: controller.isEnglish
                              ? GoogleFonts.spaceGrotesk(
                                  fontSize: 30,
                                  fontWeight: FontWeight.w700,
                                )
                              : GoogleFonts.googleSans(
                                  fontSize: 30,
                                  fontWeight: FontWeight.w700,
                                ),
                        ),
                      ),
                      SizedBox(height: 16),

                      // ── First Name ─────────────────────────────────────
                      _ShakeField(
                        animation: controller.firstNameShake,
                        child: _buildInput(
                          ctrl: controller.firstNameController,
                          hintText: 'last name'.tr,
                          validator: controller.validateFirstName,
                        ),
                      ),
                      SizedBox(height: 16),

                      // ── Last Name ──────────────────────────────────────
                      _ShakeField(
                        animation: controller.lastNameShake,
                        child: _buildInput(
                          ctrl: controller.lastNameController,
                          hintText: "First Name".tr,
                          validator: controller.validateLastName,
                        ),
                      ),
                      SizedBox(height: 16),

                      // ── Gender ─────────────────────────────────────────
                      Text(
                        "Gender".tr,
                        style: controller.isEnglish
                            ? GoogleFonts.spaceGrotesk(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              )
                            : GoogleFonts.googleSans(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                              ),
                      ),
                      SizedBox(height: 10),
                      _buildGender(),
                      SizedBox(height: 16),

                      // ── Email ──────────────────────────────────────────
                      _ShakeField(
                        animation: controller.emailShake,
                        child: _buildInput(
                          ctrl: controller.emailController,
                          hintText: "E-mail".tr,
                          keyboardType: TextInputType.emailAddress,
                          validator: controller.validateEmail,
                        ),
                      ),
                      SizedBox(height: 16),

                      // ── Phone ──────────────────────────────────────────
                      _ShakeField(
                        animation: controller.phoneShake,
                        child: _buildInput(
                          ctrl: controller.phoneController,
                          hintText: "Phone Number".tr,
                          keyboardType: TextInputType.phone,
                          validator: controller.validatePhone,
                        ),
                      ),
                      SizedBox(height: 16),
                      // ── Password ───────────────────────────────────────
                      _ShakeField(
                        animation: controller.passwordShake,
                        child: Obx(
                          () => _buildPasswordField(
                            ctrl: controller.passwordController,
                            hintText: "Password".tr,
                            hide: controller.hidePassword.value,
                            toggle: controller.togglePassword,
                            validator: controller.validatePassword,
                          ),
                        ),
                      ),
                      // ── Password hint row ──────────────────────────────
                      Obx(
                        () => _buildPasswordHints(
                          controller.passwordController.text,
                          controller.submitted.value,
                        ),
                      ),
                      SizedBox(height: 16),

                      // ── Confirm Password ───────────────────────────────
                      _ShakeField(
                        animation: controller.confirmPasswordShake,
                        child: Obx(
                          () => _buildPasswordField(
                            ctrl: controller.confirmPasswordController,
                            hintText: "Confirm Password".tr,
                            hide: controller.hideConfirmPassword.value,
                            toggle: controller.toggleConfirmPassword,
                            validator: controller.validateConfirmPassword,
                          ),
                        ),
                      ),
                      // SizedBox(height: 10),

                      // ── Checkbox ───────────────────────────────────────
                      Obx(
                        () => Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Checkbox(
                              value: controller.isChecked.value,
                              onChanged: controller.toggleCheckbox,
                              activeColor: AppColors.lightPrimaryColor,

                              side: BorderSide(
                                width: 2,
                                color: AppColors.lightPrimaryColor,
                              ),
                            ),
                            Expanded(
                              child: Wrap(
                                spacing: 4,
                                runSpacing: 2,
                                children: [
                                  Text(
                                    "I have read".tr,
                                    style: controller.isEnglish
                                        ? GoogleFonts.spaceGrotesk(
                                            fontSize: 13,
                                            // fontWeight: FontWeight.w700,
                                            // color: Colors.black,
                                          )
                                        : GoogleFonts.googleSans(fontSize: 13),
                                  ),
                                  Text(
                                    "Agree & Attend".tr,
                                    style: controller.isEnglish
                                        ? GoogleFonts.spaceGrotesk(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.lightPrimaryColor,
                                          )
                                        : GoogleFonts.googleSans(
                                            fontSize: 13,
                                            color: AppColors.lightPrimaryColor,
                                            fontWeight: FontWeight.w600,
                                          ),
                                  ),
                                  Text(
                                    "And I accept it".tr,
                                    style: controller.isEnglish
                                        ? GoogleFonts.spaceGrotesk(fontSize: 13)
                                        : GoogleFonts.googleSans(fontSize: 13),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 10),

                      // ── Buttons Row ────────────────────────────────────
                      Row(
                        children: [
                          Expanded(child: _buildSignupButton()),
                          SizedBox(width: 12),
                          Expanded(child: _buildGuestButton()),
                        ],
                      ),
                      SizedBox(height: 20),

                      _buildOr(),
                      SizedBox(height: 23),
                      _buildLoginAs(),
                      SizedBox(height: 14),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Have an account already?".tr,
                            style: controller.isEnglish
                                ? GoogleFonts.spaceGrotesk(fontSize: 16)
                                : GoogleFonts.googleSans(fontSize: 16),
                          ),
                          SizedBox(width: 10),
                          GestureDetector(
                            onTap: controller.goToLogin,
                            child: Text(
                              "Login".tr,
                              style: controller.isEnglish
                                  ? GoogleFonts.spaceGrotesk(
                                      fontSize: 16,
                                      color: AppColors.lightPrimaryColor,
                                      fontWeight: FontWeight.w600,
                                    )
                                  : GoogleFonts.googleSans(
                                      fontSize: 16,
                                      color: AppColors.lightPrimaryColor,
                                      fontWeight: FontWeight.w600,
                                    ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
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

  Widget _buildLoginAs() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: controller.loginWithGoogle,
          child: Image.asset(
            "assets/images/google_icon.png",
            width: 40,
            height: 40,
          ),
        ),
        SizedBox(width: 15),
        GestureDetector(
          onTap: controller.loginWithTelegram,
          child: Image.asset(
            "assets/images/telegram_icon.png",
            width: 40,
            height: 40,
          ),
        ),
      ],
    );
  }

  Widget _buildOr() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 1,
            decoration: BoxDecoration(color: Colors.grey),
          ),
        ),
        SizedBox(width: 20),
        Text(
          "Or".tr,
          style: GoogleFonts.googleSans(
            fontSize: 20,
            fontWeight: .w500,
            color: Colors.grey,
          ),
        ),
        SizedBox(width: 20),
        Expanded(
          child: Container(
            height: 1,
            decoration: BoxDecoration(color: Colors.grey),
          ),
        ),
      ],
    );
  }

  // ── Password hints (live feedback) ─────────────────────────────────────────
  Widget _buildPasswordHints(String value, bool submitted) {
    if (!submitted && value.isEmpty) return SizedBox.shrink();

    final has8 = value.length >= 8;
    final hasLetter = RegExp(r'[A-Za-z]').hasMatch(value);
    final hasNumber = RegExp(r'\d').hasMatch(value);

    if (has8 && hasLetter && hasNumber) return SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 6, left: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!has8) _hintRow("At least 8 characters".tr, has8),
          if (!hasLetter) _hintRow("At least one letter".tr, hasLetter),
          if (!hasNumber) _hintRow("At least one number".tr, hasNumber),
        ],
      ),
    );
  }

  Widget _hintRow(String text, bool passed) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Row(
        children: [
          Icon(
            passed ? Icons.check_circle : Icons.cancel,
            size: 14,
            color: passed ? Colors.green : Colors.red,
          ),
          SizedBox(width: 6),
          Text(
            text,
            style: controller.isEnglish
                ? GoogleFonts.spaceGrotesk(
                    fontSize: 12,
                    color: passed ? Colors.green : Colors.red,
                    fontWeight: FontWeight.w500,
                  )
                : GoogleFonts.googleSans(
                    fontSize: 12,
                    color: passed ? Colors.green : Colors.red,
                    fontWeight: FontWeight.w500,
                  ),
          ),
        ],
      ),
    );
  }

  // ── Gender Widget ──────────────────────────────────────────────────────────
  Widget _buildGender() {
    return Obx(
      () => Row(
        children: [
          _buildGenderItem('male'.tr),
          SizedBox(width: 10),
          _buildGenderItem('female'.tr),
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
          height: 50,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: isSelected ? AppColors.lightPrimaryColor : Colors.grey,width: 2),
          ),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 20),
                child: Text(
                  value,
                  style: controller.isEnglish
                      ? GoogleFonts.spaceGrotesk(
                          fontSize: 16,
                          fontWeight: isSelected
                              ? .bold
                              : FontWeight.w400,
                    color: isSelected ? Colors.black : Colors.grey.shade400,
                        )
                      : GoogleFonts.googleSans(
                          fontSize: 16,
                          fontWeight: isSelected
                              ? FontWeight.w700
                              : FontWeight.w400,
                    color: isSelected ? Colors.black : Colors.grey.shade400,
                        ),
                ),
              ),
              Spacer(),
              Icon(
                isSelected
                    ? Icons.radio_button_checked
                    : Icons.radio_button_off,
                color: isSelected ? AppColors.lightPrimaryColor : Colors.grey,
              ),
              SizedBox(width: 20),
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
                ? SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.5,
                    ),
                  )
                : Text(
                    'Register'.tr,
                    style: controller.isEnglish
                        ? GoogleFonts.spaceGrotesk(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          )
                        : GoogleFonts.kantumruyPro(
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
              backgroundColor: Color(0xFF6D6D6D),
              minimumSize: Size(double.infinity, 52),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(26),
              ),
              elevation: 0,
            ),
            child: Text(
              'Continue as a guest'.tr,
              style: controller.isEnglish
                  ? GoogleFonts.spaceGrotesk(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    )
                  : GoogleFonts.kantumruyPro(
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

  // ── Password Field (matches login style exactly) ───────────────────────────
  Widget _buildPasswordField({
    required TextEditingController ctrl,
    required String hintText,
    required bool hide,
    required VoidCallback toggle,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: ctrl,
      obscureText: hide,
      maxLength: 32,
      validator: validator,
      decoration: _inputDecoration(
        hintText: hintText,
        suffixIcon: IconButton(
          icon: Icon(hide ? Icons.visibility_off : Icons.visibility),
          onPressed: toggle,
        ),
      ).copyWith(counterText: ''),
    );
  }

  // ── Normal Input Field ─────────────────────────────────────────────────────
  Widget _buildInput({
    required TextEditingController ctrl,
    required String hintText,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: ctrl,
      keyboardType: keyboardType,
      validator: validator,
      decoration: _inputDecoration(hintText: hintText),
    );
  }

  InputDecoration _inputDecoration({
  required String hintText,
  Widget? suffixIcon,
}) {
  final isDark = Get.isDarkMode;

  return InputDecoration(
    hintText: hintText,
    hintStyle: controller.isEnglish
        ? GoogleFonts.spaceGrotesk(color: Colors.grey)
        : GoogleFonts.googleSans(color: Colors.grey),
    suffixIcon: suffixIcon,
    filled: true,
    fillColor: isDark ? Colors.grey[850] : Colors.white,  // ← fix
    contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
    errorStyle: controller.isEnglish
        ? GoogleFonts.spaceGrotesk(
            color: Colors.red, fontSize: 13, fontWeight: FontWeight.w500)
        : GoogleFonts.googleSans(
            color: Colors.red, fontSize: 13, fontWeight: FontWeight.w500),
    errorMaxLines: 2,
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(20),
      borderSide: BorderSide(
        color: isDark ? Colors.grey[600]! : Color(0xFFE6E6E6),  // ← fix
        width: 2,
      ),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(20),
      borderSide: BorderSide(color: AppColors.lightPrimaryColor, width: 1.2),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(20),
      borderSide: BorderSide(color: Colors.red, width: 1),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(20),
      borderSide: BorderSide(color: Colors.red, width: 1.2),
    ),
  );
}
}

// ── Shake Field Widget ─────────────────────────────────────────────────────
class _ShakeField extends StatelessWidget {
  final Animation<double> animation;
  final Widget child;
  const _ShakeField({required this.animation, required this.child});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (_, w) =>
          Transform.translate(offset: Offset(animation.value, 0), child: w),
      child: child,
    );
  }
}
