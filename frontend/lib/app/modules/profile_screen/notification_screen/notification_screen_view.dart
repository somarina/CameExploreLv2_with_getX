import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:frontend/app/core/constants/Globle/section_card.dart';
import 'package:frontend/app/core/constants/app_colors/app_colors.dart';
import 'package:frontend/app/core/constants/app_image.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

part 'notification_screen_binding.dart';
part 'notification_screen_controller.dart';

class NotificationScreenView extends GetView<NotificationScreenViewController> {
  const NotificationScreenView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: Get.back,
          icon: SvgPicture.asset(AppImage.arrowBackIcon, width: 30, height: 30),
        ),
        title: Text(
          "Notification",
          style: GoogleFonts.kantumruyPro(
            color: Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            SectionCard(
              title: "ការជូនដំណឹងប្រព័ន្ធ",
              child: Obx(
                () => SwitchListTile(
                  title: Text(
                    "ប្រព័ន្ធ",
                    style: GoogleFonts.spaceGrotesk(fontSize: 16),
                  ),
                  inactiveThumbColor: Colors.white,
                  activeTrackColor: AppColors.lightPrimaryColor,
                  trackOutlineColor: WidgetStateProperty.all(Colors.grey[100]),
                  value: controller.system.value,
                  onChanged: (v) => controller.system.value = v,
                ),
              ),
            ),

            SectionCard(
              title: 'អន្តរកម្ម',
              child: Column(
                children: [
                  Obx(
                    () => SwitchListTile(
                      title: Row(
                        children: [
                          SvgPicture.asset(AppImage.messageIcon),
                          Text(
                            "សារ",
                            style: GoogleFonts.spaceGrotesk(fontSize: 16),
                          ),
                        ],
                      ),
                      inactiveThumbColor: Colors.white,
                      activeTrackColor: AppColors.lightPrimaryColor,
                      trackOutlineColor: WidgetStateProperty.all(
                        Colors.grey[100],
                      ),
                      value: controller.message.value,
                      onChanged: (v) => controller.message.value = v,
                    ),
                  ),
                  Obx(
                    () => SwitchListTile(
                      title: Text(
                        'ចូលចិត្ត',
                        style: GoogleFonts.spaceGrotesk(fontSize: 16),
                      ),
                      inactiveThumbColor: Colors.white,
                      activeTrackColor: AppColors.lightPrimaryColor,
                      trackOutlineColor: WidgetStateProperty.all(
                        Colors.grey[100],
                      ),
                      value: controller.like.value,
                      onChanged: (v) => controller.like.value = v,
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
}
