import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:frontend/app/core/api/Model/user_model.dart';
import 'package:frontend/app/core/api/services/profile_services.dart';
import 'package:frontend/app/core/constants/app_colors/app_colors.dart';
import 'package:frontend/app/core/constants/app_image.dart';
import 'package:frontend/app/modules/profile_screen/userProfile_screen/user_profile_screen_view.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

part 'edit_screen_binding.dart';
part 'edit_screen_controller.dart';

class EditScreenView extends GetView<EditScreenViewController> {
  const EditScreenView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        leading: IconButton(
          icon: SvgPicture.asset(AppImage.arrowBackIcon, width: 30, height: 30),
          onPressed: () {
            Get.back();
          },
        ),
        title: Text(
          "editprofile".tr,
          style: GoogleFonts.spaceGrotesk(
            fontSize: 24,
            fontWeight: .bold,
            color: Theme.of(context).colorScheme.secondary,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: .start,
          children: [
            Center(
              child:
                  //  CircleAvatar(radius: 60)
                  _profile(),
            ),
            _label("fristName".tr, context),
            SizedBox(height: 5),
            _textField(controller.firstnameCtrl, context),
            SizedBox(height: 20),
            _label("lastName".tr, context),
            SizedBox(height: 5),
            _textField(controller.lastnameCtrl, context),
            SizedBox(height: 20),
            _label("email".tr, context),
            SizedBox(height: 5),
            _textField(controller.newEmailCtrl, context),
            SizedBox(height: 20),
            _label("phone".tr, context),
            SizedBox(height: 5),
            _textField(controller.newPhoneCtrl, context),
            SizedBox(height: 20),
            _label("gender".tr, context),
            SizedBox(height: 5),
            Row(
              children: [
                Expanded(
                  child: Obx(
                    () => _gender(
                      "male".tr,
                      controller.selectedGender.value == "Male",
                      () => controller.selectedGender("Male"),
                      context,
                    ),
                  ),
                ),
                SizedBox(width: 20),
                Expanded(
                  child: Obx(
                    () => _gender(
                      "female".tr,
                      controller.selectedGender.value == "Female",
                      () => controller.selectedGender("Female"),
                      context,
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 20),
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
                    onTap: controller.editProfile,
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

  Widget _profile() {
    return Obx(
      () => GestureDetector(
        onTap: () {
          Get.bottomSheet(
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    leading: Icon(Icons.camera_alt),
                    title: Text("Camera".tr),
                    onTap: () async {
                      // controller.pickImage(ImageSource.camera);
                      await controller.pickImage(ImageSource.camera);
                      Get.back();
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.image),
                    title: Text("Gallery".tr),
                    onTap: () {
                      controller.pickImage(ImageSource.gallery);
                      Get.back();
                    },
                  ),
                ],
              ),
            ),
          );
        },
        child: CircleAvatar(
          radius: 60,

          backgroundColor: Colors.grey.shade300,
          backgroundImage: controller.profileImage.value.isEmpty
              ? NetworkImage(controller.userProfileController.user.avatar)
              :
             FileImage(controller.pickedImage.value!),

          child: controller.pickedImage.value == null
              ? const Icon(Icons.camera_alt, size: 30, color: Colors.grey)
              : null,
        ),
      ),
    );
  }

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

  Widget _gender(
    String gender,
    bool selected,
    VoidCallback onTap,
    BuildContext context,
  ) {
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
            Text(
              gender,
              style: GoogleFonts.spaceGrotesk(
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
            const Spacer(),
            if (selected)
              const Icon(Icons.circle, size: 10, color: Colors.green),
          ],
        ),
      ),
    );
  }

  Widget _label(String text, BuildContext context) => Text(
    text,
    style: GoogleFonts.spaceGrotesk(
      fontSize: 16,
      fontWeight: .bold,
      color: Theme.of(context).colorScheme.secondary,
    ),
  );

  Widget _textField(TextEditingController controller, BuildContext context) {
    return TextFormField(
      controller: controller,
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
      ),
    );
  }
}
