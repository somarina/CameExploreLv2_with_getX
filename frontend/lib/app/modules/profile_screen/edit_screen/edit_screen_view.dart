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
            _label(text: "fristName".tr),
            _textField(controller.firstNameCtrl)
          ],
        ),
      ),
    );
  }

  Widget _label({required String text}) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: EdgeInsets.only(top: 15, bottom: 8),
        child: Text(
          text,
          style: GoogleFonts.spaceGrotesk(fontSize: 16, fontWeight: .bold),
        ),
      ),
    );
  }

  Widget _textField(
    TextEditingController ctrl, {
    TextInputType keyboard = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: ctrl,
      keyboardType: keyboard,
      validator: validator,
      decoration: InputDecoration(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }

  Widget _gender(String text, bool selected, VoidCallback onTap) {
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
            Text(text),
            const Spacer(),
            if (selected)
              const Icon(Icons.circle, size: 10, color: Colors.green),
          ],
        ),
      ),
    );
  }
}
