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
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
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
            _textfield(text: "First Name"),
            SizedBox(height: 20),
            _textfield(text: "Last Name"),
            SizedBox(height: 20),
            _textfield(text: "Email"),
            SizedBox(height: 20),
            _textfield(text: "Forget Password"),
          ],
        ),
      ),
    );
  }

  Widget _textfield({required String text}) {
    return Column(
      crossAxisAlignment: .start,
      children: [
        Text(
          text,
          style: GoogleFonts.spaceGrotesk(fontSize: 16, fontWeight: .bold),
        ),
        TextField(
          decoration: InputDecoration(
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.black26, width: 2),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppColors.lightPrimaryColor,
                width: 2,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.red, width: 2),
            ),
          ),
        ),
      ],
    );
  }
}
