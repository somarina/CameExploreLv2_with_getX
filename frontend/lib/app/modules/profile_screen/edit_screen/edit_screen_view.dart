import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:frontend/app/core/constants/app_colors/app_colors.dart';
import 'package:frontend/app/core/constants/app_image.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

part 'edit_screen_binding.dart';
part 'edit_screen_controller.dart';

class EditScreenView extends GetView<EditScreenViewController> {
  const EditScreenView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackgroundColor,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: AppColors.lightBackgroundColor,
        leading: IconButton(
          icon: SvgPicture.asset(AppImage.arrowBackIcon, width: 30, height: 30),
          onPressed: () {
            Get.back();
          },
        ),
        title: Text(
          "Edit Profile",
          style: GoogleFonts.spaceGrotesk(fontSize: 24, fontWeight: .bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: .start,
          children: [
            Center(child: CircleAvatar(radius: 60)),
            _label("fristName".tr),
            SizedBox(height: 5),
            _textField(controller.firstNameCtrl),
            SizedBox(height: 20),
            _label("lastName".tr),
            SizedBox(height: 5),
            _textField(controller.lastNameCtrl),
            SizedBox(height: 20),
            _label("email".tr),
            SizedBox(height: 5),
            _textField(controller.emailCtrl),
            SizedBox(height: 20),
            _label("forgetPWD".tr),
            SizedBox(height: 5),
            _textField(controller.forgetPWDCtrl),
            SizedBox(height: 20),
            _label("gender".tr),
            SizedBox(height: 5),
            Row(
              children: [
                Expanded(
                  child: Obx(
                    () => _gender(
                      "Male",
                      controller.selectedGender.value == "Male",
                      () => controller.selectGender("Male"),
                    ),
                  ),
                ),
                SizedBox(width: 20),
                Expanded(
                  child: Obx(
                    () => _gender(
                      "Female",
                      controller.selectedGender.value == "Female",
                      () => controller.selectGender("Female"),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _btn(text: "cancel".tr, color: Colors.red),
                ),
                SizedBox(width: 20),
                Expanded(
                  child: _btn(
                    text: "save".tr,
                    color: AppColors.lightPrimaryColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _btn({required String text, required Color color}) {
    return ElevatedButton(
      onPressed: () {
        controller.saveProfile();
      },
      style: ElevatedButton.styleFrom(backgroundColor: color),
      child: SizedBox(
        height: 45,
        child: Center(
          child: Text(
            text,
            style: GoogleFonts.spaceGrotesk(fontSize: 16, color: Colors.white),
          ),
        ),
      ),
    );
  }

  Widget _gender(String gender, bool selected, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          border: Border.all(
            color: selected ? AppColors.lightPrimaryColor : Colors.grey,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Text(gender),
            const Spacer(),
            if (selected)
              const Icon(Icons.circle, size: 10, color: Colors.green),
          ],
        ),
      ),
    );
  }

  Widget _label(String text) => Text(
    text,
    style: GoogleFonts.spaceGrotesk(fontSize: 16, fontWeight: .bold),
  );

  Widget _textField(TextEditingController controller) {
    return TextFormField(
      controller: controller,
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
      ),
    );
  }
}
