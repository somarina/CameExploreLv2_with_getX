import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:frontend/app/core/constants/app_colors/app_colors.dart';
import 'package:frontend/app/core/constants/app_image.dart';
import 'package:frontend/app/modules/profile_screen/theme_mode/theme_mode_view.dart';
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
          "security_".tr,
          style: GoogleFonts.googleSans(
            fontSize: 24,
            fontWeight: .bold,
            color: Theme.of(context).colorScheme.secondary,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              _containerText(context),
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
        border: controller.themeCtrl.getDark()
            ? Border.all(color: Theme.of(context).colorScheme.primary)
            : null,
        color: controller.themeCtrl.getDark() ? null : Colors.white,
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
          _label(label: "devices".tr, context),
          SizedBox(height: 20),
          _device_use(
            Get.context!,
            perfix: AppImage.phoneIcon,
            title: "iphone".tr,
            subtext1: "iphone_desc".tr,
            containerColor: Color(0xffF0FDF4),
            textBtn: "now".tr,
            color: Colors.white,
            bgColor: AppColors.lightPrimaryColor,
          ),
          _device_use(
            Get.context!,
            containerColor: Color(0xffF9FAFB),
            perfix: AppImage.phoneIcon,
            title: "samsung".tr,
            subtext1: "samsung_desc".tr,
            textBtn: "leave".tr,
            color: Colors.red,
            bgColor: Color(0xffF9FAFB),
          ),
        ],
      ),
    );
  }

  Text _label(BuildContext context, {required String label}) {
    return Text(
      label,
      style: GoogleFonts.googleSans(
        fontSize: 18,
        fontWeight: .bold,
        color: Theme.of(context).colorScheme.secondary,
      ),
    );
  }

  Widget _security(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(16),
      // height: 50,
      decoration: BoxDecoration(
        border: controller.themeCtrl.getDark()
            ? Border.all(color: Theme.of(context).colorScheme.primary)
            : null,
        color: controller.themeCtrl.getDark() ? null : Colors.white,
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
          _label(label: "safety".tr, context),
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
        border: controller.themeCtrl.getDark()
            ? Border.all(color: Theme.of(context).colorScheme.primary)
            : null,
        color: controller.themeCtrl.getDark() ? null : containerColor,
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
                  style: GoogleFonts.googleSans(
                    color: Theme.of(context).colorScheme.secondary,
                    fontSize: 18,
                    fontWeight: .bold,
                  ),
                ),
                Text(
                  subtext1,
                  style: GoogleFonts.googleSans(
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
              style: GoogleFonts.googleSans(fontSize: 16, color: color),
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
            title: "safety_1".tr,
            subtext1: "safety_1_desc".tr,
          ),
          SizedBox(height: 10),
          textbox(
            Get.context!,
            perfix: AppImage.doneIcon,
            title: "safety_2".tr,
            subtext1: "safety_2_desc".tr,
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
                style: GoogleFonts.googleSans(
                  color: Theme.of(context).colorScheme.secondary,
                  fontSize: 18,
                  fontWeight: .bold,
                ),
              ),
              Text(
                subtext1,
                style: GoogleFonts.googleSans(
                  fontSize: 16,
                  color: Theme.of(
                    context,
                  ).colorScheme.secondary.withValues(alpha: 0.7),
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
        border: controller.themeCtrl.getDark()
            ? Border.all(color: Theme.of(context).colorScheme.primary)
            : null,
        color: controller.themeCtrl.getDark() ? null : Colors.white,
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
            "log&sec".tr,
            style: GoogleFonts.googleSans(
              fontSize: 18,
              fontWeight: .bold,
              color: Theme.of(context).colorScheme.secondary,
            ),
          ),
          SizedBox(height: 10),
          _smallbox(
            Get.context!,
            prefixIcon: AppImage.verifyIcon,
            title: "tow_step_verif".tr,
            subtype: "tow_step_verif_desc".tr,
          ),
          SizedBox(height: 20),
          _smallbox(
            Get.context!,
            prefixIcon: AppImage.keyIcon,
            title: "finger".tr,
            subtype: "finger_desc".tr,
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
                style: GoogleFonts.googleSans(
                  fontSize: 18,
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
              Text(
                subtype,
                style: GoogleFonts.googleSans(
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
            color: AppColors.lightPrimaryColor,
          ),
          child: Text(
            "open".tr,
            style: GoogleFonts.googleSans(
              color: Theme.of(context).colorScheme.secondary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _containerText(BuildContext context) {
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
          Expanded(
            child: Column(
              crossAxisAlignment: .start,
              children: [
                Text(
                  "acc_secure".tr,
                  style: GoogleFonts.googleSans(
                    fontSize: 18,
                    fontWeight: .bold,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
                Text(
                  "acc_secure1".tr,
                  style: GoogleFonts.googleSans(
                    fontSize: 16,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
