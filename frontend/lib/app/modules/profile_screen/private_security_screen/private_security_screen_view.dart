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
      appBar: AppBar(
        leading: IconButton(
          icon: SvgPicture.asset(AppImage.arrowBackIcon, width: 30, height: 30),
          onPressed: () {
            Get.back();
          },
        ),
        title: Text(
          "Privacy & Security",
          style: GoogleFonts.spaceGrotesk(fontSize: 24, fontWeight: .bold),
        ),
      ),
      body: Column(children: [_containerText(), _container(), _devices()]),
    );
  }

  Widget _devices() {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(16),
      // height: 50,
      decoration: BoxDecoration(
        color: Colors.white,
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
            "Devices",
            style: GoogleFonts.spaceGrotesk(fontSize: 18, fontWeight: .bold),
          ),
          SizedBox(height: 20),
          _device_use(
            containerColor: AppColors.lightPrimaryColor.withValues(alpha: 0.1),
            perfix: AppImage.phoneIcon,
            title: "iPhone 14 Pro",
            subtext1: "Phnom Penh, Cambodia",
            subtext2: "Lastday: Now",
            textBtn: "Now",
            color: Colors.white,
            bgColor: AppColors.lightPrimaryColor,
          ),
          _device_use(
            containerColor: Color(0xffF9FAFB),
            perfix: AppImage.phoneIcon,
            title: "Samsung Galaxy S23",
            subtext1: "Siem Reap, Cambodia",
            subtext2: "Lastday: yesterday",
            textBtn: "Leave",
            color: Colors.red,
            bgColor: Color(0xffF9FAFB),
          ),
        ],
      ),
    );
  }

  Widget _device_use({
    required String perfix,
    required String title,
    required String subtext1,
    required String subtext2,
    required String textBtn,
    required Color color,
    required Color bgColor,
    required Color containerColor,
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
                Text(subtext1, style: GoogleFonts.spaceGrotesk(fontSize: 16)),
                Text(subtext2, style: GoogleFonts.spaceGrotesk(fontSize: 16)),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 7),
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

  Widget _container() {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(16),
      // height: 50,
      decoration: BoxDecoration(
        color: Colors.white,
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
            style: GoogleFonts.spaceGrotesk(fontSize: 18, fontWeight: .bold),
          ),
          SizedBox(height: 10),
          _smallbox(
            prefixIcon: AppImage.verifyIcon,
            title: "Two-step verification",
            subtype: "Add an extra layer of security",
          ),
          SizedBox(height: 20),
          _smallbox(
            prefixIcon: AppImage.keyIcon,
            title: "fingerprint entry",
            subtype: "Use fingerprint to sign in",
          ),
        ],
      ),
    );
  }

  Widget _smallbox({
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

                  color: Colors.black,
                ),
              ),
              Text(
                subtype,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 16,

                  color: Colors.black38,
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
