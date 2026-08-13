import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:frontend/app/core/constants/Globle/section_card.dart';
import 'package:frontend/app/core/constants/app_colors/app_colors.dart';
import 'package:frontend/app/core/constants/app_image.dart';
import 'package:frontend/app/modules/profile_screen/theme_mode/theme_mode_view.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

part 'notification_screen_binding.dart';
part 'notification_screen_controller.dart';

class NotificationScreenView extends GetView<NotificationScreenViewController> {
  const NotificationScreenView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          onPressed: Get.back,
          icon: SvgPicture.asset(AppImage.arrowBackIcon, width: 30, height: 30),
        ),
        title: Text(
          "notification".tr,
          style: GoogleFonts.googleSans(
            color: Theme.of(context).colorScheme.secondary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            SectionCard(
              title: "system_notification".tr,
              child: Obx(
                () => SwitchListTile(
                  title: Text(
                    "system".tr,
                    style: GoogleFonts.googleSans(
                      fontSize: 16,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                  inactiveThumbColor: Colors.white,
                  activeThumbColor: Colors.white,
                  // inactiveTrackColor: Color,
                  activeTrackColor: AppColors.lightPrimaryColor,
                  inactiveTrackColor: Colors.grey[500],
                  trackOutlineColor: WidgetStateProperty.all(
                    Colors.transparent,
                  ),
                  value: controller.system.value,
                  onChanged: (v) => controller.system.value = v,
                ),
              ),
            ),

            SectionCard(
              title: "interaction".tr,
              child: Column(
                children: [
                  Obx(
                    () => SwitchListTile(
                      title: Row(
                        children: [
                          SvgPicture.asset(
                            AppImage.messageIcon,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          SizedBox(width: 5),
                          Text(
                            "message".tr,
                            style: GoogleFonts.googleSans(
                              fontSize: 16,
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                          ),
                        ],
                      ),
                      inactiveThumbColor: Colors.white,
                      activeThumbColor: Colors.white,
                      // inactiveTrackColor: Color,
                      activeTrackColor: AppColors.lightPrimaryColor,
                      inactiveTrackColor: Colors.grey[500],
                      trackOutlineColor: WidgetStateProperty.all(
                        Colors.transparent,
                      ),
                      value: controller.message.value,
                      onChanged: (v) => controller.message.value = v,
                    ),
                  ),
                  Obx(
                    () => SwitchListTile(
                      title: Text(
                        "like".tr,
                        style: GoogleFonts.googleSans(
                          fontSize: 16,
                          color: Get.theme.colorScheme.secondary,
                        ),
                      ),
                      inactiveThumbColor: Colors.white,
                      activeThumbColor: Colors.white,
                      // inactiveTrackColor: Color,
                      activeTrackColor: AppColors.lightPrimaryColor,
                      inactiveTrackColor: Colors.grey[500],
                      trackOutlineColor: WidgetStateProperty.all(
                        Colors.transparent,
                      ),
                      value: controller.like.value,
                      onChanged: (v) => controller.like.value = v,
                    ),
                  ),
                ],
              ),
            ),
            SectionCard(
              title: "push_notification".tr,
              child: Obx(
                () => SwitchListTile(
                  title: Text(
                    "app_update_notification".tr,
                    style: GoogleFonts.googleSans(
                      fontSize: 16,
                      color: Get.theme.colorScheme.secondary,
                    ),
                  ),
                  inactiveThumbColor: Colors.white,
                  activeThumbColor: Colors.white,
                  // inactiveTrackColor: Color,
                  activeTrackColor: AppColors.lightPrimaryColor,
                  inactiveTrackColor: Colors.grey[500],
                  trackOutlineColor: WidgetStateProperty.all(
                    Colors.transparent,
                  ),
                  value: controller.pushNot.value,
                  onChanged: (v) => controller.pushNot.value = v,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
