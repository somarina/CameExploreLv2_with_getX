import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/app/core/constants/app_colors/app_colors.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../controllers/forget_password_controller.dart';

class ForgetPasswordView extends GetView<ForgetPasswordController> {
  const ForgetPasswordView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final step = controller.currentStep.value;
      return WillPopScope(
        onWillPop: () async {
          controller.goBack();
          return false;
        },
        child: Scaffold(
          backgroundColor: AppColors.lightBackgroundColor,
          appBar: _buildAppBar(step),
          body: GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: SafeArea(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, animation) => SlideTransition(
                  position: Tween<Offset>(
                    begin: Offset(0.15, 0),
                    end: Offset.zero,
                  ).animate(CurvedAnimation(
                      parent: animation, curve: Curves.easeOut)),
                  child: FadeTransition(opacity: animation, child: child),
                ),
                child: KeyedSubtree(
                  key: ValueKey(step),
                  child: switch (step) {
                    1 => _Step1(controller: controller),
                    2 => _Step2(controller: controller),
                    3 => _Step3(controller: controller),
                    4 => _Step4(controller: controller),
                    _ => SizedBox.shrink(),
                  },
                ),
              ),
            ),
          ),
        ),
      );
    });
  }

  AppBar _buildAppBar(int step) {
    final titles = {
      1: 'ភ្លេចពាក្យសម្ងាត់',
      2: 'ផ្ទៀងផ្ទាត់អត្តសញ្ញាណ',
      3: 'បង្គីតពាក្យសម្ងាត់ថ្មី',
      4: 'បង្គីតពាក្យសម្ងាត់ថ្មី',
    };
    return AppBar(
      backgroundColor: AppColors.lightBackgroundColor,
      elevation: 0,
      leading: IconButton(
        icon: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.lightPrimaryColor, width: 1.5),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(Icons.chevron_left,
              color: AppColors.lightPrimaryColor, size: 22),
        ),
        onPressed: controller.goBack,
      ),
      title: Text(
        titles[step] ?? '',
        style: GoogleFonts.kantumruyPro(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AppColors.lightTextColor,
        ),
      ),
      centerTitle: true,
    );
  }
}

// ── Step 1: Enter email/phone ─────────────────────────────────────────────
class _Step1 extends StatelessWidget {
  final ForgetPasswordController controller;
  const _Step1({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Form(
        key: controller.step1FormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20),
            Text(
              'ស្វែងរកគណនីនៃរបស់លោកអ្នក',
              style: GoogleFonts.kantumruyPro(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.lightTextColor,
              ),
            ),
            SizedBox(height: 20),
            TextFormField(
              controller: controller.emailOrPhoneController,
              keyboardType: TextInputType.emailAddress,
              style: GoogleFonts.kantumruyPro(fontSize: 14),
              decoration: InputDecoration(
                // ✅ Fixed: clean hint text
                hintText: 'សូមបញ្ចូលអ៊ីមែល',
                hintStyle:
                    GoogleFonts.kantumruyPro(fontSize: 13, color: Colors.grey[400]),
                filled: true,
                fillColor: Colors.white,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[300]!)),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[300]!)),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                        color: AppColors.lightPrimaryColor, width: 1.5)),
                errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        BorderSide(color: Colors.red, width: 1.5)),
              ),
              validator: (v) {
  if (v == null || v.trim().isEmpty) {
    return 'សូមបញ្ចូលអ៊ីមែល';
  }

  if (!GetUtils.isEmail(v.trim())) {
    return 'អ៊ីមែលមិនត្រឹមត្រូវ';
  }

  return null;
},
            ),
            SizedBox(height: 20),
            Obx(() => SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: controller.isLoading.value
                        ? null
                        : controller.requestOtp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.lightPrimaryColor,
                      disabledBackgroundColor:
                          AppColors.lightPrimaryColor.withOpacity(0.6),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                      elevation: 0,
                    ),
                    child: controller.isLoading.value
                        ? SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2.5))
                        : Text('បន្ត',
                            style: GoogleFonts.kantumruyPro(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white)),
                  ),
                )),
          ],
        ),
      ),
    );
  }
}

// ── Step 2: OTP input ─────────────────────────────────────────────────────
class _Step2 extends StatelessWidget {
  final ForgetPasswordController controller;
  const _Step2({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: 24),
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: GoogleFonts.kantumruyPro(
                  fontSize: 16,
                  color: AppColors.lightTextColor,
                  fontWeight: FontWeight.w600),
              children: [
                TextSpan(text: 'បញ្ចូល '),
                TextSpan(
                    text: 'OTP',
                    style: TextStyle(color: AppColors.lightPrimaryColor)),
                TextSpan(text: ' ដើម្បី'),
                TextSpan(
                    text: 'ផ្ទៀងផ្ទាត់\nអត្តសញ្ញាណរបស់អ្នក 🔐',
                    style: TextStyle(color: AppColors.lightPrimaryColor)),
              ],
            ),
          ),
          SizedBox(height: 8),
          Text(
            'A one-time password (OTP) has been sent to your registered email address.',
            textAlign: TextAlign.center,
            style: GoogleFonts.roboto(fontSize: 12, color: Colors.grey[500]),
          ),
          SizedBox(height: 28),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(
              6,
              (i) => _OtpBox(
                controller: controller.otpControllers[i],
                focusNode: controller.otpFocusNodes[i],
                onChanged: (v) => controller.handleOtpInput(i, v),
              ),
            ),
          ),
          SizedBox(height: 14),
          // Fixed: colon instead of dot in timer
          Obx(() => controller.resendSeconds.value > 0
              ? Text(
                  'Resend code in 00:${controller.resendSeconds.value.toString().padLeft(2, '0')}',
                  style: GoogleFonts.roboto(
                      fontSize: 13, color: AppColors.lightPrimaryColor),
                )
              : GestureDetector(
                  onTap: controller.resendOtp,
                  child: Text(
                    'Resend code',
                    style: GoogleFonts.roboto(
                        fontSize: 13,
                        color: AppColors.lightPrimaryColor,
                        decoration: TextDecoration.underline),
                  ),
                )),
          SizedBox(height: 24),
          Obx(() => SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: controller.isLoading.value
                      ? null
                      : controller.verifyOtp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.lightPrimaryColor,
                    disabledBackgroundColor:
                        AppColors.lightPrimaryColor.withOpacity(0.6),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  child: controller.isLoading.value
                      ? SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2.5))
                      : Text('បន្ត',
                          style: GoogleFonts.kantumruyPro(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white)),
                ),
              )),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('មិនបានទទួលព័ត៌មានដែរទេ? ',
                  style: GoogleFonts.kantumruyPro(
                      fontSize: 13, color: Colors.grey[600])),
              GestureDetector(
                onTap: controller.resendOtp,
                child: Text('ផ្ញើម្តងទៀត',
                    style: GoogleFonts.kantumruyPro(
                        fontSize: 13,
                        color: AppColors.lightPrimaryColor,
                        decoration: TextDecoration.underline)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _OtpBox extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;
  const _OtpBox(
      {required this.controller,
      required this.focusNode,
      required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 52,
      height: 56,
      child: TextFormField(
        controller: controller,
        focusNode: focusNode,
        maxLength: 1,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        style:
            GoogleFonts.roboto(fontSize: 20, fontWeight: FontWeight.bold),
        decoration: InputDecoration(
          counterText: '',
          filled: true,
          fillColor: Colors.white,
          contentPadding: EdgeInsets.zero,
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!)),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!)),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  BorderSide(color: AppColors.lightPrimaryColor, width: 2)),
        ),
        onChanged: onChanged,
      ),
    );
  }
}

// ── Step 3: Confirm ───────────────────────────────────────────────────────
class _Step3 extends StatelessWidget {
  final ForgetPasswordController controller;
  const _Step3({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 20),
          Text(
            'កំណត់ពាក្យសម្ងាត់ឡើងវិញ',
            style: GoogleFonts.kantumruyPro(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: AppColors.lightTextColor),
          ),
          SizedBox(height: 10),
          Text(
            'ពាក្យសម្ងាត់របស់អ្នកត្រូវបានកំណត់ឡើងវិញដោយជោគជ័យ។\nចុចបន្តដើម្បីប្ដូរពាក្យសម្ងាត់ឡើងវិញ។',
            style: GoogleFonts.kantumruyPro(
                fontSize: 13, color: Colors.grey[600], height: 1.6),
          ),
          SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () => controller.currentStep.value = 4,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.lightPrimaryColor,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
              child: Text('បន្តទៅ',
                  style: GoogleFonts.kantumruyPro(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white)),
            ),
          ),
          SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () => Get.back(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
              child: Text('មិនព្រម',
                  style: GoogleFonts.kantumruyPro(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}

// Set new password
class _Step4 extends StatelessWidget {
  final ForgetPasswordController controller;
  const _Step4({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Form(
        key: controller.step4FormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20),
            Text(
              'កំណត់ពាក្យសម្ងាត់ថ្មី',
              style: GoogleFonts.kantumruyPro(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: AppColors.lightTextColor),
            ),
            SizedBox(height: 8),
            Text(
              'បង្គីតពាក្យសម្ងាត់ថ្មី ត្រូវបានចាត់ទុកជាតម្លៃដំបូងពីគណនីតម្រូវការ\nដើម្បីចូលប្រើប្រាស់ពាក្យសម្ងាត់ថ្មីឡើងវិញ។',
              style: GoogleFonts.kantumruyPro(
                  fontSize: 12, color: Colors.grey[600], height: 1.6),
            ),
            SizedBox(height: 24),
            Text('ពាក្យសម្ងាត់',
                style: GoogleFonts.kantumruyPro(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.lightTextColor)),
            SizedBox(height: 8),
            // Fixed: password visibility icon toggles correctly
            Obx(() => TextFormField(
                  controller: controller.passwordController,
                  obscureText: !controller.showPassword.value,
                  style: GoogleFonts.roboto(fontSize: 14),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    suffixIcon: IconButton(
                      icon: Icon(
                        controller.showPassword.value
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: Colors.grey[400],
                        size: 20,
                      ),
                      onPressed: () => controller.showPassword.toggle(),
                    ),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[300]!)),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[300]!)),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                            color: AppColors.lightPrimaryColor, width: 1.5)),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'សូមបញ្ចូលពាក្យសម្ងាត់';
                    if (v.length < 6) return 'ត្រូវការយ៉ាងហោចណាស់ 6 តួ';
                    return null;
                  },
                )),
            SizedBox(height: 16),
            Text('បញ្ជាក់ពាក្យសម្ងាត់',
                style: GoogleFonts.kantumruyPro(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.lightTextColor)),
            SizedBox(height: 8),
            // Fixed: confirm password visibility icon toggles correctly
            Obx(() => TextFormField(
                  controller: controller.confirmPasswordController,
                  obscureText: !controller.showConfirmPassword.value,
                  style: GoogleFonts.roboto(fontSize: 14),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    suffixIcon: IconButton(
                      icon: Icon(
                        controller.showConfirmPassword.value
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: Colors.grey[400],
                        size: 20,
                      ),
                      onPressed: () => controller.showConfirmPassword.toggle(),
                    ),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[300]!)),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[300]!)),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                            color: AppColors.lightPrimaryColor, width: 1.5)),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'សូមបញ្ជាក់ពាក្យសម្ងាត់';
                    if (v != controller.passwordController.text)
                      return 'ពាក្យសម្ងាត់មិនត្រូវគ្នា';
                    return null;
                  },
                )),
            SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () => Get.back(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                        elevation: 0,
                      ),
                      child: Text('មិនព្រម',
                          style: GoogleFonts.kantumruyPro(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.white)),
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Obx(() => SizedBox(
                        height: 50,
                        child: ElevatedButton(
                          onPressed: controller.isLoading.value
                              ? null
                              : controller.resetPassword,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.lightPrimaryColor,
                            disabledBackgroundColor:
                                AppColors.lightPrimaryColor.withOpacity(0.6),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14)),
                            elevation: 0,
                          ),
                          child: controller.isLoading.value
                              ? SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                      color: Colors.white, strokeWidth: 2.5))
                              : Text('បន្ត',
                                  style: GoogleFonts.kantumruyPro(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white)),
                        ),
                      )),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}