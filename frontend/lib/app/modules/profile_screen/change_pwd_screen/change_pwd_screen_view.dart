import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:frontend/app/core/constants/Globle/textfield.dart';
import 'package:frontend/app/core/constants/app_colors/app_colors.dart';
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
          "changePWD".tr,
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

                buildTitle("currentPWD".tr, context),
                Obx(
                  () => CustomTextField(
                    hintText: "enterCurrentPWD".tr,
                    controller: controller.currentpassCtrl,
                    suffix: GestureDetector(
                      onTap: controller.isCurrentHidden.toggle,
                      child: Icon(
                        controller.isCurrentHidden.value
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                    ),
                    isPwd: true,
                    isHide: controller.isCurrentHidden.value,
                  ),
                ),

                const SizedBox(height: 25),

                buildTitle("newPWD".tr, context),
                Obx(
                  () => CustomTextField(
                    hintText: "enterNewPWD".tr,
                    controller: controller.newpassCtrl,
                    suffix: GestureDetector(
                      onTap: controller.isNewHidden.toggle,
                      child: Icon(
                        controller.isNewHidden.value
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                    ),
                    isPwd: true,
                    isHide: controller.isNewHidden.value,
                  ),
                ),

                const SizedBox(height: 25),

                buildTitle("cfNewPWD".tr, context),
                Obx(
                  () => CustomTextField(
                    hintText: "cfNewPWD".tr,
                    controller: controller.cfpassCtrl,
                    suffix: GestureDetector(
                      onTap: controller.isConfirmHidden.toggle,
                      child: Icon(
                        controller.isConfirmHidden.value
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                    ),
                    isPwd: true,
                    isHide: controller.isConfirmHidden.value,
                  ),
                ),

                const SizedBox(height: 40),

                Row(
                  children: [
                    Expanded(
                      child: _btn(
                        text: "cancel".tr,
                        color: Colors.red,
                        onTap: () => Get.back(),
                      ),
                    ),
                    SizedBox(width: 20),
                    Expanded(
                      child: _btn(
                        onTap: controller.changePassword,
                        text: "save".tr,
                        color: AppColors.lightPrimaryColor,
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
          color: Theme.of(context).colorScheme.secondary,
          fontSize: 17,
          fontWeight: FontWeight.w500,
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
      style: GoogleFonts.spaceGrotesk(
        color: Theme.of(context).colorScheme.secondary,
      ),
      decoration: InputDecoration(
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: Colors.grey.shade400, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(
            color: AppColors.lightPrimaryColor, // focus color
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: Colors.red, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: Colors.redAccent, width: 2),
        ),
        hintText: hint,
        suffixIcon: IconButton(
          icon: Icon(obscure ? Icons.visibility_off : Icons.visibility),
          onPressed: toggle,
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }

  // Widget buildButton(String text, Color color, VoidCallback onTap) {
  //   return ElevatedButton(
  //     onPressed: onTap,
  //     style: ElevatedButton.styleFrom(
  //       backgroundColor: color,
  //       padding: const EdgeInsets.symmetric(vertical: 16),
  //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
  //     ),
  //     child: Text(
  //       text,
  //       style: GoogleFonts.kantumruyPro(
  //         color: Colors.white,
  //         fontWeight: .bold,
  //         fontSize: 16,
  //       ),
  //     ),
  //   );
  // }
  Widget _btn({
    required String text,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(backgroundColor: color),
      child: SizedBox(
        height: 45,
        child: Center(
          child: Text(
            text,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 16,
              color: Colors.white,
              fontWeight: .bold,
            ),
          ),
        ),
      ),
    );
  }
}
