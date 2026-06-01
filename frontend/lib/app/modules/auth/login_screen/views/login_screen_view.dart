import 'package:flutter/material.dart';
import 'package:frontend/app/core/constants/app_colors/app_colors.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';

import '../controllers/login_screen_controller.dart';

class LoginScreenView extends GetView<LoginScreenController> {
  const LoginScreenView({super.key});

  @override
  Widget build(BuildContext context) {
    final keyboard = MediaQuery.of(context).viewInsets.bottom;
    final keyboardOpen = keyboard > 0;
    final topPad = keyboardOpen ? 8.0 : 0.0;

    return Scaffold(
      backgroundColor: AppColors.lightBackgroundColor,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: AnimatedPadding(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            padding: EdgeInsets.only(top: topPad),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SingleChildScrollView(
                controller: controller.scrollController,
                physics: BouncingScrollPhysics(),
                padding: EdgeInsets.only(bottom: keyboard + 16),
                child: Obx(
                  () => Form(
                    key: controller.formKey,
                    autovalidateMode: controller.submitted.value
                        ? AutovalidateMode.onUserInteraction
                        : AutovalidateMode.disabled,
                    child: Column(
                      children: [
                        _buildTopImage(context, keyboardOpen),
                        SizedBox(height: 15),
                        Padding(
                          padding: const EdgeInsets.all(10),
                          child: Column(
                            children: [
                              _buildTitle(),
                              SizedBox(height: 14),
                              _buildSwitchBox(),
                              SizedBox(height: 8),
                              _buildFormContent(),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopImage(BuildContext context, bool keyboardOpen) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      height: keyboardOpen
          ? MediaQuery.of(context).size.height * 0.18
          : MediaQuery.of(context).size.height * 0.32,
      // child: Image.asset("assets/icons/login_icon.png", fit: BoxFit.contain),
      child: Lottie.asset("assets/icons/Login_image.json", fit: BoxFit.contain),
    );
  }

  Widget _buildTitle() {
    return Text(
      "ចូលគណនី",
      style: GoogleFonts.kantumruyPro(
        fontSize: 26,
        fontWeight: FontWeight.bold,

        color: Colors.black,
      ),
    );
  }

  Widget _buildSwitchBox() {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.grey[350],
      ),
      child: Row(
        children: [
          _buildSwitchButton(
            text: "លេខទូរស័ព្ទ",
            selected: !controller.isEmail.value,
            onTap: () => controller.changeLoginType(false),
          ),
          _buildSwitchButton(
            text: "អ៊ីម៉ែល",
            selected: controller.isEmail.value,
            onTap: () => controller.changeLoginType(true),
          ),
        ],
      ),
    );
  }

  Widget _buildFormContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 15),
        Text(
          controller.isEmail.value ? "អ៊ីម៉ែល" : "លេខទូរស័ព្ទ",
          style: _generalStyle(),
        ),
        SizedBox(height: 8),
        controller.isEmail.value ? _buildEmailField() : _buildPhoneField(),
        SizedBox(height: 10),
        Text("ពាក្យសម្ងាត់", style: _generalStyle()),
        SizedBox(height: 10),
        _buildPasswordField(),
        // SizedBox(height: 8),
        _buildForgotPassword(),
        SizedBox(height: 20),
        _buildMainButtonsRow(),
        SizedBox(height: 23),
        _buildOr(),
        SizedBox(height: 23),
        _buildLoginAs(),
        SizedBox(height: 14),
        _buildRegisterText(),
        SizedBox(height: 10),
      ],
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
          "ឬ",
          style: GoogleFonts.kantumruyPro(
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

  Widget _buildEmailField() {
    return AnimatedBuilder(
      animation: controller.idShake,
      builder: (_, child) => Transform.translate(
        offset: Offset(controller.idShake.value, 0),
        child: child,
      ),
      child: TextFormField(
        controller: controller.emailController,
        keyboardType: TextInputType.emailAddress,
        onChanged: (_) => controller.clearIdError(),
        validator: (value) {
          final v = (value ?? '').trim();

          if (v.isEmpty) return "សូមបញ្ចូលអ៊ីម៉ែល";

          if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(v)) {
            return "អ៊ីម៉ែលមិនត្រឹមត្រូវ";
          }

          return null;
        },
        decoration: _decoration(
          hasError: controller.submitted.value && controller.idHasError.value,
        ),
      ),
    );
  }

  Widget _buildPhoneField() {
    return AnimatedBuilder(
      animation: controller.idShake,
      builder: (_, child) => Transform.translate(
        offset: Offset(controller.idShake.value, 0),
        child: child,
      ),
      child: TextFormField(
        controller: controller.phoneController,
        keyboardType: TextInputType.phone,
        onChanged: (_) => controller.clearIdError(),
        validator: (value) {
          final v = (value ?? '').trim();

          if (v.isEmpty) return "សូមបញ្ចូលលេខទូរស័ព្ទ";

          if (!RegExp(r'^\d{8,10}$').hasMatch(v)) {
            return "លេខទូរស័ព្ទមិនត្រឹមត្រូវ";
          }

          return null;
        },
        decoration: _decoration(
          hasError: controller.submitted.value && controller.idHasError.value,
        ),
      ),
    );
  }

  Widget _buildPasswordField() {
    return AnimatedBuilder(
      animation: controller.passShake,
      builder: (_, child) => Transform.translate(
        offset: Offset(controller.passShake.value, 0),
        child: child,
      ),
      child: TextFormField(
        controller: controller.passController,
        obscureText: controller.obscure.value,
        maxLength: 32,
        onChanged: (_) => controller.clearPassError(),
        validator: (value) {
          final v = (value ?? '').trim();

          if (v.isEmpty) return "សូមបញ្ចូលពាក្យសម្ងាត់";

          if (v.length < 8) return "ពាក្យសម្ងាត់យ៉ាងតិច 8 តួ";

          if (!RegExp(r'[a-zA-Z]').hasMatch(v)) return "មានអក្សរយ៉ាងតិចមួយ";

          if (!RegExp(r'[0-9]').hasMatch(v)) return "មានលេខយ៉ាងតិចមួយ";

          // if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(v))
          //   return "មានសញ្ញាពិសេសយ៉ាងតិចមួយ";

          return null;
        },
        decoration:
            _decoration(
              hasError:
                  controller.submitted.value && controller.passHasError.value,
            ).copyWith(
              counterText: "",
              suffixIcon: IconButton(
                icon: Icon(
                  controller.obscure.value
                      ? Icons.visibility_off
                      : Icons.visibility,
                ),
                onPressed: controller.togglePassword,
              ),
            ),
      ),
    );
  }

  Widget _buildForgotPassword() {
    return Row(
      children: [
        // ── Remember Me Checkbox ──
        Obx(
          () => GestureDetector(
            onTap: controller.toggleRememberMe,
            
            child: Row(
              
              children: [
                
                AnimatedContainer(
                
                  duration: Duration(milliseconds: 200),
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: controller.rememberMe.value
                        ? AppColors.lightPrimaryColor
                        : Colors.transparent,
                    border: Border.all(
                      color: AppColors.lightPrimaryColor,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: controller.rememberMe.value
                      ? Icon(Icons.check, size: 14, color: Colors.white)
                      : null,
                ),
                SizedBox(width: 10),
                Text(
                  "ចងចាំខ្ញុំ",
                  style: GoogleFonts.kantumruyPro(
                    color: AppColors.lightPrimaryColor,
                    fontSize: 17,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
        Spacer(),
        // ── Forgot Password ──
        GestureDetector(
          onTap: controller.goToForgotPassword,
          child: Text(
            "ភ្លេចពាក្យសម្ងាត់?",
            style: GoogleFonts.kantumruyPro(
              color: Color(0xffE7000B),
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMainButtonsRow() {
    return Row(
      children: [
        Expanded(child: _buildLoginButton()),
        SizedBox(width: 12),
        Expanded(child: _buildGuestButton()),
      ],
    );
  }

  Widget _buildLoginButton() {
    return Obx(
      () => ElevatedButton(
        onPressed: controller.isLoading.value ? null : controller.login,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.lightPrimaryColor,
          minimumSize: Size(double.infinity, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(26),
          ),
          elevation: 0,
        ),
        child: AnimatedSwitcher(
          duration: Duration(milliseconds: 300),
          child: controller.isLoading.value
              ? SizedBox(
                  key: ValueKey('loading'),
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Text(key: ValueKey('text'), "ចូលគណនី", style: _buttonStyle()),
        ),
      ),
    );
  }

  Widget _buildGuestButton() {
    return ElevatedButton(
      onPressed: controller.continueAsGuest,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF6D6D6D),
        minimumSize: const Size(double.infinity, 56),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
        elevation: 0,
      ),
      child: Text("បន្តជាភ្ញៀវ", style: _buttonStyle()),
    );
  }

  Widget _buildRegisterText() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "មិនមានគណនីមែនទេ?",
          style: GoogleFonts.kantumruyPro(
            fontSize: 18,
            color: Colors.black,
            fontWeight: FontWeight.normal,
          ),
        ),
        SizedBox(width: 10),
        GestureDetector(
          onTap: controller.goToRegister,
          child: Text(
            "ចុះឈ្មោះ",
            style: _generalStyle().copyWith(color: AppColors.lightPrimaryColor),
          ),
        ),
      ],
    );
  }

  Widget _buildSwitchButton({
    required String text,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: selected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(child: Text(text, style: _generalStyle())),
        ),
      ),
    );
  }

  InputDecoration _decoration({required bool hasError}) {
    return InputDecoration(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 17),
      errorStyle: GoogleFonts.kantumruyPro(
        color: Colors.red,
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
      errorMaxLines: 2,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide(
          color: hasError ? Colors.red : Color(0xFFE6E6E6),
          width: 2,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide(
          color: hasError ? Colors.red : AppColors.lightPrimaryColor,
          width: 1.2,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: const BorderSide(color: Colors.red, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: const BorderSide(color: Colors.red, width: 1.2),
      ),
    );
  }

  TextStyle _generalStyle() {
    return GoogleFonts.kantumruyPro(
      fontSize: 17,
      fontWeight: FontWeight.w500,
      color: Colors.black,
    );
  }

  TextStyle _buttonStyle() {
    return GoogleFonts.kantumruyPro(
      fontSize: 17,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    );
  }
}
