import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:frontend/app/core/constants/app_fonts/app_fonst.dart';
import 'package:frontend/app/core/constants/app_image.dart';
import 'package:frontend/app/routes/app_pages.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_colors/app_colors.dart';

part 'user_profile_screen_binding.dart';
part 'user_profile_screen_controller.dart';

class UserProfileScreenView extends GetView<UserProfileScreenViewController> {
  const UserProfileScreenView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightPrimaryColor,
      body: SingleChildScrollView(
        physics: ClampingScrollPhysics(),
        child: SafeArea(
          child: Column(
            children: [
              _header(),
              SizedBox(height: 20),
              controller.isLogin.value ? _login() : _guestUser(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _container({required Widget child}) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: child,
    );
  }

  Widget _menuItem({
    required String prefix,
    required String title,
    required String suffixIcon,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.symmetric(horizontal: 16),
      height: 50,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black45),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Row(
        children: [
          // Prefix icon
          SvgPicture.asset(prefix, width: 24, height: 24),
          SizedBox(width: 12),
          // Title
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          // Suffix icon
          SvgPicture.asset(suffixIcon, width: 30, height: 30),
        ],
      ),
    );
  }

  Widget _header() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Text("acc".tr, style: AppFonts.fontHeader),
          Spacer(),
          GestureDetector(
            onTap: () {
              controller.isLogin.value
                  ? Get.toNamed(Routes.EDIT_SCREEN)
                  : Get.toNamed(Routes.SECURITY_SCREEN);
            },
            child: SvgPicture.asset(AppImage.editIcon),
          ),
        ],
      ),
    );
  }

  Widget _guestUser() {
    return Column(
      crossAxisAlignment: .center,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 70),
          child: Row(
            // crossAxisAlignment: .end,
            children: [
              DottedBorder(
                options: CircularDottedBorderOptions(
                  dashPattern: [80, 15], // size long or short
                  strokeWidth: 3, // size big or small
                  padding: EdgeInsets.all(5),
                  color: Color(0xffE7000B),
                ),
                child: CircleAvatar(
                  radius: 45,
                  backgroundImage: AssetImage('assets/images/profile.png'),
                ),
              ),
              SizedBox(width: 20),
              Container(
                decoration: BoxDecoration(
                  color: Color(0xffFEF3C6),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                  child: Text(
                    "guest user".tr,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 15,
                      color: Color(0xffBB4D00),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 20),
        Container(
          decoration: BoxDecoration(
            color: AppColors.lightBackgroundColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Color(0xffFEE685)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: .start,
              children: [
                Text(
                  "signup".tr,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 16,
                    color: Color(0xffBB4D00),
                  ),
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {},

                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(240, 45),
                    backgroundColor: AppColors.lightPrimaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text("create acc".tr, style: AppFonts.fontsButton),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 20),
        _container(
          child: Column(
            children: [
              _language(),
              _menuItem(
                prefix: AppImage.themeIcon,
                title: "theme".tr,
                suffixIcon: AppImage.btnIcon,
              ),
              _menuItem(
                prefix: AppImage.notificationIcon,
                title: "notification".tr,
                suffixIcon: AppImage.btnIcon,
              ),
              _menuItem(
                prefix: AppImage.securityIcon,
                title: "security".tr,
                suffixIcon: AppImage.btnIcon,
              ),
              _menuItem(
                prefix: AppImage.feedbackIcon,
                title: "feedback".tr,
                suffixIcon: AppImage.btnIcon,
              ),
              _menuItem(
                prefix: AppImage.conditionIcon,
                title: "condition".tr,
                suffixIcon: AppImage.btnIcon,
              ),
              _menuItem(
                prefix: AppImage.abouAppIcon,
                title: "app".tr,
                suffixIcon: AppImage.btnIcon,
              ),
              _menuItem(
                prefix: AppImage.developerIcon,
                title: "developer".tr,
                suffixIcon: AppImage.btnIcon,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Container _language() {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.symmetric(horizontal: 16),
      height: 50,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black45),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Row(
        children: [
          // Prefix icon
          SvgPicture.asset(AppImage.languageIcon, width: 24, height: 24),
          SizedBox(width: 12),
          // Title
          Expanded(
            child: Text(
              "language".tr,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            "translate".tr,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 16,
              color: Colors.black45,
            ),
          ),
          SizedBox(width: 10),
          // Suffix icon
          SvgPicture.asset(AppImage.btnIcon),
        ],
      ),
    );
  }

  Widget _login() {
    return Column(
      crossAxisAlignment: .center,
      children: [
        DottedBorder(
          options: CircularDottedBorderOptions(
            dashPattern: [80, 15], // size long or short
            strokeWidth: 3, // size big or small
            padding: EdgeInsets.all(5),
            color: Color(0xffE7000B),
          ),
          child: CircleAvatar(
            radius: 45,
            backgroundImage: AssetImage('assets/images/profile.png'),
          ),
        ),
        Text(
          controller.userName.value,
          style: GoogleFonts.spaceGrotesk(
            fontSize: 22,
            fontWeight: .bold,
            color: Colors.white,
          ),
        ),
        Text(
          controller.email.value,
          style: GoogleFonts.spaceGrotesk(
            fontSize: 16,
            color: Colors.white.withValues(alpha: 0.8),
          ),
        ),
        SizedBox(height: 20),
        _container(
          child: Column(
            children: [
              _menuItem(
                prefix: AppImage.themeIcon,
                title: "cpwd".tr,
                suffixIcon: AppImage.btnIcon,
              ),
              _language(),
              _menuItem(
                prefix: AppImage.themeIcon,
                title: "theme".tr,
                suffixIcon: AppImage.btnIcon,
              ),
              GestureDetector(
                onTap: () {
                  Get.toNamed(Routes.NOTIFICATION_SCREEN);
                },
                child: _menuItem(
                  prefix: AppImage.notificationIcon,
                  title: "notification".tr,
                  suffixIcon: AppImage.btnIcon,
                ),
              ),
              GestureDetector(
                onTap: () {
                  Get.toNamed(Routes.SECURITY_SCREEN);
                },
                child: _menuItem(
                  prefix: AppImage.securityIcon,
                  title: "security".tr,
                  suffixIcon: AppImage.btnIcon,
                ),
              ),
              GestureDetector(
                onTap: () {
                  Get.toNamed(Routes.FEEDBACK_SCREEN);
                },
                child: _menuItem(
                  prefix: AppImage.feedbackIcon,
                  title: "feedback".tr,
                  suffixIcon: AppImage.btnIcon,
                ),
              ),
              GestureDetector(
                onTap: () { 
                  Get.toNamed(Routes.HELPSUPPORT_SCREEN);
                },
                child: _menuItem(
                  prefix: AppImage.conditionIcon,
                  title: "condition".tr,
                  suffixIcon: AppImage.btnIcon,
                ),
              ),
              GestureDetector(
                onTap: () {   
                  Get.toNamed(Routes.ABOUTAPP_SCREEN);
                },
                child: _menuItem(
                  prefix: AppImage.abouAppIcon,
                  title: "app".tr,
                  suffixIcon: AppImage.btnIcon,
                ),
              ),
              _menuItem(
                prefix: AppImage.developerIcon,
                title: "developer".tr,
                suffixIcon: AppImage.btnIcon,
              ),
              btn(),
            ],
          ),
        ),
      ],
    );
  }

  Widget btn() {
    return ElevatedButton(
      onPressed: () {},
      child: Text("logout".tr, style: GoogleFonts.spaceGrotesk()),
    );
  }
}
