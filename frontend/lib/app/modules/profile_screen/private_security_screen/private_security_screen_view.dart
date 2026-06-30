import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:frontend/app/core/constants/app_colors/app_colors.dart';
import 'package:frontend/app/core/constants/app_image.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

part 'private_security_screen_binding.dart';
part 'private_security_screen_controller.dart';

class PrivateSecurityScreenView
    extends GetView<PrivateSecurityScreenViewController> {
  const PrivateSecurityScreenView({super.key});

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
          "Privacy & Security",
          style: GoogleFonts.spaceGrotesk(
            fontSize: 24,
            fontWeight: .bold,
            color: Theme.of(context).colorScheme.secondary,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              _containerText(),
              _container(context),
              _devices(context),
              _security(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _devices(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(16),
      // height: 50,
      decoration: BoxDecoration(
        border: Get.isDarkMode
            ? Border.all(color: Theme.of(context).colorScheme.primary, width: 2)
            : null,
        color: 
        Get.isDarkMode
            ? Theme.of(context).scaffoldBackgroundColor
            : Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            spreadRadius: 2,
            offset: Offset(0, 4), // x, y
          ),
        ],
        borderRadius: BorderRadius.circular(25),
      ),
      child: Column(
        crossAxisAlignment: .start,
        children: [
          _label(label: "Devices"),
          SizedBox(height: 20),
          _device_use(
            Get.context!,
            containerColor: Get.isDarkMode
                ? Get.theme.colorScheme.primary
                : Get.theme.colorScheme.primary.withValues(alpha: 0.1),
            perfix: AppImage.phoneIcon,
            title: "iPhone 14 Pro",
            subtext1: "Phnom Penh, Cambodia\nLastday: Now",

            textBtn: "Now",
            color: Colors.white,
            bgColor: AppColors.lightPrimaryColor,
          ),
          _device_use(
            Get.context!,
            containerColor: Get.isDarkMode ? Color(0xff2a2a2a) : Colors.white,
            perfix: AppImage.phoneIcon,
            title: "Samsung Galaxy S23",
            subtext1: "Siem Reap, Cambodia\nLastday: yesterday",
            textBtn: "Leave",
            color: Colors.red,
            bgColor: Color(0xffF9FAFB),
          ),
        ],
      ),
    );
  }

  Text _label({required String label}) {
    return Text(
      label,
      style: GoogleFonts.spaceGrotesk(fontSize: 18, fontWeight: .bold),
    );
  }

  Widget _security(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(16),
      // height: 50,
      decoration: BoxDecoration(
        color: Get.isDarkMode ? null : Colors.white,
        border: Get.isDarkMode
            ? Border.all(color: Theme.of(context).colorScheme.primary)
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            spreadRadius: 2,
            offset: Offset(0, 4), // x, y
          ),
        ],
        borderRadius: BorderRadius.circular(25),
      ),
      child: Column(
        crossAxisAlignment: .start,
        children: [
          _label(label: "Safety Recommendations"),
          _safety(),
        ],
      ),
    );
  }

  Widget _device_use(
    BuildContext context, {
    required String perfix,
    required String title,
    required String subtext1,

    required String textBtn,
    required Color color,
    required Color bgColor,
    Color? containerColor,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: containerColor,
        borderRadius: BorderRadius.circular(12),
        // boxShadow: [
        //   BoxShadow(
        //     color: Colors.black.withValues(alpha: 0.1),
        //     blurRadius: 12,
        //     spreadRadius: 0.1,
        //     offset: Offset(0, 4), // x, y
        //   ),
        // ],
      ),

      child: Row(
        crossAxisAlignment: .start,
        children: [
          SvgPicture.asset(perfix, width: 30, height: 30),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: .start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 18,
                    fontWeight: .bold,
                  ),
                ),
                Text(
                  subtext1,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 16,
                    color: Theme.of(
                      context,
                    ).colorScheme.secondary.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),

          Container(
            padding: EdgeInsets.symmetric(horizontal: 7, vertical: 5),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: bgColor,
            ),
            child: Text(
              textBtn,
              style: GoogleFonts.spaceGrotesk(fontSize: 16, color: color),
            ),
          ),
        ],
      ),
    );
  }

  Widget _safety() {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          textbox(
            Get.context!,
            perfix: AppImage.warningIcon,
            title: "Change password regularly",
            subtext1: "We recommend changing your password every 3 months",
          ),
          SizedBox(height: 10),
          textbox(
            Get.context!,
            perfix: AppImage.doneIcon,
            title: "Do not share your passwords",
            subtext1: "Do not give your password to anyone",
          ),
        ],
      ),
    );
  }

  Row textbox(
    BuildContext context, {
    required String perfix,
    required String title,
    required String subtext1,
  }) {
    return Row(
      crossAxisAlignment: .start,
      children: [
        SvgPicture.asset(perfix, width: 24, height: 24),
        SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: .start,
            children: [
              Text(
                title,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 18,
                  fontWeight: .bold,
                ),
              ),
              Text(
                subtext1,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 16,
                  color: Theme.of(
                    context,
                  ).colorScheme.secondary.withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _container(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(16),
      // height: 50,
      decoration: BoxDecoration(
        color: Get.isDarkMode
            ? null
            : Theme.of(context).scaffoldBackgroundColor,
        border: Get.isDarkMode
            ? Border.all(color: Theme.of(context).colorScheme.primary)
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            spreadRadius: 2,
            offset: Offset(0, 4), // x, y
          ),
        ],
        borderRadius: BorderRadius.circular(25),
      ),
      child: Column(
        crossAxisAlignment: .start,
        children: [
          Text(
            "Login & safely",
            style: GoogleFonts.spaceGrotesk(
              fontSize: 18,
              fontWeight: .bold,
              color: Theme.of(context).colorScheme.secondary,
            ),
          ),
          SizedBox(height: 10),
          _smallbox(
            Get.context!,
            prefixIcon: AppImage.verifyIcon,
            title: "Two-step verification",
            subtype: "Add an extra layer of security",
          ),
          SizedBox(height: 20),
          _smallbox(
            Get.context!,
            prefixIcon: AppImage.keyIcon,
            title: "fingerprint entry",
            subtype: "Use fingerprint to sign in",
          ),
        ],
      ),
    );
  }

  Widget _smallbox(
    BuildContext context, {
    required String prefixIcon,
    required String title,
    required String subtype,
  }) {
    return Row(
      crossAxisAlignment: .start,
      children: [
        SvgPicture.asset(prefixIcon, width: 30, height: 30),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: .start,
            children: [
              Text(
                title,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 18,

                  // color: Colors.black,
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
              Text(
                subtype,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 16,

                  color: Theme.of(
                    context,
                  ).colorScheme.secondary.withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: AppColors.lightPrimaryColor.withValues(alpha: 0.3),
          ),
          child: Text("Open"),
        ),
      ],
    );
  }

  Widget _containerText() {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(16),
      // height: 50,
      decoration: BoxDecoration(
        color: AppColors.lightPrimaryColor,
        borderRadius: BorderRadius.circular(25),
      ),
      child: Row(
        crossAxisAlignment: .start,
        children: [
          SvgPicture.asset(AppImage.checkIcon, width: 24, height: 24),
          SizedBox(width: 12),
          Column(
            crossAxisAlignment: .start,
            children: [
              Text(
                "Your account is secure",
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 18,
                  fontWeight: .bold,
                  color: Colors.white,
                ),
              ),
              Text(
                "All security setting are enabled",
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 16,

                  color: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
