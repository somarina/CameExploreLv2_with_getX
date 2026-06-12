import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:frontend/app/core/constants/app_colors/app_colors.dart';
import 'package:frontend/app/core/constants/app_image.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

part 'about_organization_screen_binding.dart';
part 'about_organization_screen_controller.dart';

class AboutOrganizationScreenView extends GetView<AboutOrganizationScreenViewController> {
  const AboutOrganizationScreenView({super.key});

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      backgroundColor: AppColors.lightBackgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.lightBackgroundColor,
        leading: IconButton(
          icon: SvgPicture.asset(AppImage.arrowBackIcon, width: 30, height: 30),
          onPressed: () {
            Get.back();
          },
        ),
        title: Text(
          "About Organization",
          style: GoogleFonts.spaceGrotesk(fontSize: 24, fontWeight: .bold),
        ),
      ),
    );
  }
}