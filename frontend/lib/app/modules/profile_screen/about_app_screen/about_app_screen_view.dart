import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:frontend/app/core/constants/app_colors/app_colors.dart';
import 'package:frontend/app/core/constants/app_image.dart';
import 'package:frontend/app/modules/profile_screen/theme_mode/theme_mode_view.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

part 'about_app_screen_binding.dart';
part 'about_app_screen_controller.dart';

class AboutAppScreenView extends GetView<AboutAppScreenViewController> {
  const AboutAppScreenView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: SvgPicture.asset(AppImage.arrowBackIcon, width: 30, height: 30),
        ),
        title: Text(
          "about_cam".tr,
          style: GoogleFonts.googleSans(
            color: Theme.of(context).colorScheme.secondary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              Center(
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 15,
                        spreadRadius: 4,
                        offset: Offset(0, 6),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      "assets/images/logo.png",
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              buildContainer2(
                context,
                text: "about_cam_desc".tr,
                icon: Icons.home,
                iconcolor: AppColors.lightPrimaryColor,
                backgroundColor: Color(0xFFF3F4F6),
                title: "about".tr,
              ),
              SizedBox(height: 20),
              buildImportant(context),
              SizedBox(height: 20),
              buildContainer(
                context,
                gradient: const LinearGradient(
                  colors: [Color(0xFFF0FDF4), Color(0xFFDCFCE7)],
                ),
                text: "goal_desc".tr,
              ),
              SizedBox(height: 20),
              buildVersion(context),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildVersion(BuildContext context) {
    return Container(
      width: Get.width * 0.35,
      decoration: BoxDecoration(
        color: controller.themeCtrl.getDark() ? null : Colors.white,
        border: controller.themeCtrl.getDark()
            ? Border.all(color: Theme.of(context).colorScheme.primary)
            : null,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            spreadRadius: 2,
            offset: Offset(0, 5), // x, y
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            Icon(Icons.circle, size: 10, color: AppColors.lightPrimaryColor),
            SizedBox(width: 5),
            Text(
              "Version 1.0.0",
              style: GoogleFonts.kantumruyPro(
                fontSize: 16,
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildImportant(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            spreadRadius: 2,
            offset: Offset(0, 5), // x, y
          ),
        ],
        color: controller.themeCtrl.getDark() ? null : Colors.white,
        border: controller.themeCtrl.getDark()
            ? Border.all(color: Theme.of(context).colorScheme.primary)
            : null,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          buildTitle(text: "Important".tr),
          smallContainer(
            context,
            "ស្វែងរកកន្លែងទេសចរណ៍",
            "Discover tourist attractions",
            Icons.location_on_outlined,
          ),
          SizedBox(height: 20),
          smallContainer(
            context,
            "ស្វែងយល់ពីប្រទេសកម្ពុជា",
            "Explore Cambodian",
            Icons.map_outlined,
          ),
          SizedBox(height: 20),
          smallContainer(
            context,
            "ស្វែងយល់ពីម្ហូបអាហារក្នុងប្រទេសកម្ពុជា",
            "Explore local food of Cambodia",
            Icons.restaurant_outlined,
          ),
          SizedBox(height: 20),
          smallContainer(
            context,
            "សិក្សានិងស្វែងយល់ពីវប្បធ៌នៃប្រទេសកម្ពុជា",
            "Explore Cambodia Culture",
            Icons.calendar_today,
          ),
          SizedBox(height: 20),
          smallContainer(
            context,
            "រក្សាទុកកន្លែងដែលអ្នកចូលចិត្ត",
            "Save favorite places",
            Icons.favorite_outline,
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget smallContainer(
    BuildContext context,
    String text1,
    String text2,
    IconData icon,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SizedBox(
        width: double.infinity,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 1,
              child: CircleAvatar(
                backgroundColor: Color(0xFFF0FDF4),
                child: Icon(icon, color: AppColors.lightPrimaryColor),
              ),
            ),
            SizedBox(width: 20),
            Expanded(
              flex: 4,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    text1,
                    style: GoogleFonts.googleSans(
                      color: Theme.of(
                        context,
                      ).colorScheme.secondary.withValues(alpha: 0.8),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    text2,
                    style: GoogleFonts.googleSans(
                      fontSize: 16,
                      color: Theme.of(
                        context,
                      ).colorScheme.secondary.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildTitle({required String text}) {
    return Padding(
      padding: EdgeInsets.all(20),
      child: Container(
        width: 150,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.lightPrimaryColor,
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(50),
            topRight: Radius.circular(50),
          ),
        ),
        child: Center(
          child: Text(
            text,
            style: GoogleFonts.googleSans(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget buildContainer2(
    BuildContext context, {
    // required Color color,
    required String text,
    required IconData icon,
    required Color iconcolor,
    required Color backgroundColor,
    required String title,
  }) {
    return Container(
      width: double.infinity,
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
            offset: Offset(0, 5), // x, y
          ),
        ],
        // color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(7),
                    color: Color(0xFFDCFCE7),
                  ),

                  child: Icon(icon, color: iconcolor),
                ),
                SizedBox(width: 20),
                Text(
                  title,
                  style: GoogleFonts.googleSans(
                    color: Theme.of(context).colorScheme.secondary,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            SizedBox(height: 5),
            Text(
              text,
              style: GoogleFonts.googleSans(
                fontSize: 16,
                color: Theme.of(
                  context,
                ).colorScheme.secondary.withValues(alpha: 0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildContainer(
    BuildContext context, {
    required LinearGradient gradient,
    required String text,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: controller.themeCtrl.getDark() ? null : Colors.white,
        border: controller.themeCtrl.getDark()
            ? Border.all(color: Theme.of(context).colorScheme.primary)
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            spreadRadius: 2,
            offset: Offset(0, 5), // x, y
          ),
        ],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildTitle(text: "cam_goal".tr),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              text,
              style: GoogleFonts.googleSans(
                fontSize: 16,
                color: Theme.of(
                  context,
                ).colorScheme.secondary.withValues(alpha: 0.8),
              ),
            ),
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }
}
