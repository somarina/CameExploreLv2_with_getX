import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:frontend/app/core/constants/app_image.dart';
import 'package:frontend/app/modules/profile_screen/change_pwd_screen/change_pwd_screen_controller.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class ChangePasswordView extends GetView<ChangePasswordController> {
  const ChangePasswordView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        leading: IconButton(
          icon: SvgPicture.asset(AppImage.arrowBackIcon, width: 30, height: 30),
          onPressed: () {
            Get.back();
          },
        ),
        title: Text(
          "ផ្លាស់ប្តូរពាក្យសម្ងាត់",
          style: GoogleFonts.spaceGrotesk(
            fontSize: 24,
            fontWeight: .bold,
            color: Theme.of(context).colorScheme.secondary,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25),
        child: Form(
          // key: controller.formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: SvgPicture.asset(
                    AppImage.changePWDIcon,
                    width: 250,
                    height: 250,
                  ),
                ),
                SizedBox(height: 30),

                buildTitle("ពាក្យសម្ងាត់បច្ចុប្បន្ន", context),
                Obx(
                  () => buildTextField(
                    context,
                    controller: controller.currentPWD,
                    hint: "ពាក្យសម្ងាត់បច្ចុប្បន្ន",
                    obscure: controller.hideCurrent.value,
                    toggle: controller.toggleCurrent,
                  ),
                ),

                const SizedBox(height: 25),

                buildTitle("ពាក្យសម្ងាត់ថ្មី", context),
                Obx(
                  () => buildTextField(
                    context,
                    controller: controller.newPWD,
                    hint: "ពាក្យសម្ងាត់ថ្មី",
                    obscure: controller.hideNew.value,
                    toggle: controller.toggleNew,
                  ),
                ),

                const SizedBox(height: 25),

                buildTitle("បញ្ជាក់ពាក្យសម្ងាត់ថ្មី", context),
                Obx(
                  () => buildTextField(
                    context,
                    controller: controller.confirmPWD,
                    hint: "បញ្ជាក់ពាក្យសម្ងាត់ថ្មី",
                    obscure: controller.hideConfirm.value,
                    toggle: controller.toggleConfirm,
                    validator: (v) => v != controller.newPWD.text
                        ? "ពាក្យសម្ងាត់មិនដូចគ្នា"
                        : null,
                  ),
                ),

                const SizedBox(height: 40),

                Row(
                  children: [
                    Expanded(
                      child: buildButton(
                        "បោះបង់",
                        Theme.of(context).colorScheme.tertiary,
                        Get.back,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: buildButton(
                        "រក្សាទុក",
                        Theme.of(context).colorScheme.primary,
                        controller.savePassword,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 60),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildTitle(String text, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: GoogleFonts.spaceGrotesk(
          fontSize: 17,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget buildTextField(
    BuildContext context, {
    required TextEditingController controller,
    required String hint,
    required bool obscure,
    required VoidCallback toggle,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      validator: validator,
      decoration: InputDecoration(
        focusColor: Theme.of(context).colorScheme.tertiary,
        hintText: hint,
        suffixIcon: IconButton(
          icon: Icon(obscure ? Icons.visibility_off : Icons.visibility),
          onPressed: toggle,
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }

  Widget buildButton(String text, Color color, VoidCallback onTap) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
      child: Text(
        text,
        style: GoogleFonts.kantumruyPro(
          color: Colors.white,
          fontWeight: .bold,
          fontSize: 16,
        ),
      ),
    );
  }
}
